targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
param location string = 'eastus'
// Sample tags parameters
var tags = {
  project: 'test'
  env: 'dev'
}

// ------------------------------------------------------------------------------------------------
// VNET Configurations Examples
// ------------------------------------------------------------------------------------------------
var subnets = [
  {
    name: 'snet-pdnsz-vnetlink'
    subnetPrefix: '192.168.0.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    delegations: []
  }
]

resource vnetApp 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'vnet-pdnsz-vnetlink'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/24'
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        delegations: subnet.delegations
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
      }
    }]
  }
}

resource pdnsz 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
  tags: tags
}

module pdnszVnetLinkDeployment '../main.bicep'= {
  name: 'pdnszVnetLinkDeployment'
  params: {
    vnet_id: vnetApp.id
    enable_pdnsz_autoregistration: false
    pdnsz_id: pdnsz.id
    tags: tags
  }
}
