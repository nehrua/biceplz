targetScope = 'subscription'

param deploymentNameSuffix string = utcNow()
param hubNetworkName string = 'hub-vnet'
param hubAddressPrefixes array = [
  '10.0.0.0/24'
]
param managementNetworkName string = 'mgmt-vnet'
param managementAddressPrefixes array = [
  '10.0.1.0/24'
]
param avdNetworkName string = 'avd-vnet'
param avdAddressPrefixes array = [
  '10.1.0.0/16'
]

param gatewaySubnetPrefix string = '10.0.0.0/26'
param firewallSubnetPrefix string = '10.0.0.64/26'
param bastionSubnetPrefix string = '10.0.0.128/26'

param managementSubnets array = [
  {
    name: 'default-subnet'
    addressPrefix: '10.0.1.0/24'
  }
]

param avdSubnets array = [
  {
    name: 'genuser-subnet'
    addressPrefix: '10.1.0.0/20'
  }
  {
    name: 'devuser-subnet'
    addressPrefix: '10.1.16.0/23'
  }
  {
    name: 'powuser-subnet'
    addressPrefix: '10.1.18.0/23'
  }
]

var resourceGroups = [
  {
    name: 'network-rg'
    location: 'usgovvirginia'
    tags: {}
  }
  {
    name: 'security-rg'
    location: 'usgovvirginia'
    tags: {}
  }
]

// DEPLOY RESOURCE GROUPS
module rg 'modules/resource-groups.bicep' = {
  name: 'deploy-resourceGroups-${deploymentNameSuffix}'
  params: {
    resourceGroups: resourceGroups 
  }
}

// DEPLOY HUB NETWORK
module hubNetwork 'modules/hub-network.bicep' = {
  scope: resourceGroup(resourceGroups[0].name)
  name: 'deploy-hubVirtualNetwork-${deploymentNameSuffix}'
  params: {
    virtualNetworkName: hubNetworkName
    addressSpacePrefixes: hubAddressPrefixes
    gatewaySubnetPrefix: gatewaySubnetPrefix
    firewallSubnetPrefix: firewallSubnetPrefix
    bastionSubnetPrefix: bastionSubnetPrefix
  }
  dependsOn: [
    rg
  ]
}

// DEPLOY MANAGEMENT SPOKE
module managementNetwork 'modules/spoke-networks.bicep' = {
  scope: resourceGroup(resourceGroups[0].name)
  name: 'deploy-managementVirtualNetwork-${deploymentNameSuffix}'
  params: {
    virtualNetworkName: managementNetworkName
    addressSpacePrefixes: managementAddressPrefixes
    subnets: managementSubnets
  }
  dependsOn: [
    rg
  ]
}

// DEPLOY AVD SPOKE
module avdNetwork 'modules/spoke-networks.bicep' = {
  scope: resourceGroup(resourceGroups[0].name)
  name: 'deploy-avdVirtualNetwork-${deploymentNameSuffix}'
  params: {
    virtualNetworkName: avdNetworkName
    addressSpacePrefixes: avdAddressPrefixes
    subnets: avdSubnets
  }
  dependsOn: [
    rg
    managementNetwork
  ]
}

// VNET PEERINGS
module hubToMgmtPeering 'modules/virtual-network-peering.bicep' = {
  scope: resourceGroup(resourceGroups[0].name)
  name: 'deploy-hubMgmtPeering-${deploymentNameSuffix}'
  params: {
    allowForwardedTrafic: true
    allowGatewayTransit: true
    remoteVirtualNetworkResourceId: managementNetwork.outputs.id
    useRemoteGateways: false
    virtualNetworkName: hubNetworkName
    virtualNetworkPeerName: 'hub2Mgmt-peer'
  }
}

module hubToAvdPeering 'modules/virtual-network-peering.bicep' = {
  scope: resourceGroup(resourceGroups[0].name)
  name: 'deploy-hubAvdPeering-${deploymentNameSuffix}'
  params: {
    allowForwardedTrafic: true
    allowGatewayTransit: true
    remoteVirtualNetworkResourceId: avdNetwork.outputs.id
    useRemoteGateways: false
    virtualNetworkName: hubNetworkName
    virtualNetworkPeerName: 'hub2Avd-peer'
  }
}

module mgmtToHubPeering 'modules/virtual-network-peering.bicep' = {
  scope: resourceGroup(resourceGroups[0].name)
  name: 'deploy-mgmtHubPeering-${deploymentNameSuffix}'
  params: {
    allowForwardedTrafic: true
    allowGatewayTransit: false
    remoteVirtualNetworkResourceId: hubNetwork.outputs.id 
    useRemoteGateways: false              // CHANGE TO TRUE AFTER GW DEPLOYMENT
    virtualNetworkName: managementNetworkName
    virtualNetworkPeerName: 'mgmt2Hub-peer'
  }
}

module avdToHubPeering 'modules/virtual-network-peering.bicep' = {
  scope: resourceGroup(resourceGroups[0].name)
  name: 'deploy-avdHubPeering-${deploymentNameSuffix}'
  params: {
    allowForwardedTrafic: true
    allowGatewayTransit: false
    remoteVirtualNetworkResourceId: hubNetwork.outputs.id 
    useRemoteGateways: false              // CHANGE TO TRUE AFTER GW DEPLOYMENT
    virtualNetworkName: avdNetworkName
    virtualNetworkPeerName: 'avd2Hub-peer'
  }
}

// ENABLE NETWORK WATCHERS
module networkWatcher 'modules/network-watchers.bicep' = {
  scope: resourceGroup(resourceGroups[0].name)
  name: 'netwatch-nw'
}


