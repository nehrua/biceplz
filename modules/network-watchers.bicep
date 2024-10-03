
param name string = 'watcher-nw'
param location string = resourceGroup().location
param tags object = {}

resource networkWatchers 'Microsoft.Network/networkWatchers@2023-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {}
}
