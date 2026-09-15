// Target scope set to subscription to allow resource group creation
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

// --- NAMING CONVENTION VARIABLES ---
// Pattern: <workload>-<environment>-<region>-<resource-type>
var locationShort = toLower(location)
var baseName = '${toLower(workloadName)}-${toLower(environment)}-${locationShort}'

// Dynamic Resource Group Name
var resourceGroupName = '${baseName}-rg'

// Example of formatted resource names (to be used when adding child resources)
// Storage Account names must be lowercase alphanumeric only and <= 24 chars
var uniqueHash = uniqueString(subscription().subscriptionId, workloadName, environment)
var storageAccountName = take('st${toLower(workloadName)}${toLower(environment)}${uniqueHash}', 24)

// Virtual Network Name
var vnetName = '${baseName}-vnet'

// --- RESOURCES ---
@description('Main Resource Group for VM Fleet Commander')
resource fleetResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: {
    Environment: environment
    Workload: workloadName
    ManagedBy: 'Bicep'
  }
}

// --- OUTPUTS ---
output resourceGroupName string = fleetResourceGroup.name
output resourceGroupId string = fleetResourceGroup.id
output calculatedStorageName string = storageAccountName
output calculatedVnetName string = vnetName
