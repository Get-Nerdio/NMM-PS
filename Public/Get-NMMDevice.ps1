function Get-NMMDevice {
    <#
    .SYNOPSIS
        Get Intune managed devices for an account.
    .DESCRIPTION
        Retrieves Intune managed devices from the NMM API.
        This is a v1-beta endpoint.
    .PARAMETER AccountId
        The NMM account ID to query devices for.
    .PARAMETER DeviceId
        Optional. The ID of a specific device to retrieve.
    .EXAMPLE
        Get-NMMDevice -AccountId 123
    .EXAMPLE
        Get-NMMDevice -AccountId 123 -DeviceId "device-guid"
    .EXAMPLE
        Get-NMMAccount | Get-NMMDevice
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [int]$AccountId,

        [Parameter()]
        [string]$DeviceId
    )

    process {
        $response = if ($DeviceId) {
            Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/devices/$DeviceId" -ApiVersion 'v1-beta'
        }
        else {
            Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/devices" -ApiVersion 'v1-beta'
        }

        # API returns { devices: [...], totalCount: X } for list, extract the devices array
        $result = if ($response.devices) {
            $response.devices
        }
        else {
            $response
        }

        # Add PSTypeName for report template matching
        foreach ($device in @($result)) {
            $device.PSObject.TypeNames.Insert(0, 'NMM.Device')
        }
        $result
    }
}
