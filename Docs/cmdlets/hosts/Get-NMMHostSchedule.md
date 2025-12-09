# Get-NMMHostSchedule

Gets scheduled jobs for a session host.

## Syntax

```powershell
Get-NMMHostSchedule
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    -HostName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostSchedule` cmdlet retrieves scheduled tasks for a specific session host VM.

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

The session host VM name.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

## Examples

### Example 1: Get schedules for a host

```powershell
Get-NMMHostSchedule -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" `
    -PoolName "hp-prod" -HostName "avd-vm-0"
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Schedule ID |
| name | String | Schedule name |
| scheduleType | String | Type of schedule |
| enabled | Boolean | Schedule enabled |
| nextRun | DateTime | Next execution time |

## Related Links

- [Get-NMMHost](Get-NMMHost.md)
- [Get-NMMSchedule](../automation/Get-NMMSchedule.md)
