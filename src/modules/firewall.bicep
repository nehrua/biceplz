
param deploymentNameSuffix string = utcNow()
param name string
param location string = resourceGroup().location
param avdVirtualNetworkCidrs array
param avdAdminPoolCidrs array
param avdDevPoolCidrs array

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

// param appRuleCollections array = [
//   {
//     name: 'App-AVD-Outbound'
//     priority: 10200
//     rules: [
//       {
//         name: 'TelemetryService'
//         ipProtocols: [
//           {
//             protocolType: 'Https'
//             port: 443
//           }
//         ]
//         targetFqdns: [
//           '*.events.data.microsoft.com'
//         ]
//         targetUrls: []
//         terminateTLS: false
//         sourceAddresses: avdSubnetCidrs
//         destinationAddresses: []
//         sourceIpGroups: []
//       }
//       {
//         name: 'WindowsUpdate'
//         ipProtocols: [
//           {
//             protocolType: 'Https'
//             port: 443
//           }
//         ]
//         fqdnTags: [
//           'WindowsUpdate'
//         ]
//         terminateTLS: false
//         sourceAddresses: avdSubnetCidrs
//         destinationAddresses: []
//         sourceIpGroups: []
//       }
//       {
//         name: 'UpdatesForOneDrive'
//         ipProtocols: [
//           {
//             protocolType: 'Https'
//             port: 443
//           }
//         ]
//         targetFqdns: [
//           '*.sfx.ms'
//         ]
//         terminateTLS: false
//         sourceAddresses: avdSubnetCidrs
//         destinationAddresses: []
//         sourceIpGroups: []
//       }
//       {
//         name: 'DigicertCRL'
//         ipProtocols: [
//           {
//             protocolType: 'Http'
//             port: 80
//           }
//           {
//             protocolType: 'Https'
//             port: 443
//           }
//         ]
//         targetFqdns: [
//           '*.digicert.com'
//         ]
//         terminateTLS: false
//         sourceAddresses: avdSubnetCidrs
//         destinationAddresses: []
//         sourceIpGroups: []
//       }
//       {
//         name: 'AzureDNSresolution'
//         ipProtocols: [
//           {
//             protocolType: 'Https'
//             port: 443
//           }
//         ]
//         targetFqdns: [
//           '*.azure-dns.com'
//           '*.azure-dns.net'
//         ]
//         terminateTLS: false
//         sourceAddresses: avdSubnetCidrs
//       }
//       {
//         name: 'WindowsDiagnostics'
//         ipProtocols: [
//           {
//             protocolType: 'Https'
//             port: 443
//           }
//         ]
//         fqdnTags: [
//           'WindowsDiagnostics'
//         ]
//         webCategories: []
//         targetFqdns: []
//         targetUrls: []
//         terminateTLS: false
//         sourceAddresses: avdSubnetCidrs
//         destinationAddresses: []
//         sourceIpGroups: []
//       }
//     ]
//   }
//   {
//     name: 'collection2'
//     priority: 200
//     rules: [
//       {
//         name: 'rule3'
//         // description: 'Allow access to www.example.com'
//         sourceAddresses: ['*']
//         fqdnTags: []
//         targetFqdns: ['www.example.com']
//         ipProtocols: [
//           {
//             port: 80
//             protocolType: 'Http'
//           }
//         ]
//       }
//     ]
//   }
// ]

// param natRuleCollections array = [
//   // {
//   //   name: 'natCollection1'
//   //   priority: 100
//   //   rules: [
//   //     {
//   //       name: 'natRule1'
//   //       description: 'NAT rule for web traffic'
//   //       sourceAddresses: ['*']
//   //       destinationAddresses: ['10.0.0.4']
//   //       destinationPorts: ['80']
//   //       translatedAddress: '10.0.0.5'
//   //       translatedPort: '8080'
//   //       ipProtocols: ['TCP']
//   //     }
//   //   ]
//   // }
// ]

// param networkRuleCollections array = [
//   {
//     name: 'Network-AVD-Outbound'
//     priority: 10100
//     type: 'Allow'
//     rules: [
//       {
//         name: 'AVD Service Traffic'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: [
//           'WindowsVirtualDesktop'
//         ]
//         destinationIpGroups: []
//         destinationFqdns: []
//         destinationPorts: [
//           '443'
//         ]
//       }
//       {
//         name: 'Azure Monitor Tagged Traffic'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: [
//           'AzureMonitor'
//         ]
//         destinationIpGroups: []
//         destinationFqdns: []
//         destinationPorts: [
//           '443'
//         ]
//       }
//       {
//         name: 'Agent Monitor FQDN Traffic'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: []
//         destinationIpGroups: []
//         destinationFqdns: [
//           'gcs.prod.monitoring.${environment().suffixes.storage}'
//         ]
//         destinationPorts: [
//           '443'
//         ]
//       }
//       {
//         name: 'Azure Marketplace'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: [
//           'AzureFrontDoor.Frontend'
//         ]
//         destinationIpGroups: []
//         destinationFqdns: []
//         destinationPorts: [
//           '443'
//         ]
//       }
//       {
//         name: 'Windows activation'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: []
//         destinationIpGroups: []
//         destinationFqdns: [
//           'kms.${environment().suffixes.storage}'
//         ]
//         destinationPorts: [
//           '1688'
//         ]
//       }
//       {
//         name: 'Azure Windows activation'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: []
//         destinationIpGroups: []
//         destinationFqdns: [
//           'azkms.${environment().suffixes.storage}'
//         ]
//         destinationPorts: [
//           '1688'
//         ]
//       }
//       {
//         name: 'Agent and SXS Stack Updates'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: []
//         destinationIpGroups: []
//         destinationFqdns: [
//           'mrsglobalsteus2prod.blob.${environment().suffixes.storage}'
//         ]
//         destinationPorts: [
//           '443'
//         ]
//       }
//       {
//         name: 'Azure Portal Support'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: []
//         destinationIpGroups: []
//         destinationFqdns: [
//           'wvdportalstorageblob.blob.${environment().suffixes.storage}'
//         ]
//         destinationPorts: [
//           '443'
//         ]
//       }
//       {
//         name: 'Certificate CRL OneOCSP'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: []
//         destinationIpGroups: []
//         destinationFqdns: [
//           'oneocsp.microsoft.com'
//         ]
//         destinationPorts: [
//           '80'
//         ]
//       }
//       {
//         name: 'Certificate CRL MicrosoftDotCom'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: []
//         destinationIpGroups: []
//         destinationFqdns: [
//           'www.microsoft.com'
//         ]
//         destinationPorts: [
//           '80'
//         ]
//       }
//       {
//         name: 'Authentication to Microsoft Online Services'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: []
//         destinationIpGroups: []
//         destinationFqdns: [
//           replace(replace(environment().authentication.loginEndpoint, 'https://', ''), '/', '')
//         ]
//         destinationPorts: [
//           '443'
//         ]
//       }
//       {
//         name: 'NTP'
//         ipProtocols: [
//           'TCP'
//           'UDP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         destinationFqdns: [
//           'time.windows.com'
//         ]
//         destinationPorts: [
//           '123'
//         ]
//       }
//       {
//         name: 'SigninToMSOL365'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         destinationFqdns: [
//           replace(replace(environment().authentication.loginEndpoint, 'https://', ''), '/', '')
//         ]
//         destinationPorts: [
//           '443'
//         ]
//       }
//       {
//         name: 'DetectOSconnectedToInternet'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         destinationFqdns: [
//           'www.msftconnecttest.com'
//         ]
//         destinationPorts: [
//           '443'
//         ]
//       }
//       {
//         name: 'RDP Shortpath Server Endpoint'
//         ipProtocols: [
//           'UDP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         destinationAddresses: [
//           '*'
//         ]
//         destinationPorts: [
//           '49152-65535'
//         ]
//       }
//       {
//         name: 'STUN/TURN UDP'
//         ipProtocols: [
//           'UDP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         destinationAddresses: [
//           '20.202.0.0/16'
//         ]
//         destinationPorts: [
//           '3478'
//         ]
//       }
//       {
//         name: 'STUN/TURN TCP'
//         ipProtocols: [
//           'TCP'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         destinationAddresses: [
//           '20.202.0.0/16'
//         ]
//         destinationPorts: [
//           '443'
//         ]
//       }
//       {
//         name: 'Allow All Outbound'
//         ipProtocols: [
//           'Any'
//         ]
//         sourceAddresses: avdSubnetCidrs
//         sourceIpGroups: []
//         destinationAddresses: [
//           '*'
//         ]
//         destinationIpGroups: []
//         destinationFqdns: []
//         destinationPorts: [
//           '*'
//         ]
//       }
//     ]
//   }
// ]

module publicIp 'public-ip.bicep' = {
  name: 'deploy-fwPip-${deploymentNameSuffix}'
  params: {
    name: '${name}-pip'
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
  name: '${name}-afwp'
  location: location
  properties: {
    sku: {
      tier: firewallPolicySku
    }
    threatIntelMode: 'Alert'
  }
}

// COMMENTED NETWORK RULES WITH FQDN...ERROR DEPLOYING SAID REQUIRED DNS PROXY BE ENABLED
resource ruleCollectionGroup_AVD_Outbound 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-03-01' = {
  parent: firewallPolicy
  name: 'AVD-Outbound'
  properties: {
    priority: 10000
    ruleCollections: [
      {
        action: {
          type: 'Allow'
        }
        name: 'AVD-Baseline-Outbound'
        priority: 10100
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        rules: [
          //NETWORK RULES
          {
            ruleType: 'NetworkRule'
            name: 'Other Azure Services'    //https://learn.microsoft.com/en-us/azure/virtual-network/service-tags-overview
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: avdVirtualNetworkCidrs
            sourceIpGroups: []
            destinationAddresses: [
              'AzureActiveDirectory'              // Entra
              'AzureAdvancedThreatProtection'     // Defender for Identity
              'AzureBackup'                       // Azure Backup
              'AzureCloud'                        // Azure Datacenters
              'AzureFrontDoor.Frontend'           // Outbound access to FrontDoor public endpoint
              'AzureFrontDoor.Backend'            // **Inbound FrontDoor access to Frontdoor customer managed services
              'AzureFrontDoor.FirstParty'         // **Azure Intneral service access to a subset of FrontDoor services
              'AzureInformationProtection'        // **Allows management of security rules related to AIP
              'AzureKeyVault'                     // Azure KeyVault
              'AzureLoadBalancer'                 // Azure Load Balancer health probes and mgmt traffic
              'AzureMonitor'                      // Azure Monitor tagged traffic
              'AzureResourceManager'              // Azure Portal and API access
              'AzurePlatformDNS'                  // Azure DNS
              'AzurePlatformIDMS'                 // Azure Instance Metadata Service
              'AzureSentinel'                     // Microsoft Sentinel
              'AzureSiteRecovery'                 // Azure Site Recovery (DR)
              'GuestAndHybridManagement'          // Azure Automation and Guest Configuration
              'LogicApps'                         // Logic Apps
              'M365ManagementActivityApi'         // O365 Management API
              'MicrosoftDefenderForEndpoint'      // MDE onboarding
              'OneDSCollector'                    // MDE cyber and diagnostic data
              'Storage'                           // Storage service access
              'WindowsVirtualDesktop'             // AVD Service Traffic
              'VirtualNetwork'                    // Managing traffic between Virtual Networks
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Other Azure Services'    //https://learn.microsoft.com/en-us/azure/virtual-network/service-tags-overview
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: avdVirtualNetworkCidrs
            sourceIpGroups: []
            destinationAddresses: [
              'AzurePlatformLKM'                  // Windows licensing or KMS
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '1688'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'RDP Shortpath Server Endpoint'
            ipProtocols: [
              'UDP'
            ]
            sourceAddresses: avdVirtualNetworkCidrs
            destinationAddresses: [
              '*'
            ]
            destinationPorts: [
              '49152-65535'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'STUN/TURN UDP'
            ipProtocols: [
              'UDP'
            ]
            sourceAddresses: avdVirtualNetworkCidrs
            destinationAddresses: [
              '20.202.0.0/16'
            ]
            destinationPorts: [
              '3478'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'STUN/TURN TCP'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: avdVirtualNetworkCidrs
            destinationAddresses: [
              '20.202.0.0/16'
            ]
            destinationPorts: [
              '443'
            ]
          }
          // {
          //   ruleType: 'NetworkRule'
          //   name: 'Agent Monitor FQDN Traffic'
          //   ipProtocols: [
          //     'TCP'
          //   ]
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   sourceIpGroups: []
          //   destinationAddresses: []
          //   destinationIpGroups: []
          //   destinationFqdns: [
          //     'gcs.prod.monitoring.${environment().suffixes.storage}'
          //   ]
          //   destinationPorts: [
          //     '443'
          //   ]
          // }
          // {
          //   ruleType: 'NetworkRule'
          //   name: 'Windows activation'
          //   ipProtocols: [
          //     'TCP'
          //   ]
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   sourceIpGroups: []
          //   destinationAddresses: []
          //   destinationIpGroups: []
          //   destinationFqdns: [
          //     'kms.${environment().suffixes.storage}'
          //   ]
          //   destinationPorts: [
          //     '1688'
          //   ]
          // }
          // {
          //   ruleType: 'NetworkRule'
          //   name: 'Azure Windows activation'
          //   ipProtocols: [
          //     'TCP'
          //   ]
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   sourceIpGroups: []
          //   destinationAddresses: []
          //   destinationIpGroups: []
          //   destinationFqdns: [
          //     'azkms.${environment().suffixes.storage}'
          //   ]
          //   destinationPorts: [
          //     '1688'
          //   ]
          // }
          // {
          //   ruleType: 'NetworkRule'
          //   name: 'Agent and SXS Stack Updates'
          //   ipProtocols: [
          //     'TCP'
          //   ]
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   sourceIpGroups: []
          //   destinationAddresses: []
          //   destinationIpGroups: []
          //   destinationFqdns: [
          //     'mrsglobalsteus2prod.blob.${environment().suffixes.storage}'
          //   ]
          //   destinationPorts: [
          //     '443'
          //   ]
          // }
          // {
          //   ruleType: 'NetworkRule'
          //   name: 'Azure Portal Support'
          //   ipProtocols: [
          //     'TCP'
          //   ]
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   sourceIpGroups: []
          //   destinationAddresses: []
          //   destinationIpGroups: []
          //   destinationFqdns: [
          //     'wvdportalstorageblob.blob.${environment().suffixes.storage}'
          //   ]
          //   destinationPorts: [
          //     '443'
          //   ]
          // }
          // {
          //   ruleType: 'NetworkRule'
          //   name: 'Certificate CRL OneOCSP'
          //   ipProtocols: [
          //     'TCP'
          //   ]
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   sourceIpGroups: []
          //   destinationAddresses: []
          //   destinationIpGroups: []
          //   destinationFqdns: [
          //     'oneocsp.microsoft.com'
          //   ]
          //   destinationPorts: [
          //     '80'
          //   ]
          // }
          // {
          //   ruleType: 'NetworkRule'
          //   name: 'Certificate CRL MicrosoftDotCom'
          //   ipProtocols: [
          //     'TCP'
          //   ]
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   sourceIpGroups: []
          //   destinationAddresses: []
          //   destinationIpGroups: []
          //   destinationFqdns: [
          //     'www.microsoft.com'
          //   ]
          //   destinationPorts: [
          //     '80'
          //   ]
          // }
          // {
          //   ruleType: 'NetworkRule'
          //   name: 'Authentication to Microsoft Online Services'
          //   ipProtocols: [
          //     'TCP'
          //   ]
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   sourceIpGroups: []
          //   destinationAddresses: []
          //   destinationIpGroups: []
          //   destinationFqdns: [
          //     replace(replace(environment().authentication.loginEndpoint, 'https://', ''), '/', '')
          //   ]
          //   destinationPorts: [
          //     '443'
          //   ]
          // }
          // {
          //   ruleType: 'NetworkRule'
          //   name: 'NTP'
          //   ipProtocols: [
          //     'TCP'
          //     'UDP'
          //   ]
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   destinationFqdns: [
          //     'time.windows.com'
          //   ]
          //   destinationPorts: [
          //     '123'
          //   ]
          // }
          // {
          //   ruleType: 'NetworkRule'
          //   name: 'SigninToMSOL365'
          //   ipProtocols: [
          //     'TCP'
          //   ]
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   destinationFqdns: [
          //     replace(replace(environment().authentication.loginEndpoint, 'https://', ''), '/', '')
          //   ]
          //   destinationPorts: [
          //     '443'
          //   ]
          // }
          // {
          //   ruleType: 'NetworkRule'
          //   name: 'DetectOSconnectedToInternet'
          //   ipProtocols: [
          //     'TCP'
          //   ]
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   destinationFqdns: [
          //     'www.msftconnecttest.com'
          //   ]
          //   destinationPorts: [
          //     '443'
          //   ]
          // }
          // APPLICATION RULES
          {
            ruleType: 'ApplicationRule'
            name: 'M365/Azure Service FQDN Tags'    //https://learn.microsoft.com/en-us/azure/firewall/fqdn-tags
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: [
              'WindowsUpdate'                         // Windows Update service endpoints
              'WindowsDiagnostics'                    // Windows Diagnostics endpoints
              'MicrosoftActiveProtectionService'      // MAPS 
              'AzureBackup'                           // Azure Backup services
              'WindowsVirtualDesktop'                 // AVD platform traffic
              'Office365'                             // O365 Commercial and Gov endpoints (https://learn.microsoft.com/en-us/azure/firewall/protect-office-365) 
              'MicrosoftIntune'                       // AVD Intune access
            ]
            webCategories: []
            targetFqdns: []
            targetUrls: []
            terminateTLS: false
            sourceAddresses: avdVirtualNetworkCidrs
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Defender for Endpoint'     //https://learn.microsoft.com/en-us/mem/intune-service/fundamentals/intune-us-government-endpoints
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              '*.dm.microsoft.us'
            ]
            terminateTLS: false
            sourceAddresses: avdVirtualNetworkCidrs
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Office365 DoD'     //https://learn.microsoft.com/en-us/microsoft-365/enterprise/microsoft-365-u-s-government-dod-endpoints?view=o365-worldwide
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              // Exchange Online
              //'outlook-dod.office365.us'
              //'webmail.apps.mil'
              'attachments-dod.office365-net.us'
              'autodiscover-s-dod.office365.us'
              // 'autodiscover.<tenant>.mail.onmicrosoft.us'
              // 'autodiscover.<tenant>.onmicrosoft.us'
              '*.protection.apps.mil'
              //'*.protection.office365.us'
              // SharePoint Online
              '*.dps.mil'
              '*.sharepoint-mil.us'
              //'*.wns.windows.com'
              //'g.live.com'
              //'oneclient.sfx.ms'
              //'*.svc.ms'
              //'az741266.vo.msecnd.net'
              //'spoprod-a.akamaihd.net'
              //'static.sharepointonline.com'
              // Teams
              '*.dod.teams.microsoft.us'
              '*.online.dod.skypeforbusiness.us'
              'dod.teams.microsoft.us'
              'dodteamsapuiwebcontent.blob.core.usgovcloudapi.net'
              //'msteamsstatics.blob.core.usgovcloudapi.net'
              //'statics.teams.microsoft.com'
              'endpoint1-proddodcecompsvc-dodc.streaming.media.usgovcloudapi.net'
              'endpoint1-proddodeacompsvc-dode.streaming.media.usgovcloudapi.net'
              // M365 Common and Office Online
              // '*.dod.online.office365.us'
              '*.apps.mil'
              '*.office365.us'
              //'*.auth.microsoft.us'
              //'*.gov.us.microsoftonline.com'
              'dod-graph.microsoft.us'
              //'graph.microsoftazure.us'
              //'login.microsoftonline.us'
              //'*.msauth.net'
              //'*.msauthimages.us'
              //'*.msftauth.net'
              //'*.msftauthimages.us'
              //'clientconfig.microsoftonline-p.net'
              //'graph.windows.net'
              //'login-us.microsoftonline.com'
              //'login.microsoftonline-p.com'
              //'login.microsoftonline.com'
              //'login.windows.net'
              // 'loginex.microsoftonline.com'
              // 'mscrl.microsoft.com'
              // 'nexus.microsoftonline-p.com'
              // 'secure.aadcdn.microsoftonline-p.com'
              // 'portal.apps.mil'
              // 'reports.apps.mil'
              'webshell.dodsuite.office365.us'
              // 'www.ohome.apps.mil'
              // 'dod.loki.office365.us'
              // 'activation.sls.microsoft.com'
              // 'crl.microsoft.com'
              // 'go.microsoft.com'
              // 'insertmedia.bing.office.net'
              // 'ocsa.officeapps.live.com'
              // 'ocsredir.officeapps.live.com'
              // 'ocws.officeapps.live.com'
              // 'office15client.microsoft.com'
              // 'officecdn.microsoft.com'
              // 'officecdn.microsoft.com.edgesuite.net'
              // 'officepreviewredir.microsoft.com'
              // 'officeredir.microsoft.com'
              // 'ols.officeapps.live.com'
              // 'r.office.microsoft.com'
              // 'cdn.odc.officeapps.live.com'
              // 'mrodevicemgr.officeapps.live.com'
              // 'odc.officeapps.live.com'
              // 'officeclient.microsoft.com'
              // 'lpcres.delve.office.com'
              // '*.cdn.office.net'
              // '*.security.apps.mil'
              // 'compliance.apps.mil'
              // 'purview.apps.mil'
              // 'scc.protection.apps.mil'
              // 'security.apps.mil'
              // 'activity.windows.com'
              'dod.activity.windows.us'
              'dod-mtis.cortana.ai'
              // '*.aadrm.us'
              // '*.informationprotection.azure.us'
              // 'pf.events.data.microsoft.com'
              // 'pf.pipe.aria.microsoft.com'
            ]
            terminateTLS: false
            sourceAddresses: avdVirtualNetworkCidrs
          }
          // {
          //   ruleType: 'ApplicationRule'
          //   name: 'TelemetryService'
          //   protocols: [
          //     {
          //       protocolType: 'Https'
          //       port: 443
          //     }
          //   ]
          //   targetFqdns: [
          //     '*.events.data.microsoft.com'
          //   ]
          //   targetUrls: []
          //   terminateTLS: false
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   destinationAddresses: []
          //   sourceIpGroups: []
          // }
          // {
          //   ruleType: 'ApplicationRule'
          //   name: 'UpdatesForOneDrive'
          //   protocols: [
          //     {
          //       protocolType: 'Https'
          //       port: 443
          //     }
          //   ]
          //   targetFqdns: [
          //     '*.sfx.ms'
          //   ]
          //   terminateTLS: false
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   destinationAddresses: []
          //   sourceIpGroups: []
          // }
          // {
          //   ruleType: 'ApplicationRule'
          //   name: 'AzureDNSresolution'
          //   protocols: [
          //     {
          //       protocolType: 'Https'
          //       port: 443
          //     }
          //   ]
          //   targetFqdns: [
          //     '*.azure-dns.com'
          //     '*.azure-dns.net'
          //   ]
          //   terminateTLS: false
          //   sourceAddresses: avdVirtualNetworkCidrs
          // }
          // {
          //   ruleType: 'ApplicationRule'
          //   name: 'WindowsDiagnostics'
          //   protocols: [
          //     {
          //       protocolType: 'Https'
          //       port: 443
          //     }
          //   ]
          //   fqdnTags: [
          //     'WindowsDiagnostics'
          //   ]
          //   webCategories: []
          //   targetFqdns: []
          //   targetUrls: []
          //   terminateTLS: false
          //   sourceAddresses: avdVirtualNetworkCidrs
          //   destinationAddresses: []
          //   sourceIpGroups: []
          // }
          // {
          //   ruleType: 'ApplicationRule'
          //   name: 'Intune US Gov'     //https://learn.microsoft.com/en-us/mem/intune-service/fundamentals/intune-us-government-endpoints
          //   protocols: [
          //     {
          //       protocolType: 'Https'
          //       port: 443
          //     }
          //   ]
          //   targetFqdns: [
          //     '*.manage.microsoft.us'
          //     'enterpriseregistration.microsoftonline.us'
          //   ]
          //   terminateTLS: false
          //   sourceAddresses: avdVirtualNetworkCidrs
          // }
        ]
      }
      {
        name: 'AVD-AdminPool-Outbound'
        action: {
          type: 'Allow'
        }
        priority: 10200
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        rules: [
        ]
      }
      {
        name: 'AVD-DevPool-Outbound'
        action: {
          type: 'Allow'
        }
        priority: 10200
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        rules: [
        ]
      }
    ]
  }
}



// resource appRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = [for collection in appRuleCollections: {
//   name: '${name}-${collection.name}'
//   parent: firewallPolicy
//   properties: {
//     priority: collection.priority
//     ruleCollections: [
//       {
//         name: collection.name
//         priority: collection.priority
//         ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
//         action: {
//           type: 'Allow'
//         }
//         rules: [for rule in collection.rules: {
//           name: rule.name
//           // description: rule.description
//           ruleType: 'ApplicationRule'
//           sourceAddresses: rule.sourceAddresses
//           targetFqdns: rule.targetFqdns
//           fqdnTags: rule.fqdnTags
//           protocols: rule.ipProtocols
//         }]
//       }
//     ]
//   }
// }]

// resource natRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-05-01' = [for collection in natRuleCollections: {
//   name: '${name}-${collection.name}'
//   parent: firewallPolicy
//   properties: {
//     priority: collection.priority
//     ruleCollections: [
//       {
//         name: collection.name
//         priority: collection.priority
//         ruleCollectionType: 'FirewallPolicyNatRuleCollection'
//         action: {
//           type: 'DNAT'
//         }
//         rules: [for rule in collection.rules: {
//           name: rule.name
//           // description: rule.description
//           ruleType: 'NatRule'
//           sourceAddresses: rule.sourceAddresses
//           destinationAddresses: rule.destinationAddresses
//           destinationPorts: rule.destinationPorts
//           translatedAddress: rule.translatedAddress
//           translatedPort: rule.translatedPort
//           ipProtocols: rule.ipProtocols
//         }]
//       }
//     ]
//   }
// }]

// resource networkRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = [for collection in networkRuleCollections: {
//   name: '${name}-${collection.name}'
//   parent: firewallPolicy
//   properties: {
//     priority: collection.priority
//     ruleCollections: [
//       {
//         name: collection.name
//         priority: collection.priority
//         ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
//         action: {
//           type: collection.type
//         }
//         rules: [for rule in collection.rules: {
//           name: rule.name
//           // description: rule.description
//           ruleType: 'NetworkRule'
//           sourceAddresses: rule.sourceAddresses
//           destinationAddresses: rule.destinationAddresses
//           destinationPorts: rule.destinationPorts
//           ipProtocols: rule.ipProtocols
//         }]
//       }
//     ]
//   }
// }]

output name string = firewall.name
output privateIpAddress string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output resourceId string = firewall.id
