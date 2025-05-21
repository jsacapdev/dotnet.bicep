metadata name = 'Virtual Network Subnets'
metadata description = 'This module deploys a Virtual Network Subnet.'

@description('Optional. The Name of the subnet resource.')
param name string

@description('Conditional. The name of the parent virtual network. Required if the template is used in a standalone deployment.')
param virtualNetworkName string

@description('Required. The address prefix for the subnet.')
param addressPrefix string

@description('Optional. The resource ID of the network security group to assign to the subnet.')
param networkSecurityGroupResourceId string = ''

@description('Optional. The resource ID of the route table to assign to the subnet.')
param routeTableResourceId string = ''

@description('Optional. The delegations to enable on the subnet.')
param delegations array = []

@description('Optional. enable or disable apply network policies on private endpoint in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
  ''
])
param privateEndpointNetworkPolicies string = ''

@description('Optional. enable or disable apply network policies on private link service in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
  ''
])
param privateLinkServiceNetworkPolicies string = ''

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  name: name
  parent: virtualNetwork
  properties: {
    addressPrefix: addressPrefix
    networkSecurityGroup: !empty(networkSecurityGroupResourceId)
      ? {
          id: networkSecurityGroupResourceId
        }
      : null
    routeTable: !empty(routeTableResourceId)
      ? {
          id: routeTableResourceId
        }
      : null
    delegations: delegations
    privateEndpointNetworkPolicies: !empty(privateEndpointNetworkPolicies) 
      ? any(privateEndpointNetworkPolicies) 
      : null
    privateLinkServiceNetworkPolicies: !empty(privateLinkServiceNetworkPolicies)
      ? any(privateLinkServiceNetworkPolicies)
      : null
  }
}
