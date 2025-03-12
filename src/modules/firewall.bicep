
param deploymentNameSuffix string = utcNow()
param name string
param location string = resourceGroup().location

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param firewallSkuTier string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param firewallPolicySku string

param azureFirewallSubnetId string

param appRuleCollections array = [
  // {
  //   name: 'collection1'
  //   priority: 100
  //   rules: [
  //     {
  //       name: 'rule1'
  //       description: 'Allow access to www.microsoft.com'
  //       sourceAddresses: ['*']
  //       fqdnTags: []
  //       targetFqdns: ['www.microsoft.com']
  //       protocols: [
  //         {
  //           port: 80
  //           protocolType: 'Http'
  //         }
  //       ]
  //     }
  //     {
  //       name: 'rule2'
  //       description: 'Allow access to Windows Update'
  //       sourceAddresses: ['*']
  //       fqdnTags: ['WindowsUpdate']
  //       targetFqdns: []
  //       protocols: [
  //         {
  //           port: 443
  //           protocolType: 'Https'
  //         }
  //       ]
  //     }
  //   ]
  // }
  // {
  //   name: 'collection2'
  //   priority: 200
  //   rules: [
  //     {
  //       name: 'rule3'
  //       description: 'Allow access to www.example.com'
  //       sourceAddresses: ['*']
  //       fqdnTags: []
  //       targetFqdns: ['www.example.com']
  //       protocols: [
  //         {
  //           port: 80
  //           protocolType: 'Http'
  //         }
  //       ]
  //     }
  //   ]
  // }
]

param natRuleCollections array = [
  // {
  //   name: 'natCollection1'
  //   priority: 100
  //   rules: [
  //     {
  //       name: 'natRule1'
  //       description: 'NAT rule for web traffic'
  //       sourceAddresses: ['*']
  //       destinationAddresses: ['10.0.0.4']
  //       destinationPorts: ['80']
  //       translatedAddress: '10.0.0.5'
  //       translatedPort: '8080'
  //       protocols: ['TCP']
  //     }
  //   ]
  // }
]

param networkRuleCollections array = [
  {
    name: 'networkCollection1'
    priority: 100
    rules: [
      {
        name: 'networkRule1'
        description: 'Allow traffic to subnet'
        sourceAddresses: ['*']
        destinationAddresses: ['10.0.1.0/24']
        destinationPorts: ['*']
        protocols: ['TCP']
      }
    ]
  }
]

module publicIp 'public-ip.bicep' = {
  name: 'deploy-fwPip-${deploymentNameSuffix}'
  params: {
    name: 'fw-pip'
    publicIpAllocationMethod: 'Static'
    skuName: 'Standard'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: firewallSkuTier
    }
    ipConfigurations: [
      {
        name: 'configuration'
        properties: {
          subnet: {
            id: azureFirewallSubnetId
          }
          publicIPAddress: {
            id: publicIp.outputs.id
          }
        }
      }
    ]
  }
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: '${name}-policy'
  location: location
  properties: {
    sku: {
      tier: firewallPolicySku
    }
  }
}

resource appRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-05-01' = [for collection in appRuleCollections: {
  name: '${name}-${collection.name}'
  parent: firewallPolicy
  properties: {
    priority: collection.priority
    ruleCollections: [
      {
        name: collection.name
        priority: collection.priority
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [for rule in collection.rules: {
          name: rule.name
          description: rule.description
          ruleType: 'ApplicationRule'
          sourceAddresses: rule.sourceAddresses
          targetFqdns: rule.targetFqdns
          fqdnTags: rule.fqdnTags
          protocols: rule.protocols
        }]
      }
    ]
  }
}]

resource natRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-05-01' = [for collection in natRuleCollections: {
  name: '${name}-${collection.name}'
  parent: firewallPolicy
  properties: {
    priority: collection.priority
    ruleCollections: [
      {
        name: collection.name
        priority: collection.priority
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        action: {
          type: 'DNAT'
        }
        rules: [for rule in collection.rules: {
          name: rule.name
          description: rule.description
          ruleType: 'NatRule'
          sourceAddresses: rule.sourceAddresses
          destinationAddresses: rule.destinationAddresses
          destinationPorts: rule.destinationPorts
          translatedAddress: rule.translatedAddress
          translatedPort: rule.translatedPort
          ipProtocols: rule.protocols
        }]
      }
    ]
  }
}]

resource networkRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-05-01' = [for collection in networkRuleCollections: {
  name: '${name}-${collection.name}'
  parent: firewallPolicy
  properties: {
    priority: collection.priority
    ruleCollections: [
      {
        name: collection.name
        priority: collection.priority
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [for rule in collection.rules: {
          name: rule.name
          description: rule.description
          ruleType: 'NetworkRule'
          sourceAddresses: rule.sourceAddresses
          destinationAddresses: rule.destinationAddresses
          destinationPorts: rule.destinationPorts
          ipProtocols: rule.protocols
        }]
      }
    ]
  }
}]

output name string = firewall.name
output privateIpAddress string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output resourceId string = firewall.id
