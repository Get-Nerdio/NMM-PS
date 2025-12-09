# Get-NMMHostPoolTimeout

Gets session timeout settings for a host pool.

## Syntax

```powershell
Get-NMMHostPoolTimeout
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPoolTimeout` cmdlet retrieves session timeout and disconnect settings for a host pool.

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

### Example 1: Get timeout settings

```powershell
Get-NMMHostPoolTimeout -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| idleTimeout | Int32 | Idle timeout (minutes) |
| disconnectTimeout | Int32 | Disconnect timeout |
| logoffTimeout | Int32 | Force logoff timeout |
| remoteAppLogoff | Boolean | Logoff on RemoteApp close |

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [Get-NMMHostPoolSettings](Get-NMMHostPoolSettings.md)
