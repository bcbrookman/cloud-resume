param location string
param staticSiteName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: staticSiteName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    dualStackEndpointPreference: {
      publishIpv6Endpoint: false
    }
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
    networkAcls: {
      ipv6Rules: []
      resourceAccessRules: []
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: [
        {
          value: '173.245.48.0/20'
          action: 'Allow'
        }
        {
          value: '103.21.244.0/22'
          action: 'Allow'
        }
        {
          value: '103.22.200.0/22'
          action: 'Allow'
        }
        {
          value: '103.31.4.0/22'
          action: 'Allow'
        }
        {
          value: '141.101.64.0/18'
          action: 'Allow'
        }
        {
          value: '108.162.192.0/18'
          action: 'Allow'
        }
        {
          value: '190.93.240.0/20'
          action: 'Allow'
        }
        {
          value: '188.114.96.0/20'
          action: 'Allow'
        }
        {
          value: '197.234.240.0/22'
          action: 'Allow'
        }
        {
          value: '198.41.128.0/17'
          action: 'Allow'
        }
        {
          value: '162.158.0.0/15'
          action: 'Allow'
        }
        {
          value: '104.16.0.0/13'
          action: 'Allow'
        }
        {
          value: '104.24.0.0/14'
          action: 'Allow'
        }
        {
          value: '172.64.0.0/13'
          action: 'Allow'
        }
        {
          value: '131.0.72.0/22'
          action: 'Allow'
        }
      ]
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2025-06-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
    staticWebsite: {
      enabled: true
      indexDocument: 'index.html'
      errorDocument404Path: 'index.html'
    }
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01' = {
  parent: blobService
  name: '$web'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

output staticSiteEndpoint string = storageAccount.properties.primaryEndpoints.web
