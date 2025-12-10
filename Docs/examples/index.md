# Examples

Real-world examples and automation scenarios for NMM-PS.

## Report Generation

Generate interactive HTML reports with charts and searchable tables.

- **[Report Generation Examples](reports.md)** - Single-section reports, multi-section dashboards, and advanced patterns

---

## Common Workflows

### Get All Host Pools Across All Accounts

```powershell
# Connect first
Connect-NMMApi

# Get all host pools for all accounts
Get-NMMAccount | Get-NMMHostPool | Format-Table -Property poolName, hostPoolType, resourceGroup
```

### Export Active Sessions Report

```powershell
# Get all active sessions across all accounts
$sessions = Get-NMMAccount | ForEach-Object {
    $account = $_
    Get-NMMHostPool -AccountId $_.id | ForEach-Object {
        Get-NMMHostPoolSession -AccountId $account.id `
            -SubscriptionId $_.subscriptionId `
            -ResourceGroup $_.resourceGroup `
            -PoolName $_.poolName |
        Select-Object @{N='Account';E={$account.name}}, *
    }
}

# Export to CSV
$sessions | Export-Csv -Path "sessions-report.csv" -NoTypeInformation
```

### Check Host Pool Health

```powershell
function Get-HostPoolHealth {
    param([int]$AccountId)

    Get-NMMHostPool -AccountId $AccountId | ForEach-Object {
        $pool = $_
        $hosts = Get-NMMHost -AccountId $AccountId `
            -SubscriptionId $_.subscriptionId `
            -ResourceGroup $_.resourceGroup `
            -PoolName $_.poolName

        [PSCustomObject]@{
            PoolName = $pool.poolName
            TotalHosts = $hosts.Count
            AvailableHosts = ($hosts | Where-Object status -eq 'Available').Count
            UnavailableHosts = ($hosts | Where-Object status -eq 'Unavailable').Count
            TotalSessions = ($hosts | Measure-Object -Property sessionCount -Sum).Sum
        }
    }
}

Get-HostPoolHealth -AccountId 123
```

### Sync Non-Compliant Devices

```powershell
# Find and sync all non-compliant devices
Get-NMMAccount | ForEach-Object {
    $accountId = $_.id
    Get-NMMDevice -AccountId $accountId |
        Where-Object { $_.complianceState -ne 'Compliant' } |
        ForEach-Object {
            Write-Host "Syncing device: $($_.deviceName)"
            Sync-NMMDevice -AccountId $accountId -DeviceId $_.deviceId
        }
}
```

## Authentication Examples

### Certificate-Based Authentication

=== "Windows"

    ```powershell
    # Create and configure certificate
    New-NMMApiCertificate -ExportToCertStore -Upload -UpdateConfig

    # Connect using certificate
    Connect-NMMApi -CertificateThumbprint "YOUR_THUMBPRINT"
    ```

=== "macOS"

    ```powershell
    # Create certificate and import to Keychain
    New-NMMApiCertificate -ExportToCertStore -Upload -UpdateConfig

    # Or import existing P12 to Keychain using Swift tool
    # swift Private/Tools/ImportP12ToKeychain.swift ./cert.pfx "password"

    # Connect using Keychain certificate
    Connect-NMMApi  # Uses Keychain config automatically
    ```

### macOS Keychain Setup

```powershell
# Step 1: Import certificate to Keychain
$result = & swift Private/Tools/ImportP12ToKeychain.swift ./nmm-cert.pfx "password"
# Output: SUCCESS:ABC123DEF456...:NMM-API-Certificate

# Step 2: Extract thumbprint from result
$thumbprint = ($result -split ':')[1]

# Step 3: Update ConfigData.json
@{
    AuthMethod = "Certificate"
    Certificate = @{
        Source = "Keychain"
        Thumbprint = $thumbprint
    }
} | ConvertTo-Json | Set-Content Private/Data/ConfigData.json

# Step 4: Connect
Connect-NMMApi -Verbose
```

### Token Expiry Check

```powershell
function Test-NMMConnection {
    $token = Get-NMMApiToken
    if ($null -eq $token) {
        Write-Host "Not connected. Connecting..."
        Connect-NMMApi
    }
    elseif ($token.Expiry -lt (Get-Date)) {
        Write-Host "Token expired. Reconnecting..."
        Connect-NMMApi
    }
    else {
        Write-Host "Connected. Token valid until $($token.Expiry)"
    }
}
```

## Automation Scenarios

### Scheduled Autoscale Update

```powershell
# Update autoscale settings for all production pools
Get-NMMAccount | Get-NMMHostPool |
    Where-Object { $_.poolName -like "*prod*" } |
    ForEach-Object {
        Set-NMMAutoscale -AccountId $_.accountId `
            -SubscriptionId $_.subscriptionId `
            -ResourceGroup $_.resourceGroup `
            -PoolName $_.poolName `
            -MinActiveHosts 2 `
            -MaxActiveHosts 20
    }
```

### Backup Status Report

```powershell
# Generate backup health report
$report = Get-NMMAccount | ForEach-Object {
    $account = $_
    Get-NMMProtectedItem -AccountId $_.id |
    Select-Object @{N='Account';E={$account.name}},
        friendlyName,
        protectionStatus,
        lastBackupStatus,
        lastBackupTime
}

$report | Where-Object lastBackupStatus -ne 'Completed' |
    Format-Table -AutoSize
```

### User Session Audit

```powershell
# Find users with multiple active sessions
$allSessions = Get-NMMAccount | Get-NMMHostPool | ForEach-Object {
    Get-NMMHostPoolSession -AccountId $_.accountId `
        -SubscriptionId $_.subscriptionId `
        -ResourceGroup $_.resourceGroup `
        -PoolName $_.poolName
}

$allSessions |
    Group-Object userName |
    Where-Object { $_.Count -gt 1 } |
    Select-Object Name, Count |
    Sort-Object Count -Descending
```

## Pipeline Patterns

### Chaining Commands

```powershell
# Full pipeline: Account → Host Pool → Sessions
Get-NMMAccount -Name "Contoso*" |
    Get-NMMHostPool |
    Where-Object { $_.hostPoolType -eq 'Pooled' } |
    Get-NMMHostPoolSession |
    Format-Table userName, sessionHost, sessionState
```

### Filtering with Where-Object

```powershell
# Find pools with high session counts
Get-NMMAccount | Get-NMMHostPool | ForEach-Object {
    $sessions = Get-NMMHostPoolSession -AccountId $_.accountId `
        -SubscriptionId $_.subscriptionId `
        -ResourceGroup $_.resourceGroup `
        -PoolName $_.poolName

    [PSCustomObject]@{
        Pool = $_.poolName
        Sessions = $sessions.Count
    }
} | Where-Object Sessions -gt 10
```

## Error Handling

### Robust API Calls

```powershell
function Invoke-SafeNMMCommand {
    param(
        [scriptblock]$Command,
        [int]$MaxRetries = 3
    )

    $attempt = 0
    while ($attempt -lt $MaxRetries) {
        try {
            return & $Command
        }
        catch {
            $attempt++
            if ($attempt -eq $MaxRetries) {
                throw $_
            }
            Write-Warning "Attempt $attempt failed. Retrying..."
            Start-Sleep -Seconds (2 * $attempt)
        }
    }
}

# Usage
Invoke-SafeNMMCommand { Get-NMMHostPool -AccountId 123 }
```
