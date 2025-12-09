# Get-NMMScriptedActionSchedule

Gets schedules for scripted actions.

## Syntax

```powershell
Get-NMMScriptedActionSchedule
    [-AccountId <Int32>]
    -Scope <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMScriptedActionSchedule` cmdlet retrieves scheduled executions of scripted actions.

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

### Example 1: Get account-scoped schedules

```powershell
Get-NMMScriptedActionSchedule -AccountId 123 -Scope Account
```

### Example 2: Get global schedules

```powershell
Get-NMMScriptedActionSchedule -Scope Global
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Schedule ID |
| scriptedActionId | Int32 | Associated action |
| name | String | Schedule name |
| enabled | Boolean | Schedule enabled |
| recurrence | String | Schedule pattern |
| nextRun | DateTime | Next execution |

## Related Links

- [Get-NMMScriptedAction](Get-NMMScriptedAction.md)
- [Get-NMMSchedule](Get-NMMSchedule.md)
