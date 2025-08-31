// main.bicep - BetSavior core infrastructure (dev, westeurope)
// Azure-only, idempotent, no secrets, MI enabled
param location string = 'westeurope'
param env string = 'dev'
param cosmosDbAccountName string = 'betsavior-cosmos-${env}'
param keyVaultName string = 'betsavior-kv-${env}'
param storageAccountName string = 'betsaviorstoragedev'
param aiSearchName string = 'betsavior-search-${env}'
param appInsightsName string = 'betsavior-ai-${env}'
param functionAppName string = 'betsavior-func-${env}'
param acsName string = 'betsavior-acs-${env}'

// Key Vault (RBAC, purge protection)
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    enableRbacAuthorization: true
    enablePurgeProtection: true
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
  }
}

// Storage Account
resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
  }
}

// Cosmos DB Account
resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosDbAccountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    enableFreeTier: true
    enableAnalyticalStorage: false
    isVirtualNetworkFilterEnabled: false
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    capabilities: []
  }
}

// Cosmos DB SQL Database and containers (users, sessions, goals, journals, finance_events, risk_states)
module cosmosContainers 'cosmos-containers.bicep' = {
  name: 'cosmos-containers'
  params: {
    cosmosDbAccountName: cosmosDbAccountName
    dbName: 'betsavior'
  }
  dependsOn: [cosmos]
}

// Azure AI Search
resource aiSearch 'Microsoft.Search/searchServices@2023-11-01' = {
  name: aiSearchName
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    hostingMode: 'default'
    semanticSearch: 'standard'
    replicaCount: 1
    partitionCount: 1
    publicNetworkAccess: 'enabled'
    vectorSearch: {
      algorithmConfigurations: [
        {
          name: 'default'
          kind: 'hnsw'
        }
      ]
    }
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    IngestionMode: 'ApplicationInsights'
  }
}

// App Service Plan (Y1 Consumption for Functions)
resource plan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'betsavior-funcplan-${env}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  kind: 'functionapp'
}

// Function App (system-assigned MI, HTTPS only, minimal secure app settings)
resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storage.properties.primaryEndpoints.blob
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
      ]
    }
  }
  dependsOn: [plan, storage, appInsights]
}

// Azure Communication Services (ACS)
resource acs 'Microsoft.Communication/communicationServices@2023-04-01-preview' = {
  name: acsName
  location: location
  properties: {
    dataLocation: 'Europe'
  }
}

output keyVaultUri string = keyVault.properties.vaultUri
output cosmosDbAccount string = cosmos.name
output aiSearchName string = aiSearch.name
output appInsightsName string = appInsights.name
output functionAppName string = functionApp.name
output acsName string = acs.name
