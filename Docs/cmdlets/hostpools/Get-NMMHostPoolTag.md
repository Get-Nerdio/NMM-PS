# Get-NMMHostPoolTag

Gets Azure resource tags for a host pool.

## Syntax

```powershell
Get-NMMHostPoolTag
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPoolTag` cmdlet retrieves Azure resource tags applied to a host pool and its associated resources.

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

### Example 1: Get resource tags

```powershell
Get-NMMHostPoolTag -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

## Outputs

**PSCustomObject**

Returns a hashtable of tag key-value pairs.

| Property | Type | Description |
|----------|------|-------------|
| (TagName) | String | Tag value |

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
