function Get-FSLogixConfigs {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [int[]]$id # Array of integers for IDs
    )

    Begin {
        $begin = Get-Date
        $results = New-Object System.Collections.ArrayList  # Initialize an ArrayList
    }
    
    Process {
        try {
            if ($id) {
                foreach ($singleId in $id) {
                    $fslogixconfigs = Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$singleid/fslogix/"
                    foreach ($config in $fslogixconfigs) {
                        [void]$results.Add($config)
                    }
                }
            }
        }
        Catch {
            Write-LogError "Error: $($_.Exception.Message)" 
        }
    
        Finally {
            $runtime = New-TimeSpan -Start $begin -End (Get-Date)
            Write-Verbose "Execution completed in $runtime"
        }
    }

    End {
        if (!$id) {
            $results = "Please provide an Account ID to get the FSLogix Config"
        }
        return $results
    }
}
    
