// This template deploys a resource group at the subscription level
// targetScope must be 'subscription' to create resource groups
targetScope = 'subscription'

// Parameters
// rgName: Name of the resource group to be created
// Default follows Azure naming convention: rg-<workload>-<environment>-<region>-<instance>
param rgName string = 'rg-aks-prod-eastus-001'

// location: Azure region where the resource group will be deployed
// This region should be chosen based on latency, data sovereignty, or service availability requirements
param location string = 'eastus'

// Deploy a resource group using the Azure Verified Module (AVM)
// AVM modules implement Microsoft's recommended best practices for Azure resources
module ResourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'myRg' // Name of the deployment operation (not the resource group name)
  params: {  
    name: rgName  // Actual resource group name passed from parameters
    location: location  // Azure region for the resource group
    // Note: Additional parameters like tags, lock settings, and role assignments
    // can be added here if needed for governance and management
  }
}

// No outputs are defined, but you could add resource group ID or other properties
// if you need them for subsequent deployments
