param workspaceName string = 'azinsider'
param location string = resourceGroup().location

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}
resource solution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(${workspace.name})'
  location: location
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: 'SecurityInsights(${workspace.name})'
    product: 'OMSGallery/SecurityInsights'
    publisher: 'Microsoft'
    promotionCode: ''
  }
}
