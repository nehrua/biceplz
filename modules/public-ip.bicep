
param name string
param location string = resourceGroup().location
param publicIpAllocationMethod string
param skuName string
param tags object = {}
param availabilityZones array = []

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
  }
  zones: availabilityZones
}

output id string = publicIPAddress.id
