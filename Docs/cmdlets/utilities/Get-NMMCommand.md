# Get-NMMCommand

Lists available NMM-PS commands.

## Syntax

```powershell
Get-NMMCommand
    [-Category <String>]
    [<CommonParameters>]
```

## Description

The `Get-NMMCommand` cmdlet lists all available cmdlets in the NMM-PS module, optionally filtered by category.

## Parameters

### -Category

Filter by cmdlet category.

| | |
|---|---|
| Type | String |
| Required | False |
| Valid Values | Authentication, Accounts, HostPools, Hosts, Images, Users, Devices, Backup, Automation, Utilities |

## Examples

### Example 1: List all commands

```powershell
Get-NMMCommand
```

### Example 2: List host pool commands

```powershell
Get-NMMCommand -Category HostPools
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| Name | String | Cmdlet name |
| Category | String | Functional category |
| Synopsis | String | Brief description |

## Related Links

- [Module Overview](../../index.md)
