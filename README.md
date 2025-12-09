![image](https://github.com/Get-Nerdio/NMM-SE/assets/52416805/5c8dd05e-84a7-49f9-8218-64412fdaffaf)

# NMM-PS Module

PowerShell module for the Nerdio Manager for MSP (NMM) REST API.

[![Documentation](https://img.shields.io/badge/docs-Get--Nerdio.github.io%2FNMM--PS-blue)](https://Get-Nerdio.github.io/NMM-PS/)
[![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue)](https://github.com/PowerShell/PowerShell)

> **Note:** This module is not yet available on the PowerShell Gallery. Use at your own risk.

## Documentation

Full documentation is available at **[https://Get-Nerdio.github.io/NMM-PS/](https://Get-Nerdio.github.io/NMM-PS/)**

## Installation

### Option 1: Quick Install (Recommended)
```powershell
iex (irm https://raw.githubusercontent.com/Get-Nerdio/NMM-PS/main/Install.ps1?v=1)
```

### Option 2: Manual Download
Download the ZIP from this repository and extract to a folder of your choice.

## Quick Start

### 1. Configure API Credentials

Create `Private/Data/ConfigData.json`:

```json
{
    "BaseUri": "https://api.yournmmdomain.com",
    "TenantId": "your-tenant-id",
    "ClientId": "your-client-id",
    "Scope": "111111-111-1111-11111-1111111111/.default",
    "Secret": "your-secret"
}
```

See [NMM API Docs](https://nmmhelp.getnerdio.com/hc/en-us/articles/26125597051277-Nerdio-Manager-Distributor-API-Getting-Started) for setup instructions.

### 2. Connect and Use

```powershell
Import-Module ./NMM-PS.psm1
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

# Filter by verb
Get-NMMCommand -Verb Get

# Get as objects for scripting
Get-NMMCommand -AsObject | Where-Object { $_.Category -eq 'Device' }
```

---

## Authentication Methods

### Client Secret (Default)
Configure `Secret` in ConfigData.json and run:
```powershell
Connect-NMMApi
```

### Certificate-Based (Recommended for Production)
More secure than client secrets. Create and configure a certificate:

```powershell
# Create certificate, import to cert store, upload to Azure AD, update config
New-NMMApiCertificate -ExportToCertStore -Upload -UpdateConfig

# Connect using certificate thumbprint
Connect-NMMApi -CertificateThumbprint "YOUR_THUMBPRINT"

# Or connect using PFX file
Connect-NMMApi -CertificatePath "./cert.pfx" -CertificatePassword $securePassword
```

See the [Authentication Guide](https://Get-Nerdio.github.io/NMM-PS/getting-started/authentication/) for detailed setup instructions.

---

## Available Cmdlets

### Account Management
| Cmdlet | Description |
|--------|-------------|
| `Connect-NMMApi` | Authenticate to the NMM API |
| `Get-NMMAccount` | List all NMM accounts (tenants) |
| `Get-NMMApiToken` | Get current API token information |
| `New-NMMApiCertificate` | Create certificate for authentication |

### Host Pool Management
| Cmdlet | Description |
|--------|-------------|
| `Get-NMMHostPool` | List host pools for an account |
| `Get-NMMHostPoolSettings` | Get AVD settings for a host pool |
| `Get-NMMHostPoolAutoscale` | Get autoscale configuration |
| `Get-NMMHostPoolAD` | Get Active Directory settings |
| `Get-NMMHostPoolRDP` | Get RDP/device redirection settings |
| `Get-NMMHostPoolFSLogix` | Get FSLogix profile settings |
| `Get-NMMHostPoolVMDeployment` | Get VM deployment configuration |
| `Get-NMMHostPoolTimeout` | Get session timeout settings |
| `Get-NMMHostPoolTag` | Get Azure resource tags |
| `Get-NMMHostPoolSchedule` | Get scheduled tasks for host pool |
| `Get-NMMHostPoolUser` | Get assigned users |
| `New-NMMHostPool` | Create a new host pool |
| `Remove-NMMHostPool` | Delete a host pool |
| `Set-NMMAutoscale` | Configure autoscale settings |

### Host Management
| Cmdlet | Description |
|--------|-------------|
| `Get-NMMHost` | List session hosts in a pool |
| `Get-NMMHostSchedule` | Get scheduled tasks for a host |

### Desktop Image Management
| Cmdlet | Description |
|--------|-------------|
| `Get-NMMDesktopImage` | List desktop images |
| `Get-NMMDesktopImageDetail` | Get image details |
| `Get-NMMDesktopImageLog` | Get image change history |
| `Get-NMMDesktopImageSchedule` | Get image update schedules |
| `Get-NMMImageTemplate` | List image templates |

### User & Group Management
| Cmdlet | Description |
|--------|-------------|
| `Get-NMMUser` | Get user details by ID |
| `Get-NMMUsers` | Search users with filters |
| `Get-NMMUserMFA` | Get user MFA status |
| `Get-NMMGroup` | Get group details |

### Session Management
| Cmdlet | Description |
|--------|-------------|
| `Get-NMMHostPoolSession` | List active sessions in pool |
| `Get-NMMWorkspaceSession` | List sessions in workspace |
| `Get-NMMWorkspace` | List workspaces |

### Backup & Recovery
| Cmdlet | Description |
|--------|-------------|
| `Get-NMMBackup` | List backup policies |
| `Get-NMMProtectedItem` | List protected backup items |
| `Get-NMMRecoveryPoint` | List recovery points |

### Automation & Scheduling
| Cmdlet | Description |
|--------|-------------|
| `Get-NMMScriptedAction` | List scripted actions (`-Scope Account\|Global`) |
| `Get-NMMScriptedActionSchedule` | Get scripted action schedules |
| `Get-NMMSchedule` | List schedules (`-Scope Account\|Global`) |
| `Get-NMMScheduleConfig` | Get schedule configurations |
| `Get-NMMAutoscaleProfile` | List autoscale profiles (`-Scope Account\|Global`) |

### Device Management (Beta API)
| Cmdlet | Description |
|--------|-------------|
| `Get-NMMDevice` | List managed devices |
| `Get-NMMDeviceCompliance` | Get device compliance status |
| `Get-NMMDeviceApp` | List installed apps |
| `Get-NMMDeviceAppFailure` | List failed app installs |
| `Get-NMMDeviceHardware` | Get hardware inventory |
| `Get-NMMDeviceLAPS` | Get local admin password (**Sensitive**) |
| `Get-NMMDeviceBitLocker` | Get BitLocker keys (**Sensitive**) |
| `Sync-NMMDevice` | Force Intune sync |

### Infrastructure & Config
| Cmdlet | Description |
|--------|-------------|
| `Get-NMMDirectory` | List Active Directory connections |
| `Get-NMMFSLogixConfig` | List FSLogix configurations |
| `Get-NMMEnvironmentVariable` | List secure variables |
| `Get-NMMCostEstimator` | Get cost estimation data |

### Billing
| Cmdlet | Description |
|--------|-------------|
| `Get-NMMInvoice` | List invoices |

### Hidden API (Internal Web Portal)
| Cmdlet | Description |
|--------|-------------|
| `Connect-NMMHiddenApi` | Start listener & open browser for cookie auth |
| `Set-NMMHiddenApiCookie` | Manually set cookies (fallback method) |
| `Invoke-HiddenApiRequest` | Call internal NMM web portal APIs |

---

## Common Patterns

### Pipeline Support
Most cmdlets support pipeline input:
```powershell
# Get all host pools across all accounts
Get-NMMAccount | Get-NMMHostPool

# Get settings for all pools in an account
Get-NMMHostPool -AccountId 123 | ForEach-Object {
    Get-NMMHostPoolSettings -AccountId 123 `
        -SubscriptionId $_.subscription `
        -ResourceGroup $_.resourceGroup `
        -PoolName $_.hostPoolName
}
```

### Scope Parameter
Some cmdlets support both Account and Global scope:
```powershell
# Account-level scripted actions
Get-NMMScriptedAction -AccountId 123 -Scope Account

# Global (MSP-level) scripted actions
Get-NMMScriptedAction -Scope Global
```

### Beta API
Device management cmdlets use the beta API:
```powershell
Get-NMMDevice -AccountId 123
Get-NMMDeviceCompliance -AccountId 123 -DeviceId "device-guid"
```

### Hidden API (Internal Web Portal)
Access internal NMM APIs not exposed via the public REST API.

#### Quick Start with Browser Extension (Recommended)

1. **Install the extension**: Load the `BrowserExtension` folder as an unpacked extension in Chrome/Edge
   - Go to `chrome://extensions` or `edge://extensions`
   - Enable "Developer mode"
   - Click "Load unpacked" and select the `BrowserExtension` folder

2. **Authenticate**:
```powershell
# This opens browser, waits for you to log in and click the extension
Connect-NMMHiddenApi

# Make API requests
Invoke-HiddenApiRequest -Method GET -Endpoint "accounts"
Invoke-HiddenApiRequest -Method POST -Endpoint "some/endpoint" -Body @{ key = "value" }
```

#### Manual Method (Fallback)
If you prefer not to use the extension, use Cookie-Editor:

```powershell
# 1. Install "Cookie-Editor" browser extension
# 2. Log into NMM web portal
# 3. Click Cookie-Editor > Export > "Header String"
# 4. Paste the cookie string:
Set-NMMHiddenApiCookie -CookieString ".AspNetCore.Cookies=abc123;XSRF-TOKEN=xyz789"

# Or call a full URL directly
Invoke-HiddenApiRequest -Method GET -Uri "https://nmmdemo.nerdio.net/api/v1/msp/intune/global/policies/baselines"
```

> **Note:** Cookies expire when your browser session ends. Re-authenticate after logging back in.

---

## Bulk Partner Center Enrollment

For bulk enrollment of customers from Partner Center, see [Bulk Enroll PartnerCenter.md](Bulk%20Enroll%20PartnerCenter.md).

---

## Disclaimer

This repository is a collaborative space maintained by Nerdio Sales Engineers on a best-effort basis.

- **Not officially supported** by Nerdio
- **No formal support** - use the Issues section for community help
- **Use at your own risk** - test thoroughly before deployment
- **No commitment** to specific features or timelines

## Contributing

1. Fork the repository
2. Make your changes
3. Submit a pull request with a detailed description

## License

(c) Nerdio. All rights reserved.
