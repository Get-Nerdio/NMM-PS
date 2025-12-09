# Get-NMMSchedule

Lists schedules.

## Syntax

```powershell
Get-NMMSchedule
    [-AccountId <Int32>]
    -Scope <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMSchedule` cmdlet retrieves all schedules configured for automation tasks.

## Parameters

### -AccountId

The NMM account ID (required for Account scope).

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Pipeline Input | True (ByPropertyName) |

### -Scope

The scope of schedules to retrieve.

| | |
|---|---|
| Type | String |
| Required | True |
| Valid Values | Account, Global |

## Examples

### Example 1: Get account schedules

```powershell
Get-NMMSchedule -AccountId 123 -Scope Account
```

### Example 2: Get all global schedules

```powershell
Get-NMMSchedule -Scope Global
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Schedule ID |
| name | String | Schedule name |
| scheduleType | String | Type of task |
| enabled | Boolean | Schedule enabled |
| recurrence | String | Daily, Weekly, etc. |
| nextRun | DateTime | Next execution |
| lastRun | DateTime | Last execution |

## Related Links

- [Get-NMMScheduleConfig](Get-NMMScheduleConfig.md)
- [Get-NMMScriptedActionSchedule](Get-NMMScriptedActionSchedule.md)
