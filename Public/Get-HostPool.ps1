function Get-Hostpool {
    [CmdletBinding(DefaultParameterSetName = 'None')]
    Param(
        [Parameter(ParameterSetName = 'None', Mandatory = $true)]
        [Parameter(ParameterSetName = 'All', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Details', Mandatory = $true)]
        [int]$Id,

        [Parameter(ParameterSetName = 'All', Mandatory = $false)]
        [bool]$All = $true,

        [Parameter(ParameterSetName = 'None', Mandatory = $false)]
        [string]$HostpoolName,

        [Parameter(ParameterSetName = 'None', Mandatory = $false)]
        [string]$Subscription,

        [Parameter(ParameterSetName = 'None', Mandatory = $false)]
        [string]$ResourceGroup,

        [Parameter(ParameterSetName = 'None', Mandatory = $false)]
        [bool]$AutoScaleEnabled = $false,

        [Parameter(ParameterSetName = 'Details', Mandatory = $false)]
        [bool]$AutoScaleSettings = $false,

        [Parameter(ParameterSetName = 'Details', Mandatory = $false)]
        [bool]$AutoScaleConfiguration = $false,

        [Parameter(ParameterSetName = 'Details', Mandatory = $false)]
        [bool]$ActiveDirectory = $false,

        [Parameter(ParameterSetName = 'Details', Mandatory = $false)]
        [bool]$FSLogixConfig = $false,

        [Parameter(ParameterSetName = 'Details', Mandatory = $false)]
        [bool]$RDPSettings = $false,

        [Parameter(ParameterSetName = 'Details', Mandatory = $false)]
        [bool]$AssignedUsers = $false,

        [Parameter(ParameterSetName = 'Details', Mandatory = $false)]
        [bool]$HostPoolProperties = $false,

        [Parameter(ParameterSetName = 'Details', Mandatory = $false)]
        [bool]$VMDeploymentSettings = $false,

        [Parameter(ParameterSetName = 'Details', Mandatory = $false)]
        [bool]$SessionTimouts = $false
    )

    # Validate the Id parameter
    [ValidateScript({
            if ($PSCmdlet.ParameterSetName -eq 'None' -and -not $All -and 
                -not $HostpoolName -and 
                -not $AutoScaleSettings -and 
                -not $AutoScaleConfiguration -and 
                -not $ActiveDirectory -and 
                -not $FSLogixConfig -and 
                -not $RDPSettings -and 
                -not $AssignedUsers -and 
                -not $HostPoolProperties -and 
                -not $VMDeploymentSettings -and 
                -not $SessionTimouts) {
                throw "The -Id parameter must be combined with -All or one of the detail parameters."
            }
            return $true
        })]
    $Id

    $begin = Get-Date
    $results = [System.Collections.Generic.List[object]]::new()

    Try {
        # Get all host pools in the account
        $allHostPools = Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$Id/host-pool"

        switch ($PSCmdlet.ParameterSetName) {
            'All' {
                $results.Add($allHostPools)
            }
            'Details' {
                if (-not $HostpoolName) {
                    # Iterate over each host pool and gather details
                    foreach ($hostPool in $allHostPools) {
                        # Initialize an object to hold endpoint responses for the current host pool
                        $hostPoolResponseObj = @{}
                
                        $Subscription = $hostPool.subscription
                        $ResourceGroup = $hostPool.resourceGroup
                        $HostpoolName = $hostPool.hostPoolName
                
                        # List to hold endpoints
                        $endpoints = New-Object System.Collections.Generic.List[System.String]
                        if ($AutoScaleSettings) { $endpoints.Add("accounts/$Id/host-pool/$Subscription/$ResourceGroup/$HostpoolName/autoscale-settings") }
                        if ($AutoScaleConfiguration) { $endpoints.Add("accounts/$Id/host-pool/$Subscription/$ResourceGroup/$HostpoolName/autoscale-configuration") }
                        if ($ActiveDirectory) { $endpoints.Add("accounts/$Id/host-pool/$Subscription/$ResourceGroup/$HostpoolName/active-directory") }
                        if ($FSLogixConfig) { $endpoints.Add("accounts/$Id/host-pool/$Subscription/$ResourceGroup/$HostpoolName/fslogix") }
                        if ($RDPSettings) { $endpoints.Add("accounts/$Id/host-pool/$Subscription/$ResourceGroup/$HostpoolName/rdp-settings") }
                        if ($AssignedUsers) { $endpoints.Add("accounts/$Id/host-pool/$Subscription/$ResourceGroup/$HostpoolName/assigned-users") }
                        if ($HostPoolProperties) { $endpoints.Add("accounts/$Id/host-pool/$Subscription/$ResourceGroup/$HostpoolName/avd") }
                        if ($VMDeploymentSettings) { $endpoints.Add("accounts/$Id/host-pool/$Subscription/$ResourceGroup/$HostpoolName/vm-deployment") }
                        if ($SessionTimouts) { $endpoints.Add("accounts/$Id/host-pool/$Subscription/$ResourceGroup/$HostpoolName/session-timeouts") }
                
                        # Collect responses from each endpoint
                        foreach ($endpoint in $endpoints) {
                            $response = Invoke-APIRequest -Method 'GET' -Endpoint $endpoint
                            $propertyName = ($endpoint -split '/')[-1]
                            Write-Output "Adding property $propertyName to host pool response object for $HostpoolName"
                            $hostPoolResponseObj[$propertyName] = $response
                        }
                
                        # Add the nested object under the host pool name in the main results object
                        $responseObj = @{$HostpoolName = $hostPoolResponseObj }
                
                        # Add the complete object to the results array
                        [void]$results.Add($responseObj)
                    }
                }
                else {
                    # Gather details for the specified host pool
                    $Hostpool = $allHostPools | Where-Object { $_.hostPoolName -eq $HostpoolName }
                    Write-Verbose "Hostpool: $($Hostpool)"
                    
                    # Collect responses from each endpoint and add as separate properties
                    $responseObj = @{}

                    $responseObj['Hostpool'] = $Hostpool

                    $Subscription = $hostPool.subscription
                    $ResourceGroup = $hostPool.resourceGroup
                    $HostpoolName = $hostPool.hostPoolName

                    $baseEndpoint = "accounts/$($Id)/host-pool/$($Subscription)/$($ResourceGroup)/$($HostpoolName)"

                    $endpoints = New-Object System.Collections.Generic.List[System.String]
                    if ($AutoScaleSettings) { $endpoints.Add("$baseEndpoint/autoscale-settings") }
                    if ($AutoScaleConfiguration) { $endpoints.Add("$baseEndpoint/autoscale-configuration") }
                    if ($ActiveDirectory) { $endpoints.Add("$baseEndpoint/active-directory") }
                    if ($FSLogixConfig) { $endpoints.Add("$baseEndpoint/fslogix") }
                    if ($RDPSettings) { $endpoints.Add("$baseEndpoint/rdp-settings") }
                    if ($AssignedUsers) { $endpoints.Add("$baseEndpoint/assigned-users") }
                    if ($HostPoolProperties) { $endpoints.Add("$baseEndpoint/avd") }
                    if ($VMDeploymentSettings) { $endpoints.Add("$baseEndpoint/vm-deployment") }
                    if ($SessionTimouts) { $endpoints.Add("$baseEndpoint/session-timeouts") }

                                        
                    # Collect responses from each endpoint
                    foreach ($endpoint in $endpoints) {
                        $response = Invoke-APIRequest -Method 'GET' -Endpoint $endpoint
                        $propertyName = ($endpoint -split '/')[-1]
                        Write-Output "Adding property $propertyName to response object"
                        $responseObj[$propertyName] = $response
                        
                    }
                    
                    # Add the dynamic object to the results array
                    [void]$results.Add($responseObj)

                }
            }
        }

        return $results
    }
    Catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
    Finally {
        $runtime = New-TimeSpan -Start $begin -End (Get-Date)
        Write-Verbose "Execution completed in $runtime"
    }
}

