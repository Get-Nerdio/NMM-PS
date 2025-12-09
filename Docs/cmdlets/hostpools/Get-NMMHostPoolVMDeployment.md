# Get-NMMHostPoolVMDeployment

Gets VM deployment settings for a host pool.

## Syntax

```powershell
Get-NMMHostPoolVMDeployment
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPoolVMDeployment` cmdlet retrieves the virtual machine deployment configuration for a host pool, including VM size, image, and networking settings.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -SubscriptionId

The Azure subscription ID.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -ResourceGroup

The Azure resource group name.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -PoolName

The host pool name.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

## Examples

### Example 1: Get VM deployment settings

```powershell
Get-NMMHostPoolVMDeployment -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| vmSize | String | Azure VM SKU |
| imageId | String | Desktop image ID |
| osDiskType | String | Premium_LRS, Standard_SSD |
| vnetId | String | Virtual network ID |
| subnetName | String | Subnet name |
| availabilityOption | String | Zone or Set |

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [Get-NMMDesktopImage](../images/Get-NMMDesktopImage.md)
