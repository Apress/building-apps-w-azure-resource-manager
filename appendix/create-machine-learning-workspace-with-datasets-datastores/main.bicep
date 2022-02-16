//This Bicep file creates an AML workspace with multiple datastores

@description('Specifies name of workspace to create in Azure Machine Learning workspace.')
param workspaceName string

@description('Specifies the location for all resources.')
param location string = 'eastus'

@description('Specifies the number of datastores to be created.')
param datastoreCount int = 2

@description('The name for the storage account to created and associated with the workspace.')
param storageAccountName string = 'sa${uniqueString(resourceGroup().id)}'

@description('The container name.')
param containerName string = 'container${uniqueString(resourceGroup().id)}'

@description('The name for the key vault to created and associated with the workspace.')
param keyVaultName string = 'kve${uniqueString(resourceGroup().id)}'

@description('Specifies the tenant ID of the subscription. Get using Get-AzureRmSubscription cmdlet or Get Subscription API.')
param tenantId string = subscription().tenantId

@description('The name for the application insights to created and associated with the workspace.')
param applicationInsightsName string = 'ai${uniqueString(resourceGroup().id)}'

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource storageAccountName_default_containerName 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${storageAccountName}/default/${containerName}'
  dependsOn: [
    storageAccountName_resource
  ]
}

resource keyVaultName_resource 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
  }
}

resource applicationInsightsName_resource 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: applicationInsightsName
  location: ((location == 'westcentralus') ? 'southcentralus' : location)
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource workspaceName_resource 'Microsoft.MachineLearningServices/workspaces@2020-03-01' = {
  name: workspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: workspaceName
    storageAccount: storageAccountName_resource.id
    keyVault: keyVaultName_resource.id
    applicationInsights: applicationInsightsName_resource.id
  }
}

resource workspaceName_datastore 'Microsoft.MachineLearningServices/workspaces/datastores@2021-03-01-preview' = [for i in range(0, int(datastoreCount)): {
  name: '${workspaceName}/datastore${i}'
  properties: {
    contents: {
      contentsType: 'AzureBlob'
      accountName: storageAccountName
      containerName: containerName
      credentials: {
        credentialsType: 'AccountKey'
        secrets: {
          key: listKeys(storageAccountName_resource.id, '2019-06-01').keys[0].value
          secretsType: 'AccountKey'
        }
      }
      endpoint: storageAccountName
      protocol: 'http'
    }
  }

  dependsOn: [
    workspaceName_resource
    storageAccountName_resource
  ]
}]
