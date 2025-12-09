function Sync-NMMDevice {
    <#
    .SYNOPSIS
        Sync a device with Intune.
    .DESCRIPTION
        Forces a device to sync with Intune (policy and app refresh).
        This is a v1-beta endpoint.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER DeviceId
        The Intune device ID.
    .EXAMPLE
        Sync-NMMDevice -AccountId 123 -DeviceId "device-guid"
    .EXAMPLE
        # Sync all devices for an account
        Get-NMMDevices -AccountId 123 | ForEach-Object { Sync-NMMDevice -AccountId 123 -DeviceId $_.id }
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [int]$AccountId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [string]$DeviceId
    )

    process {
        if ($PSCmdlet.ShouldProcess($DeviceId, "Sync device with Intune")) {
            Invoke-APIRequest -Method 'POST' -Endpoint "accounts/$AccountId/devices/$DeviceId/sync" -ApiVersion 'v1-beta'
        }
    }
}
