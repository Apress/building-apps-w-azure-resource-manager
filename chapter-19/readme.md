

Deployment of Bicep file and leverage the whatIf -C flag to confirm the deployment with the command below:



     New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName ifabrikApp -TemplateFile .\create-multiple-sites.bicep -c 
     
   
