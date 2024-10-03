
param remoteVirtualNetworkResourceId string
param virtualNetworkName string
param virtualNetworkPeerName string
param allowGatewayTransit bool
param allowForwardedTrafic bool
param useRemoteGateways bool

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: virtualNetworkName
}

resource virtualNetworkPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  parent: virtualNetwork
  name: virtualNetworkPeerName
  properties: {
    remoteVirtualNetwork: {
      id: remoteVirtualNetworkResourceId
    }
    allowForwardedTraffic: allowForwardedTrafic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
  }
}
