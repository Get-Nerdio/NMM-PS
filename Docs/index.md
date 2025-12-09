# NMM-PS Documentation

Welcome to the **NMM-PS** documentation - a PowerShell module for automating Nerdio Manager for MSP (NMM) operations.

!!! warning "Unofficial Module"
    This is an **unofficial**, community-maintained module created by Nerdio Sales Engineers. It is **not officially supported** by Nerdio. Use at your own risk. Do not contact Nerdio Support for issues with this module.

<div class="grid cards" markdown>

-   :material-download:{ .lg .middle } __Quick Install__

    ---

    Install NMM-PS from PowerShell Gallery:

    ```powershell
    Install-Module -Name NMM-PS
    ```

    [:octicons-arrow-right-24: Installation Guide](getting-started/installation.md)

-   :material-key:{ .lg .middle } __Authentication__

    ---

    Connect using client secret or certificate:

    ```powershell
    Connect-NMMApi
    ```

    [:octicons-arrow-right-24: Authentication Guide](getting-started/authentication.md)

-   :material-book-open-variant:{ .lg .middle } __Cmdlet Reference__

    ---

    Browse all 60+ cmdlets organized by category

    [:octicons-arrow-right-24: Cmdlet Reference](cmdlets/index.md)

-   :material-github:{ .lg .middle } __Open Source__

    ---

    Contribute on GitHub - issues, PRs welcome

    [:octicons-arrow-right-24: GitHub Repository](https://github.com/Get-Nerdio/NMM-PS)

</div>

## Features

- **60+ Cmdlets** covering accounts, host pools, session hosts, images, users, devices, and more
- **Multiple Authentication Methods** - Client secret or certificate-based authentication
- **Pipeline Support** - Chain cmdlets together for powerful automation
- **Cross-Platform** - Works on Windows, macOS, and Linux with PowerShell 7+
- **Auto-Pagination** - Handles large result sets automatically

## Quick Start

```powershell
# Install the module
Install-Module -Name NMM-PS

# Import the module
Import-Module NMM-PS

# Connect to NMM API
Connect-NMMApi

# List all accounts
Get-NMMAccount

# Get host pools for a specific account
Get-NMMAccount -AccountId 12345 | Get-NMMHostPool
```

## API Coverage

NMM-PS covers the following NMM API areas:

| Category | Cmdlets | API Version |
|----------|---------|-------------|
| Accounts | `Get-NMMAccount` | v1 |
| Host Pools | `Get-NMMHostPool`, `Get-NMMHostPoolSettings`, + 10 more | v1 |
| Session Hosts | `Get-NMMHost`, `Get-NMMHostSchedule` | v1 |
| Desktop Images | `Get-NMMDesktopImage`, `Get-NMMImageTemplate`, + 3 more | v1 |
| Users & Groups | `Get-NMMUser`, `Get-NMMUsers`, `Get-NMMGroup` | v1 |
| Devices | `Get-NMMDevice`, `Sync-NMMDevice`, + 6 more | v1-beta |
| Backup | `Get-NMMBackup`, `Get-NMMProtectedItem`, `Get-NMMRecoveryPoint` | v1 |
| Automation | `Get-NMMScriptedAction`, `Get-NMMSchedule`, + 3 more | v1 |

## Requirements

- **PowerShell 7.0+** (PowerShell Core)
- **NMM API Access** - Valid API credentials from Nerdio Manager

## Getting Help

- **Documentation**: You're here!
- **GitHub Issues**: [Report bugs or request features](https://github.com/Get-Nerdio/NMM-PS/issues)
- **PowerShell Help**: `Get-Help Connect-NMMApi -Full`

## Disclaimer

!!! note "Community Project"
    This module is maintained by Nerdio Sales Engineers on a **best-effort basis**.

    - **Unofficial** - Not an official Nerdio product
    - **No warranty** - Provided "as-is" without any guarantees
    - **No SLA** - No commitment to response times or fixes
    - **Community support only** - Use [GitHub Issues](https://github.com/Get-Nerdio/NMM-PS/issues) for questions

## License

NMM-PS is open source software licensed under the MIT license.
