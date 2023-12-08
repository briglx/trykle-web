targetScope = 'subscription'

@minLength(1)
@description('Primary location for all resources')
param location string

@minLength(1)
@maxLength(64)
@description('Application name')
param applicationName string

param applicationInsightsName string = ''
param logAnalyticsName string = ''
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
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${applicationName}-${environmentName}-${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: 'Y1'
      tier: 'Dynamic'
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
    // appSettings: {
    //   AzureWebJobsFeatureFlags: 'EnableWorkerIndexing'
    //   FUNCTIONS_WORKER_RUNTIME: 'python'
    //   AZURE_TENANT_ID: tenant().tenantId
    // }
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    appServicePlanId: appServicePlan.outputs.id
    keyVaultName: keyVault.outputs.name
    runtimeName: 'python'
    runtimeVersion: '3.10'
  }
}


/////////// Database ///////////

output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_LOCATION string = location

output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output STORAGE_ACCOUNT_ID string = storageAccount.outputs.id
output STORAGE_ACCOUNT_NAME string = storageAccount.outputs.name
output STORAGE_CONTAINER_NAME array = storageAccount.outputs.containerNames
output EVENT_GRID_NAME string = eventGrid.outputs.systemTopicName
output APPLICATION_INSIGHTS_NAME string = monitoring.outputs.applicationInsightsName
output LOG_ANALYTICS_NAME string = monitoring.outputs.logAnalyticsName
output APP_SERVICE_PLAN_NAME string = appServicePlan.outputs.name
output FUNCTION_APP_ID string = functions.outputs.id
output FUNCTION_APP_NAME string = functions.outputs.name
output FUNCTION_APP_HOST_NAME string = functions.outputs.uri
output FUNCTION_APP_PRINCIPAL_ID string = functions.outputs.identityPrincipalId
output RESOURCE_TOKEN string = resourceToken
output AZURE_RESOURCE_GROUP_NAME string = rg.name
