// Creates one SQL container under an existing Cosmos SQL database.
// Uses autoscale throughput on the container.

param accountName string
param databaseName string
param containerName string
param partitionKey string = '/userId'
@minValue(400)
param maxRu int = 1000

// IMPORTANT: parent must be a RESOURCE reference, not a string.
// We declare the SQL database as an existing resource and attach the container to it.
resource sqlDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' existing = {
  name: '${accountName}/${databaseName}'
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  name: '${containerName}'
  parent: sqlDb
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          partitionKey
        ]
        kind: 'Hash'
        version: 2
      }
      indexingPolicy: {
        indexingMode: 'consistent'
      }
    }
    options: {
      autoscaleSettings: {
        maxThroughput: maxRu
      }
    }
  }
}
