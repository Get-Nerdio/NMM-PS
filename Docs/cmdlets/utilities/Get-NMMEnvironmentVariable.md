# Get-NMMEnvironmentVariable

Gets environment variables.

## Syntax

```powershell
Get-NMMEnvironmentVariable
    [-AccountId <Int32>]
    -Scope <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMEnvironmentVariable` cmdlet retrieves environment variables used in scripted actions and automation.

## Parameters

### -AccountId

The NMM account ID (required for Account scope).

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Pipeline Input | True (ByPropertyName) |

### -Scope

The scope of variables to retrieve.

| | |
|---|---|
| Type | String |
| Required | True |
| Valid Values | Account, Global |

## Examples

### Example 1: Get account variables

```powershell
Get-NMMEnvironmentVariable -AccountId 123 -Scope Account
```

### Example 2: Get global variables

```powershell
Get-NMMEnvironmentVariable -Scope Global
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| name | String | Variable name |
| value | String | Variable value |
| scope | String | Account or Global |
| isSecret | Boolean | Masked value |

## Related Links

- [Get-NMMScriptedAction](../automation/Get-NMMScriptedAction.md)
