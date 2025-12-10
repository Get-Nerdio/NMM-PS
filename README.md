![image](https://github.com/Get-Nerdio/NMM-SE/assets/52416805/5c8dd05e-84a7-49f9-8218-64412fdaffaf)

# NMM-PS Module

PowerShell module for the Nerdio Manager for MSP (NMM) REST API.

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/NMM-PS?label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/NMM-PS)
[![Documentation](https://img.shields.io/badge/docs-Get--Nerdio.github.io%2FNMM--PS-blue)](https://Get-Nerdio.github.io/NMM-PS/)
[![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue)](https://github.com/PowerShell/PowerShell)

> **Disclaimer:** This is an **unofficial**, community-maintained module created by Nerdio Sales Engineers. It is **not officially supported** by Nerdio. Use at your own risk.

## Documentation

Full documentation: **[https://Get-Nerdio.github.io/NMM-PS/](https://Get-Nerdio.github.io/NMM-PS/)**

---

## Installation

### PowerShell Gallery (Recommended)

```powershell
Install-Module -Name NMM-PS -Scope CurrentUser
```

### Update Existing Installation

```powershell
Update-Module -Name NMM-PS
```

### Alternative: Install from GitHub

```powershell
# Quick install script
iex (irm https://raw.githubusercontent.com/Get-Nerdio/NMM-PS/main/Install.ps1)

# Or clone and import manually
git clone https://github.com/Get-Nerdio/NMM-PS.git
Import-Module ./NMM-PS/NMM-PS.psm1
```

---

## Quick Start

### 1. Configure API Credentials

Create `Private/Data/ConfigData.json`:

```json
{
    "BaseUri": "https://api.yournmmdomain.com",
    "TenantId": "your-tenant-id",
    "ClientId": "your-client-id",
    "Scope": "111111-111-1111-11111-1111111111/.default",
    "ClientSecret": "your-secret"
}
```

See [NMM API Docs](https://nmmhelp.getnerdio.com/hc/en-us/articles/26125597051277-Nerdio-Manager-Distributor-API-Getting-Started) for setup instructions.

### 2. Connect and Use

```powershell
Import-Module NMM-PS
Connect-NMMApi

# List all accounts
Get-NMMAccount

# Get host pools for an account
Get-NMMHostPool -AccountId 123

# Chain commands with pipeline
Get-NMMAccount | Get-NMMHostPool
```

### 3. Discover Available Commands

```powershell
# Interactive color-coded command list
Get-NMMCommand

# Filter by category
Get-NMMCommand -Category HostPool

# Get as objects for scripting
Get-NMMCommand -AsObject | Where-Object { $_.Category -eq 'Device' }
```

---

## Authentication Methods

### Client Secret (Default)
```powershell
Connect-NMMApi
```

### Certificate-Based (Recommended for Production)
```powershell
# Create certificate, upload to Azure AD, update config
New-NMMApiCertificate -ExportToCertStore -Upload -UpdateConfig

# Connect using certificate thumbprint
Connect-NMMApi -CertificateThumbprint "YOUR_THUMBPRINT"
```

See the [Authentication Guide](https://Get-Nerdio.github.io/NMM-PS/getting-started/authentication/) for details.

---

## Available Cmdlets

Run `Get-NMMCommand` for a full list, or see the [cmdlet reference](https://Get-Nerdio.github.io/NMM-PS/cmdlets/).

| Category | Examples |
|----------|----------|
| **Accounts** | `Connect-NMMApi`, `Get-NMMAccount` |
| **Host Pools** | `Get-NMMHostPool`, `Get-NMMHostPoolSettings`, `New-NMMHostPool` |
| **Session Hosts** | `Get-NMMHost`, `Get-NMMHostSchedule` |
| **Desktop Images** | `Get-NMMDesktopImage`, `Get-NMMImageTemplate` |
| **Users & Groups** | `Get-NMMUser`, `Get-NMMUsers`, `Get-NMMGroup` |
| **Devices (Beta)** | `Get-NMMDevice`, `Get-NMMDeviceCompliance`, `Sync-NMMDevice` |
| **Backup** | `Get-NMMBackup`, `Get-NMMProtectedItem`, `Get-NMMRecoveryPoint` |
| **Automation** | `Get-NMMScriptedAction`, `Get-NMMSchedule`, `Get-NMMAutoscaleProfile` |
| **Reports** | `Invoke-NMMReport`, `New-NMMReport`, `ConvertTo-NMMHtmlReport` |

---

## Hidden API (Experimental)

> **Warning:** The Hidden API accesses internal NMM web portal endpoints that are **not part of the official API**. These endpoints may change without notice and could break at any time. Use at your own risk.

Access internal NMM APIs not exposed via the public REST API using browser cookie authentication.

```powershell
# Start listener and open browser for authentication
Connect-NMMHiddenApi

# After logging in and clicking the browser extension:
Invoke-HiddenApiRequest -Method GET -Endpoint "accounts"
```

See the [Hidden API Guide](https://Get-Nerdio.github.io/NMM-PS/getting-started/hidden-api/) for setup instructions including the browser extension.

---

## Disclaimer

> **This module is NOT officially supported by Nerdio.**

This repository is a collaborative space maintained by Nerdio Sales Engineers on a **best-effort basis**.

- **Unofficial** - Not an official Nerdio product
- **No warranty** - Provided "as-is" without any guarantees
- **No SLA** - No commitment to response times or fixes
- **Use at your own risk** - Test thoroughly before production use
- **May break** - API changes may cause issues without warning
- **Community support only** - Use GitHub Issues for questions

By using this module, you acknowledge that:
1. You understand this is unofficial software
2. You will not contact Nerdio Support for issues with this module
3. You accept all risks associated with using unofficial tools

---

## Contributing

1. Fork the repository
2. Make your changes
3. Submit a pull request with a detailed description

---

## License

MIT License - See [LICENSE](LICENSE) file for details.
