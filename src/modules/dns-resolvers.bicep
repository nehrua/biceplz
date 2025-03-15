
param resolverName string
param location string = resourceGroup().location

param inboundEndpointName string
param inboundEndpointPrivateIp string
param inboundEndpointSubnetId string

param outboundEndpointName string
param outboundEndpointSubnetId string

param tags object = {}
param virtualNetworkId string


resource dnsResolver 'Microsoft.Network/dnsResolvers@2023-07-01-preview' = {
  location: location
  name: resolverName
  properties: {
      virtualNetwork: {
      id: virtualNetworkId
      }
  }
  tags: tags
}

resource dnsInboundEndpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2023-07-01-preview' = {
  parent: dnsResolver
  location: location
  name: inboundEndpointName
  properties: {
    ipConfigurations: [
      {
        privateIpAddress: inboundEndpointPrivateIp
        privateIpAllocationMethod: 'Static'
        subnet: {
          id: inboundEndpointSubnetId
        }
      }
    ]
  }
  tags: tags
}

resource dnsOutboundEndpoint 'Microsoft.Network/dnsResolvers/outboundEndpoints@2023-07-01-preview' = {
  parent: dnsResolver
  location: location
  name: outboundEndpointName
  properties: {
    subnet: {
      id: outboundEndpointSubnetId
    }
  }
  tags: tags
}

