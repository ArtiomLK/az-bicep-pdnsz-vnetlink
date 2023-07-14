// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
@description('Az Resources tags')
param tags object = {}

// ------------------------------------------------------------------------------------------------
// Resource parameters
// ------------------------------------------------------------------------------------------------
@description('App Service Private DNS Zone Resource ID where the A records will be written')
param pdnsz_id string
var pdnsz_id_parsed = {
  sub_id: substring(substring(pdnsz_id, indexOf(pdnsz_id, 'subscriptions/') + 14), 0, indexOf(substring(pdnsz_id, indexOf(pdnsz_id, 'subscriptions/') + 14), '/'))
  rg_n: substring(substring(pdnsz_id, indexOf(pdnsz_id, 'resourceGroups/') + 15), 0, indexOf(substring(pdnsz_id, indexOf(pdnsz_id, 'resourceGroups/') + 15), '/'))
  res_n: substring(pdnsz_id, lastIndexOf(pdnsz_id, '/') + 1)
}

@description('subnet ID to Enbable App Private Endpoints Connections')
param vnet_id string

@description('Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled')
param enable_pdnsz_autoregistration bool

var pdnsz_vnet_link_n = '${pdnsz_id_parsed.res_n}/${take('${pdnsz_id_parsed.res_n}-link-${guid(subscription().id, resourceGroup().id, vnet_id)}', 80)}'
// ------------------------------------------------------------------------------------------------
// Deploy Resource
// ------------------------------------------------------------------------------------------------
resource vnLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: pdnsz_vnet_link_n
  location: 'global'
  properties: {
    registrationEnabled: enable_pdnsz_autoregistration
    virtualNetwork: {
      id: vnet_id
    }
  }
  tags: tags
}
