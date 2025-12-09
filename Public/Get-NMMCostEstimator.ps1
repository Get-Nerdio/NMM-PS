function Get-NMMCostEstimator {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(ParameterSetName = 'ById', HelpMessage = 'Search for an estimate by ID')]
        [int]$id, # Search on estimate ID

        [Parameter(ParameterSetName = 'All', HelpMessage = 'Use -All $true to list all saved estimates')]
        [bool]$All = $false # List All Saved Estimates
    )

    # Check if neither parameter is specified
    if (-not ($id -or $All)) {
        Write-LogError 'Please choose one of the parameters: -id or -All $true.' -Severity 'Info'
        return
    }

    $begin = Get-Date
        
    Try {
        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $estimate = Invoke-APIRequest -Method 'GET' -Endpoint "costestimator/$id"
                return $estimate
            }
            'All' {
                if ($All) {
                    $estimates = Invoke-APIRequest -Method 'GET' -Endpoint 'costestimator/list'
                    return $estimates
                }
                else {
                    Write-LogError -Message "The -All flag is not set. Use -All to list all estimates." -Severity 'Info'
                }
            }
        }
    }
    Catch {
        Write-LogError "Error: $($_.Exception.Message)" -Severity 'Error'
    }
    finally {
        $runtime = New-TimeSpan -Start $begin -End (Get-Date)
        Write-Verbose "Execution completed in $runtime"
    }
}
