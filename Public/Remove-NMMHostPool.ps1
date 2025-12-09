function Remove-NMMHostPool {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AccountId,

        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string]$ResourceGroup,

        [Parameter(Mandatory = $true)]
        [string]$PoolName
    )

    process {
        try {
            $endpoint = "accounts/$AccountId/host-pool/$SubscriptionId/$ResourceGroup/$PoolName"
            
            Write-Verbose "Attempting to remove host pool with parameters:"
            Write-Verbose "AccountId: $AccountId"
            Write-Verbose "SubscriptionId: $SubscriptionId"
            Write-Verbose "ResourceGroup: $ResourceGroup"
            Write-Verbose "PoolName: $PoolName"
            Write-Verbose "Endpoint: $endpoint"

            if ($PSCmdlet.ShouldProcess("Host Pool '$PoolName'", "Remove")) {
                $response = Invoke-APIRequest -Method 'DELETE' -Endpoint $endpoint -ErrorAction Stop
                Write-Output $response
            }
        }
        catch {
            [System.Collections.Generic.List[string]]$errorDetails = @()
            $errorDetails.Add("Failed to remove host pool '$PoolName'.")

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
                $errorMessage = "An unknown error occurred while removing the host pool."
            }
            Write-Error $errorMessage -ErrorAction Stop
        }
    }
}

