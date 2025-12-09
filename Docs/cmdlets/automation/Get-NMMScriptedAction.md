# Get-NMMScriptedAction

Lists scripted actions.

## Syntax

```powershell
Get-NMMScriptedAction
    [-AccountId <Int32>]
    -Scope <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMScriptedAction` cmdlet retrieves scripted actions (PowerShell scripts) that can be executed on host pools or session hosts.

## Parameters

### -AccountId

The NMM account ID (required for Account scope).

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Pipeline Input | True (ByPropertyName) |

### -Scope

The scope of scripted actions to retrieve.

| | |
|---|---|
| Type | String |
| Required | True |
| Valid Values | Account, Global |

## Examples

### Example 1: Get account-scoped actions

```powershell
Get-NMMScriptedAction -AccountId 123 -Scope Account
```

### Example 2: Get global actions

```powershell
Get-NMMScriptedAction -Scope Global
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Action ID |
| name | String | Action name |
| description | String | Action description |
| scriptType | String | PowerShell, AzureCLI |
| scope | String | Account or Global |
| enabled | Boolean | Action enabled |

## Related Links

- [Get-NMMScriptedActionSchedule](Get-NMMScriptedActionSchedule.md)
- [Get-NMMSchedule](Get-NMMSchedule.md)
