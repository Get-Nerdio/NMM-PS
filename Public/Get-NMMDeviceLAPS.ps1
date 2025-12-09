function Get-NMMDeviceLAPS {
    <#
    .SYNOPSIS
        Get local administrator password (LAPS) for an Intune device.
    .DESCRIPTION
        Retrieves the Windows LAPS (Local Administrator Password Solution) credentials
        for a specific Intune device. This returns sensitive credential information.
        This is a v1-beta endpoint.

        WARNING: This cmdlet retrieves sensitive local administrator credentials.
        Ensure you have proper authorization before accessing this data.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER DeviceId
        The Intune device ID.
    .EXAMPLE
        Get-NMMDeviceLAPS -AccountId 123 -DeviceId "device-guid"
    .EXAMPLE
        # With confirmation prompt
        Get-NMMDeviceLAPS -AccountId 123 -DeviceId "device-guid" -Confirm
    .EXAMPLE
        # Skip confirmation (use with caution)
        Get-NMMDeviceLAPS -AccountId 123 -DeviceId "device-guid" -Confirm:$false
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [int]$AccountId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [string]$DeviceId
    )

    process {
        Write-Warning "This cmdlet retrieves sensitive local administrator credentials. Ensure you have authorization to access this data."

        if ($PSCmdlet.ShouldProcess($DeviceId, "Retrieve local admin password (LAPS)")) {
            Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/devices/$DeviceId/local-admin-password" -ApiVersion 'v1-beta'
        }
    }
}
