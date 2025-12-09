# Get-NMMHostPoolRDP

Gets RDP settings for a host pool.

## Syntax

```powershell
Get-NMMHostPoolRDP
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPoolRDP` cmdlet retrieves Remote Desktop Protocol settings for a host pool, including device redirections, display settings, and connection properties.

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

### Example 1: Get RDP settings

```powershell
Get-NMMHostPoolRDP -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| audioMode | String | Audio redirection mode |
| driveRedirection | Boolean | Allow drive mapping |
| printerRedirection | Boolean | Allow printer mapping |
| clipboardRedirection | Boolean | Allow clipboard |
| usbRedirection | Boolean | Allow USB devices |
| multiMonitor | Boolean | Multi-monitor support |

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [Get-NMMHostPoolSettings](Get-NMMHostPoolSettings.md)
