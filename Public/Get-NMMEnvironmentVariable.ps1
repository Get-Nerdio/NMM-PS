function Get-NMMEnvironmentVariable {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true)]
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
                    $accountVars = Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$singleid/environment-variables/"
                    foreach ($var in $accountVars) {
                        [void]$results.Add($var)
                    }
                }
            }
        }
        Catch {
            Write-LogError "Error: $($_.Exception.Message)"  # Changed from Write-LogError to Write-Error for common use
        }
    
        Finally {
            $runtime = New-TimeSpan -Start $begin -End (Get-Date)
            Write-Verbose "Execution completed in $runtime"
        }
    }

    End {
        if (!$id) {
            # Return all global environment variables if no id is specified
            $results = Invoke-APIRequest -Method 'GET' -Endpoint 'environment-variables'
        }
        return $results
    }
}
    
