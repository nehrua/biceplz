
targetScope = 'subscription'

param resourceGroups array

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = [for rg in resourceGroups: {
  name: rg.name
  location: rg.location
  tags: rg.tags
}]

output names array = [for (rg, i) in resourceGroups: resourceGroups[i].name]
