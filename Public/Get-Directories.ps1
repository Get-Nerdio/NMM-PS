function Get-Directories {
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
                    $accountDirectory = Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$singleid/directories/"
                    foreach ($directory in $accountDirectory) {
                        [void]$results.Add($directory)
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
            # Return all global directories if no id is specified
            $results = Invoke-APIRequest -Method 'GET' -Endpoint 'directories'
        }
        return $results
    }
}
    
