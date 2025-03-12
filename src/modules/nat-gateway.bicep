
param name string = 'hubNatGateway-ngw'
param ipPrefixName string = 'natGateway-ipp' 
param prefixLength int = 31
param publicIPAddressVersion string = 'IPv4'
param location string = resourceGroup().location

// deploy public ip prefix
resource publicIpPrefix 'Microsoft.Network/publicIPPrefixes@2024-05-01' = {
  location: location
  name: ipPrefixName
  properties: {
    // customIPPrefix: {
    //   id: 'string'
    // }
    prefixLength: prefixLength
    publicIPAddressVersion: publicIPAddressVersion
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  // tags: {
  //   {customized property}: 'string'
  // }
  // zones: [
  //   'string'
  // ]
}

resource natGateway 'Microsoft.Network/natGateways@2024-05-01' = {
  location: location
  name: name
  properties: {
    publicIpPrefixes: [
      {
        id: publicIpPrefix.id
      }
    ]
  }
  sku: {
    name: 'Standard'
  }
  // tags: {
  //   {customized property}: 'string'
  // }
  // zones: [
  //   'string'
  // ]
}

output id string = natGateway.id
