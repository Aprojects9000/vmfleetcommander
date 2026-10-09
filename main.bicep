targetScope = 'subscription'

@description('The primary Azure region for deployment')
param location string = 'westeurope'

@description('Environment tag (e.g. dev, prod, test)')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('Workload or application prefix name')
@minLength(3)
@maxLength(10)
param workloadName string = 'vmfleet'

@description('Number of VM instances to provision')
@minValue(1)
@maxValue(10)
param vmCount int = 2

@description('VM Size SKU')
param vmSize string = 'Standard_B2s_v2'

@description('Administrator password for the VMs')
@secure()
param adminPassword string

// --- NAMING CONVENTION VARIABLES ---
var locationShort = toLower(location)
var baseName = '${toLower(workloadName)}-${toLower(environment)}-${locationShort}'
var resourceGroupName = '${baseName}-rg'

// --- RESOURCE GROUP ---
resource fleetResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: {
    Environment: environment
    Workload: workloadName
    ManagedBy: 'Bicep'
  }
}

// --- MODULE DEPLOYMENTS (SCOPED TO RESOURCE GROUP) ---

// Deploy Supporting Network (VNet, Subnet, and NSG)
module networkModule 'modules/network.bicep' = {
  name: 'networkDeployment'
  scope: fleetResourceGroup
  params: {
    location: location
    vnetName: '${baseName}-vnet'
  }
}

// Loop to deploy VMs using the VM module attached to the secure subnet
module vmModule 'modules/vm.bicep' = [for i in range(0, vmCount): {
  name: 'vmDeployment-${i}'
  scope: fleetResourceGroup
  params: {
    vmName: '${baseName}-vm-${i}'
    location: location
    vmSize: vmSize
    adminPasswordOrKey: adminPassword
    subnetId: networkModule.outputs.subnetId
  }
}]

// --- OUTPUTS ---
output resourceGroupName string = fleetResourceGroup.name
output deployedVmCount int = vmCount
