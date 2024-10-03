/*
Copyright (c) Microsoft Corporation.
Licensed under the MIT License.
*/

param disableBgpRoutePropagation bool
param location string
param name string
param routeAddressPrefix string = '0.0.0.0/0'
param routeName string = 'default_route'
param routeNextHopIpAddress string
param routeNextHopType string = 'VirtualAppliance'
param tags object

resource routeTable 'Microsoft.Network/routeTables@2021-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: [
      {
        name: routeName
        properties: {
          addressPrefix: routeAddressPrefix
          nextHopIpAddress: routeNextHopIpAddress
          nextHopType: routeNextHopType
        }
      }
    ]
  }
}

output id string = routeTable.id
output name string = routeTable.name
