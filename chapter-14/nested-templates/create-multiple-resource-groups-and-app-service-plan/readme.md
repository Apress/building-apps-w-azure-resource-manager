This ARM template contains two nested templates: One nested template creates multiple resource groups, the second nested template creates an app service plan in the first resource group provisioned

```New-AzDeployment -Name $deploymentName -TemplateFile .\azuredeploy.json -Location eastus```
