
param deploymentNameSuffix string = utcNow()
param name string
param pipName string = 'bastion-pip'
param location string = resourceGroup().location
param tags object = {}
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'
param subnetId string
param virtualNetworkId string

module publicIp 'public-ip.bicep' = {
  name: 'deploy-bastionPip-${deploymentNameSuffix}'
  params: {
    name: pipName
    publicIpAllocationMethod: 'Static' 
    skuName: 'Standard'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2023-11-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    disableCopyPaste: false
    dnsName: 'string'
    enableFileCopy: false
    enableIpConnect: false
    enableKerberos: false
    enableShareableLink: false
    enableTunneling: false
    ipConfigurations: [
      {
        name: 'ipocnfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.outputs.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    scaleUnits: 2
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}
