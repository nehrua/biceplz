
param name string = 'quadzero-rt'
param location string = resourceGroup().location

@description('Array of routes')
param routesArray array = [
  {
    name: 'route1'
    addressPrefix: '0.0.0.0/0'
    hasBgpOverride: false
    nextHopIpAddress: '10.0.0.3'
    nextHopType: 'VirtualAppliance'
  }
]

resource routeTable 'Microsoft.Network/routeTables@2023-11-01' = {
  name: name
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [for route in routesArray: {
      name: route.name
      properties: {
        addressPrefix: route.addressPrefix
        hasBgpOverride: route.hasBgpOverride
        nextHopIpAddress: route.nextHopIpAddress
        nextHopType: route.nextHopType
      }
    }]
  }
}

output id string = routeTable.id
output name string = routeTable.name
