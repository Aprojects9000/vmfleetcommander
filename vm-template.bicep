@description('Name of the Virtual Machine')
param vmName string = 'myVM'

@description('Location for all resources')
param location string = resourceGroup().location
param adminUsername string = 'azureuser'

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s_v2'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: 'Password1234!'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
    }
  }
}

output adminUser string = adminUsername
