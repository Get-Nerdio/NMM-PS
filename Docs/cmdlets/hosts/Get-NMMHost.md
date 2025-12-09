# Get-NMMHost

Lists session hosts in a host pool.

## Syntax

```powershell
Get-NMMHost
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [-HostName <String>]
    [<CommonParameters>]
```

## Description

The `Get-NMMHost` cmdlet retrieves session host VMs within a specified host pool.

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

### -HostName

Filter by specific host name.

| | |
|---|---|
| Type | String |
| Required | False |

## Examples

### Example 1: Get all hosts in a pool

```powershell
Get-NMMHost -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

### Example 2: Pipeline from Get-NMMHostPool

```powershell
Get-NMMHostPool -AccountId 123 | Get-NMMHost
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| hostName | String | VM name |
| status | String | Available, Unavailable, Shutdown |
| sessionCount | Int32 | Active sessions |
| allowNewSessions | Boolean | Accepting connections |
| agentVersion | String | AVD agent version |
| lastHeartbeat | DateTime | Last health check |

## Related Links

- [Get-NMMHostPool](../hostpools/Get-NMMHostPool.md)
- [Get-NMMHostSchedule](Get-NMMHostSchedule.md)
