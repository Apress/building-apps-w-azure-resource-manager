
## ARM template to deploy a storage account

 - It provides a unique name for the storage account
 - It passes on the name for the storage account as variable


You can execute the script below and add a date value to each deployment 
```
$date = Get-Date -Format "MM-dd-yyyy"
$deploymentName = "iFabrikDeployment"+"$date"
New-AzResourceGroupDeployment `
  -Name $deploymentName `
  -ResourceGroupName iFabrikRG `
  TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
```
