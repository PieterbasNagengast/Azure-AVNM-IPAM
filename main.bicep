import { _environment, _regions } from './types.bicep'

param location string = resourceGroup().location
// This parameter is used to control the deployment of the IPAM resources.
// when set to false, the IPAM resources will not be deployed an only the outputs will be generated.
@description('Set to true to deploy IPAM resources, false to only generate outputs.')
param deploy bool = true

param ipam _environment = {
  avnm: {
    name: 'avnm01'
    subscriptionScopes: [subscription().id]
    managementGroupScopes: []
  }
  settings: {
    rootIPAMpoolName: 'AzureGlobal'
    AzureCIDR: '172.16.0.0/12'
    RegionCIDRsize: 16
    RegionCIDRsplitSize: 21
  }
}

param regions _regions = [
  {
    name: 'northeurope'
    displayName: 'North Europe'
    PlatformAndApplicationSplitFactor: 10
    ConnectivityAndIdentitySplitFactor: 50
    CorpAndOnlineSplitFactor: 75
    cidr: cidrSubnet(ipam.settings.AzureCIDR, ipam.settings.RegionCIDRsize, 0)
  }
  {
    name: 'swedencentral'
    displayName: 'Sweden Central'
    PlatformAndApplicationSplitFactor: 10
    ConnectivityAndIdentitySplitFactor: 50
    CorpAndOnlineSplitFactor: 75
    cidr: cidrSubnet(ipam.settings.AzureCIDR, ipam.settings.RegionCIDRsize, 1)
  }
]

resource avnm 'Microsoft.Network/networkManagers@2024-05-01' = if (deploy) {
  name: ipam.avnm.name
  location: location
  properties: {
    networkManagerScopes: {
      managementGroups: ipam.avnm.?managementGroupScopes
      subscriptions: ipam.avnm.?subscriptionScopes
    }
  }
}

resource rootIPAMpool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = if (deploy) {
  name: 'root-${replace(replace(ipam.settings.AzureCIDR, '/', '-'), '.', '-')}'
  parent: avnm
  location: location
  properties: {
    addressPrefixes: [
      ipam.settings.AzureCIDR
    ]
    displayName: ipam.settings.rootIPAMpoolName
    description: 'Root IPAM pool for Azure CIDR block (${ipam.settings.AzureCIDR})'
  }
}

module ipamPerRegion 'ipamPerRegion.bicep' = [
  for region in regions: {
    name: 'ipamPerRegion-${region.name}'
    params: {
      regionDisplayName: region.displayName
      regionCIDR: region.cidr
      location: region.name
      rootIPAMpoolName: rootIPAMpool.name
      avnmName: avnm.name
      RegionCIDRsplitSize: ipam.settings.RegionCIDRsplitSize
      PlatformAndApplicationSplitFactor: region.PlatformAndApplicationSplitFactor
      ConnectivityAndIdentitySplitFactor: region.ConnectivityAndIdentitySplitFactor
      CorpAndOnlineSplitFactor: region.CorpAndOnlineSplitFactor
      deploy: deploy
    }
  }
]

// outputs
output AzureCIDR string = ipam.settings.AzureCIDR

// outputs per region:
output regionIpamPools array = [
  for (region, i) in regions: {
    Region: region.displayName
    value: {
      name: region.name
      regionCIDR: region.cidr
      platformLzCIDRs: ipamPerRegion[i].outputs.platformLzCIDRs
      platformLzCIDRsCount: ipamPerRegion[i].outputs.platformLzCIDRsCount
      platformConnectivityCIDRs: ipamPerRegion[i].outputs.platformConnectivityCIDRs
      platformConnectivityCIDRsCount: ipamPerRegion[i].outputs.platformConnectivityCIDRsCount
      platformIdentityCIDRs: ipamPerRegion[i].outputs.platformIdentityCIDRs
      platformIdentityCIDRsCount: ipamPerRegion[i].outputs.platformIdentityCIDRsCount
      applicationLzCIDRs: ipamPerRegion[i].outputs.applicationLzCIDRs
      applicationLzCIDRsCount: ipamPerRegion[i].outputs.applicationLzCIDRsCount
      applicationLzCorpCIDRs: ipamPerRegion[i].outputs.applicationLzCorpCIDRs
      applicationLzCorpCIDRsCount: ipamPerRegion[i].outputs.applicationLzCorpCIDRsCount
      applicationLzOnlineCIDRs: ipamPerRegion[i].outputs.applicationLzOnlineCIDRs
      applicationLzOnlineCIDRsCount: ipamPerRegion[i].outputs.applicationLzOnlineCIDRsCount
    }
  }
]
