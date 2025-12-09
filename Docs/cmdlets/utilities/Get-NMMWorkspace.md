# Get-NMMWorkspace

Gets AVD workspaces for an account.

## Syntax

```powershell
Get-NMMWorkspace
    -AccountId <Int32>
    [<CommonParameters>]
```

## Description

The `Get-NMMWorkspace` cmdlet retrieves Azure Virtual Desktop workspaces for an NMM account.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |
| Aliases | id |

## Examples

### Example 1: Get workspaces

```powershell
Get-NMMWorkspace -AccountId 123
```

### Example 2: Pipeline from accounts

```powershell
Get-NMMAccount | Get-NMMWorkspace
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | String | Workspace resource ID |
| name | String | Workspace name |
| resourceGroup | String | Azure resource group |
| friendlyName | String | Display name |
| applicationGroups | String[] | Associated app groups |

## Related Links

- [Get-NMMHostPool](../hostpools/Get-NMMHostPool.md)
- [Get-NMMWorkspaceSession](../users/Get-NMMWorkspaceSession.md)
