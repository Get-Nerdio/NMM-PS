function Get-NMMHostPool {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$AccountId,

        [Parameter(ParameterSetName = 'Specific', Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(ParameterSetName = 'Specific', Mandatory = $true)]
        [string]$ResourceGroup,

        [Parameter(ParameterSetName = 'Specific', Mandatory = $true)]
        [string]$PoolName,

        [Parameter(ParameterSetName = 'Specific')]
        [switch]$AutoScaleConfiguration,

        [Parameter(ParameterSetName = 'Specific')]
        [switch]$AutoScaleSettings,

        [Parameter(ParameterSetName = 'Specific')]
        [switch]$ActiveDirectory,

        [Parameter(ParameterSetName = 'Specific')]
        [switch]$HostPoolProperties,

        [Parameter(ParameterSetName = 'Specific')]
        [switch]$VMDeploymentSettings,

        [Parameter(ParameterSetName = 'Specific')]
        [switch]$RDPSettings,

        [Parameter(ParameterSetName = 'Specific')]
        [switch]$FSLogixConfig,

        [Parameter(ParameterSetName = 'Specific')]
        [switch]$SessionTimeouts,

        [Parameter(ParameterSetName = 'Specific')]
        [switch]$Tags,

        [Parameter(ParameterSetName = 'Specific')]
        [switch]$ScheduleConfigurations,

        [Parameter(ParameterSetName = 'Specific')]
        [switch]$AssignedUsers,

        [Parameter(ParameterSetName = 'All')]
        [Parameter(ParameterSetName = 'Specific')]
        [switch]$IncludeAllDetails,

        [switch]$AsJson
    )

    begin {
        $results = [System.Collections.Generic.List[object]]::new()
        $startTime = Get-Date
        Write-Verbose "Starting Get-HostpoolV2 execution at $startTime"
    }

    process {
        try {
            # Define available detail endpoints
            $detailEndpoints = @{
                AutoScaleConfiguration = 'autoscale-configuration'
                AutoScaleSettings     = 'autoscale-settings'
                ActiveDirectory       = 'active-directory'
                HostPoolProperties    = 'avd'
                VMDeploymentSettings  = 'vm-deployment'
                RDPSettings          = 'rdp-settings'
                FSLogixConfig        = 'fslogix'
                SessionTimeouts      = 'session-timeouts'
                Tags                 = 'tags'
                ScheduleConfigurations = 'schedule-configurations'
                AssignedUsers        = 'assigned-users'
            }

            switch ($PSCmdlet.ParameterSetName) {
                'Specific' {
                    Write-Verbose "Retrieving specific host pool details for $PoolName"
                    
                    # First get all host pools to find the specific one
                    $allHostPools = Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/host-pool"
                    $hostPool = $allHostPools | Where-Object { 
                        $_.hostPoolName -eq $PoolName -and 
                        $_.subscription -eq $SubscriptionId -and 
                        $_.resourceGroup -eq $ResourceGroup 
                    }

                    if (-not $hostPool) {
                        Write-Error "Host pool '$PoolName' not found"
                        return
                    }
                    
                    $hostPoolObj = [PSCustomObject]@{
                        HostPool = $hostPool
                        Details  = @{}
                    }

                    # Base endpoint for details
                    $baseEndpoint = "accounts/$AccountId/host-pool/$SubscriptionId/$ResourceGroup/$PoolName"

                    # If IncludeAllDetails is specified, get all details
                    if ($IncludeAllDetails) {
                        foreach ($endpoint in $detailEndpoints.GetEnumerator()) {
                            $detailEndpoint = "$baseEndpoint/$($endpoint.Value)"
                            Write-Verbose "Getting $($endpoint.Key) details from: $detailEndpoint"
                            
                            try {
                                $response = Invoke-APIRequest -Method 'GET' -Endpoint $detailEndpoint
                                $hostPoolObj.Details[$endpoint.Key] = $response
                            }
                            catch {
                                Write-Warning "Failed to retrieve $($endpoint.Key) for host pool $PoolName`: $_"
                                $hostPoolObj.Details[$endpoint.Key] = $null
                            }
                        }
                    }
                    # Otherwise, get only requested details
                    else {
                        foreach ($param in $PSBoundParameters.Keys) {
                            if ($detailEndpoints.ContainsKey($param)) {
                                $detailEndpoint = "$baseEndpoint/$($detailEndpoints[$param])"
                                Write-Verbose "Getting $param details from: $detailEndpoint"
                                
                                try {
                                    $response = Invoke-APIRequest -Method 'GET' -Endpoint $detailEndpoint
                                    $hostPoolObj.Details[$param] = $response
                                }
                                catch {
                                    Write-Warning "Failed to retrieve $param for host pool $PoolName`: $_"
                                    $hostPoolObj.Details[$param] = $null
                                }
                            }
                        }
                    }

                    $results.Add($hostPoolObj)
                }

                'All' {
                    Write-Verbose "Retrieving all host pools for account $AccountId"
                    $hostPools = Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/host-pool"

                    foreach ($hostPool in $hostPools) {
                        $hostPoolObj = [PSCustomObject]@{
                            HostPool = $hostPool
                            Details  = @{}
                        }

                        if ($IncludeAllDetails) {
                            Write-Verbose "Collecting all details for host pool $($hostPool.hostPoolName)"
                            foreach ($endpoint in $detailEndpoints.GetEnumerator()) {
                                $baseEndpoint = "accounts/$AccountId/host-pool/$($hostPool.subscription)/$($hostPool.resourceGroup)/$($hostPool.hostPoolName)"
                                try {
                                    $response = Invoke-APIRequest -Method 'GET' -Endpoint "$baseEndpoint/$($endpoint.Value)"
                                    $hostPoolObj.Details[$endpoint.Key] = $response
                                }
                                catch {
                                    Write-Warning "Failed to retrieve $($endpoint.Key) for host pool $($hostPool.hostPoolName): $_"
                                    $hostPoolObj.Details[$endpoint.Key] = $null
                                }
                            }
                        }

                        $results.Add($hostPoolObj)
                    }
                }
            }
        }
        catch {
            $errorMessage = "Error occurred while retrieving host pool information"
            if ($_.Exception.Response) {
                $errorMessage += ": $($_.Exception.Response.StatusCode) - $($_.Exception.Response.StatusDescription)"
                try {
                    $errorContent = $_.Exception.Response.GetResponseStream()
                    $reader = New-Object System.IO.StreamReader($errorContent)
                    $errorBody = $reader.ReadToEnd()
                    if ($errorBody) {
                        $errorMessage += "`nResponse: $errorBody"
                    }
                }
                catch {
                    $errorMessage += "`nCould not read error response: $_"
                }
            }
            else {
                $errorMessage += ": $_"
            }
            Write-Error $errorMessage
        }
    }

    end {
        $endTime = Get-Date
        $duration = New-TimeSpan -Start $startTime -End $endTime
        Write-Verbose "Execution completed in $duration"

        if ($AsJson) {
            return $results | ConvertTo-Json -Depth 10
        }
        return $results
    }
}



