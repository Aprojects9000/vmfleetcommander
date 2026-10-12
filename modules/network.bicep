@description('Azure region for the VNet deployment')
param location string

@description('Name of the Virtual Network')
param vnetName string

@description('Address space prefix for the Virtual Network')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Name of the VM Subnet')
param subnetName string = 'default'

@description('Subnet address prefix')
param subnetAddressPrefix string = '10.0.1.0/24'

// --- RESOURCES ---
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

// --- OUTPUTS ---
output vnetId string = vnet.id
output subnetId string = vnet.properties.subnets[0].id
