function Get-NMMDeviceCompliance {
    <#
    .SYNOPSIS
        Get compliance status for an Intune device.
    .DESCRIPTION
        Retrieves the Intune compliance status for a specific device.
        This is a v1-beta endpoint.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER DeviceId
        The Intune device ID.
    .EXAMPLE
        Get-NMMDeviceCompliance -AccountId 123 -DeviceId "device-guid"
    .EXAMPLE
        # Check compliance for all devices
        Get-NMMDevice -AccountId 123 | ForEach-Object {
            Get-NMMDeviceCompliance -AccountId 123 -DeviceId $_.id
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
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/devices/$DeviceId/compliance" -ApiVersion 'v1-beta'
    }
}
