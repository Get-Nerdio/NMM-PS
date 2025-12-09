# Remove-NMMHostPool

Removes an Azure Virtual Desktop host pool.

## Syntax

```powershell
Remove-NMMHostPool
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [-Force]
    [<CommonParameters>]
```

## Description

The `Remove-NMMHostPool` cmdlet deletes an Azure Virtual Desktop host pool and optionally its associated resources.

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

The host pool name to remove.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -Force

Skip confirmation prompt.

| | |
|---|---|
| Type | Switch |
| Required | False |

## Examples

### Example 1: Remove a host pool

```powershell
Remove-NMMHostPool -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-dev"
```

### Example 2: Remove without confirmation

```powershell
Remove-NMMHostPool -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-dev" -Force
```

## Notes

- This is a destructive operation
- Ensure all sessions are terminated before removal
- Associated VMs may need to be removed separately

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [New-NMMHostPool](New-NMMHostPool.md)
