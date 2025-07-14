param location string
param regionDisplayName string
param regionCIDR string
param rootIPAMpoolName string
param avnmName string

// This parameter is used to control the deployment of the IPAM resources.
param deploy bool = false

// Azure Region CIDR size used to calculate the region CIDRs
@maxValue(32)
@minValue(8)
param RegionCIDRsplitSize int

// Factor to divide the region CIDR into platform and application landing zones, in percentage
@maxValue(100)
@minValue(0)
param PlatformAndApplicationSplitFactor int

// Factor to divide the platform CIDR into connectivity and identity landing zones, in percentage
@maxValue(100)
@minValue(0)
param ConnectivityAndIdentitySplitFactor int

// Factor to divide the platform CIDR into application landing zone Corp and Online. in percentage
@maxValue(100)
@minValue(0)
param CorpAndOnlineSplitFactor int

// Calculate the total number of CIDR blocks available in the region
// Using the RegionCIDRsplitSize parameter to determine subdivision granularity
var powersOfTwo = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]
var currentRegionCIDRspliSize = int(split(regionCIDR, '/')[1])
var subdivisionSize = RegionCIDRsplitSize // Use the parameter directly for subdivision
var totalSubnetCount = powersOfTwo[subdivisionSize - currentRegionCIDRspliSize]

// Generate all possible CIDR blocks for allocation
var allSubnets = [for i in range(0, totalSubnetCount): cidrSubnet(regionCIDR, subdivisionSize, i)]

// Calculate how many subnets go to platform vs application based on the factor
var platformSubnetCount = max(1, totalSubnetCount * PlatformAndApplicationSplitFactor / 100)
var platformSubnets = take(allSubnets, platformSubnetCount)
var applicationSubnets = skip(allSubnets, platformSubnetCount)

// Create platform and application landing zone CIDRs using the allocated subnets
// For platform: subdivide the platform subnets into smaller pieces for connectivity and identity
var platformLzCIDRs = platformSubnets
var platformSubCIDRsize = subdivisionSize + 3 // Create 8 smaller subnets within each platform subnet
var platformSubCIDRcount = 8
// Use the first platform subnet and subdivide it for connectivity and identity
var platformFirstSubnet = platformSubnets[0]
var platformSubCIDRs = [
  for i in range(0, platformSubCIDRcount): cidrSubnet(platformFirstSubnet, platformSubCIDRsize, i)
]

// Calculate how many subnets go to connectivity vs identity based on the factor
var platformConnectivityCount = max(1, platformSubCIDRcount * ConnectivityAndIdentitySplitFactor / 100)
var platformConnectivityCIDRs = take(platformSubCIDRs, platformConnectivityCount)
var platformIdentityCIDRs = skip(platformSubCIDRs, platformConnectivityCount)

// Calculate the CIDRs for application landing zones
var applicationLzCIDRs = applicationSubnets
var totalRemainingCount = length(applicationLzCIDRs)
var applicationLzCorpCount = max(1, totalRemainingCount * CorpAndOnlineSplitFactor / 100)

var applicationLzCorpCIDRs = take(applicationLzCIDRs, applicationLzCorpCount)
var applicationLzOnlineCIDRs = skip(applicationLzCIDRs, applicationLzCorpCount)

resource avnm 'Microsoft.Network/networkManagers@2024-05-01' existing = if (deploy) {
  name: avnmName
}

// Root IPAM pool for the Azure region
resource regionIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = if (deploy) {
  name: 'region-${replace(replace(regionCIDR, '/', '-'), '.', '-')}'
  parent: avnm
  location: location
  properties: {
    addressPrefixes: [
      regionCIDR
    ]
    parentPoolName: rootIPAMpoolName
    displayName: regionDisplayName
    description: 'IPAM pool for ${regionDisplayName} region (${regionCIDR})'
  }
}

resource platformLzIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = if (deploy) {
  name: 'platform-${replace(replace(location, ' ', '-'), '.', '-')}'
  parent: avnm
  location: location
  properties: {
    addressPrefixes: platformLzCIDRs
    parentPoolName: regionIpamPool.name
    displayName: 'Platform Landing Zones'
    description: 'IPAM pool for Platform Landing Zones in ${regionDisplayName} region'
  }
}

resource platformConnectivityLzIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = if (deploy) {
  name: 'platform-connectivity-${replace(replace(location, ' ', '-'), '.', '-')}'
  parent: avnm
  location: location
  properties: {
    addressPrefixes: platformConnectivityCIDRs
    parentPoolName: platformLzIpamPool.name
    displayName: 'Connectivity'
    description: 'IPAM pool for Platform Connectivity Landing Zone in ${regionDisplayName} region'
  }
}

resource platformIdentityLzIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = if (deploy) {
  name: 'platform-identity-${replace(replace(location, ' ', '-'), '.', '-')}'
  parent: avnm
  location: location
  properties: {
    addressPrefixes: platformIdentityCIDRs
    parentPoolName: platformLzIpamPool.name
    displayName: 'Identity'
    description: 'IPAM pool for Platform Identity Landing Zone in ${regionDisplayName} region'
  }
}

resource applicationLzIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = if (deploy) {
  name: 'application-${replace(replace(location, ' ', '-'), '.', '-')}'
  parent: avnm
  location: location
  properties: {
    addressPrefixes: applicationLzCIDRs
    parentPoolName: regionIpamPool.name
    displayName: 'Application Landing Zones'
    description: 'IPAM pool for Application Landing Zones in ${regionDisplayName} region'
  }
}

resource applicationLzCorpIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = if (deploy) {
  name: 'application-corp-${replace(replace(location, ' ', '-'), '.', '-')}'
  parent: avnm
  location: location
  properties: {
    addressPrefixes: applicationLzCorpCIDRs
    parentPoolName: applicationLzIpamPool.name
    displayName: 'Corp'
    description: 'IPAM pool for Application Corp Landing Zones in ${regionDisplayName} region'
  }
}

resource applicationLzOnlineIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = if (deploy) {
  name: 'application-online-${replace(replace(location, ' ', '-'), '.', '-')}'
  parent: avnm
  location: location
  properties: {
    addressPrefixes: applicationLzOnlineCIDRs
    parentPoolName: applicationLzIpamPool.name
    displayName: 'Online'
    description: 'IPAM pool for Application Online Landing Zones in ${regionDisplayName} region'
  }
}

// outputs
output regionCIDR string = regionCIDR
// Platform Landing Zone CIDRs
output platformLzCIDRs array = platformLzCIDRs
output platformLzCIDRsCount int = length(platformLzCIDRs)
output platformConnectivityCIDRs array = platformConnectivityCIDRs
output platformConnectivityCIDRsCount int = length(platformConnectivityCIDRs)
output platformIdentityCIDRs array = platformIdentityCIDRs
output platformIdentityCIDRsCount int = length(platformIdentityCIDRs)

output applicationLzCIDRs array = applicationLzCIDRs
output applicationLzCIDRsCount int = length(applicationLzCIDRs)
output applicationLzCorpCIDRs array = applicationLzCorpCIDRs
output applicationLzCorpCIDRsCount int = length(applicationLzCorpCIDRs)
output applicationLzOnlineCIDRs array = applicationLzOnlineCIDRs
output applicationLzOnlineCIDRsCount int = length(applicationLzOnlineCIDRs)
