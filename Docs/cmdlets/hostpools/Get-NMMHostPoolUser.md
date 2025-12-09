# Get-NMMHostPoolUser

Gets assigned users for a host pool.

## Syntax

```powershell
Get-NMMHostPoolUser
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPoolUser` cmdlet retrieves users and groups assigned to a host pool's application groups.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -SubscriptionId

The Azure subscription ID.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -ResourceGroup

The Azure resource group name.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -PoolName

The host pool name.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

## Examples

### Example 1: Get assigned users

```powershell
Get-NMMHostPoolUser -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| objectId | String | Azure AD object ID |
| displayName | String | User/group name |
| userPrincipalName | String | UPN (for users) |
| objectType | String | User or Group |

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [Get-NMMUser](../users/Get-NMMUser.md)
