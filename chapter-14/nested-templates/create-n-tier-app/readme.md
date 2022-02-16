
This ARM template includes three nested templates: 
 - A nested template that creates multiple resource groups
 - A nested template that creates an app service plan in the first resource group
 - A nested template that creates an app service in the second resource group
 
 
  ```New-AzDeployment -Name $deploymentName -Location eastus -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json```
