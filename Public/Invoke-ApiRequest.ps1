function Invoke-APIRequest {
    [CmdletBinding(DefaultParameterSetName = 'None')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Method,

        [Parameter(Mandatory = $true)]
        [string]$Endpoint,

        [Parameter()]
        $Body,

        [Parameter(ParameterSetName = 'Simple')]
        [string]$Query, # Name of the query parameter

        [Parameter(ParameterSetName = 'Simple')]
        [string]$Filter, # Value for the query parameter

        [Parameter(ParameterSetName = 'Hashtable')]
        [Hashtable]$QueryParameters  # Hashtable for multiple query parameters
    )

    try {
        $token = $script:cachedToken

        if (!$token.AccessToken -or $token.Expiry -le (Get-Date)) {
            Write-Warning "Token is missing or expired, retrieving a new one."
            $token = Connect-NMMApi
        }

        $requestHeaders = @{
            'Accept'        = 'application/json'
            'Authorization' = "Bearer $($token.AccessToken)"
        }

        # Initialize URI
        $uri = "$($token.APIUrl)/$Endpoint"

        # Determine how to append query parameters based on method used
        if ($PSCmdlet.ParameterSetName -eq 'Simple' -and $Query -and $Filter) {
            $uri = "$($uri)?$($Query)=$($Filter)"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Hashtable' -and $QueryParameters) {
            $queryString = ($QueryParameters.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
            $uri = "$($uri)?$($queryString)"
        }

        # Execute the API request
        if ($Body) {
            $BodyJSON = $Body | ConvertTo-Json -ErrorAction Stop
            $response = Invoke-RestMethod -Uri $uri -Body $BodyJSON -Method $Method -Headers $requestHeaders -ContentType 'application/json'
        }
        else {
            $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $requestHeaders
        }
        
        return $response

    }
    catch {
        Write-Error "API request failed: $_"
    }
    finally {
        Write-Verbose "Completed API request"
    }
}

