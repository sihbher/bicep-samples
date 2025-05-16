
# Login with device code authentication
# This is useful for environments where interactive login isn't available
# az login --use-device-code

# Set the base name for your resource group
rg_name=aks-rg

# Set the Azure region for deployment
location='eastus2'

# Generate a random 6-character suffix for unique resource naming
# This prevents naming conflicts when deploying multiple instances
suffix=$(openssl rand -hex 3)

# Create the final resource group name with suffix
rg_name_with_suffix=$rg_name-$suffix

# Navigate to the directory containing deployment templates
cd aks-deployment

# First
# Deploy the resource group using subscription-level deployment
# This creates a new resource group with a unique name
az deployment sub create --name 'rg-creation' --location $location \
    --template-file './aks-rg.bicep' \
    --parameters rgName=$rg_name_with_suffix location=$location

# Second
# Deploy the AKS cluster within the resource group
# This uses both parameter file values and command-line parameters
az deployment group create --name aks-$suffix \
    --resource-group $rg_name_with_suffix \
    --template-file './aks-deployment.bicep' \
    --parameters './aks-deployment.bicepparam' --parameters location=$location