
module hubnetwork 'modules/hub-network.bicep' = {
  name: 'deploy-hub-${deploymentNameSuffix}'
  params: {
    location: location
    tags: tags
    azureGatewaySubnetAddressPrefix: azureGatewaySubnetAddressPrefix
    bastionHostNetworkSecurityGroup:  
    bastionHostSubnetAddressPrefix: bastionHostSubnetAddressPrefix
    deployAzureGatewaySubnet: deployGatewaySubnet
    deployBastion: deployBastion
    deployNetworkWatcher: deployNetworkWatcher
    dnsServers: dnsServers
    enableProxy: enableProxy
    firewallClientPrivateIpAddress:  
    firewallClientPublicIPAddressAvailabilityZones: 
    firewallClientPublicIPAddressName: 
    firewallClientSubnetAddressPrefix: firewallClientSubnetAddressPrefix
    firewallIntrusionDetectionMode: 
    firewallManagementPublicIPAddressAvailabilityZones: 
    firewallManagementPublicIPAddressName: 
    firewallManagementSubnetAddressPrefix: firewallManagementSubnetAddressPrefix
    firewallName: 
    firewallPolicyName: 
    firewallSkuTier: 
    firewallSupernetIPAddress: 
    firewallThreatIntelMode: 
    mlzTags: {}
    networkSecurityGroupName: 
    networkSecurityGroupRules: 
    networkWatcherName: 
    routeTableName: 
    subnetAddressPrefix: hubSubnetAddressPrefix
    subnetName: 
    vNetDnsServers: 
    virtualNetworkAddressPrefix: hubVirtualNetworkAddressPrefix
    virtualNetworkName: 
  }
}
