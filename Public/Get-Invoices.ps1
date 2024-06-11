function Get-Invoices {
    [CmdletBinding(DefaultParameterSetName = 'None')]
    Param(
        [Parameter(ParameterSetName = 'None')]
        [bool]$All = $True,

        [Parameter(ParameterSetName = 'ById', Mandatory = $true)]
        [int]$id,

        [Parameter(ParameterSetName = 'ByDate', Mandatory = $true)]
        [datetime]$periodStart,

        [Parameter(ParameterSetName = 'ByDate', Mandatory = $true)]
        [datetime]$periodEnd,

        # Apply to all parameter sets as they share the same specification
        [Parameter(Mandatory = $false)]
        [bool]$HidePaid = $False,

        [Parameter(Mandatory = $false)]
        [bool]$HideUnpaid = $False
    )

    $begin = Get-Date
    $results = New-Object System.Collections.ArrayList

    Try {
        switch ($PSCmdlet.ParameterSetName) {
            'None' {
                $response = Invoke-APIRequest -Method 'GET' -Endpoint 'invoices'
            }
            'ById' {
                $response = Invoke-APIRequest -Method 'GET' -Endpoint "invoices/$id"
            }
            'ByDate' {
                $dateRangeBegin = Get-FirstAndLastDays -Date $periodStart.ToShortDateString()
                $dateRangeEnd = Get-FirstAndLastDays -Date $periodEnd.ToShortDateString()
                $queryParams = @{
                    periodStart = $dateRangeBegin['FirstDay']
                    periodEnd   = $dateRangeEnd['LastDay']
                    hidePaid    = $HidePaid
                    hideUnpaid  = $HideUnpaid
                }
                $response = Invoke-APIRequest -Method 'GET' -Endpoint 'invoices' -QueryParameters $queryParams
            }
            
        }

        if ($response -is [Array] -or $response -is [Collections.IEnumerable]) {
            $results.AddRange($response)
        }
        else {
            $results.Add($response)
        }
        return $results
        
    }
    Catch {
        Write-LogError "Error: $($_.Exception.Message)"
    }
    Finally {
        $runtime = New-TimeSpan -Start $begin -End (Get-Date)
        Write-Verbose "Execution completed in $runtime"
        
    }
}