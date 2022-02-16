## Storage account v3

 - This template deployment includes 2 storage accounts deployed in 2 resource groups in the same subscription with an unique id 

```
New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName iFabrikRG -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
```
