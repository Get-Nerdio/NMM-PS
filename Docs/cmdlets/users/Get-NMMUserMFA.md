# Get-NMMUserMFA

Gets MFA status for a user.

## Syntax

```powershell
Get-NMMUserMFA
    -AccountId <Int32>
    -UserPrincipalName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMUserMFA` cmdlet retrieves multi-factor authentication status and methods for a user.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -UserPrincipalName

The user's UPN.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

## Examples

### Example 1: Get MFA status

```powershell
Get-NMMUserMFA -AccountId 123 -UserPrincipalName "john.doe@contoso.com"
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| mfaEnabled | Boolean | MFA enabled |
| defaultMethod | String | Default MFA method |
| methods | String[] | Registered methods |
| lastSignIn | DateTime | Last authentication |

## Related Links

- [Get-NMMUser](Get-NMMUser.md)
