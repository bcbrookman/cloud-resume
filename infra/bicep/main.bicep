@minLength(3)
@maxLength(3)
param environment string

@description('Azure region into which all resources will be deployed.')
param location string = resourceGroup().location

@description('Name of the DNS zone for the custom domain')
param dnsZoneName string = toLower('resume-${environment}.bcbrookman.com')

@description('Name of the customDomain resource used by the edge')
param edgeCustomDomainResourceName string = toLower(replace('${dnsZoneName}-customdomain', '.', '-'))

@description('Name of the Azure Front Door instance')
param frontDoorName string = toLower('cloudresume-${environment}-afd')

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


module edge './modules/edge.bicep' = {
  name: 'cloudResumeEdgeModule'
  params: {
    customDomainResourceName: edgeCustomDomainResourceName
    dnsZoneName: dnsZoneName
    frontDoorName: frontDoorName
    storageEndpoint: staticSite.outputs.staticSiteEndpoint
  }
}

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
    dnsZoneName: dnsZoneName
    edgeEndpointDNS: edge.outputs.endpointDNS
    functionAppName: functionAppName
    functionAppServicePlanName: functionAppServicePlanName
    functionAppStorageAccountName: functionAppStorageAccountName
    location: location
  }
}

module data './modules/data.bicep' = {
  name: 'cloudResumeDataModule'
  params: {
    accountName: databaseAccountName
    location: location
  }
}
