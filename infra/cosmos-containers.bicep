// cosmos-containers.bicep - Cosmos DB containers for BetSavior
// All containers use /userId as partition key
param cosmosDbAccountName string
param dbName string = 'betsavior'

resource db 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: resourceId('Microsoft.DocumentDB/databaseAccounts', cosmosDbAccountName)
  name: dbName
  properties: {}
}

resource users 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: db
  name: 'users'
  properties: {
    partitionKey: {
      paths: ['/userId']
      kind: 'Hash'
    }
    indexingPolicy: {
      indexingMode: 'consistent'
    }
  }
}

resource sessions 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: db
  name: 'sessions'
  properties: {
    partitionKey: {
      paths: ['/userId']
      kind: 'Hash'
    }
    indexingPolicy: {
      indexingMode: 'consistent'
    }
  }
}

resource goals 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: db
  name: 'goals'
  properties: {
    partitionKey: {
      paths: ['/userId']
      kind: 'Hash'
    }
    indexingPolicy: {
      indexingMode: 'consistent'
    }
  }
}

resource journals 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: db
  name: 'journals'
  properties: {
    partitionKey: {
      paths: ['/userId']
      kind: 'Hash'
    }
    indexingPolicy: {
      indexingMode: 'consistent'
    }
  }
}

resource finance_events 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: db
  name: 'finance_events'
  properties: {
    partitionKey: {
      paths: ['/userId']
      kind: 'Hash'
    }
    indexingPolicy: {
      indexingMode: 'consistent'
    }
  }
}

resource risk_states 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: db
  name: 'risk_states'
  properties: {
    partitionKey: {
      paths: ['/userId']
      kind: 'Hash'
    }
    indexingPolicy: {
      indexingMode: 'consistent'
    }
  }
}
