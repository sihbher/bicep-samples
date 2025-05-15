targetScope = 'subscription'

module ResourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'resourceGroupDeployment'
  params: {  
    name: 'rg-aks-prod-eastus-001'  
    location: 'eastus'  
  }
}
