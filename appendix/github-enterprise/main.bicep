@description('Unique prefix for your Storage Account and VM name. Must be all lower case letters or numbers. No spaces or special characters.')
param accountPrefix string

@description('Username for the VM. This value is ignored.')
param adminUsername string

@description('VM Size. Select an ES v3 Series VM with at least 32 GB of RAM. Default value: Standard_E4s_v3')
param vmSize string = 'Standard_E4s_v3'

@description('Select a Premium Storage disk capacity for your source code, in GB. Default value: 512.')
param storageDiskSizeGB int = 512

@allowed([
  'sshPublicKey'
  'password'
])
@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
param authenticationType string = 'sshPublicKey'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Location for all resources.')
param location string = resourceGroup().location

var imagePublisher = 'GitHub'
var imageOffer = 'GitHub-Enterprise'
var OSDiskName = 'osdiskforlinuxsimple'
var nicName_var = '${replace(replace(accountPrefix, '.', ''), '_', '-')}-nic'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var storageAccountType = 'Premium_LRS'
var storageAccountName_var = '${replace(replace(replace(accountPrefix, '.', ''), '_', ''), '-', '')}data'
var publicIPAddressName_var = '${replace(replace(accountPrefix, '.', ''), '_', '-')}-pub-ip'
var publicIPAddressType = 'Dynamic'
var dnsNameForPublicIP = '${accountPrefix}-ghe'
var vmName_var = '${replace(replace(accountPrefix, '.', ''), '_', '-')}-ghe-vm'
var virtualNetworkName_var = '${replace(replace(accountPrefix, '.', ''), '_', '-')}-vnet'
var networkSecurityGroupName_var = '${replace(replace(accountPrefix, '.', ''), '_', '-')}-nsg'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName_var, subnetName)
var dataDiskName = 'ghe-data'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

resource storageAccountName 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: storageAccountName_var
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
}

resource publicIPAddressName 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: publicIPAddressName_var
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: dnsNameForPublicIP
    }
  }
}

resource virtualNetworkName 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: virtualNetworkName_var
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupName.id
          }
        }
      }
    ]
  }
}

resource nicName 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nicName_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddressName.id
          }
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetworkName
  ]
}

resource vmName 'Microsoft.Compute/virtualMachines@2019-12-01' = {
  name: vmName_var
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName_var
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageOffer
        version: 'latest'
      }
      osDisk: {
        name: '${OSDiskName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          name: '${dataDiskName}_DataDisk1'
          diskSizeGB: storageDiskSizeGB
          createOption: 'Empty'
          lun: 0
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicName.id
        }
      ]
    }
  }
  dependsOn: [
    storageAccountName
  ]
}

resource networkSecurityGroupName 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: networkSecurityGroupName_var
  location: location
  properties: {
    securityRules: [
      {
        name: 'https_8443'
        properties: {
          description: 'https'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '8443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'http_8080'
        properties: {
          description: 'http plain text'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
        }
      }
      {
        name: 'ssh_port_122'
        properties: {
          description: 'Allow admin SSH'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '122'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 102
          direction: 'Inbound'
        }
      }
      {
        name: 'vpn_1194'
        properties: {
          description: 'Allow VPN'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '1194'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 103
          direction: 'Inbound'
        }
      }
      {
        name: 'snmp_161'
        properties: {
          description: 'Allow SNMP'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '161'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 104
          direction: 'Inbound'
        }
      }
      {
        name: 'https_443'
        properties: {
          description: 'Allow HTTPS'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 105
          direction: 'Inbound'
        }
      }
      {
        name: 'http_80'
        properties: {
          description: 'Allow HTTP'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 106
          direction: 'Inbound'
        }
      }
      {
        name: 'ssh_22'
        properties: {
          description: 'Allow Git SSH'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 107
          direction: 'Inbound'
        }
      }
      {
        name: 'git_9418'
        properties: {
          description: 'Allow Git'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '9418'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 108
          direction: 'Inbound'
        }
      }
      {
        name: 'smtp_25'
        properties: {
          description: 'Allow SMTP'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '25'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 109
          direction: 'Inbound'
        }
      }
    ]
  }
}
