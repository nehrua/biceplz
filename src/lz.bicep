targetScope = 'subscription'

// SUBSCRIPTIONS
param hubSubId string = 'ff22a377-a3cf-495d-b0c4-46c645a339eb'
param avdSpokeSubId string = 'ff22a377-a3cf-495d-b0c4-46c645a339eb'
param mgmtSpokeSubId string = 'ff22a377-a3cf-495d-b0c4-46c645a339eb'

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
param natGatewayName string = 'hub-ngw'

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
    location: 'eastus'
    tags: {}
  }
  {
    name: 'security-rg'
    location: 'eastus'
    tags: {}
  }
]

// DEPLOY RESOURCE GROUPS
module hubRgs 'modules/resource-groups.bicep' = {
  scope: subscription(hubSubId)
  name: 'deploy-hub-resourceGroups-${deploymentNameSuffix}'
  params: {
    resourceGroups: resourceGroups 
  }
}

module avdRgs 'modules/resource-groups.bicep' = {
  scope: subscription(avdSpokeSubId)
  name: 'deploy-avd-resourceGroups-${deploymentNameSuffix}'
  params: {
    resourceGroups: resourceGroups 
  }
}

module mgmtRgs 'modules/resource-groups.bicep' = {
  scope: subscription(mgmtSpokeSubId)
  name: 'deploy-mgmt-resourceGroups-${deploymentNameSuffix}'
  params: {
    resourceGroups: resourceGroups 
  }
}

// DEPLOY HUB NETWORK
module hubNetwork 'modules/hub-network.bicep' = {
  scope: resourceGroup(hubSubId, resourceGroups[0].name)
  name: 'deploy-hubVirtualNetwork-${deploymentNameSuffix}'
  params: {
    virtualNetworkName: hubNetworkName
    addressSpacePrefixes: hubAddressPrefixes
    gatewaySubnetPrefix: gatewaySubnetPrefix
    firewallSubnetPrefix: firewallSubnetPrefix
    bastionSubnetPrefix: bastionSubnetPrefix
    natGatewayName: natGatewayName
  }
  dependsOn: [
    hubRgs
  ]
}

// DEPLOY MANAGEMENT SPOKE
module managementNetwork 'modules/spoke-networks.bicep' = {
  scope: resourceGroup(mgmtSpokeSubId, resourceGroups[0].name)
  name: 'deploy-managementVirtualNetwork-${deploymentNameSuffix}'
  params: {
    virtualNetworkName: managementNetworkName
    addressSpacePrefixes: managementAddressPrefixes
    subnets: managementSubnets
  }
  dependsOn: [
    mgmtRgs
  ]
}

// DEPLOY AVD SPOKE
module avdNetwork 'modules/spoke-networks.bicep' = {
  scope: resourceGroup(avdSpokeSubId, resourceGroups[0].name)
  name: 'deploy-avdVirtualNetwork-${deploymentNameSuffix}'
  params: {
    virtualNetworkName: avdNetworkName
    addressSpacePrefixes: avdAddressPrefixes
    subnets: avdSubnets
  }
  dependsOn: [
    avdRgs
  ]
}

// VNET PEERINGS
module hubToMgmtPeering 'modules/virtual-network-peering.bicep' = {
  scope: resourceGroup(hubSubId, resourceGroups[0].name)
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
  scope: resourceGroup(hubSubId, resourceGroups[0].name)
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
  scope: resourceGroup(mgmtSpokeSubId, resourceGroups[0].name)
  name: 'deploy-mgmtHubPeering-${deploymentNameSuffix}'
  params: {
    allowForwardedTrafic: true
    allowGatewayTransit: false
    remoteVirtualNetworkResourceId: hubNetwork.outputs.id 
    useRemoteGateways: false
    virtualNetworkName: managementNetworkName
    virtualNetworkPeerName: 'mgmt2Hub-peer'
  }
}

module avdToHubPeering 'modules/virtual-network-peering.bicep' = {
  scope: resourceGroup(avdSpokeSubId, resourceGroups[0].name)
  name: 'deploy-avdHubPeering-${deploymentNameSuffix}'
  params: {
    allowForwardedTrafic: true
    allowGatewayTransit: false
    remoteVirtualNetworkResourceId: hubNetwork.outputs.id 
    useRemoteGateways: false
    virtualNetworkName: avdNetworkName
    virtualNetworkPeerName: 'avd2Hub-peer'
  }
}


// ENABLE NETWORK WATCHERS (don't deploy after first run)
// module networkWatcher 'modules/network-watchers.bicep' = {
//   scope: resourceGroup(resourceGroups[0].name)
//   name: 'deploy-hubSub-netwatcher-${deploymentNameSuffix}'
//   params: {
//     name: 'netwatch-${hubSubId}-nw'
//   }
// }


