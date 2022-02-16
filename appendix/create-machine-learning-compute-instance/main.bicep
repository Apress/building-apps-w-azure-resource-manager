@description('Specifies the name of the Azure Machine Learning workspace to which compute instance will be deployed')
param workspaceName string

@description('Specifies the name of the Azure Machine Learning compute instance to be deployed')
param computeName string

@description('Location of the Azure Machine Learning workspace.')
param location string = resourceGroup().location

@description('The VM size for compute instance')
param vmSize string = 'Standard_DS3_v2'

@description('Name of the resource group which holds the VNET to which you want to inject your compute instance in.')
param vnetResourceGroupName string = ''

@description('Name of the vnet which you want to inject your compute instance in.')
param vnetName string = ''

@description('Name of the subnet inside the VNET which you want to inject your compute instance in.')
param subnetName string = ''

@description('AAD tenant id of the user to which compute instance is assigned to')
param tenantId string = subscription().tenantId

@description('AAD object id of the user to which compute instance is assigned to')
param objectId string

@description('inline command')
param inlineCommand string = 'ls'

@description('Specifies the cmd arguments of the creation script in the storage volume of the Compute Instance.')
param creationScript_cmdArguments string = ''


var subnet = {
  id: resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
}

resource workspaceName_computeName 'Microsoft.MachineLearningServices/workspaces/computes@2021-07-01' = {
  name: '${workspaceName}/${computeName}'
  location: location
  properties: {
    computeType: 'ComputeInstance'
    properties: {
      vmSize: vmSize
      subnet: (((!empty(vnetResourceGroupName)) && (!empty(vnetName)) && (!empty(subnetName))) ? subnet : json('null'))
      personalComputeInstanceSettings: {
        assignedUser: {
          objectId: objectId
          tenantId: tenantId
        }
      }
      setupScripts: {
        scripts: {
          creationScript: {
            scriptSource: 'inline'
            scriptData: base64(inlineCommand)
            scriptArguments: creationScript_cmdArguments
          }
        }
      }
      
    }
  }
}
