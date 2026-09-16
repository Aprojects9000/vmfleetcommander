@description('Name of the Virtual Machine')
param vmName string

@description('Azure region for the VM deployment')
param location string

@description('VM Size (SKU)')
param vmSize string = 'Standard_B1s'

@description('Administrator username for the VM')
param adminUsername string = 'azureuser'

@description('SSH Public Key or password for authentication')
@secure()
param adminPasswordOrKey string

@description('ID of the Subnet where the VM Network Interface will attach')
param subnetId string

// --- RESOURCES ---

// Network Interface (NIC) for each VM
resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

// Virtual Machine Resource
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: take(vmName, 15) // Hostname restricted to 15 chars
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// --- OUTPUTS ---
output vmId string = vm.id
output vmName string = vm.name
output nicId string = nic.id
