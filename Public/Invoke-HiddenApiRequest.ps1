function Invoke-HiddenApiRequest {
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

        # Update the base URI to use the correct API endpoint
        # Remove the double forward slash and ensure we're using the API endpoint
        $baseUri = 'https://web-admin-portal-qzcg6537olky6.azurewebsites.net/api/v1/'
        $uri = "$baseUri/$($Endpoint.TrimStart('/'))"

        # Add verbose logging for troubleshooting
        Write-Verbose "Requesting URI: $uri"
        Write-Verbose "HTTP Method: $Method"

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
            $BodyJSON = $Body | ConvertTo-Json -Depth 10 -ErrorAction Stop
            Write-Verbose "Request body JSON:"
            Write-Verbose $BodyJSON
            $response = Invoke-WebRequest -Uri $uri -Body $BodyJSON -Method $Method -Headers $requestHeaders -ContentType 'application/json'
        }
        else {
            $response = Invoke-WebRequest -Uri $uri -Method $Method -Headers $requestHeaders
        }
        
        return $response

    }
    catch {
        # Enhance error handling
        Write-Error "API request failed: $_"
        Write-Verbose "Error details: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            Write-Verbose "Response status code: $statusCode"
            
            # Try to read response content safely
            try {
                $rawContent = $_.Exception.Response.GetResponseStream()
                $reader = [System.IO.StreamReader]::new($rawContent)
                $errorContent = $reader.ReadToEnd()
                Write-Verbose "Response content: $errorContent"
            }
            catch {
                Write-Verbose "Could not read error response content: $_"
            }
            finally {
                if ($reader) { $reader.Dispose() }
                if ($rawContent) { $rawContent.Dispose() }
            }
        }
        throw  # Re-throw the error after logging
    }
    finally {
        Write-Verbose "Completed API request"
    }
}