This ARM template shows how to use conditions and logical/comparison functions to dynamically create windows/linux app service


```
$date = Get-Date -Format "MM-dd-yyyy"
$deploymentName = "iFabrikDeployment"+"$date"
New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName ifabrik2 -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
```
