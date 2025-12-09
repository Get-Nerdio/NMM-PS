# Get-NMMBackup

Lists backup items for an account.

## Syntax

```powershell
Get-NMMBackup
    -AccountId <Int32>
    [<CommonParameters>]
```

## Description

The `Get-NMMBackup` cmdlet retrieves Azure Backup items configured for an NMM account.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |
| Aliases | id |

## Examples

### Example 1: Get all backup items

```powershell
Get-NMMBackup -AccountId 123
```

### Example 2: Pipeline from accounts

```powershell
Get-NMMAccount | Get-NMMBackup
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | String | Backup item ID |
| name | String | Item name |
| protectionState | String | Protected, NotProtected |
| lastBackupTime | DateTime | Last backup |
| backupPolicy | String | Applied policy |

## Related Links

- [Get-NMMProtectedItem](Get-NMMProtectedItem.md)
- [Get-NMMRecoveryPoint](Get-NMMRecoveryPoint.md)
