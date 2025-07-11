# Azure AVNM IPAM Documentation

Welcome to the Azure Virtual Network Manager (AVNM) IP Address Management (IPAM) Solution documentation.

## Overview

This documentation provides comprehensive guidance for deploying and managing Azure Virtual Network Manager with hierarchical IP Address Management (IPAM) pools, specifically designed to align with Azure Landing Zone architectures.

## What You'll Find Here

- **Getting Started**: Quick deployment guides and prerequisites
- **Architecture**: Detailed explanation of the IPAM hierarchy and design patterns
- **Configuration**: Parameter reference and customization options
- **Examples**: Real-world scenarios and deployment patterns
- **Troubleshooting**: Common issues and solutions
- **Best Practices**: Recommendations for production deployments

## Quick Navigation

### Core Concepts
- [IPAM Architecture](./architecture/)
- [Landing Zone Integration](./landing-zones/)
- [CIDR Planning](./cidr-planning/)

### Deployment Guides
- [Quick Start](./quick-start/)
- [Advanced Configuration](./configuration/)
- [Multi-Region Setup](./multi-region/)

### Reference
- [Parameter Reference](./reference/parameters.md)
- [Bicep Templates](./reference/templates.md)
- [Azure CLI Commands](./reference/cli.md)

## About This Solution

This project provides an Azure Bicep template solution for deploying Azure Virtual Network Manager with hierarchical IP Address Management (IPAM) pools. The solution represents a suggested approach for implementing IPAM within Azure Landing Zones.

::: tip Note
There are multiple ways to design and implement IP address management in Azure. This template provides one opinionated solution that organizations can evaluate and adapt for their specific requirements.
:::

## Key Features

- ✅ **Multi-region support**: Automatically creates IPAM pools for multiple Azure regions
- ✅ **Hierarchical IP management**: Implements a structured approach to IP allocation
- ✅ **Azure Landing Zone alignment**: Supports platform and application landing zone patterns
- ✅ **Percentage-based allocation**: Flexible CIDR allocation using configurable percentage factors
- ✅ **Automated subnet calculation**: Uses Azure Bicep CIDR functions for automatic IP allocation
- ✅ **Dynamic sizing**: Adapts to different region CIDR sizes automatically

## Getting Help

- 📖 Browse the documentation sections
- 🐛 [Report issues](https://github.com/tanure/Azure-AVNM-IPAM/issues)
- 💡 [Request features](https://github.com/tanure/Azure-AVNM-IPAM/issues/new)
- 📚 [Azure AVNM Documentation](https://docs.microsoft.com/azure/virtual-network-manager/)

---

*Ready to get started? Check out our [Quick Start Guide](./quick-start/) to deploy your first IPAM solution!*