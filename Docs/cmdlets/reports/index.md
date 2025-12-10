# Reports

Cmdlets for generating interactive HTML reports from NMM data.

## Overview

The report cmdlets enable you to create professional, self-contained HTML reports with:

- Interactive tables (search, sort, paginate)
- Charts (bar, pie, donut, line, area)
- Nerdio branding
- Dark/light themes
- Automatic template detection

## Cmdlets

| Cmdlet | Description |
|--------|-------------|
| [ConvertTo-NMMHtmlReport](ConvertTo-NMMHtmlReport.md) | Simple pipeline to HTML report |
| [New-NMMReport](New-NMMReport.md) | Initialize multi-section report builder |
| [Add-NMMReportSection](Add-NMMReportSection.md) | Add section to report builder |
| [Export-NMMReport](Export-NMMReport.md) | Generate final HTML output |
| [Add-NMMTypeName](Add-NMMTypeName.md) | Tag data with PSTypeName for templates |

## Quick Examples

### Simple Pipeline Report

```powershell
Get-NMMDevice -AccountId 123 |
    ConvertTo-NMMHtmlReport -Title "Devices" -ShowChart -OutputPath "./devices.html"
```

### Multi-Section Dashboard

```powershell
$report = New-NMMReport -Title "Dashboard"
$report | Add-NMMReportSection -Title "Pools" -Data $pools -ShowChart
$report | Add-NMMReportSection -Title "Devices" -Data $devices -ShowChart
$report | Export-NMMReport -OutputPath "./dashboard.html" -OpenInBrowser
```

## Supported Data Types

| PSTypeName | Display Name | Default Chart |
|------------|--------------|---------------|
| `NMM.HostPool` | Host Pool | Donut (by auto-scale status) |
| `NMM.Host` | Session Host | Donut (by power state) |
| `NMM.Device` | Intune Device | Pie (by compliance) |
| `NMM.Account` | Account | None |
| `NMM.User` | User | None |
| `NMM.Backup` | Backup Item | Donut (by protection state) |

## Related

- [HTML Reports Guide](../../getting-started/reports.md) - Comprehensive guide
- [Report Examples](../../examples/reports.md) - Example scripts
