# Add-NMMReportSection

Adds a data section to an NMM report.

## Syntax

```powershell
Add-NMMReportSection
    -ReportBuilder <NMMReportBuilder>
    -Title <String>
    [-Description <String>]
    [-Data <Object>]
    [-ShowChart]
    [-ChartType <String>]
    [-ChartConfig <Hashtable>]
    [-HideTable]
    [-CustomHtml <String>]
    [-PassThru]
    [<CommonParameters>]
```

## Description

The `Add-NMMReportSection` cmdlet adds data sections with optional charts to an existing report builder. The template is automatically selected based on the data's PSTypeName.

## Parameters

### -ReportBuilder

The report builder object from `New-NMMReport`.

| | |
|---|---|
| Type | NMMReportBuilder |
| Required | True |
| Pipeline Input | True |

### -Title

Section title displayed in the section header.

| | |
|---|---|
| Type | String |
| Required | True |

### -Description

Optional section description displayed below the header.

| | |
|---|---|
| Type | String |
| Required | False |

### -Data

The data for this section. Should be an array of objects.

| | |
|---|---|
| Type | Object |
| Required | False |

### -ShowChart

Include a chart visualization based on the data.

| | |
|---|---|
| Type | Switch |
| Required | False |

### -ChartType

Chart type for visualization.

| | |
|---|---|
| Type | String |
| Required | False |
| Default | `bar` |
| Valid Values | `bar`, `pie`, `donut`, `line`, `area` |

### -ChartConfig

Custom chart configuration hashtable. Overrides template defaults.

| | |
|---|---|
| Type | Hashtable |
| Required | False |

### -HideTable

Hide the data table (show only chart if enabled).

| | |
|---|---|
| Type | Switch |
| Required | False |

### -CustomHtml

Custom HTML content to include in the section.

| | |
|---|---|
| Type | String |
| Required | False |

### -PassThru

Returns the report builder for pipeline chaining.

| | |
|---|---|
| Type | Switch |
| Required | False |

## Examples

### Example 1: Basic section with chart

```powershell
$report | Add-NMMReportSection -Title "Host Pools" -Data $pools -ShowChart
```

### Example 2: Section with description

```powershell
$report | Add-NMMReportSection `
    -Title "Session Hosts" `
    -Description "Virtual machines serving as session hosts" `
    -Data $hosts `
    -ShowChart -ChartType donut
```

### Example 3: Pipeline chaining with PassThru

```powershell
$report | Add-NMMReportSection -Title "Pools" -Data $pools -ShowChart -PassThru |
          Add-NMMReportSection -Title "Hosts" -Data $hosts -ShowChart -PassThru |
          Add-NMMReportSection -Title "Users" -Data $users
```

### Example 4: Chart only (no table)

```powershell
$report | Add-NMMReportSection -Title "Compliance Overview" -Data $devices -ShowChart -ChartType pie -HideTable
```

### Example 5: Custom HTML section

```powershell
$report | Add-NMMReportSection `
    -Title "Status" `
    -CustomHtml "<div class='alert alert-success'>All systems operational</div>"
```

### Example 6: Include record count in title

```powershell
$report | Add-NMMReportSection -Title "Devices ($($devices.Count))" -Data $devices -ShowChart -ChartType pie
```

## Outputs

**None** by default.

With `-PassThru`: Returns the **NMMReportBuilder** for pipeline chaining.

## Related Links

- [New-NMMReport](New-NMMReport.md)
- [Export-NMMReport](Export-NMMReport.md)
- [HTML Reports Guide](../../getting-started/reports.md)
