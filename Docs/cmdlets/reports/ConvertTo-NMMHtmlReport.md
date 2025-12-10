# ConvertTo-NMMHtmlReport

Converts pipeline data to a self-contained HTML report.

## Syntax

```powershell
ConvertTo-NMMHtmlReport
    -InputObject <Object[]>
    [-Title <String>]
    [-OutputPath <String>]
    [-ShowChart]
    [-ChartType <String>]
    [-LogoUrl <String>]
    [-Theme <String>]
    [-OpenInBrowser]
    [<CommonParameters>]
```

## Description

The `ConvertTo-NMMHtmlReport` cmdlet creates a single-section HTML report from piped data. It automatically detects the data type via PSTypeName and applies the appropriate template for columns and charts.

For multi-section reports, use `New-NMMReport` with `Add-NMMReportSection` instead.

## Parameters

### -InputObject

The data to convert to an HTML report.

| | |
|---|---|
| Type | Object[] |
| Required | True |
| Pipeline Input | True |

### -Title

Report title displayed in the header.

| | |
|---|---|
| Type | String |
| Required | False |
| Default | "NMM Report" |

### -OutputPath

Path to save the HTML file. If not specified, returns HTML as a string.

| | |
|---|---|
| Type | String |
| Required | False |

### -ShowChart

Include a chart visualization based on template defaults.

| | |
|---|---|
| Type | Switch |
| Required | False |

### -ChartType

Chart type. Overrides the template default.

| | |
|---|---|
| Type | String |
| Required | False |
| Valid Values | `bar`, `pie`, `donut`, `line`, `area` |

### -LogoUrl

URL for a custom logo image. Uses embedded Nerdio logo by default.

| | |
|---|---|
| Type | String |
| Required | False |

### -Theme

Report theme.

| | |
|---|---|
| Type | String |
| Required | False |
| Default | `light` |
| Valid Values | `light`, `dark` |

### -OpenInBrowser

Open the generated report in the default browser after saving.

| | |
|---|---|
| Type | Switch |
| Required | False |

## Examples

### Example 1: Basic device report

```powershell
Get-NMMDevice -AccountId 123 |
    ConvertTo-NMMHtmlReport -Title "Device Inventory" -OutputPath "./devices.html"
```

### Example 2: Report with chart

```powershell
Get-NMMDevice -AccountId 123 |
    ConvertTo-NMMHtmlReport -Title "Compliance" -ShowChart -ChartType pie -OutputPath "./compliance.html"
```

### Example 3: Open in browser

```powershell
Get-NMMHostPool -AccountId 123 | ForEach-Object { $_.HostPool } |
    ConvertTo-NMMHtmlReport -Title "Host Pools" -ShowChart -OutputPath "./pools.html" -OpenInBrowser
```

### Example 4: Get HTML string

```powershell
$html = Get-NMMAccount | ConvertTo-NMMHtmlReport -Title "Accounts"
# Use $html for email, API response, etc.
```

### Example 5: Dark theme

```powershell
Get-NMMBackup -AccountId 123 -ListProtected |
    ConvertTo-NMMHtmlReport -Title "Backup Status" -Theme dark -ShowChart -OutputPath "./backups.html"
```

## Outputs

**With -OutputPath:**

| Property | Type | Description |
|----------|------|-------------|
| Path | String | Full path to saved file |
| Title | String | Report title |
| RecordCount | Int | Number of data records |

**Without -OutputPath:**

Returns HTML content as a string.

## Related Links

- [New-NMMReport](New-NMMReport.md)
- [HTML Reports Guide](../../getting-started/reports.md)
