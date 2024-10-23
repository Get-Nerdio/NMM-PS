function New-Hostpool {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AccountId,

        [Parameter(Mandatory = $true)]
        [ValidatePattern("^[a-zA-Z0-9\s-]+$")]
        [string]$Name,

        [ValidateLength(0, 512)]
        [string]$Description,

        [ValidateSet("PersonalSingleUserDesktop", "PooledMultiUserDesktop", "PooledMultiUserRemoteApp", "PooledSingleUserDesktop")]
        [string]$WvdPoolUserExperience = "PooledMultiUserDesktop",

        [ValidateSet("Automatic", "Direct", $null)]
        [string]$AssignmentType,

        [string]$TimeZoneId = "UTC",

        [Parameter(Mandatory = $true)]
        [string]$WorkspaceId,

        [System.Collections.Generic.List[string]]$UsersToAssign,

        [System.Collections.Generic.List[string]]$GroupsToAssign,

        [Parameter(Mandatory = $true)]
        [hashtable]$VmTemplate,

        [hashtable]$AdConfiguration = @{ Type = 0 },

        [hashtable]$FsLogixConfiguration = @{ Type = 0 },

        [bool]$UseTrustedLaunch,

        [int]$HostsCount
    )

    process {
        Write-Verbose "Starting New-Hostpool with parameters:"
        Write-Verbose "AccountId: $AccountId"
        Write-Verbose "Name: $Name"
        Write-Verbose "Description: $Description"
        Write-Verbose "WvdPoolUserExperience: $WvdPoolUserExperience"
        Write-Verbose "AssignmentType: $AssignmentType"
        Write-Verbose "TimeZoneId: $TimeZoneId"
        Write-Verbose "WorkspaceId: $WorkspaceId"
        Write-Verbose "UsersToAssign: $($UsersToAssign -join ', ')"
        Write-Verbose "GroupsToAssign: $($GroupsToAssign -join ', ')"
        Write-Verbose "VmTemplate: $($VmTemplate | ConvertTo-Json -Compress)"
        Write-Verbose "AdConfiguration: $($AdConfiguration | ConvertTo-Json -Compress)"
        Write-Verbose "FsLogixConfiguration: $($FsLogixConfiguration | ConvertTo-Json -Compress)"
        Write-Verbose "UseTrustedLaunch: $UseTrustedLaunch"
        Write-Verbose "HostsCount: $HostsCount"
        # Log other important parameters...

        $endpoint = "accounts/$AccountId/host-pool"
        $method = "POST"

        # Validate VmTemplate
        if (-not $VmTemplate.ContainsKey('prefix') -or -not $VmTemplate.ContainsKey('size') -or 
            -not $VmTemplate.ContainsKey('image') -or -not $VmTemplate.ContainsKey('storageType') -or 
            -not $VmTemplate.ContainsKey('resourceGroupId') -or -not $VmTemplate.ContainsKey('networkId')) {
            throw "VmTemplate must contain prefix, size, image, storageType, resourceGroupId, and networkId"
        }

        $body = @{
            name = $Name
            description = $Description
            wvdPoolUserExperience = $WvdPoolUserExperience
            timeZoneId = $TimeZoneId
            workspaceId = $WorkspaceId
            usersToAssign = $UsersToAssign
            groupsToAssign = $GroupsToAssign
            vmTemplate = $VmTemplate
            adConfiguration = $AdConfiguration
            fsLogixConfiguration = $FsLogixConfiguration
            useTrustedLaunch = $UseTrustedLaunch
        }

        # Add AssignmentType if it's not null and WvdPoolUserExperience is PersonalSingleUserDesktop
        if ($WvdPoolUserExperience -eq "PersonalSingleUserDesktop" -and $AssignmentType) {
            $body.assignmentType = $AssignmentType
        } else {
            $body.Remove('assignmentType')
        }

        # Add HostsCount if WvdPoolUserExperience is PersonalSingleUserDesktop
        if ($WvdPoolUserExperience -eq "PersonalSingleUserDesktop") {
            if ($null -eq $HostsCount) {
                throw "HostsCount is required when WvdPoolUserExperience is set to PersonalSingleUserDesktop"
            }
            $body.hostsCount = $HostsCount
        }

        # Remove null values from the body
        #$body = $body | Where-Object { $null -ne $_.Value }

        Write-Verbose "Body Object: $($body | ConvertTo-Json -Depth 10)"

        try {
            Write-Verbose "Sending request to $endpoint"
            Write-Verbose "Request body:"
            Write-Verbose ($body | ConvertTo-Json -Depth 10)
            $response = Invoke-APIRequest -Method $method -Endpoint $endpoint -Body $body -ErrorAction Stop

            Write-Output $response
        }
        catch {
            [System.Collections.Generic.List[string]]$errorDetails = @()
            $errorDetails.Add("Failed to create host pool.")

            if ($_.Exception) {
                $errorDetails.Add("Exception message: $($_.Exception.Message)")
            }

            if ($_.Exception.Response) {
                $errorDetails.Add("Response status code: $($_.Exception.Response.StatusCode)")
                try {
                    $errorContent = $_.Exception.Response.Content.ReadAsStringAsync().Result
                    if ($errorContent) {
                        $errorDetails.Add("Response content: $errorContent")
                    }
                }
                catch {
                    $errorDetails.Add("Unable to read response content: $($_.Exception.Message)")
                }
            }

            $errorMessage = $errorDetails -join " "
            if ([string]::IsNullOrWhiteSpace($errorMessage)) {
                $errorMessage = "An unknown error occurred while creating the host pool."
            }
            Write-Error $errorMessage -ErrorAction Stop
        }
    }
}
