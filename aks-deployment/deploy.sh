
#Login with code
az login --tenant --use-device-code

#name of the resource group
rg_name=aks-rg
location='eastus2'
#random suffix to be used, 6 letters
suffix=$(openssl rand -hex 3)
rg_name_with_suffix=$rg_name-$suffix

cd aks-deployment
#First deploy the resource group
az deployment sub create --name 'rg-creation' --location $location \
    --template-file './aks-rg.bicep'  \
    --parameters rgName=$rg_name_with_suffix location=$location

#Second deploy the AKS cluster
az deployment group create --name aks-$suffix \
    --resource-group $rg_name_with_suffix \
    --template-file './aks-deployment.bicep' \
    --parameters './aks-deployment.bicepparam' --parameters location=$location