# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NMM-PS is a PowerShell module that provides cmdlets to interact with the Nerdio Manager for MSP (NMM) API. It enables automation of Azure Virtual Desktop management tasks including accounts, host pools, backups, FSLogix configurations, and Partner Center bulk enrollment.

**Requirements:** PowerShell 7.0+

**Documentation:** https://Get-Nerdio.github.io/NMM-PS/

## Architecture

```
NMM-PS/
├── NMM-PS.psm1          # Module loader - dot-sources all functions from Public/ and Private/
├── NMM-PS.psd1          # Module manifest
├── Public/              # Exported cmdlets (user-facing API)
├── Private/             # Internal helper functions
│   └── Data/            # Configuration files (ConfigData.json)
├── Tests/               # Pester tests
├── docs/                # MkDocs documentation source (auto-deploys to GitHub Pages)
├── Docs/                # Legacy PlatyPS cmdlet docs
├── en-US/               # MAML help for Get-Help
├── mkdocs.yml           # MkDocs configuration
├── requirements.txt     # Python dependencies for MkDocs
├── .github/workflows/   # GitHub Actions (docs deployment)
├── BrowserExtension/    # Chrome/Edge extension for Hidden API auth
└── Templates/           # Example usage templates
```

### Core Flow

1. `Connect-NMMApi` authenticates via OAuth2 client credentials (secret or certificate) and caches token in `$script:cachedToken`
2. All API calls go through `Invoke-APIRequest` which handles auth headers, token refresh, and JSON serialization
3. Public cmdlets wrap `Invoke-APIRequest` with domain-specific parameters and filtering

### Key Files

- `Public/Connect-NMMApi.ps1` - Config loading and OAuth token acquisition (supports secret and certificate auth)
- `Public/Invoke-ApiRequest.ps1` - Central API request handler with query parameter support
- `Private/Get-ConfigData.ps1` - Supports `NMM_DEV_MODE=true` env var for local development config
- `Private/New-JwtAssertion.ps1` - JWT assertion signing for certificate-based authentication

## Configuration

API credentials stored in `Private/Data/ConfigData.json`:

### Client Secret Authentication
```json
{
    "BaseUri": "https://api.yournmmdomain.com",
    "TenantId": "your-tenant-id",
    "ClientId": "your-client-id",
    "Scope": "111111-111-1111-11111-1111111111/.default",
    "Secret": "your-secret"
}
```

### Certificate Authentication (Recommended)
```json
{
    "BaseUri": "https://api.yournmmdomain.com",
    "TenantId": "your-tenant-id",
    "ClientId": "your-client-id",
    "Scope": "111111-111-1111-11111-1111111111/.default",
    "Certificate": {
        "Source": "PfxFile",
        "Thumbprint": "ABC123...",
        "PfxPath": "./path/to/cert.pfx",
        "PfxPassword": "password"
    }
}
```

For local development, set `$env:NMM_DEV_MODE = 'true'` to use `ConfigData-Local.json` instead.

## Commands

```powershell
# Import module
Import-Module ./NMM-PS.psm1

# Run tests
Invoke-Pester ./Tests/

# Run single test file
Invoke-Pester ./Tests/Set-LogSettings.Tests.ps1

# Build/serve documentation locally
pip install -r requirements.txt
mkdocs serve  # http://127.0.0.1:8000
```

## Cmdlet Reference

### Authentication & Core
- `Connect-NMMApi` - Authenticate to NMM API (supports secret and certificate auth)
- `Invoke-APIRequest` - Internal API handler (supports v1 and v1-beta)
- `Get-NMMAccount` - List/filter NMM accounts
- `Get-NMMApiToken` - Get current cached API token
- `New-NMMApiCertificate` - Create self-signed certificate for authentication

### Host Pool (Tier 1)
- `Get-NMMHostPool` - List host pools for an account
- `Get-NMMHostPoolSettings` - AVD properties (max sessions, load balancer)
- `Get-NMMHostPoolAutoscale` - Autoscale configuration
- `Get-NMMHostPoolAD` - Active Directory settings
- `Get-NMMHostPoolRDP` - RDP settings (redirections, display)
- `Get-NMMHostPoolFSLogix` - FSLogix profile configuration
- `Get-NMMHostPoolVMDeployment` - VM deployment settings
- `Get-NMMHostPoolTimeout` - Session timeout settings
- `Get-NMMHostPoolTag` - Azure resource tags
- `Get-NMMHostPoolSchedule` - Scheduled jobs for pool
- `Get-NMMHostPoolUser` - Assigned users/groups
- `Get-NMMHostPoolSession` - Active user sessions
- `New-NMMHostPool` - Create new host pool
- `Remove-NMMHostPool` - Delete host pool
- `Set-NMMAutoscale` - Configure autoscale settings

### Session Hosts (Tier 1)
- `Get-NMMHost` - List session hosts in a pool
- `Get-NMMHostSchedule` - Scheduled jobs for a host

### Desktop Images (Tier 1)
- `Get-NMMDesktopImage` - List golden images
- `Get-NMMDesktopImageDetail` - Image configuration
- `Get-NMMDesktopImageLog` - Image change history
- `Get-NMMDesktopImageSchedule` - Image maintenance schedules

### Users & Groups (Tier 1)
- `Get-NMMUsers` - List/search users (POST with pagination)
- `Get-NMMUser` - Single user details
- `Get-NMMUserMFA` - User MFA status
- `Get-NMMGroup` - Group details
- `Get-NMMWorkspaceSession` - Workspace sessions

### Backup (Tier 1)
- `Get-NMMBackup` - Backup items
- `Get-NMMProtectedItem` - Backup protected items
- `Get-NMMRecoveryPoint` - Recovery points

### Automation (Tier 2) - Support `-Scope Account|Global`
- `Get-NMMScriptedAction` - List scripted actions
- `Get-NMMScriptedActionSchedule` - Scripted action schedules
- `Get-NMMSchedule` - List schedules
- `Get-NMMScheduleConfig` - Schedule configuration
- `Get-NMMAutoscaleProfile` - Autoscale profiles

### Intune/Devices (Tier 3 - Beta API)
- `Get-NMMDevice` - List Intune devices
- `Get-NMMDeviceCompliance` - Device compliance status
- `Get-NMMDeviceApp` - Installed applications
- `Get-NMMDeviceAppFailure` - Failed app installations
- `Get-NMMDeviceHardware` - Hardware information
- `Get-NMMDeviceLAPS` - Local admin password (SENSITIVE)
- `Get-NMMDeviceBitLocker` - BitLocker keys (SENSITIVE)
- `Sync-NMMDevice` - Force Intune sync

### Infrastructure & Config
- `Get-NMMDirectory` - AD directories (account or global)
- `Get-NMMEnvironmentVariable` - Environment variables (account or global)
- `Get-NMMFSLogixConfig` - FSLogix configurations for account
- `Get-NMMImageTemplate` - Desktop image templates
- `Get-NMMWorkspace` - AVD workspaces

### Billing & Cost
- `Get-NMMInvoice` - List/filter invoices
- `Get-NMMCostEstimator` - Cost estimates

### Hidden API (Internal Web Portal)
- `Connect-NMMHiddenApi` - Start listener & open browser for cookie auth
- `Set-NMMHiddenApiCookie` - Manually set cookies
- `Invoke-HiddenApiRequest` - Call internal NMM web portal APIs

## Adding New Cmdlets

1. Create function in `Public/` for exported cmdlets or `Private/` for internal helpers
2. Functions are auto-loaded by `NMM-PS.psm1` via dot-sourcing
3. Use `Invoke-APIRequest` for all NMM API calls with `-ApiVersion 'v1'` or `'v1-beta'`
4. Support pipeline input with `ValueFromPipelineByPropertyName` and `Alias` attributes
5. Add Pester tests in `Tests/` for each new cmdlet
6. Add documentation in `docs/cmdlets/<category>/` for the MkDocs site

### Cmdlet Template
```powershell
function Get-NMMResource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [int]$AccountId
    )
    process {
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/resource"
    }
}
```

### Pipeline Aliases
| Property | Alias |
|----------|-------|
| AccountId | `id` |
| SubscriptionId | `subscription` |
| PoolName | `hostPoolName` |
| ResourceGroup | `resourceGroup` |

## Documentation

The documentation site uses MkDocs with Material theme and Nerdio branding.

### Local Development
```bash
pip install -r requirements.txt
mkdocs serve
```

### Deployment
Documentation auto-deploys to GitHub Pages via `.github/workflows/docs.yml` when pushing to main.

### Structure
- `docs/index.md` - Homepage
- `docs/getting-started/` - Installation, configuration, authentication guides
- `docs/cmdlets/` - Cmdlet reference organized by category
- `docs/examples/` - Usage examples
- `docs/changelog.md` - Version history