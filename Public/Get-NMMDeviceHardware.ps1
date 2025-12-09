function Get-NMMDeviceHardware {
    <#
    .SYNOPSIS
        Get hardware information for an Intune device.
    .DESCRIPTION
        Retrieves detailed hardware information for a specific Intune device,
        including CPU, memory, storage, and system details.
        This is a v1-beta endpoint.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER DeviceId
        The Intune device ID.
    .EXAMPLE
        Get-NMMDeviceHardware -AccountId 123 -DeviceId "device-guid"
    .EXAMPLE
        # Get hardware info for all devices
        Get-NMMDevice -AccountId 123 | ForEach-Object {
            Get-NMMDeviceHardware -AccountId 123 -DeviceId $_.id
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
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/devices/$DeviceId/hardware" -ApiVersion 'v1-beta'
    }
}
