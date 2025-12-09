# Get-NMMHostPool

Lists host pools for an NMM account.

## Syntax

```powershell
Get-NMMHostPool
    -AccountId <Int32>
    [-PoolName <String>]
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPool` cmdlet retrieves Azure Virtual Desktop host pools for a specified NMM account. Supports pipeline input from `Get-NMMAccount`.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |
| Aliases | id |

### -PoolName

Filter by host pool name.

| | |
|---|---|
| Type | String |
| Required | False |

## Examples

### Example 1: Get all host pools for an account

```powershell
Get-NMMHostPool -AccountId 123
```

### Example 2: Pipeline from Get-NMMAccount

```powershell
Get-NMMAccount | Get-NMMHostPool
```

Returns all host pools for all accounts.

### Example 3: Filter by name

```powershell
Get-NMMHostPool -AccountId 123 -PoolName "Production*"
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | String | Host pool resource ID |
| poolName | String | Host pool name |
| resourceGroup | String | Azure resource group |
| subscriptionId | String | Azure subscription |
| hostPoolType | String | Pooled or Personal |
| maxSessionLimit | Int32 | Maximum sessions per host |

## Notes

- Supports pipeline input from `Get-NMMAccount`
- Output can be piped to other host pool cmdlets

## Related Links

- [Get-NMMAccount](../accounts/Get-NMMAccount.md)
- [Get-NMMHostPoolSettings](Get-NMMHostPoolSettings.md)
- [Get-NMMHost](../hosts/Get-NMMHost.md)
