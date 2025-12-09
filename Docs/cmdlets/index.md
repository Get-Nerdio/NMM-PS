# Cmdlet Reference

NMM-PS provides 60+ cmdlets organized by functional area.

## Cmdlet Categories

### Authentication

Connect to the NMM API and manage credentials.

| Cmdlet | Description |
|--------|-------------|
| [Connect-NMMApi](authentication/Connect-NMMApi.md) | Authenticate to the NMM API |
| [Get-NMMApiToken](authentication/Get-NMMApiToken.md) | Get the current cached token |
| [New-NMMApiCertificate](authentication/New-NMMApiCertificate.md) | Create certificate for auth |

### Accounts

Manage NMM accounts.

| Cmdlet | Description |
|--------|-------------|
| [Get-NMMAccount](accounts/Get-NMMAccount.md) | List or get NMM accounts |

### Host Pools

Manage Azure Virtual Desktop host pools.

| Cmdlet | Description |
|--------|-------------|
| [Get-NMMHostPool](hostpools/Get-NMMHostPool.md) | List host pools |
| [Get-NMMHostPoolSettings](hostpools/Get-NMMHostPoolSettings.md) | Get AVD settings |
| [Get-NMMHostPoolAutoscale](hostpools/Get-NMMHostPoolAutoscale.md) | Get autoscale config |
| [Get-NMMHostPoolAD](hostpools/Get-NMMHostPoolAD.md) | Get AD settings |
| [Get-NMMHostPoolRDP](hostpools/Get-NMMHostPoolRDP.md) | Get RDP settings |
| [Get-NMMHostPoolFSLogix](hostpools/Get-NMMHostPoolFSLogix.md) | Get FSLogix config |
| [Get-NMMHostPoolSchedule](hostpools/Get-NMMHostPoolSchedule.md) | Get scheduled jobs |
| [Get-NMMHostPoolUser](hostpools/Get-NMMHostPoolUser.md) | Get assigned users |
| [Get-NMMHostPoolSession](hostpools/Get-NMMHostPoolSession.md) | Get active sessions |

### Session Hosts

Manage individual session hosts within pools.

| Cmdlet | Description |
|--------|-------------|
| [Get-NMMHost](hosts/Get-NMMHost.md) | List session hosts |
| [Get-NMMHostSchedule](hosts/Get-NMMHostSchedule.md) | Get host schedules |

### Desktop Images

Manage golden images and templates.

| Cmdlet | Description |
|--------|-------------|
| [Get-NMMDesktopImage](images/Get-NMMDesktopImage.md) | List desktop images |
| [Get-NMMDesktopImageDetail](images/Get-NMMDesktopImageDetail.md) | Get image details |
| [Get-NMMImageTemplate](images/Get-NMMImageTemplate.md) | List image templates |

### Users & Groups

Manage users and groups.

| Cmdlet | Description |
|--------|-------------|
| [Get-NMMUser](users/Get-NMMUser.md) | Get user details |
| [Get-NMMUsers](users/Get-NMMUsers.md) | Search/list users |
| [Get-NMMGroup](users/Get-NMMGroup.md) | Get group details |

### Devices (Beta API)

Manage Intune-enrolled devices.

| Cmdlet | Description | Note |
|--------|-------------|------|
| [Get-NMMDevice](devices/Get-NMMDevice.md) | List devices | Beta |
| [Get-NMMDeviceCompliance](devices/Get-NMMDeviceCompliance.md) | Get compliance status | Beta |
| [Sync-NMMDevice](devices/Sync-NMMDevice.md) | Force Intune sync | Beta |

!!! warning "Beta API"
    Device cmdlets use the v1-beta API and may change without notice.

### Backup

Manage Azure Backup protected items.

| Cmdlet | Description |
|--------|-------------|
| [Get-NMMBackup](backup/Get-NMMBackup.md) | List backup items |
| [Get-NMMProtectedItem](backup/Get-NMMProtectedItem.md) | Get protected items |
| [Get-NMMRecoveryPoint](backup/Get-NMMRecoveryPoint.md) | List recovery points |

### Automation

Manage scripted actions and schedules.

| Cmdlet | Description |
|--------|-------------|
| [Get-NMMScriptedAction](automation/Get-NMMScriptedAction.md) | List scripted actions |
| [Get-NMMSchedule](automation/Get-NMMSchedule.md) | List schedules |
| [Get-NMMAutoscaleProfile](automation/Get-NMMAutoscaleProfile.md) | Get autoscale profiles |

## Pipeline Support

Most NMM-PS cmdlets support pipeline input for chaining:

```powershell
# Get all host pools for all accounts
Get-NMMAccount | Get-NMMHostPool

# Get sessions for specific accounts
Get-NMMAccount -Name "Contoso*" | Get-NMMHostPool | Get-NMMHostPoolSession
```

## Common Parameters

All cmdlets support:

- `-Verbose` - Show detailed progress
- `-Debug` - Show debug information
- `-ErrorAction` - Control error behavior

## Getting Help

Use PowerShell's built-in help:

```powershell
# Get help for a cmdlet
Get-Help Get-NMMHostPool -Full

# List all parameters
Get-Help Connect-NMMApi -Parameter *

# Show examples
Get-Help Get-NMMAccount -Examples
```
