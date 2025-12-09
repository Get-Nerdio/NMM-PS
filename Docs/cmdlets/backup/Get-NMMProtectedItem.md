# Get-NMMProtectedItem

Gets backup protected items.

## Syntax

```powershell
Get-NMMProtectedItem
    -AccountId <Int32>
    [-ResourceGroup <String>]
    [<CommonParameters>]
```

## Description

The `Get-NMMProtectedItem` cmdlet retrieves items protected by Azure Backup.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -ResourceGroup

Filter by resource group.

| | |
|---|---|
| Type | String |
| Required | False |

## Examples

### Example 1: Get all protected items

```powershell
Get-NMMProtectedItem -AccountId 123
```

### Example 2: Filter by resource group

```powershell
Get-NMMProtectedItem -AccountId 123 -ResourceGroup "rg-avd"
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | String | Protected item ID |
| friendlyName | String | Display name |
| protectionStatus | String | Healthy, Unhealthy |
| protectionState | String | IRPending, Protected |
| lastBackupStatus | String | Completed, Failed |
| lastBackupTime | DateTime | Last backup time |
| policyName | String | Backup policy |

## Related Links

- [Get-NMMBackup](Get-NMMBackup.md)
- [Get-NMMRecoveryPoint](Get-NMMRecoveryPoint.md)
