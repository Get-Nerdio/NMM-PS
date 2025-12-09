# Get-NMMRecoveryPoint

Lists recovery points for a protected item.

## Syntax

```powershell
Get-NMMRecoveryPoint
    -AccountId <Int32>
    -ProtectedItemId <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMRecoveryPoint` cmdlet retrieves available recovery points for a backup protected item.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -ProtectedItemId

The protected item ID.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

## Examples

### Example 1: Get recovery points

```powershell
Get-NMMRecoveryPoint -AccountId 123 -ProtectedItemId "item-abc-123"
```

### Example 2: Pipeline from protected items

```powershell
Get-NMMProtectedItem -AccountId 123 | Get-NMMRecoveryPoint
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| recoveryPointId | String | Recovery point ID |
| recoveryPointTime | DateTime | Backup timestamp |
| recoveryPointType | String | Full, Incremental |
| sourceResourceId | String | Source resource |

## Related Links

- [Get-NMMProtectedItem](Get-NMMProtectedItem.md)
- [Get-NMMBackup](Get-NMMBackup.md)
