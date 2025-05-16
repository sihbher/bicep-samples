# bicep-samples

This repository contains a collection of Bicep templates and deployment examples for Azure resources. The lab environment is designed to be deployed using GitHub Codespaces, providing a containerized dev environment with all dependencies included.

## Prerequisites

- GitHub account

## Steps to Deploy the Lab

1. **Create a Codespace from the GitHub Repository**

   - Navigate to the GitHub repository for this lab.
   - Click on the `Code` button.
   - Select the `Codespaces` tab.
   - Click on `Create codespace on main` (or the appropriate branch).

2. **Login to Azure**

   Open a terminal in the Codespace and run the following command to login to your Azure account:

   ```sh
   az login
   ```
   If you have issues signing in, try using:
   ```sh
   az login --use-device-code
   ```

3. **Navigate to an Example Folder**

   Each example is self-contained in its own folder. For example, to deploy an AKS cluster:

   ```sh
   cd aks-deployment
   ```

4. **Review and Update Parameters**

   Edit the parameter files (e.g., `*.bicepparam`) in the example folder to match your environment and requirements.

5. **Run the Deployment Script**

   Most examples include a deployment script (e.g., `deploy.sh`). Run the script to deploy the resources:

   ```sh
   ./deploy.sh
   ```

## Clean Up the Lab

When you're ready to clean up the lab environment, use the provided destroy script (if available) or delete the resource group via the Azure CLI:

```sh
az group delete --name <your-resource-group>
```

## Structure

- `aks-deployment/` – Deploys an Azure Kubernetes Service (AKS) cluster and supporting resources.
- *(Add more folders/examples as needed)*

## References

- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure CLI Documentation](https://learn.microsoft.com/cli/azure/)

---

*This repository is for educational and demonstration purposes. Ensure you have the necessary permissions to create and manage resources in your Azure subscription.*
