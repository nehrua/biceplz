
targetScope = 'subscription'

param deploymentNameSuffix string
param hubVirtualNetworkName string
param resourceGroupName string
param spokeVirtualNetworkResourceId string
param subscriptionId string

module hubToSpokePeering 'virtual-network-peering.bicep' = {
  name: 'hub-peering-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    remoteVirtualNetworkResourceId: spokeVirtualNetworkResourceId
    virtualNetworkName: hubVirtualNetworkName
    virtualNetworkPeerName: 'to-${split(spokeVirtualNetworkResourceId, '/')[8]}'
    allowForwardedTrafic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}



