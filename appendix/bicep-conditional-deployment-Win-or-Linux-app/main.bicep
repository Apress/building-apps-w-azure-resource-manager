@allowed([
  'Win'
  'Linux'
])
@description('Select the OS type to deploy.')
param platform string

@minLength(2)
@description('Web app name.')
param webAppName string = 'webApp-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The SKU of App Service Plan.')
param sku string = 'F1'

@description('Optional Git Repo URL')
param repoUrl string = ' '

@description('true = deploy a sample Hello World app.')
param helloWorld bool

var language = '.net'
var configReferenceLinux = {
  node: {
    appSettings: [
      {
        name: 'WEBSITE_NODE_DEFAULT_VERSION'
        value: '12.15.0'
      }
    ]
  }
}
var linuxOffer = 'linux'
var windowsOffer = 'windows'
var appServicePlanPortalName_var = 'AppServicePlan-${webAppName}'
var gitRepoReference = {
  '.net': 'https://github.com/Azure-Samples/app-service-web-dotnet-get-started'
  node: 'https://github.com/Azure-Samples/nodejs-docs-hello-world'
  php: 'https://github.com/Azure-Samples/php-docs-hello-world'
  html: 'https://github.com/Azure-Samples/html-docs-hello-world'
}
var gitRepoUrl = (bool(helloWorld) ? gitRepoReference[toLower(language)] : repoUrl)
var configReferenceWindows = {
  '.net': {
    comments: '.Net app. No additional configuration needed.'
  }
  html: {
    comments: 'HTML app. No additional configuration needed.'
  }
  php: {
    phpVersion: '7.4'
  }
  node: {
    appSettings: [
      {
        name: 'WEBSITE_NODE_DEFAULT_VERSION'
        value: '12.15.0'
      }
    ]
  }
}

resource appServicePlanPortalName 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanPortalName_var
  location: location
  sku: {
    name: sku
  }
  kind: ((platform == 'Linux') ? linuxOffer : windowsOffer)
}

resource webAppName_resource 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlanPortalName.id
    siteConfig: ((platform == 'Linux') ? configReferenceLinux : configReferenceWindows)
  }
}

resource webAppName_web 'Microsoft.Web/sites/sourcecontrols@2020-06-01' = if (contains(gitRepoUrl, 'http')) {
  parent: webAppName_resource
  name: 'web'
  properties: {
    repoUrl: gitRepoUrl
    branch: 'master'
    isManualIntegration: true
  }
}
