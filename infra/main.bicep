targetScope = 'resourceGroup'

@description('Project short name')
param project string = 'bsrv'

@description('Environment: dev | stage | prod')
param env string = 'dev'

@description('Azure region')
param location string = resourceGroup().location

@description('Cosmos DB autoscale max RU/s per container')
@minValue(400)
param cosmosMaxRu int = 1000

@description('Deploy Azure Communication Services (may be unavailable on some subscriptions)')
param deployAcs bool = false

var namePrefix = '${project}-${env}'

// --------------------- Key Vault (RBAC) ---------------------
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${namePrefix}-kv'
  location: location
  properties: {
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    sku: {
      name: 'standard'
      family: 'A'
    }
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Enabled'
  }
}

// --------------------- Storage Account ---------------------
resource st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: toLower(replace('${namePrefix}st', '-', ''))
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

// --------------------- Azure AI Search Service ---------------------
resource ais 'Microsoft.Search/searchServices@2023-11-01' = {
  name: '${namePrefix}-aisearch'
  location: location
  sku: {
    name: 'basic'
  }
  properties: {
    // semanticSearch must be a string (free|standard)
    semanticSearch: 'free'
    // vector settings are configured at the INDEX level, not here
  }
}

// --------------------- Application Insights ---------------------
resource appi 'Microsoft.Insights/components@2020-02-02' = {
  name: '${namePrefix}-appi'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// --------------------- Functions (Consumption Y1) ---------------------
resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: '${namePrefix}-plan'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource func 'Microsoft.Web/sites@2023-12-01' = {
  name: '${namePrefix}-func'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'AzureWebJobsStorage'
          value: st.listKeys().keys[0].value
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appi.properties.InstrumentationKey
        }
      ]
    }
  }
}

// --------------------- Cosmos DB (SQL API) ---------------------
resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: '${namePrefix}-cosmos'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    publicNetworkAccess: 'Enabled'
    minimalTlsVersion: 'Tls12'
    // No Serverless capability here, we will use autoscale on containers
  }
}

// SQL database
resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  name: '${cosmos.name}/betsavior'
  properties: {
    resource: {
      id: 'betsavior'
    }
    options: {}
  }
}

// Containers (module invocation) - all partitioned by /userId
module containers 'cosmos-containers.bicep' = [for c in [
  'users', 'sessions', 'goals', 'journals', 'finance_events', 'risk_states'
]: {
  name: 'container-${c}'
  params: {
    accountName: cosmos.name
    databaseName: 'betsavior'
    containerName: c
    partitionKey: '/userId'
    maxRu: cosmosMaxRu
  }
}]

// --------------------- Azure Communication Services (optional) ---------------------
resource acs 'Microsoft.Communication/communicationServices@2023-04-01' = if (deployAcs) {
  name: '${namePrefix}-acs'
  location: location
  properties: {
    // choose a dataLocation compatible with your tenant; 'Europe' fits westeurope
    dataLocation: 'Europe'
  }
}

// --------------------- Outputs ---------------------
output keyVaultName string = kv.name
output storageAccountName string = st.name
output searchServiceName string = ais.name
output functionAppName string = func.name
output cosmosAccountName string = cosmos.name
output appInsightsName string = appi.name
output acsName string = deployAcs ? acs.name : 'not-deployed'
