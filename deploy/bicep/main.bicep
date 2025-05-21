targetScope = 'subscription'

@description('Required. The name of the environment.')
param environment string

@description('Required. The location for the resources.')
param location string

@description('Required. The name of the region.')
param region string

@description('Required. The name of the resource group.')
param resourceGroupName string

var tags = union(loadJsonContent('../../templates/tags/tags.json'), {
  Environment: environment
})

var resourceNames = {
  eventHub: '${namingModule.outputs.eventHubNamespaceName}-01'
}

param eventHubs array = [
  {
    name: 'an'
    partitionCount: 1
  }
]

module resourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: '${uniqueString(deployment().name, location)}-resourceGroup'
  params: {
    name: resourceGroupName
    location: location
    tags: tags
  }
}

module namingModule '../../templates/bicep/naming-module.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: 'naming'
  params: {
    environment: environment
    region: region
    workload: 'workload'
  }
}

module eventHubNamespace 'br/public:avm/res/event-hub/namespace:0.11.0' = {
  scope: az.resourceGroup(resourceGroupName)
  name: 'eventHubNamespace'
  params: {
    name: resourceNames.eventHub
    location: resourceGroup.outputs.location
    tags: tags
    managedIdentities: {
      systemAssigned: true
    }
    publicNetworkAccess: 'Disabled'
    skuCapacity: 1
    skuName: 'Standard'
    disableLocalAuth: true
    eventhubs: [
      for eventHub in eventHubs: {
        name: eventHub.name
        partitionCount: eventHub.partitionCount
        messageRetentionInDays: 7
        retentionDescriptionCleanupPolicy: 'Delete'
        retentionDescriptionRetentionTimeInHours: 168
      }
    ]
  }
}
