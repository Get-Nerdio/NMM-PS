function Get-NMMDeviceBitLocker {
    <#
    .SYNOPSIS
        Get BitLocker recovery keys for an Intune device.
    .DESCRIPTION
        Retrieves the BitLocker recovery keys for a specific Intune device.
        This returns sensitive encryption key information.
        This is a v1-beta endpoint.

        WARNING: This cmdlet retrieves sensitive BitLocker recovery keys.
        Ensure you have proper authorization before accessing this data.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER DeviceId
        The Intune device ID.
    .EXAMPLE
        Get-NMMDeviceBitLocker -AccountId 123 -DeviceId "device-guid"
    .EXAMPLE
        # With confirmation prompt
        Get-NMMDeviceBitLocker -AccountId 123 -DeviceId "device-guid" -Confirm
    .EXAMPLE
        # Skip confirmation (use with caution)
        Get-NMMDeviceBitLocker -AccountId 123 -DeviceId "device-guid" -Confirm:$false
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
        Write-Warning "This cmdlet retrieves sensitive BitLocker recovery keys. Ensure you have authorization to access this data."

        if ($PSCmdlet.ShouldProcess($DeviceId, "Retrieve BitLocker recovery keys")) {
            Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/devices/$DeviceId/bitlocker-keys" -ApiVersion 'v1-beta'
        }
    }
}
