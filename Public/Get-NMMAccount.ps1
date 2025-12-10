function Get-NMMAccount {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [int[]]$id, # Array of integers for IDs

        [Parameter()]
        [string[]]$Name, # Array of strings for Names

        [Parameter()]
        [string[]]$TenantId  # Array of strings for Tenant IDs
    )

    

    $allAccounts = Invoke-APIRequest -Method 'GET' -Endpoint 'accounts'
    $begin = Get-Date
    $results = New-Object System.Collections.ArrayList  # Initialize an ArrayList
    

    
    Try {

        if ($id -or $Name -or $TenantId) {
            if ($id) {
                foreach ($singleId in $id) {
                    $idResults = $allAccounts | Where-Object { $_.id -eq $singleId }
                    foreach ($item in $idResults) {
                        [void]$results.Add($item)
                    }
                }
            }
            if ($Name) {
                foreach ($singleName in $Name) {
                    $nameResults = $allAccounts | Where-Object { $_.name -like "*$singleName*" }
                    foreach ($item in $nameResults) {
                        [void]$results.Add($item)
                    }
                }
            }
            if ($TenantId) {
                foreach ($singleTenantId in $TenantId) {
                    $tenantResults = $allAccounts | Where-Object { $_.tenantId -eq $singleTenantId }
                    foreach ($item in $tenantResults) {
                        [void]$results.Add($item)
                    }
                }
            }
            $results = $results | Sort-Object -Property id -Unique  # Remove duplicates and sort
        }
        else {
            # Return all accounts if no filters are specified
            $results = $allAccounts
        }

        # Add PSTypeName for report template matching
        foreach ($account in @($results)) {
            $account.PSObject.TypeNames.Insert(0, 'NMM.Account')
        }
        return $results
    }
    Catch {
        
        Write-LogError "Error: $($_.Exception.Message)"
    }
    finally {
    
        $runtime = New-TimeSpan -Start $begin -End (Get-Date)
        Write-Verbose "Execution completed in $runtime"
    
    }

}