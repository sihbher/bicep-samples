targetScope = 'subscription'


param rgName string = 'rg-aks-prod-eastus-001'
param location string = 'eastus'

module ResourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'myRg'
  params: {  
    name: rgName  
    location: location  
  }
}
