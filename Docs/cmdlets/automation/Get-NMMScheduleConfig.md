# Get-NMMScheduleConfig

Gets schedule configuration details.

## Syntax

```powershell
Get-NMMScheduleConfig
    -ScheduleId <Int32>
    [-AccountId <Int32>]
    -Scope <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMScheduleConfig` cmdlet retrieves detailed configuration for a specific schedule.

## Parameters

### -ScheduleId

The schedule ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -AccountId

The NMM account ID (required for Account scope).

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Pipeline Input | True (ByPropertyName) |

### -Scope

The scope of the schedule.

| | |
|---|---|
| Type | String |
| Required | True |
| Valid Values | Account, Global |

## Examples

### Example 1: Get schedule config

```powershell
Get-NMMScheduleConfig -ScheduleId 456 -Scope Global
```

### Example 2: Pipeline from Get-NMMSchedule

```powershell
Get-NMMSchedule -Scope Global | Get-NMMScheduleConfig -Scope Global
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Schedule ID |
| name | String | Schedule name |
| cronExpression | String | Cron schedule |
| timezone | String | Time zone |
| parameters | Object | Task parameters |
| notifications | Object | Alert settings |

## Related Links

- [Get-NMMSchedule](Get-NMMSchedule.md)
