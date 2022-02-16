@description('The exposed port for the compute instance.')
param computeName string

@description('The exposed port for the compute instance.')
param dnsServiceIP string = ''

@description('Name of the resource group which holds the VNET to which you want to inject your compute in.')
param vnetResourceGroupName string = ''

@description('Name of the vnet which you want to inject your compute in.')
param vnetName string = ''

@description('Name of the subnet inside the VNET which you want to inject your compute in.')
param subnetName string = ''

@description('The exposed port for the compute instance.')
param location string = resourceGroup().location

@description('The exposed port for the compute instance.')
param dockerBridgeCidr string = ''

@description('The exposed port for the compute instance.')
param serviceCidr string = ''

@description('The Azure VM size of the agent VM nodes. This cannot be changed once the cluster is created.')
param agentVmSize string = 'Standard_D4_v3'

@description('The number of agent nodes in the Container Service..')
param agentCount int = 6

@description('The SSL cert data in PEM format encoded as base64 string')
param cert string = ''

@description('The SSL key data in PEM format encoded as base64 string.')
param key string = ''

@description('The CName of the cert.')
param cname string = ''

@description('The leaf domain label of public endpoint.')
param leafDomainLabel string = ''

@description('Value indicating whether to overwrite existing domain label.')
param overwriteExistingDomain bool = false

@description('Value indicating whether to renew certificate.')
param renew bool = false

@allowed([
  'Enabled'
  'Disabled'
  'Auto'
])
@description('SSL status. Allowed values are Enabled and Disabled.')
param sslStatus string = 'Disabled'

@description('The exposed port for the compute instance.')
param workspaceName string

var aksNetworkingConfiguration = {
  subnetId: resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
  serviceCidr: serviceCidr
  dnsServiceIP: dnsServiceIP
  dockerBridgeCidr: dockerBridgeCidr
}
var sslConfiguration = {
  status: sslStatus
  cert: cert
  key: key
  cname: cname
  leafDomainLabel: leafDomainLabel
  overwriteExistingDomain: overwriteExistingDomain
  renew: renew
}

resource workspaceName_computeName 'Microsoft.MachineLearningServices/workspaces/computes@2021-01-01' = {
  name: '${workspaceName}/${computeName}'
  location: location
  properties: {
    computeType: 'AKS'
    properties: {
      agentVmSize: agentVmSize
      agentCount: agentCount
      sslConfiguration: ((sslStatus == 'Disabled') ? json('null') : sslConfiguration)
      aksNetworkingConfiguration: (((!empty(vnetResourceGroupName)) && (!empty(vnetName)) && (!empty(subnetName)) && (!empty(serviceCidr)) && (!empty(dnsServiceIP)) && (!empty(dockerBridgeCidr))) ? aksNetworkingConfiguration : json('null'))
    }
  }
}
