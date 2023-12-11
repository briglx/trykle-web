targetScope = 'subscription'

@minLength(1)
@description('Primary location for all resources')
param location string

@minLength(1)
@maxLength(64)
@description('Application name')
param applicationName string

param applicationInsightsName string = ''
param applicationInsightsResourceGroup string = ''
param keyVaultName string = ''
param keyVaultResourceGroup string = ''
param appServicePlanName string = ''
param appServiceName string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, applicationName, location))
var tags = { 'app-name': applicationName }

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${applicationName}_${location}'
  location: location
  tags: tags
}

/////////// Web App ///////////

module appServicePlan './core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: rg
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${applicationName}-${resourceToken}'
    location: location
    kind: 'linux'
    tags: tags
    sku: {
      name: 'F1'
      tier: 'Free'
    }
  }
}

module appService './core/host/appservice.bicep' = {
  name: '${applicationName}-web'
  scope: rg
  params: {
    name: !empty(appServiceName) ? appServiceName : '${abbrs.webSitesAppService}${applicationName}-${resourceToken}'
    location: location
    tags: tags
    alwaysOn: false
    applicationInsightsName: applicationInsightsName
    applicationInsightsResourceGroup: applicationInsightsResourceGroup
    appServicePlanId: appServicePlan.outputs.id
    keyVaultName: keyVaultName
    keyVaultResourceGroup: keyVaultResourceGroup
    use32BitWorkerProcess: true
    runtimeName: 'python'
    runtimeVersion: '3.10'
  }
}

/////////// Database ///////////
// TBD
/////////// Outputs ///////////

output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_LOCATION string = location

output RESOURCE_TOKEN string = resourceToken
output WEB_APP_RESOURCE_GROUP_NAME string = rg.name

output APP_SERVICE_PLAN_ID string = appServicePlan.outputs.id
output APP_SERVICE_PLAN_NAME string = appServicePlan.outputs.name

output WEB_APP_ID string = appService.outputs.id
output WEB_APP_NAME string = appService.outputs.name
output WEB_APP_IDENTITY string = appService.outputs.identityPrincipalId
output WEB_APP_URI string = appService.outputs.uri
