using './aks-deployment.bicep'

param location = 'eastus'
param nsgName = 'nsg-aks-prod-${location}-001'
param vnetName = 'vnet-aks-prod-${location}-001'
param addressSpace = '10.201.0.0/16'
param systemPoolSubnetName = 'snet-aks-prod-${location}-systempool1'
param userPool1SubnetName = 'snet-aks-prod-${location}-userpool1'
param userPool2SubnetName = 'snet-aks-prod-${location}-userpool2'
param uaidName = 'mi-aks-prod-${location}-001'
param privateDnsZoneName = 'private.${location}.azmk8s.io'
param aksName = 'aks-prod-${location}-001'
