# Report Generation Examples

Real-world examples for generating HTML reports from NMM data.

## Quick Single-Section Reports

### Host Pool Inventory

```powershell
# Get host pools and generate report
$hostPools = (Get-NMMHostPool -AccountId 123).HostPool

$hostPools | ConvertTo-NMMHtmlReport `
    -Title "Host Pool Inventory" `
    -ShowChart -ChartType donut `
    -OutputPath "./HostPool-Report.html" `
    -OpenInBrowser
```

### Device Compliance Report

```powershell
# Compliance overview with pie chart
Get-NMMDevice -AccountId 123 |
    ConvertTo-NMMHtmlReport `
        -Title "Device Compliance Status" `
        -ShowChart -ChartType pie `
        -OutputPath "./Compliance-Report.html" `
        -OpenInBrowser
```

### Backup Status Report

```powershell
# Backup protection state overview
Get-NMMBackup -AccountId 123 -ListProtected |
    ConvertTo-NMMHtmlReport `
        -Title "Backup Protection Status" `
        -ShowChart -ChartType donut `
        -OutputPath "./Backup-Report.html" `
        -OpenInBrowser
```

---

## Multi-Section Dashboards

### Complete Account Report

A comprehensive report gathering all data types for an account:

```powershell
$AccountId = 67

Import-Module ./NMM-PS.psm1 -Force
Connect-NMMApi | Out-Null

Write-Host "=== Gathering All Data for Account $AccountId ===" -ForegroundColor Cyan

# Host Pools
Write-Host "Fetching Host Pools..." -ForegroundColor Yellow
$hostPools = (Get-NMMHostPool -AccountId $AccountId).HostPool

# Session Hosts - from ALL host pools
Write-Host "Fetching Session Hosts from all pools..." -ForegroundColor Yellow
$allHosts = @()
foreach ($pool in $hostPools) {
    $poolHosts = Get-NMMHost -AccountId $AccountId `
        -SubscriptionId $pool.subscription `
        -ResourceGroup $pool.resourceGroup `
        -PoolName $pool.hostPoolName -ErrorAction SilentlyContinue
    if ($poolHosts) {
        $allHosts += $poolHosts
    }
}
Write-Host "  Found $($allHosts.Count) hosts across $($hostPools.Count) pools"

# Devices
Write-Host "Fetching Devices..." -ForegroundColor Yellow
$devices = Get-NMMDevice -AccountId $AccountId

# Accounts
Write-Host "Fetching Accounts..." -ForegroundColor Yellow
$accounts = Get-NMMAccount

# Users
Write-Host "Fetching Users..." -ForegroundColor Yellow
$users = Get-NMMUsers -AccountId $AccountId -Top 50

# Backups
Write-Host "Fetching Backups..." -ForegroundColor Yellow
$backups = Get-NMMBackup -AccountId $AccountId -ListProtected

Write-Host "`n=== Building Multi-Section Report ===" -ForegroundColor Cyan

# Create report with splatting
$reportParams = @{
    Title    = "NMM Complete Report"
    Subtitle = "Account ID: $AccountId - $(Get-Date -Format 'MMMM yyyy')"
}
$report = New-NMMReport @reportParams

# Add sections
$report | Add-NMMReportSection -Title "Host Pools ($($hostPools.Count))" -Data $hostPools -ShowChart -ChartType donut
$report | Add-NMMReportSection -Title "Session Hosts ($($allHosts.Count))" -Data $allHosts -ShowChart -ChartType donut
$report | Add-NMMReportSection -Title "Intune Devices ($($devices.Count))" -Data $devices -ShowChart -ChartType pie
$report | Add-NMMReportSection -Title "NMM Accounts ($($accounts.Count))" -Data $accounts
$report | Add-NMMReportSection -Title "Users ($($users.Count))" -Data $users
$report | Add-NMMReportSection -Title "Backup Items ($($backups.Count))" -Data $backups -ShowChart -ChartType donut

# Export with splatting
$exportParams = @{
    OutputPath    = "./NMM-Complete-Report.html"
    OpenInBrowser = $true
}
$result = $report | Export-NMMReport @exportParams

Write-Host "`n=== Report Summary ===" -ForegroundColor Green
Write-Host "Path: $($result.Path)"
Write-Host "Sections: $($result.SectionCount)"
Write-Host "Size: $([math]::Round((Get-Item $exportParams.OutputPath).Length / 1024, 1)) KB"
```

### AVD Infrastructure Report

Focus on Azure Virtual Desktop components:

```powershell
$AccountId = 123
Connect-NMMApi | Out-Null

# Collect AVD data
$hostPools = (Get-NMMHostPool -AccountId $AccountId).HostPool
$allHosts = @()
foreach ($pool in $hostPools) {
    $hosts = Get-NMMHost -AccountId $AccountId `
        -SubscriptionId $pool.subscription `
        -ResourceGroup $pool.resourceGroup `
        -PoolName $pool.hostPoolName -ErrorAction SilentlyContinue
    if ($hosts) { $allHosts += $hosts }
}

# Build report
$report = New-NMMReport -Title "AVD Infrastructure Report" -Subtitle "$(Get-Date -Format 'yyyy-MM-dd HH:mm')"

$report | Add-NMMReportSection `
    -Title "Host Pools ($($hostPools.Count))" `
    -Description "Azure Virtual Desktop host pool configuration" `
    -Data $hostPools `
    -ShowChart -ChartType donut

$report | Add-NMMReportSection `
    -Title "Session Hosts ($($allHosts.Count))" `
    -Description "Virtual machines serving as session hosts" `
    -Data $allHosts `
    -ShowChart -ChartType donut

$report | Export-NMMReport -OutputPath "./AVD-Infrastructure.html" -OpenInBrowser
```

### Security & Compliance Dashboard

```powershell
$AccountId = 123
Connect-NMMApi | Out-Null

# Collect security-related data
$devices = Get-NMMDevice -AccountId $AccountId
$backups = Get-NMMBackup -AccountId $AccountId -ListProtected
$users = Get-NMMUsers -AccountId $AccountId -Top 100

# Build security dashboard
$report = New-NMMReport -Title "Security & Compliance Dashboard" -Theme dark

$report | Add-NMMReportSection `
    -Title "Device Compliance ($($devices.Count) devices)" `
    -Data $devices `
    -ShowChart -ChartType pie

$report | Add-NMMReportSection `
    -Title "Backup Protection ($($backups.Count) items)" `
    -Data $backups `
    -ShowChart -ChartType donut

$report | Add-NMMReportSection `
    -Title "User Accounts ($($users.Count) users)" `
    -Data $users

$report | Export-NMMReport -OutputPath "./Security-Dashboard.html" -OpenInBrowser
```

---

## Advanced Patterns

### Custom Data with Add-NMMTypeName

When working with custom data or data from other sources:

```powershell
# Create custom data that matches NMM.HostPool schema
$customPools = @(
    [PSCustomObject]@{
        hostPoolName = "Production-Pool"
        resourceGroup = "rg-avd-prod"
        subscription = "sub-prod-001"
        isAutoScaleEnabled = $true
    }
    [PSCustomObject]@{
        hostPoolName = "Development-Pool"
        resourceGroup = "rg-avd-dev"
        subscription = "sub-dev-001"
        isAutoScaleEnabled = $false
    }
)

# Tag with PSTypeName for template matching
$customPools | Add-NMMTypeName -TypeName 'NMM.HostPool' |
    ConvertTo-NMMHtmlReport `
        -Title "Custom Pool Report" `
        -ShowChart -ChartType donut `
        -OutputPath "./custom-pools.html"
```

### Automated Scheduled Reports

Create a script for scheduled execution:

```powershell
# scheduled-report.ps1
param(
    [int]$AccountId = 67,
    [string]$OutputDir = "./Reports"
)

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Connect
Import-Module NMM-PS -Force
Connect-NMMApi | Out-Null

# Generate timestamp for filename
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$outputPath = Join-Path $OutputDir "NMM-Report_$timestamp.html"

# Collect data
$hostPools = (Get-NMMHostPool -AccountId $AccountId).HostPool
$devices = Get-NMMDevice -AccountId $AccountId
$backups = Get-NMMBackup -AccountId $AccountId -ListProtected

# Build report
$report = New-NMMReport `
    -Title "Automated NMM Report" `
    -Subtitle "Account $AccountId - Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

$report | Add-NMMReportSection -Title "Host Pools" -Data $hostPools -ShowChart -ChartType donut
$report | Add-NMMReportSection -Title "Devices" -Data $devices -ShowChart -ChartType pie
$report | Add-NMMReportSection -Title "Backups" -Data $backups -ShowChart -ChartType donut

$result = $report | Export-NMMReport -OutputPath $outputPath

Write-Output "Report generated: $($result.Path)"

# Optional: Send via email
# Send-MailMessage -To "admin@company.com" -Subject "NMM Report" -Attachments $result.Path ...
```

### Pipeline Chaining with PassThru

Use `-PassThru` for fluent pipeline syntax:

```powershell
New-NMMReport -Title "Chained Report" |
    Add-NMMReportSection -Title "Pools" -Data $pools -ShowChart -PassThru |
    Add-NMMReportSection -Title "Hosts" -Data $hosts -ShowChart -PassThru |
    Add-NMMReportSection -Title "Devices" -Data $devices -ShowChart -PassThru |
    Add-NMMReportSection -Title "Backups" -Data $backups -ShowChart -PassThru |
    Export-NMMReport -OutputPath "./chained-report.html" -OpenInBrowser
```

### Multiple Accounts Report

Generate a report spanning multiple accounts:

```powershell
Connect-NMMApi | Out-Null

# Get all accounts
$accounts = Get-NMMAccount

# Collect host pools from all accounts
$allPools = @()
foreach ($account in $accounts) {
    $pools = (Get-NMMHostPool -AccountId $account.id -ErrorAction SilentlyContinue).HostPool
    if ($pools) {
        # Add account name for context
        foreach ($pool in $pools) {
            $pool | Add-Member -NotePropertyName 'accountName' -NotePropertyValue $account.name -Force
        }
        $allPools += $pools
    }
}

# Build consolidated report
$report = New-NMMReport -Title "Multi-Account AVD Overview" -Subtitle "$($accounts.Count) accounts"
$report | Add-NMMReportSection -Title "All Accounts ($($accounts.Count))" -Data $accounts
$report | Add-NMMReportSection -Title "All Host Pools ($($allPools.Count))" -Data $allPools -ShowChart -ChartType donut
$report | Export-NMMReport -OutputPath "./multi-account-report.html" -OpenInBrowser
```

---

## Output Examples

### Report Object

When saving to file, `Export-NMMReport` returns metadata:

```powershell
$result = $report | Export-NMMReport -OutputPath "./report.html"
$result

# Output:
# Path         : /full/path/to/report.html
# Title        : NMM Complete Report
# SectionCount : 6
# GeneratedAt  : 12/10/2024 2:30:45 PM
```

### HTML String

For integration with other systems:

```powershell
$html = $report | Export-NMMReport -ReturnHtml

# Use in email body
Send-MailMessage -Body $html -BodyAsHtml ...

# Or save to blob storage, API response, etc.
```
