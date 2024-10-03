
param virtualNetworkName string
param name string
param addressPrefix string = ''
param addressPrefixes array = []
param defaultOutboundAccess bool = true
// param natGatewayId string = ''
param includeNsg bool = true
param networkSecurityGroupId string = ''
param includeRouteTable bool = true
param routeTableId string = ''

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  name: name
  parent: virtualNetwork
  properties: {
    addressPrefix: addressPrefix
    addressPrefixes: addressPrefixes
    defaultOutboundAccess: defaultOutboundAccess
    // natGateway: empty(natGatewayId) ? null : {
    //   id: natGatewayId
    // }
    ...(includeNsg ? {
      networkSecurityGroup: {
        id: networkSecurityGroupId
      }
    } : {})
    // networkSecurityGroup: !empty(networkSecurityGroupId) ? {
    //   id: networkSecurityGroupId
    // } : null
    privateEndpointNetworkPolicies: 'string'
    privateLinkServiceNetworkPolicies: 'string'
    ...(includeRouteTable ? {
      routeTable: {
        id: routeTableId
      }
    } : {})  
  }
}

output id string = subnet.id
