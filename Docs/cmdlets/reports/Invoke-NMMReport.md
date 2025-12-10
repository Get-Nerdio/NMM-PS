# Invoke-NMMReport

Generate pre-built HTML reports for NMM accounts with a single command.

## Synopsis

```powershell
Invoke-NMMReport
    [-ReportType <String>]
    -AccountId <Int32>
    [-OutputPath <String>]
    [-OpenInBrowser]
    [-Theme <String>]
```

## Description

`Invoke-NMMReport` provides ready-to-use report templates that automatically fetch data from multiple NMM API endpoints and generate comprehensive HTML reports.

**Key Features:**

- **Interactive Menu**: When called without `-ReportType`, displays a menu for report selection
- **One-Command Reports**: Automatically fetches all required data and generates the report
- **4 Pre-built Templates**: AccountOverview, DeviceInventory, SecurityCompliance, Infrastructure
- **Progress Tracking**: Shows progress as each section is fetched
- **Scriptable**: Use `-ReportType` parameter for automation scenarios
- **Smart Data Handling**: Automatically flattens nested arrays and resolves cross-resource contexts

## Parameters

### -ReportType

The type of report to generate. If not specified, displays an interactive selection menu.

| Type | Description |
|------|-------------|
| `AccountOverview` | Host pools, session hosts, images, and users |
| `DeviceInventory` | Intune devices with compliance, hardware, and apps |
| `SecurityCompliance` | Device compliance, backup status, and users |
| `Infrastructure` | Complete AVD infrastructure configuration |

```yaml
Type: String
Required: False
ValidateSet: AccountOverview, DeviceInventory, SecurityCompliance, Infrastructure
```

### -AccountId

The NMM account ID to generate the report for.

```yaml
Type: Int32
Required: True
```

### -OutputPath

Path for the output HTML file. Defaults to `./NMM-{ReportType}_{timestamp}.html`

```yaml
Type: String
Required: False
Default: ./NMM-{ReportType}_{yyyy-MM-dd_HHmm}.html
```

### -OpenInBrowser

Automatically open the generated report in the default browser.

```yaml
Type: SwitchParameter
Required: False
```

### -Theme

Report theme: `light` (default) or `dark`.

```yaml
Type: String
Required: False
Default: light
ValidateSet: light, dark
```

## Examples

### Example 1: Interactive Mode

```powershell
Invoke-NMMReport -AccountId 67
```

Displays an interactive menu:

```
  NMM Pre-built Reports
  ========================================

  [1] AccountOverview
      Complete account summary including host pools, session hosts, images, and users

  [2] DeviceInventory
      Intune-managed device fleet overview

  [3] SecurityCompliance
      Security posture and compliance overview

  [4] Infrastructure
      Complete AVD infrastructure configuration

  [0] Cancel

  Select report type (1-4):
```

### Example 2: Direct Generation

```powershell
Invoke-NMMReport -ReportType AccountOverview -AccountId 67 -OpenInBrowser
```

Generates an Account Overview report and opens it in the browser.

### Example 3: Dark Theme with Custom Path

```powershell
Invoke-NMMReport -ReportType SecurityCompliance -AccountId 67 -Theme dark -OutputPath "./reports/security.html"
```

### Example 4: Scheduled Report Generation

```powershell
# Daily infrastructure report
$reportPath = "C:\Reports\Infrastructure_$(Get-Date -Format 'yyyy-MM-dd').html"
Invoke-NMMReport -ReportType Infrastructure -AccountId 67 -OutputPath $reportPath
```

## Report Types

### AccountOverview

A comprehensive view of your NMM account's AVD infrastructure and user base.

**Sections:**

| Section | Data Source | Chart |
|---------|-------------|-------|
| Host Pools | Get-NMMHostPool | Donut (autoscale status) |
| Session Hosts | Get-NMMHost | Donut (power state) |
| Desktop Images | Get-NMMDesktopImage | Table only |
| Users | Get-NMMUsers | Table only |

### DeviceInventory

Complete inventory of Intune devices including compliance, hardware specs, and installed applications.

**Sections:**

| Section | Data Source | Chart |
|---------|-------------|-------|
| Devices | Get-NMMDevice | Pie (compliance state) |
| Compliance Details | Get-NMMDeviceCompliance | Table only |
| Hardware Information | Get-NMMDeviceHardware | Table only |
| Installed Applications | Get-NMMDeviceApp | Table only |

### SecurityCompliance

Assessment of device compliance, backup coverage, and user security status.

**Sections:**

| Section | Data Source | Chart |
|---------|-------------|-------|
| Device Compliance | Get-NMMDevice | Pie (compliance state) |
| Backup Protection | Get-NMMProtectedItem | Donut (protection state) |
| User Accounts | Get-NMMUsers | Table only |

### Infrastructure

Detailed view of all infrastructure components including host pools, images, profiles, and settings.

**Sections:**

| Section | Data Source | Chart |
|---------|-------------|-------|
| Host Pools | Get-NMMHostPool | Donut (autoscale status) |
| Session Hosts | Get-NMMHost | Donut (power state) |
| Desktop Images | Get-NMMDesktopImage | Table only |
| FSLogix Configurations | Get-NMMFSLogixConfig | Table only |
| Directories | Get-NMMDirectory | Table only |
| Environment Variables | Get-NMMEnvironmentVariable | Table only |

## Output

Returns a `PSCustomObject` with report metadata:

```powershell
Path         : ./NMM-AccountOverview_2024-12-10_1430.html
Title        : Account Overview Report
SectionCount : 4
GeneratedAt  : 12/10/2024 2:30:45 PM
```

## How it Works

The function performs several automatic data transformations:

1. **Context Resolution**: Session hosts require host pool context. The function automatically fetches all host pools and iterates through them to collect hosts from each pool.

2. **Device Context**: For DeviceInventory, compliance/hardware/app data requires per-device calls. The function fetches all devices first, then retrieves details for each.

3. **Data Flattening**: Nested arrays (like compliance policy states) are automatically summarized for table display:
   - `compliancePolicyStates: [...]` becomes `"2 Compliant, 1 Error"`
   - `managedApps: [...]` becomes `"93 items"`

4. **Type Mapping**: Data is automatically tagged with template types (`NMM.Device`, `NMM.Backup`, etc.) for proper column formatting.

## Notes

- Pre-built reports are defined in `Private/Data/PrebuiltReports.json`
- Report templates are defined in `Private/Data/ReportTemplates.json`
- Reports can be customized by editing the JSON configuration
- For custom reports with specific data combinations, use `New-NMMReport` and `Add-NMMReportSection` directly
- Some API endpoints may return empty data depending on account configuration

## Related Links

- [New-NMMReport](New-NMMReport.md)
- [Add-NMMReportSection](Add-NMMReportSection.md)
- [Export-NMMReport](Export-NMMReport.md)
- [ConvertTo-NMMHtmlReport](ConvertTo-NMMHtmlReport.md)
