//parameters
param location string = 'eastus'
param ifabrik string = 'ifabrik'

//define target 
targetScope = 'subscription'

//define new resoruce group
resource ifabrikRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${ifabrik}Rg'
  location: location
}

//consume appServicePlan as module from private registry
module appServicePlan 'br:azinsidercr.azurecr.io/bicep/modules/app-service-plan:v1.0' = {
  name:'appServicePlan'
  scope: ifabrikRg
  params: {
    appPlanPrefix: ifabrik
  }
}

//consume appService as module from local machine
module appService 'appService.bicep' = {
  name: 'appService'
  scope: ifabrikRg
  params: {
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    appServicePrefix: ifabrik
  }
}
