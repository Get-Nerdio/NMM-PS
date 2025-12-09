function Get-NMMCommand {
    <#
    .SYNOPSIS
        Lists all available NMM-PS module cmdlets with descriptions.
    .DESCRIPTION
        Displays a formatted, color-coded list of all cmdlets available in the NMM-PS module,
        organized by category. Use this to quickly discover available functionality.
    .PARAMETER Category
        Filter cmdlets by category. Valid values: All, HostPool, Host, DesktopImage,
        User, Session, Backup, Automation, Device, Account, Infrastructure, Billing.
    .PARAMETER Verb
        Filter cmdlets by verb (Get, Set, New, Remove, etc.).
    .PARAMETER AsObject
        Return cmdlet information as objects instead of formatted output.
        Useful for piping to other commands.
    .EXAMPLE
        Get-NMMCommand

        Lists all available cmdlets with color-coded categories.
    .EXAMPLE
        Get-NMMCommand -Category HostPool

        Lists only Host Pool related cmdlets.
    .EXAMPLE
        Get-NMMCommand -Verb Set

        Lists only Set-* cmdlets.
    .EXAMPLE
        Get-NMMCommand -AsObject | Where-Object { $_.Category -eq 'Device' }

        Returns Device cmdlets as objects for further processing.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('All', 'HostPool', 'Host', 'DesktopImage', 'User', 'Session',
                     'Backup', 'Automation', 'Device', 'Account', 'Infrastructure', 'Billing', 'HiddenApi')]
        [string]$Category = 'All',

        [Parameter()]
        [ValidateSet('Get', 'Set', 'New', 'Remove', 'Add', 'Connect', 'Invoke')]
        [string]$Verb,

        [Parameter()]
        [switch]$AsObject
    )

    # Define cmdlet metadata with categories and descriptions
    $cmdletInfo = @(
        # Account Management
        @{ Name = 'Get-NMMAccount'; Category = 'Account'; Description = 'List all NMM accounts (tenants)' }
        @{ Name = 'Get-NMMApiToken'; Category = 'Account'; Description = 'Get current API token information' }
        @{ Name = 'Connect-NMMApi'; Category = 'Account'; Description = 'Authenticate to the NMM API' }

        # Host Pool Management
        @{ Name = 'Get-NMMHostPool'; Category = 'HostPool'; Description = 'List host pools for an account' }
        @{ Name = 'Get-NMMHostPoolSettings'; Category = 'HostPool'; Description = 'Get AVD settings for a host pool' }
        @{ Name = 'Get-NMMHostPoolAutoscale'; Category = 'HostPool'; Description = 'Get autoscale configuration' }
        @{ Name = 'Get-NMMHostPoolAD'; Category = 'HostPool'; Description = 'Get Active Directory settings' }
        @{ Name = 'Get-NMMHostPoolRDP'; Category = 'HostPool'; Description = 'Get RDP/device redirection settings' }
        @{ Name = 'Get-NMMHostPoolFSLogix'; Category = 'HostPool'; Description = 'Get FSLogix profile settings' }
        @{ Name = 'Get-NMMHostPoolVMDeployment'; Category = 'HostPool'; Description = 'Get VM deployment configuration' }
        @{ Name = 'Get-NMMHostPoolTimeout'; Category = 'HostPool'; Description = 'Get session timeout settings' }
        @{ Name = 'Get-NMMHostPoolTag'; Category = 'HostPool'; Description = 'Get Azure resource tags' }
        @{ Name = 'Get-NMMHostPoolSchedule'; Category = 'HostPool'; Description = 'Get scheduled tasks for host pool' }
        @{ Name = 'Get-NMMHostPoolUser'; Category = 'HostPool'; Description = 'Get assigned users' }
        @{ Name = 'New-NMMHostPool'; Category = 'HostPool'; Description = 'Create a new host pool' }
        @{ Name = 'Remove-NMMHostPool'; Category = 'HostPool'; Description = 'Delete a host pool' }
        @{ Name = 'Set-NMMAutoscale'; Category = 'HostPool'; Description = 'Configure autoscale settings' }

        # Host Management
        @{ Name = 'Get-NMMHost'; Category = 'Host'; Description = 'List session hosts in a pool' }
        @{ Name = 'Get-NMMHostSchedule'; Category = 'Host'; Description = 'Get scheduled tasks for a host' }

        # Desktop Image Management
        @{ Name = 'Get-NMMDesktopImage'; Category = 'DesktopImage'; Description = 'List desktop images' }
        @{ Name = 'Get-NMMDesktopImageDetail'; Category = 'DesktopImage'; Description = 'Get image details' }
        @{ Name = 'Get-NMMDesktopImageLog'; Category = 'DesktopImage'; Description = 'Get image change history' }
        @{ Name = 'Get-NMMDesktopImageSchedule'; Category = 'DesktopImage'; Description = 'Get image update schedules' }
        @{ Name = 'Get-NMMImageTemplate'; Category = 'DesktopImage'; Description = 'List image templates' }

        # User Management
        @{ Name = 'Get-NMMUser'; Category = 'User'; Description = 'Get user details by ID' }
        @{ Name = 'Get-NMMUsers'; Category = 'User'; Description = 'Search users with filters' }
        @{ Name = 'Get-NMMUserMFA'; Category = 'User'; Description = 'Get user MFA status' }
        @{ Name = 'Get-NMMGroup'; Category = 'User'; Description = 'Get group details' }

        # Session Management
        @{ Name = 'Get-NMMHostPoolSession'; Category = 'Session'; Description = 'List active sessions in pool' }
        @{ Name = 'Get-NMMWorkspaceSession'; Category = 'Session'; Description = 'List sessions in workspace' }
        @{ Name = 'Get-NMMWorkspace'; Category = 'Session'; Description = 'List workspaces' }

        # Backup & Recovery
        @{ Name = 'Get-NMMBackup'; Category = 'Backup'; Description = 'List backup policies' }
        @{ Name = 'Get-NMMProtectedItem'; Category = 'Backup'; Description = 'List protected backup items' }
        @{ Name = 'Get-NMMRecoveryPoint'; Category = 'Backup'; Description = 'List recovery points' }

        # Automation & Scheduling
        @{ Name = 'Get-NMMScriptedAction'; Category = 'Automation'; Description = 'List scripted actions (-Scope Account|Global)' }
        @{ Name = 'Get-NMMScriptedActionSchedule'; Category = 'Automation'; Description = 'Get scripted action schedules' }
        @{ Name = 'Get-NMMSchedule'; Category = 'Automation'; Description = 'List schedules (-Scope Account|Global)' }
        @{ Name = 'Get-NMMScheduleConfig'; Category = 'Automation'; Description = 'Get schedule configurations' }
        @{ Name = 'Get-NMMAutoscaleProfile'; Category = 'Automation'; Description = 'List autoscale profiles (-Scope Account|Global)' }

        # Device Management (Intune/Beta)
        @{ Name = 'Get-NMMDevice'; Category = 'Device'; Description = 'List managed devices [Beta API]' }
        @{ Name = 'Get-NMMDeviceCompliance'; Category = 'Device'; Description = 'Get device compliance status [Beta]' }
        @{ Name = 'Get-NMMDeviceApp'; Category = 'Device'; Description = 'List installed apps [Beta]' }
        @{ Name = 'Get-NMMDeviceAppFailure'; Category = 'Device'; Description = 'List failed app installs [Beta]' }
        @{ Name = 'Get-NMMDeviceHardware'; Category = 'Device'; Description = 'Get hardware inventory [Beta]' }
        @{ Name = 'Get-NMMDeviceLAPS'; Category = 'Device'; Description = 'Get local admin password [Beta] [Sensitive]' }
        @{ Name = 'Get-NMMDeviceBitLocker'; Category = 'Device'; Description = 'Get BitLocker keys [Beta] [Sensitive]' }

        # Infrastructure & Config
        @{ Name = 'Get-NMMDirectory'; Category = 'Infrastructure'; Description = 'List Active Directory connections' }
        @{ Name = 'Get-NMMFSLogixConfig'; Category = 'Infrastructure'; Description = 'List FSLogix configurations' }
        @{ Name = 'Get-NMMEnvironmentVariable'; Category = 'Infrastructure'; Description = 'List secure variables' }
        @{ Name = 'Get-NMMCostEstimator'; Category = 'Infrastructure'; Description = 'Get cost estimation data' }

        # Billing
        @{ Name = 'Get-NMMInvoice'; Category = 'Billing'; Description = 'List invoices' }

        # Hidden API (Internal Web Portal)
        @{ Name = 'Connect-NMMHiddenApi'; Category = 'HiddenApi'; Description = 'Start listener & open browser for cookie auth' }
        @{ Name = 'Set-NMMHiddenApiCookie'; Category = 'HiddenApi'; Description = 'Manually set cookies (Cookie-Editor fallback)' }
        @{ Name = 'Invoke-HiddenApiRequest'; Category = 'HiddenApi'; Description = 'Call internal NMM web portal APIs' }
    )

    # Filter by category
    if ($Category -ne 'All') {
        $cmdletInfo = $cmdletInfo | Where-Object { $_.Category -eq $Category }
    }

    # Filter by verb
    if ($Verb) {
        $cmdletInfo = $cmdletInfo | Where-Object { $_.Name -like "$Verb-*" }
    }

    # Return as objects if requested
    if ($AsObject) {
        return $cmdletInfo | ForEach-Object {
            [PSCustomObject]@{
                Name        = $_.Name
                Category    = $_.Category
                Description = $_.Description
            }
        }
    }

    # Define category colors
    $categoryColors = @{
        'Account'        = 'Cyan'
        'HostPool'       = 'Green'
        'Host'           = 'Green'
        'DesktopImage'   = 'Yellow'
        'User'           = 'Magenta'
        'Session'        = 'Magenta'
        'Backup'         = 'Blue'
        'Automation'     = 'DarkYellow'
        'Device'         = 'Red'
        'Infrastructure' = 'DarkCyan'
        'Billing'        = 'DarkGreen'
        'HiddenApi'      = 'DarkMagenta'
    }

    # Print header
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "  ║" -ForegroundColor DarkGray -NoNewline
    Write-Host "                    NMM-PS Module Commands                       " -ForegroundColor White -NoNewline
    Write-Host "║" -ForegroundColor DarkGray
    Write-Host "  ╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host ""

    # Group and display by category
    $grouped = $cmdletInfo | Group-Object Category | Sort-Object Name

    foreach ($group in $grouped) {
        $color = $categoryColors[$group.Name]
        if (-not $color) { $color = 'White' }

        # Category header
        Write-Host "  ┌─ " -ForegroundColor DarkGray -NoNewline
        Write-Host "$($group.Name)" -ForegroundColor $color -NoNewline
        Write-Host " $('─' * (60 - $group.Name.Length))" -ForegroundColor DarkGray

        foreach ($cmd in ($group.Group | Sort-Object Name)) {
            Write-Host "  │  " -ForegroundColor DarkGray -NoNewline
            Write-Host "$($cmd.Name.PadRight(35))" -ForegroundColor $color -NoNewline
            Write-Host "$($cmd.Description)" -ForegroundColor Gray
        }
        Write-Host "  └$('─' * 66)" -ForegroundColor DarkGray
        Write-Host ""
    }

    # Footer with tips
    Write-Host "  " -NoNewline
    Write-Host "Tips:" -ForegroundColor DarkYellow
    Write-Host "    Get-Help <cmdlet> -Full" -ForegroundColor Gray -NoNewline
    Write-Host "        # Detailed help for a cmdlet" -ForegroundColor DarkGray
    Write-Host "    Get-NMMCommand -Category Device" -ForegroundColor Gray -NoNewline
    Write-Host "  # Filter by category" -ForegroundColor DarkGray
    Write-Host "    Get-NMMCommand -AsObject" -ForegroundColor Gray -NoNewline
    Write-Host "        # Return as objects for piping" -ForegroundColor DarkGray
    Write-Host ""
}
