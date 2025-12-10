# Export-NMMReport

Generates the final HTML report from a report builder.

## Syntax

```powershell
# Save to file
Export-NMMReport
    -ReportBuilder <NMMReportBuilder>
    -OutputPath <String>
    [-OpenInBrowser]
    [<CommonParameters>]

# Return HTML string
Export-NMMReport
    -ReportBuilder <NMMReportBuilder>
    -ReturnHtml
    [<CommonParameters>]
```

## Description

The `Export-NMMReport` cmdlet renders all sections into a self-contained HTML file with embedded CSS, JavaScript libraries (via CDN), and Nerdio branding. The generated report includes interactive tables (DataTables) and charts (ApexCharts).

## Parameters

### -ReportBuilder

The report builder object with sections from `New-NMMReport`.

| | |
|---|---|
| Type | NMMReportBuilder |
| Required | True |
| Pipeline Input | True |

### -OutputPath

Path to save the HTML file.

| | |
|---|---|
| Type | String |
| Required | True (File parameter set) |

### -ReturnHtml

Return HTML string instead of saving to file.

| | |
|---|---|
| Type | Switch |
| Required | True (String parameter set) |

### -OpenInBrowser

Open the generated report in the default browser after saving.

| | |
|---|---|
| Type | Switch |
| Required | False |
| Parameter Set | File |

## Examples

### Example 1: Export to file

```powershell
$report | Export-NMMReport -OutputPath "./report.html"
```

### Example 2: Export and open in browser

```powershell
$report | Export-NMMReport -OutputPath "./report.html" -OpenInBrowser
```

### Example 3: Get HTML string

```powershell
$html = $report | Export-NMMReport -ReturnHtml
# Use for email body, API response, etc.
```

### Example 4: Using splatting

```powershell
$exportParams = @{
    OutputPath    = "./NMM-Complete-Report.html"
    OpenInBrowser = $true
}
$result = $report | Export-NMMReport @exportParams

Write-Host "Report saved: $($result.Path)"
Write-Host "Sections: $($result.SectionCount)"
```

### Example 5: Full pipeline

```powershell
New-NMMReport -Title "Dashboard" |
    Add-NMMReportSection -Title "Pools" -Data $pools -ShowChart -PassThru |
    Add-NMMReportSection -Title "Devices" -Data $devices -ShowChart -PassThru |
    Export-NMMReport -OutputPath "./dashboard.html" -OpenInBrowser
```

## Outputs

**With -OutputPath:**

| Property | Type | Description |
|----------|------|-------------|
| Path | String | Full path to saved file |
| Title | String | Report title |
| SectionCount | Int | Number of sections |
| GeneratedAt | DateTime | Generation timestamp |

**With -ReturnHtml:**

Returns the HTML content as a string.

## Notes

The generated HTML includes:

- **DataTables.js** - Interactive tables with search, sort, pagination
- **ApexCharts** - Chart visualizations
- **Nerdio branding** - Embedded logo and styling
- **Responsive design** - Works on desktop and mobile

All JavaScript libraries are loaded via CDN for optimal performance.

## Related Links

- [New-NMMReport](New-NMMReport.md)
- [Add-NMMReportSection](Add-NMMReportSection.md)
- [HTML Reports Guide](../../getting-started/reports.md)
