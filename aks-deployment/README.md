# AKS Deployment Example

This folder contains Bicep templates and scripts to deploy an Azure Kubernetes Service (AKS) cluster and its supporting resources using Azure Verified Modules (AVM).

## Contents

- `aks-deployment.bicep` – Main Bicep template for deploying AKS, networking, managed identities, and private DNS.
- `aks-deployment.bicepparam` – Parameter file for the main Bicep template.
- `aks-rg.bicep` – Bicep template for creating a resource group at the subscription level.
- `deploy.sh` – Bash script to automate the deployment process.

## Prerequisites

- Azure CLI installed
- Logged in to Azure (`az login`)
- Sufficient permissions to create resource groups and deploy resources

## Deployment Steps

1. **Login to Azure**

   The deployment script uses device code authentication:
   ```sh
   az login --use-device-code
   ```

2. **Run the Deployment Script**

   From the root of the repository, execute:
   ```sh
   ./aks-deployment/deploy.sh
   ```

   This script will:
   - Create a new resource group with a unique name.
   - Deploy the AKS cluster and supporting resources into that resource group.

## Customization

- Edit [`aks-deployment.bicepparam`](aks-deployment.bicepparam) to change parameter values such as location, resource names, address spaces, etc.
- Modify [`aks-deployment.bicep`](aks-deployment.bicep) to adjust the architecture or add/remove resources.

## Resources Deployed

- Azure Resource Group
- User Assigned Managed Identity
- Network Security Group
- Virtual Network with subnets
- Private DNS Zone
- Azure Kubernetes Service (AKS) Cluster

## References

- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Verified Modules](https://github.com/Azure/avm-accelerators)
