targetScope = 'subscription'

param location string = 'eastus'

// SUBSCRIPTIONS
param hubSubId string = 'ff22a377-a3cf-495d-b0c4-46c645a339eb'
param avdSpokeSubId string = 'ff22a377-a3cf-495d-b0c4-46c645a339eb'
param mgmtSpokeSubId string = 'ff22a377-a3cf-495d-b0c4-46c645a339eb'

param deploymentNameSuffix string = utcNow()

// HUB Network Params
param hubNetworkName string = 'hub-vnet'
param hubAddressPrefixes array = [
  '10.0.0.0/24'
]

param gatewaySubnetPrefix string = '10.0.0.0/26'
param firewallSubnetPrefix string = '10.0.0.64/26'
param bastionSubnetPrefix string = '10.0.0.128/26'
param deployAzureFirewall bool = true
param firewallName string = 'hub-fw'
param deployHub bool = true
param deployBastion bool = true
param bastionHostName string = 'hub-bast'
param deployNatGateway bool = true
param natGatewayName string = 'hub-ngw'
param natGwPrefixLength int = 31

// Management Spoke Network Params
param managementNetworkName string = 'mgmt-vnet'
param managementAddressPrefixes array = [
  '10.0.1.0/24'
]


// AVD Spoke Network Params
param avdNetworkName string = 'avd-vnet'
param avdAddressPrefixes array = [
  '10.1.0.0/16'
]

param managementSubnets array = [
  {
    name: 'default-subnet'
    addressPrefix: '10.0.1.0/24'
  }
]

param avdSubnets array = [
  {
    name: 'genuser-snet'
    addressPrefix: '10.1.0.0/20'
  }
  {
    name: 'devuser-snet'
    addressPrefix: '10.1.16.0/23'
  }
  {
    name: 'powuser-snet'
    addressPrefix: '10.1.18.0/23'
  }
]

// Resource Groups
var hubResourceGroups = [
  {
    name: 'hub-network-rg'
    location: location
    tags: {}
  }
]

var mgmtResourceGroups = [
  {
    name: 'mgmt-network-rg'
    location: location
    tags: {}
  }
 ]
 
var avdResourceGroups = [
 {
   name: 'avd-network-rg'
   location: location
   tags: {}
 }
]

// DEPLOY RESOURCE GROUPS
module hubRgs 'modules/resource-groups.bicep' = {
  scope: subscription(hubSubId)
  name: 'deploy-hub-resourceGroups-${deploymentNameSuffix}'
  params: {
    resourceGroups: hubResourceGroups 
  }
}

module mgmtRgs 'modules/resource-groups.bicep' = {
  scope: subscription(mgmtSpokeSubId)
  name: 'deploy-mgmt-resourceGroups-${deploymentNameSuffix}'
  params: {
    resourceGroups: mgmtResourceGroups 
  }
}

module avdRgs 'modules/resource-groups.bicep' = {
  scope: subscription(avdSpokeSubId)
  name: 'deploy-avd-resourceGroups-${deploymentNameSuffix}'
  params: {
    resourceGroups: avdResourceGroups 
  }
}

// DEPLOY HUB NETWORK
module hubNetwork 'modules/hub-network.bicep' = {
  scope: resourceGroup(hubSubId, hubResourceGroups[0].name)
  name: 'deploy-hubVirtualNetwork-${deploymentNameSuffix}'
  params: {
    deployHub:deployHub
    virtualNetworkName: hubNetworkName
    addressSpacePrefixes: hubAddressPrefixes
    gatewaySubnetPrefix: gatewaySubnetPrefix
    deployAzureFirewall: deployAzureFirewall
    firewallName: firewallName
    firewallSubnetPrefix: firewallSubnetPrefix
    deployBastion: deployBastion
    bastionHostName: bastionHostName
    bastionSubnetPrefix: bastionSubnetPrefix
    deployNatGateway: deployNatGateway
    natGatewayName: natGatewayName
    natGwPrefixLength: natGwPrefixLength
  }
  dependsOn: [
    hubRgs
  ]
}

// Deploy Management Spoke
module mgmtNetwork 'modules/spoke-networks.bicep' = {
  scope: resourceGroup(avdSpokeSubId, mgmtResourceGroups[0].name)
  name: 'deploy-mgmtVirtualNetwork-${deploymentNameSuffix}'
  params: {
    virtualNetworkName: managementNetworkName
    addressSpacePrefixes: managementAddressPrefixes
    subnets: managementSubnets
  }
  dependsOn: [
    avdRgs
  ]
}

// DEPLOY AVD SPOKE
module avdNetwork 'modules/spoke-networks.bicep' = {
  scope: resourceGroup(avdSpokeSubId, avdResourceGroups[0].name)
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

// Deploy VNET PEERINGS
module hubToAvdPeering 'modules/virtual-network-peering.bicep' = {
  scope: resourceGroup(hubSubId, hubResourceGroups[0].name)
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

module hubToMgmtPeering 'modules/virtual-network-peering.bicep' = {
  scope: resourceGroup(hubSubId, hubResourceGroups[0].name)
  name: 'deploy-hubMgmtPeering-${deploymentNameSuffix}'
  params: {
    allowForwardedTrafic: true
    allowGatewayTransit: true
    remoteVirtualNetworkResourceId: mgmtNetwork.outputs.id
    useRemoteGateways: false
    virtualNetworkName: hubNetworkName
    virtualNetworkPeerName: 'hub2Mgmt-peer'
  }
}

module avdToHubPeering 'modules/virtual-network-peering.bicep' = {
  scope: resourceGroup(avdSpokeSubId, avdResourceGroups[0].name)
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

module mgmtToHubPeering 'modules/virtual-network-peering.bicep' = {
  scope: resourceGroup(avdSpokeSubId, mgmtResourceGroups[0].name)
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

// // ENABLE NETWORK WATCHERS (don't deploy after first run)
// module networkWatcher 'modules/network-watchers.bicep' = {
//   scope: resourceGroup(hubResourceGroups[0].name)
//   name: 'deploy-hubSub-netwatcher-${deploymentNameSuffix}'
//   params: {
//     name: 'netwatch-${hubSubId}-nw'
//   }
// }


