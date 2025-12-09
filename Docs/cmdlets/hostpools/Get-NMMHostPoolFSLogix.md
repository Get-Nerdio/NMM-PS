# Get-NMMHostPoolFSLogix

Gets FSLogix configuration for a host pool.

## Syntax

```powershell
Get-NMMHostPoolFSLogix
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPoolFSLogix` cmdlet retrieves the FSLogix profile container configuration for a host pool, including storage paths, container settings, and profile options.

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

### Example 1: Get FSLogix settings

```powershell
Get-NMMHostPoolFSLogix -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| enabled | Boolean | FSLogix enabled |
| vhdLocations | String[] | Profile container paths |
| profileType | String | VHD or VHDX |
| sizeInGB | Int32 | Container size |
| cloudCacheEnabled | Boolean | Cloud Cache enabled |

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [Get-NMMFSLogixConfig](../utilities/Get-NMMFSLogixConfig.md)
