function Set-AutoScale {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AccountId,

        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string]$ResourceGroup,

        [Parameter(Mandatory = $true)]
        [string]$PoolName,

        [Parameter(Mandatory = $true)]
        [bool]$EnableAutoScale,

        [ValidateSet('Standard_LRS', 'StandardSSD_LRS', 'Premium_LRS')]
        [string]$StoppedDiskType = 'Standard_LRS',

        [ValidateSet('Default', 'UserDriven', 'WorkingHours')]
        [string]$ScalingMode,

        [hashtable]$VmTemplate,

        [bool]$ReuseVmNames = $true,

        [bool]$EnableFixFailedTask = $true,

        [ValidateSet('Running', 'AvailableForConnection')]
        [string]$ActiveHostType = 'AvailableForConnection',

        [int]$HostPoolCapacity,

        [int]$MinActiveHostsCount = 1,

        [int]$BurstCapacity,

        [ValidateSet('High', 'Medium', 'Low')]
        [string]$ScaleInAggressiveness = 'High',

        [ValidateSet('LeastSessionsCount', 'Oldest')]
        [string]$ScaleInBurstHostsSelectionStrategy = 'LeastSessionsCount',

        [ValidateSet('OneTime', 'Continuously', 'Never')]
        [string]$WorkingHoursScaleOutBehavior = 'OneTime',

        [ValidateSet('OneTime', 'Continuously', 'Never')]
        [string]$WorkingHoursScaleInBehavior = 'OneTime',

        [System.Collections.Generic.List[hashtable]]$ScalingTriggers,

        [hashtable]$ScaleInRestriction = @{
            enable = $false
            timeRange = $null
        },

        [hashtable]$PreStageHosts = @{
            timeZoneId = 'UTC'
            enable = $false
            config = @{
                days = @('Monday')
                startWorkHour = 8
                durationMinutes = 60
                hostsToBeReady = 1
            }
            isMultipleConfigsMode = $false
            configs = @()
            preStageDiskType = $true
            preStageUnassigned = $true
            emailsToNotify = ''
        },

        [hashtable]$RemoveMessaging = @{
            minutesBeforeRemove = 10
            message = "Sorry for the interruption. We are doing some housekeeping and need you to log out. You can log in right away to continue working. We will be terminating your session in 10 minutes if you haven't logged out by then."
        },

        [hashtable]$AutoHeal = @{
            enable = $false
            config = $null
        }
    )

    process {
        try {
            $endpoint = "accounts/$AccountId/host-pool/$SubscriptionId/$ResourceGroup/$PoolName/autoscale-configuration"
            
            Write-Verbose "Constructing autoscale configuration"
            
            $body = @{
                enableAutoScale = $EnableAutoScale
                stoppedDiskType = $StoppedDiskType
                scalingMode = $ScalingMode
                vmTemplate = $VmTemplate
                reuseVmNames = $ReuseVmNames
                enableFixFailedTask = $EnableFixFailedTask
                activeHostType = $ActiveHostType
                hostPoolCapacity = $HostPoolCapacity
                minActiveHostsCount = $MinActiveHostsCount
                burstCapacity = $BurstCapacity
                scaleInAggressiveness = $ScaleInAggressiveness
                scaleInBurstHostsSelectionStrategy = $ScaleInBurstHostsSelectionStrategy
                workingHoursScaleOutBehavior = $WorkingHoursScaleOutBehavior
                workingHoursScaleInBehavior = $WorkingHoursScaleInBehavior
                scalingTriggers = $ScalingTriggers
                scaleInRestriction = $ScaleInRestriction
                preStageHosts = $PreStageHosts
                removeMessaging = $RemoveMessaging
                autoHeal = $AutoHeal
            }

            # Remove null values from the body
            $cleanBody = @{}
            foreach ($key in $body.Keys) {
                if ($null -ne $body[$key]) {
                    $cleanBody[$key] = $body[$key]
                }
            }
            $body = $cleanBody

            Write-Verbose "Body Object: $($body | ConvertTo-Json -Depth 10)"

            if ($PSCmdlet.ShouldProcess("Host Pool '$PoolName'", "Update autoscale configuration")) {
                Write-Verbose "Sending request to $endpoint"
                Write-Verbose "Request body:"
                Write-Verbose ($body | ConvertTo-Json -Depth 10)
                
                $response = Invoke-APIRequest -Method 'PUT' -Endpoint $endpoint -Body $body -ErrorAction Stop
                Write-Output $response
            }
        }
        catch {
            [System.Collections.Generic.List[string]]$errorDetails = @()
            $errorDetails.Add("Failed to update autoscale configuration for host pool '$PoolName'.")

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
                $errorMessage = "An unknown error occurred while updating the autoscale configuration."
            }
            Write-Error $errorMessage -ErrorAction Stop
        }
    }
}

