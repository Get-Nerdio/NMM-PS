# Get-NMMHostPoolSession

Gets active sessions for a host pool.

## Syntax

```powershell
Get-NMMHostPoolSession
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPoolSession` cmdlet retrieves active user sessions across all session hosts in a host pool.

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

### Example 1: Get all active sessions

```powershell
Get-NMMHostPoolSession -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

### Example 2: Pipeline to get sessions across all pools

```powershell
Get-NMMAccount | Get-NMMHostPool | Get-NMMHostPoolSession
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| sessionId | String | Session identifier |
| userName | String | Connected user |
| sessionHost | String | Host VM name |
| sessionState | String | Active, Disconnected |
| createTime | DateTime | Session start time |
| applicationType | String | Desktop or RemoteApp |

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [Get-NMMHost](../hosts/Get-NMMHost.md)
