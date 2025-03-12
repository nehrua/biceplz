
param deploymentNameSuffix string = utcNow()
param virtualNetworkName string
param addressSpacePrefixes array = [
  '10.0.0.0/16'
]
param dnsServers array = []
param gatewaySubnetPrefix string = '10.0.0.0/26'
param firewallSubnetPrefix string = '10.0.0.64/26'
param bastionSubnetPrefix string = '10.0.0.128/26'
param deployAzureFirewall bool = true
param deployHub bool = true
param deployBastion bool = true
param bastionHostName string = 'hub-bast'
param deployNatGateway bool = true
param natGatewayName string = 'hub-ngw'
param prefixLength int = 31

var bastionNsgRules = [
  {
    name: 'AllowHttpsInBound'
    priority: 120
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRanges: ['443']
    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
  }
  {
    name: 'AllowGatewayManagerInBound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    sourceAddressPrefix: 'GatewayManager'
    destinationPortRanges: ['443']
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 130
    direction: 'Inbound'
  }
  {
    name: 'AllowLoadBalancerInBound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    sourceAddressPrefix: 'AzureLoadBalancer'
    destinationPortRanges: ['443']
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 140
    direction: 'Inbound'
  }
  {
    name: 'AllowBastionHostCommunicationInBound'
    protocol: '*'
    sourcePortRange: '*'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationPortRanges: [
      '8080'
      '5701'
    ]
    destinationAddressPrefix: 'VirtualNetwork'
    access: 'Allow'
    priority: 150
    direction: 'Inbound'
  }
  {
    name: 'AllowSshRdpOutBound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    sourceAddressPrefix: '*'
    destinationPortRanges: [
      '22'
      '3389'
    ]
    destinationAddressPrefix: 'VirtualNetwork'
    access: 'Allow'
    priority: 120
    direction: 'Outbound'
  }
  {
    name: 'AllowAzureCloudCommunicationOutBound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    sourceAddressPrefix: '*'
    destinationPortRanges: ['443']
    destinationAddressPrefix: 'AzureCloud'
    access: 'Allow'
    priority: 130
    direction: 'Outbound'
  }
  {
    name: 'AllowBastionHostCommunicationOutBound'
    protocol: '*'
    sourcePortRange: '*'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationPortRanges: [
      '8080'
      '5701'
    ]
    destinationAddressPrefix: 'VirtualNetwork'
    access: 'Allow'
    priority: 140
    direction: 'Outbound'
  }
  {
    name: 'AllowGetSessionInformationOutBound'
    protocol: '*'
    sourcePortRange: '*'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: 'Internet'
    destinationPortRanges: [
      '80'
      '443'
    ]
    access: 'Allow'
    priority: 150
    direction: 'Outbound'
  }
]

var subnets = union([
  {
    name: 'GatewaySubnet'
    properties: {
      addressPrefix: gatewaySubnetPrefix
    }
  }
], deployAzureFirewall ? [
  {
    name: 'AzureFirewallSubnet'
    properties: {
      addressPrefix: firewallSubnetPrefix
      natGateway: {
        id: natGateway.outputs.id
      }
    }
  } 
] : [], deployBastion ? [
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefix: bastionSubnetPrefix
      networkSecurityGroup: {
        id: bastionNsg.outputs.id
      }
    }
  }
] : [])

// Deploy default NSG
module defaultNsg 'network-security-group.bicep' = {
  name: 'deploy-defaultNsg-${virtualNetworkName}-${deploymentNameSuffix}'
  params: {
    name: '${virtualNetworkName}-default-nsg'
  }
}

// Deploy Bastion NSG
module bastionNsg 'network-security-group.bicep' = if (deployBastion) {
  name: 'deploy-bastionNsg-${deploymentNameSuffix}'
  params: {
    name: 'bastion-nsg'
    rules: bastionNsgRules
  }
}

// Quad Zero route table
module routeTable 'route-table.bicep' = {
  name: 'deploy-${virtualNetworkName}-routetable-${deploymentNameSuffix}'
  params: {
    name: '${virtualNetworkName}-rt'
  }
}

module virtualNetwork 'virtual-network.bicep' = {
  name: 'deploy-${virtualNetworkName}-${deploymentNameSuffix}'
  params: {
    deployHub: deployHub
    deploySpoke: false
    hubName: virtualNetworkName
    hubAddressPrefixes: addressSpacePrefixes
    hubDnsServers: dnsServers
    hubSubnets: subnets
  }
}

// Azure Firewall must be in same resource group as virtual network
module firewall 'firewall.bicep' = if (deployAzureFirewall) {
  name: 'deploy-firewall-${deploymentNameSuffix}'
  params: {
    name: 'hub-fw'
    firewallSkuTier: 'Premium'
    azureFirewallSubnetId: virtualNetwork.outputs.hubSubnets[1].id
    firewallPolicySku: 'Premium'
  }
}

module bastion 'bastion-host.bicep' = if (deployBastion) {
  name: 'deploy-bastion-${deploymentNameSuffix}'
  params: {
    name: bastionHostName
    subnetId: virtualNetwork.outputs.hubSubnets[2].id
    virtualNetworkId: virtualNetwork.outputs.hubId
  }
}

// Link to AzureFirewallSubnet manually
module natGateway 'nat-gateway.bicep' = if (deployNatGateway) {
  name: 'deploy-natGateway-${deploymentNameSuffix}'
  params: {
    name: natGatewayName
    prefixLength: prefixLength
  }
}

output firewallName string = deployAzureFirewall ? firewall.outputs.name : ''
output firewallPrivateIPAddress string = deployAzureFirewall ? firewall.outputs.privateIpAddress : ''
output firewallId string = deployAzureFirewall ? firewall.outputs.resourceId : ''
output defaultNsgName string = defaultNsg.outputs.name
output defaultNsgId string = defaultNsg.outputs.id
output bastionNsgName string = bastionNsg.outputs.name
output bastionNsgId string = bastionNsg.outputs.id
output azureFirewallSubnetId string = virtualNetwork.outputs.hubSubnets[1].id
output bastionSubnetId string = virtualNetwork.outputs.hubSubnets[2].id
output id string = virtualNetwork.outputs.hubId
output routeTableId string = routeTable.outputs.id
output natGatewayd string = natGateway.outputs.id
