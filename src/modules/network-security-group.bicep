
param name string = 'default-nsg'
param location string = resourceGroup().location
param tags object = {}

@description('Array of rules')
param rules array = []

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    securityRules: [for rule in rules: {
      name: rule.name
      properties: {
        priority: rule.priority
        direction: rule.direction
        access: rule.access
        protocol: rule.protocol
        sourcePortRange: rule.sourcePortRange
        destinationPortRanges: rule.destinationPortRanges
        sourceAddressPrefix: rule.sourceAddressPrefix
        destinationAddressPrefix: rule.destinationAddressPrefix
      }
    }]  
  }
}

output id string = networkSecurityGroup.id
output name string = networkSecurityGroup.name
