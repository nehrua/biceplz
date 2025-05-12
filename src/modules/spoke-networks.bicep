
param deploymentNameSuffix string = utcNow()
param virtualNetworkName string
param addressSpacePrefixes array
param dnsServers array = []
param subnets array = []
param nextHopIpAddress string = '10.0.0.3'

// Deploy default NSG
module defaultNsg 'network-security-group.bicep' = {
  name: 'deploy-defaultNsg-${deploymentNameSuffix}'
  params: {
    name: '${virtualNetworkName}-default-nsg'
  }
}

// Quad Zero route table
module routeTable 'route-table.bicep' = {
  name: 'deploy-${virtualNetworkName}-routetable-${deploymentNameSuffix}'
  params: {
    name: '${virtualNetworkName}-quadz-rt'
    nextHopIpAddress: nextHopIpAddress
  }
}

module virtualNetwork 'virtual-network.bicep' = {
  name: 'deploy-${virtualNetworkName}-${deploymentNameSuffix}'
  params: {
    deployHub: false
    deploySpoke: true
    spokeName: virtualNetworkName
    spokeAddressPrefixes: addressSpacePrefixes
    spokeDnsServers: dnsServers
    spokeSubnets: subnets
    networkSecurityGroupId: defaultNsg.outputs.id
    routeTableId: routeTable.outputs.id
  }
}

output id string = virtualNetwork.outputs.spokeId
output name string = virtualNetwork.outputs.spokeName
output subnets array = virtualNetwork.outputs.spokeSubnets
