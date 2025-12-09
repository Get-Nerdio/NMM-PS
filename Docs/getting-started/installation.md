# Installation

## Requirements

- **PowerShell 7.0+** (PowerShell Core)
- **Windows, macOS, or Linux**

!!! note "PowerShell Version"
    NMM-PS requires PowerShell 7.0 or higher. Windows PowerShell 5.1 is not supported.

## Install from PowerShell Gallery

The recommended way to install NMM-PS is from the PowerShell Gallery:

```powershell
Install-Module -Name NMM-PS -Scope CurrentUser
```

To install for all users (requires admin/sudo):

```powershell
Install-Module -Name NMM-PS -Scope AllUsers
```

## Install from GitHub

Clone the repository and import directly:

```powershell
# Clone the repository
git clone https://github.com/Get-Nerdio/NMM-PS.git

# Import the module
Import-Module ./NMM-PS/NMM-PS.psm1
```

## Update the Module

To update to the latest version:

```powershell
Update-Module -Name NMM-PS
```

## Verify Installation

Check that the module is installed correctly:

```powershell
# List module information
Get-Module -Name NMM-PS -ListAvailable

# Import and check available commands
Import-Module NMM-PS
Get-Command -Module NMM-PS
```

You should see 60+ cmdlets available.

## Uninstall

To remove NMM-PS:

```powershell
Uninstall-Module -Name NMM-PS
```

## Next Steps

After installation, [configure your API credentials](configuration.md).
