# Get-NMMWorkspaceSession

Gets workspace sessions.

## Syntax

```powershell
Get-NMMWorkspaceSession
    -AccountId <Int32>
    [-WorkspaceId <String>]
    [<CommonParameters>]
```

## Description

The `Get-NMMWorkspaceSession` cmdlet retrieves active sessions for AVD workspaces.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -WorkspaceId

Filter by workspace ID.

| | |
|---|---|
| Type | String |
| Required | False |

## Examples

### Example 1: Get all workspace sessions

```powershell
Get-NMMWorkspaceSession -AccountId 123
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| sessionId | String | Session identifier |
| userName | String | Connected user |
| workspace | String | Workspace name |
| sessionState | String | Active, Disconnected |
| createTime | DateTime | Session start |

## Related Links

- [Get-NMMWorkspace](../utilities/Get-NMMWorkspace.md)
- [Get-NMMHostPoolSession](../hostpools/Get-NMMHostPoolSession.md)
