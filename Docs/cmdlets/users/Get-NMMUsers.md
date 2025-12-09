# Get-NMMUsers

Searches and lists users.

## Syntax

```powershell
Get-NMMUsers
    -AccountId <Int32>
    [-SearchString <String>]
    [-PageSize <Int32>]
    [-Page <Int32>]
    [<CommonParameters>]
```

## Description

The `Get-NMMUsers` cmdlet searches and lists Azure AD users with pagination support.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -SearchString

Search filter for user names or UPNs.

| | |
|---|---|
| Type | String |
| Required | False |

### -PageSize

Number of results per page.

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Default | 100 |

### -Page

Page number (1-based).

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Default | 1 |

## Examples

### Example 1: List all users

```powershell
Get-NMMUsers -AccountId 123
```

### Example 2: Search for users

```powershell
Get-NMMUsers -AccountId 123 -SearchString "john"
```

### Example 3: Paginated results

```powershell
Get-NMMUsers -AccountId 123 -PageSize 50 -Page 2
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| objectId | String | Azure AD object ID |
| displayName | String | Display name |
| userPrincipalName | String | UPN |
| mail | String | Email address |

## Notes

- Uses POST method with pagination
- Large directories may require multiple page requests

## Related Links

- [Get-NMMUser](Get-NMMUser.md)
- [Get-NMMGroup](Get-NMMGroup.md)
