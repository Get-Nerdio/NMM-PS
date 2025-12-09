function Get-NMMDeviceAppFailure {
    <#
    .SYNOPSIS
        Get failed application installations on an Intune device.
    .DESCRIPTION
        Retrieves the list of applications that failed to install on a specific Intune device.
        This is a v1-beta endpoint.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER DeviceId
        The Intune device ID.
    .EXAMPLE
        Get-NMMDeviceAppFailure -AccountId 123 -DeviceId "device-guid"
    .EXAMPLE
        # Check app failures for all devices
        Get-NMMDevice -AccountId 123 | ForEach-Object {
            Get-NMMDeviceAppFailure -AccountId 123 -DeviceId $_.id
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$AccountId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [string]$DeviceId
    )

    process {
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/devices/$DeviceId/apps/failures" -ApiVersion 'v1-beta'
    }
}
