param hubName string = 'hub-vnet'
param spokeName string = 'spoke-vnet'
param location string = resourceGroup().location
param tags object = {}
param hubAddressPrefixes array = [
  '10.0.0.0/16'
]
param spokeAddressPrefixes array = [
  '10.1.0.0/16'
]
param hubDnsServers array = []
param spokeDnsServers array = []
param enableVmProtection bool = false
param deployHub bool
param deploySpoke bool
param networkSecurityGroupId string = ''
param routeTableId string = ''
param hubSubnets array = []

param spokeSubnets array = [
  {
    name: 'frontend-subnet'
    addressPrefix: '10.1.0.0/24'
  }
  {
    name: 'backend-subnet'
    addressPrefix: '10.0.1.0/24'
  }
]

resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = if (deployHub) {
  name: hubName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: hubAddressPrefixes
    }
    dhcpOptions: {
      dnsServers: hubDnsServers
    }
    enableVmProtection: enableVmProtection
    flowTimeoutInMinutes: 4     // default
    subnets: hubSubnets
  }
}

resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = if (deploySpoke) {
  name: spokeName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: spokeAddressPrefixes
    }
    dhcpOptions: {
      dnsServers: spokeDnsServers
    }
    enableVmProtection: enableVmProtection
    flowTimeoutInMinutes: 4     // default
    subnets: [for subnet in spokeSubnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: {
          id: networkSecurityGroupId
        }
        routeTable:  {
          id: routeTableId
        }
      }
    }]
  }
}

output hubId string = deployHub ? hubVirtualNetwork.id : ''
output hubName string = deployHub ? hubVirtualNetwork.name : ''
output spokeName string = deploySpoke ? spokeVirtualNetwork.name : ''
output spokeId string = deploySpoke ? spokeVirtualNetwork.id : ''
output hubSubnets array = deployHub ? hubVirtualNetwork.properties.subnets : []
output spokeSubnets array = deploySpoke ? spokeVirtualNetwork.properties.subnets : []
