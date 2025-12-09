function Get-NMMDeviceApp {
    <#
    .SYNOPSIS
        Get installed applications on an Intune device.
    .DESCRIPTION
        Retrieves the list of applications installed on a specific Intune device.
        This is a v1-beta endpoint.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER DeviceId
        The Intune device ID.
    .EXAMPLE
        Get-NMMDeviceApp -AccountId 123 -DeviceId "device-guid"
    .EXAMPLE
        # Get apps for all devices
        Get-NMMDevice -AccountId 123 | ForEach-Object {
            Get-NMMDeviceApp -AccountId 123 -DeviceId $_.id
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
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/devices/$DeviceId/apps" -ApiVersion 'v1-beta'
    }
}
