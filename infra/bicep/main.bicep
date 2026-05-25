@minLength(3)
@maxLength(3)
param environment string

@description('Azure region into which all resources will be deployed.')
param location string = resourceGroup().location

@description('Name of the Fqdn zone for the custom domain')
param domainName string = toLower('resume-${environment}.bcbrookman.com')

@minLength(3)
@maxLength(24)
@description('Name of the static site')
param staticSiteName string = toLower('crstat${environment}st${uniqueString(resourceGroup().id)}')

@minLength(3)
@maxLength(24)
@description('Name of the function app')
param functionAppName string = toLower('cloudresume-${environment}-func')

@description('Name of the function app service plan')
param functionAppServicePlanName string = toLower('cloudresume-${environment}-asp')

@description('Name of the function app storage account')
param functionAppStorageAccountName string = toLower('crfunc${environment}st${uniqueString(resourceGroup().id)}')

@description('Name of the Cosmos DB account')
param databaseAccountName string = toLower('cloudresume-${environment}-cosmos')

module staticSite './modules/staticSite.bicep' = {
  name: 'cloudResumeStaticSiteModule'
  params: {
    location: location
    staticSiteName: staticSiteName
  }
}

module api './modules/api.bicep' = {
  name: 'cloudResumeApiModule'
  params: {
    domainName: domainName
    functionAppName: functionAppName
    functionAppServicePlanName: functionAppServicePlanName
    functionAppStorageAccountName: functionAppStorageAccountName
    location: location
    staticSiteWebEndpointFqdn: staticSite.outputs.staticSiteWebEndpointFqdn
  }
}

module data './modules/data.bicep' = {
  name: 'cloudResumeDataModule'
  params: {
    accountName: databaseAccountName
    location: location
  }
}

output frontendEdgeFqdn string = domainName
output frontendEdgeVerifyFqdn string = 'asverify.${staticSite.outputs.staticSiteBlobEndpointFqdn}'
output frontendOriginFqdn string = staticSite.outputs.staticSiteWebEndpointFqdn
output apiEdgeFqdn string = api.outputs.apiSiteCustomFqdn
output apiEdgeFqdnVerifyTxt string = api.outputs.apiSiteCustomFqdnVerifyTxt
output apiOriginFqdn string = api.outputs.apiSiteDefaultFqdn
