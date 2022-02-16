This ARM template includes a nested template with inner scope that deploys N resource groups in a given subscription and pass the outputs to the main template

Deploy to subscription: 
```New-AzDeployment -Name $deploymentName -TemplateFile .\azuredeploy.json -Location eastus```
