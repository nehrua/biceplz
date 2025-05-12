
param tags object = {}

@description('name of the dns private resolver')
param dnsResolverName string = 'hub-vnet-dnspr'
param location string = resourceGroup().location
param resolverVnetId string

param inboundEndpointName string = 'resolver-in'
param inboundSubnetId string

param outboundEndpointName string = 'resolver-out'
param outboundSubnetId string

@description('name of the vnet link that links outbound endpoint with forwarding rule set')
param resolvervnetlink string = 'resolver-hub-vnet-link'

@description('name of the forwarding ruleset')
param forwardingRulesetName string = 'resolver-forwardingRules'

@description('name of the forwarding rule name')
param forwardingRuleName string = 'contosocom-forwarder'

@description('the target domain name for the forwarding ruleset')
param DomainName string = 'contoso.com.'

@description('the list of target DNS servers ip address and the port number for conditional forwarding')
param targetDNS array = [
  {
    ipaddress: '10.0.0.4'
    port: 53
  }
  {
    ipaddress: '10.0.0.5'
    port: 53
  }
]


resource resolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: dnsResolverName
  location: location
  properties: {
    virtualNetwork: {
      id: resolverVnetId
    }
  }
}

resource inEndpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2023-07-01-preview' = {
  parent: resolver
  location: location
  name: inboundEndpointName
  properties: {
    ipConfigurations: [
      {
        subnet: {
          id: inboundSubnetId
        }
      }
    ]
  }
  tags: tags
}

resource outEndpoint 'Microsoft.Network/dnsResolvers/outboundEndpoints@2023-07-01-preview' = {
  parent: resolver
  location: location
  name: outboundEndpointName
  properties: {
    subnet: {
      id: outboundSubnetId
    }
  }
  tags: tags
}

resource fwruleSet 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' = {
  name: forwardingRulesetName
  location: location
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: outEndpoint.id
      }
    ]
  }
}

resource resolverLink 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2022-07-01' = {
  parent: fwruleSet
  name: resolvervnetlink
  properties: {
    virtualNetwork: {
      id: resolverVnetId
    }
  }
}

resource fwRules 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2022-07-01' = {
  parent: fwruleSet
  name: forwardingRuleName
  properties: {
    domainName: DomainName
    targetDnsServers: targetDNS
  }
}

output inboundEndpointIp string = inEndpoint.properties.ipConfigurations[0].privateIpAddress
