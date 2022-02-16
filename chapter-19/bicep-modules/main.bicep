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

//consume appServicePlan as module
module appServicePlan 'appServicePlan.bicep' = {
  name:'appServicePlan'
  scope: ifabrikRg
  params: {
    appPlanPrefix: ifabrik
  }
}

//consume appService as module
module appService 'appService.bicep' = {
  name: 'appService'
  scope: ifabrikRg
  params: {
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    appServicePrefix: ifabrik
  }
}
