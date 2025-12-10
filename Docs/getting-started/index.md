# Getting Started

Welcome to NMM-PS! This guide will help you get up and running quickly.

## Overview

NMM-PS is a PowerShell module that provides cmdlets for automating Nerdio Manager for MSP (NMM) operations. With NMM-PS, you can:

- Manage accounts and workspaces
- Configure host pools and session hosts
- Manage desktop images and templates
- Monitor user sessions
- Automate backup operations
- Control Intune-managed devices

## Quick Start

1. **Install the module**
   ```powershell
   Install-Module -Name NMM-PS
   ```

2. **Configure credentials** in `ConfigData.json`

3. **Connect to the API**
   ```powershell
   Import-Module NMM-PS
   Connect-NMMApi
   ```

4. **Start automating!**
   ```powershell
   Get-NMMAccount | Get-NMMHostPool
   ```

## Next Steps

<div class="grid cards" markdown>

-   [:material-download: **Installation**](installation.md)

    Install NMM-PS on your system

-   [:material-cog: **Configuration**](configuration.md)

    Set up your API credentials

-   [:material-key: **Authentication**](authentication.md)

    Learn about authentication methods

-   [:material-file-chart: **HTML Reports**](reports.md)

    Generate interactive dashboards

</div>
