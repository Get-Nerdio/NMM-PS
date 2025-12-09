# Get-NMMHostPoolAD

Gets Active Directory settings for a host pool.

## Syntax

```powershell
Get-NMMHostPoolAD
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPoolAD` cmdlet retrieves the Active Directory configuration for a host pool, including domain join settings and organizational unit placement.

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

### Example 1: Get AD settings

```powershell
Get-NMMHostPoolAD -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| directoryId | String | Directory configuration ID |
| domainName | String | AD domain name |
| ouPath | String | Organizational unit path |
| joinType | String | AD or Azure AD joined |

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [Get-NMMDirectory](../utilities/Get-NMMDirectory.md)
