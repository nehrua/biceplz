
param deploymentNameSuffix string = utcNow()
param virtualNetworkName string
param addressSpacePrefixes array = [
  '10.0.0.0/16'
]
param dnsServers array = []
param gatewaySubnetPrefix string = '10.0.0.0/24'
param firewallSubnetPrefix string = '10.1.0.0/24'
param bastionSubnetPrefix string = '10.2.0.0/24'
param resolverInboundSubnetPrefix string = '10.3.0.0/28'
param resolverOutboundSubnetPrefix string = '10.3.0.16/28'
param deployAzureFirewall bool = true
param firewallName string = 'hub-fw'
param deployHub bool = true
param deployBastion bool = true
param bastionHostName string = 'hub-bast'
param deployNatGateway bool = true
param natGatewayName string = 'hub-ngw'
param natGwIpPrefexName string = 'hub-ngw-ippre'
param natGwPrefixLength int = 31
param deployResolver bool = true
param deployResolverInboundEndpoint bool = true
param deployResolverOutboundEndpoint bool = true

// Azure FW ruleset params
param avdSubnetCidrs array

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
  ], 
  deployAzureFirewall ? [
    {
      name: 'AzureFirewallSubnet'
      properties: {
        addressPrefix: firewallSubnetPrefix
        natGateway: {
          id: natGateway.outputs.id
        }
      }
    } 
  ] : [], 
  deployBastion ? [
    {
      name: 'AzureBastionSubnet'
      properties: {
        addressPrefix: bastionSubnetPrefix
        networkSecurityGroup: {
          id: bastionNsg.outputs.id
        }
      }
    }
  ] : [],
  deployResolverInboundEndpoint ? [
    {
      name: 'resolver-inbound-snet'
      properties: {
        addressPrefix: resolverInboundSubnetPrefix
        delegations: [
          {
            name: 'Microsoft.Network.dnsResolvers'
            properties: {
              serviceName: 'Microsoft.Network/dnsResolvers'
            }
          }
        ]
        networkSecurityGroup: {
          id: defaultNsg.outputs.id
        }
      }
    }
  ] : [],
  deployResolverOutboundEndpoint ? [
    {
      name: 'resolver-outbound-snet'
      properties: {
        addressPrefix: resolverOutboundSubnetPrefix
        delegations: [
          {
            name: 'Microsoft.Network.dnsResolvers'
            properties: {
              serviceName: 'Microsoft.Network/dnsResolvers'
            }
          }
        ]
        networkSecurityGroup: {
          id: defaultNsg.outputs.id
        }
      }
    }
  ] : []  
)

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
    name: 'bastion-va-nsg'
    rules: bastionNsgRules
  }
}

// Quad Zero route table
module routeTable 'route-table.bicep' = {
  name: 'deploy-${virtualNetworkName}-routetable-${deploymentNameSuffix}'
  params: {
    name: '${virtualNetworkName}-quadz-rt'
  }
}

// Deploy hub network
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
    name: firewallName
    firewallSkuTier: 'Premium'
    azureFirewallSubnetId: virtualNetwork.outputs.hubSubnets[1].id
    firewallPolicySku: 'Premium'
    avdSubnetAddresses: avdSubnetCidrs
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
    ipPrefixName: natGwIpPrefexName
    prefixLength: natGwPrefixLength
  }
}

module dnsresolver 'dns-resolvers.bicep' = if (deployResolver) {
  name: 'deploy-resolver-${deploymentNameSuffix}'
  params: {
    resolverVnetId: virtualNetwork.outputs.hubId
    inboundSubnetId: virtualNetwork.outputs.hubSubnets[3].id
    outboundSubnetId: virtualNetwork.outputs.hubSubnets[4].id
  }
}

output hubVnetId string = virtualNetwork.outputs.hubId
output azureFirewallSubnetId string = virtualNetwork.outputs.hubSubnets[1].id
output bastionSubnetId string = virtualNetwork.outputs.hubSubnets[2].id
output resolverInboundEndpointSubnetId string = virtualNetwork.outputs.hubSubnets[3].id
output resolverOutboundEndpointSubnetId string = virtualNetwork.outputs.hubSubnets[4].id
output firewallName string = deployAzureFirewall ? firewall.outputs.name : ''
output firewallPrivateIPAddress string = deployAzureFirewall ? firewall.outputs.privateIpAddress : ''
output firewallId string = deployAzureFirewall ? firewall.outputs.resourceId : ''
output defaultNsgName string = defaultNsg.outputs.name
output defaultNsgId string = defaultNsg.outputs.id
output bastionNsgName string = bastionNsg.outputs.name
output bastionNsgId string = bastionNsg.outputs.id
output routeTableId string = routeTable.outputs.id
output natGatewayId string = natGateway.outputs.id
