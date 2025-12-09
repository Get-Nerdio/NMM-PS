# Get-NMMUser

Gets details for a specific user.

## Syntax

```powershell
Get-NMMUser
    -AccountId <Int32>
    -UserPrincipalName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMUser` cmdlet retrieves detailed information about a specific Azure AD user.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -UserPrincipalName

The user's UPN (email address).

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |
| Aliases | upn |

## Examples

### Example 1: Get user details

```powershell
Get-NMMUser -AccountId 123 -UserPrincipalName "john.doe@contoso.com"
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| objectId | String | Azure AD object ID |
| displayName | String | Display name |
| userPrincipalName | String | UPN |
| mail | String | Email address |
| jobTitle | String | Job title |
| department | String | Department |
| accountEnabled | Boolean | Account enabled |

## Related Links

- [Get-NMMUsers](Get-NMMUsers.md)
- [Get-NMMUserMFA](Get-NMMUserMFA.md)
