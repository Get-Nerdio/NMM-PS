# Get-NMMGroup

Gets group details.

## Syntax

```powershell
Get-NMMGroup
    -AccountId <Int32>
    -GroupId <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMGroup` cmdlet retrieves details about an Azure AD group.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -GroupId

The Azure AD group object ID.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

## Examples

### Example 1: Get group details

```powershell
Get-NMMGroup -AccountId 123 -GroupId "abc123-def456-ghi789"
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| objectId | String | Azure AD object ID |
| displayName | String | Group name |
| description | String | Group description |
| groupType | String | Security, M365 |
| memberCount | Int32 | Number of members |

## Related Links

- [Get-NMMUsers](Get-NMMUsers.md)
- [Get-NMMHostPoolUser](../hostpools/Get-NMMHostPoolUser.md)
