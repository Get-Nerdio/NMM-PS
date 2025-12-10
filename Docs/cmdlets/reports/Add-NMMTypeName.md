# Add-NMMTypeName

Adds a PSTypeName to objects for report template matching.

## Syntax

```powershell
Add-NMMTypeName
    -InputObject <Object>
    -TypeName <String>
    [<CommonParameters>]
```

## Description

The `Add-NMMTypeName` cmdlet tags PSCustomObjects with an NMM.* type name so the report generator can automatically select the appropriate template. This is useful for custom data that doesn't come from NMM cmdlets.

## Parameters

### -InputObject

The object(s) to tag with a PSTypeName.

| | |
|---|---|
| Type | Object |
| Required | True |
| Pipeline Input | True |

### -TypeName

The type name to add. Must start with 'NMM.' (e.g., 'NMM.HostPool').

| | |
|---|---|
| Type | String |
| Required | True |
| Position | 0 |
| Validation | Must match pattern `^NMM\.\w+$` |

## Examples

### Example 1: Tag custom data

```powershell
$customData | Add-NMMTypeName -TypeName 'NMM.HostPool'
```

### Example 2: Pipeline to report

```powershell
$customPools | Add-NMMTypeName 'NMM.HostPool' |
    ConvertTo-NMMHtmlReport -Title "Custom Pools" -ShowChart -OutputPath "./custom.html"
```

### Example 3: Custom device data

```powershell
$devices = @(
    [PSCustomObject]@{
        deviceName = "PC001"
        complianceState = "Compliant"
        operatingSystem = "Windows"
        osVersion = "10.0.19045"
        model = "Dell OptiPlex"
        lastSyncDateTime = (Get-Date)
    }
    [PSCustomObject]@{
        deviceName = "PC002"
        complianceState = "NonCompliant"
        operatingSystem = "Windows"
        osVersion = "10.0.18363"
        model = "HP EliteDesk"
        lastSyncDateTime = (Get-Date).AddDays(-7)
    }
)

$devices | Add-NMMTypeName 'NMM.Device' |
    ConvertTo-NMMHtmlReport -Title "Custom Devices" -ShowChart -ChartType pie -OutputPath "./custom-devices.html"
```

## Valid Type Names

| TypeName | Template Applied |
|----------|------------------|
| `NMM.HostPool` | Host Pool columns and donut chart |
| `NMM.Host` | Session Host columns and donut chart |
| `NMM.Device` | Intune Device columns and pie chart |
| `NMM.Account` | Account columns (no chart) |
| `NMM.User` | User columns (no chart) |
| `NMM.Backup` | Backup Item columns and donut chart |

## Outputs

**PSCustomObject**

Returns the input object with the PSTypeName added.

## Notes

Most `Get-NMM*` cmdlets automatically add PSTypeNames to their output. This cmdlet is primarily for:

- Custom data that matches NMM data schemas
- Data from other sources that you want to format like NMM data
- Manual tagging when automatic detection doesn't apply

## Related Links

- [ConvertTo-NMMHtmlReport](ConvertTo-NMMHtmlReport.md)
- [New-NMMReport](New-NMMReport.md)
- [HTML Reports Guide](../../getting-started/reports.md)
