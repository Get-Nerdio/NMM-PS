function Invoke-HiddenApiRequest {
    <#
    .SYNOPSIS
        Call internal NMM web portal APIs.
    .DESCRIPTION
        Makes authenticated requests to the NMM web portal internal APIs.
        Authentication methods:
        1. Connect-NMMHiddenApi - Opens browser, waits for extension to send cookies (recommended)
        2. Set-NMMHiddenApiCookie - Manually set cookies from Cookie-Editor export

        Requires HiddenApiBaseUri to be configured in Private/Data/ConfigData.json.
    .PARAMETER Method
        HTTP method (GET, POST, PUT, DELETE, PATCH).
    .PARAMETER Endpoint
        API endpoint path (e.g., "accounts", "host-pool").
    .PARAMETER Body
        Request body for POST/PUT/PATCH requests.
    .PARAMETER BaseUri
        Base URI for the API. If not provided, reads from ConfigData.json.
    .EXAMPLE
        Invoke-HiddenApiRequest -Method GET -Endpoint "accounts"
    .EXAMPLE
        Invoke-HiddenApiRequest -Method POST -Endpoint "some/endpoint" -Body @{ key = "value" }
    .EXAMPLE
        Invoke-HiddenApiRequest -Method GET -Uri "https://nmmdemo.nerdio.net/api/v1/msp/intune/global/policies/baselines"

        Calls a full URL directly.
    .EXAMPLE
        # Cookie-based auth workflow
        Set-NMMHiddenApiCookie -CookieString "AppServiceAuthSession=abc123"
        Invoke-HiddenApiRequest -Method GET -Endpoint "accounts"
    #>
    [CmdletBinding(DefaultParameterSetName = 'Endpoint')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('GET', 'POST', 'PUT', 'DELETE', 'PATCH')]
        [string]$Method,

        [Parameter(Mandatory = $true, ParameterSetName = 'Endpoint')]
        [string]$Endpoint,

        [Parameter(Mandatory = $true, ParameterSetName = 'Uri')]
        [string]$Uri,

        [Parameter()]
        [hashtable]$Body,

        [Parameter(ParameterSetName = 'Endpoint')]
        [hashtable]$QueryParameters,

        [Parameter(ParameterSetName = 'Endpoint')]
        [string]$BaseUri
    )

    process {
        # Determine authentication method
        $authMethod = $null

        if ($Script:HiddenApiAuthMethod -eq 'Cookie' -and $Script:HiddenApiCookies) {
            $authMethod = 'Cookie'
            Write-Verbose "Using cookie-based authentication"
        }
        elseif ($Script:HiddenApiToken -and $Script:HiddenApiToken.AccessToken) {
            # Check if token is expired
            if ($Script:HiddenApiToken.ExpiresOn -le (Get-Date)) {
                Write-Warning "Token has expired. Run Connect-NMMHiddenApi to re-authenticate."
                return
            }
            $authMethod = 'Bearer'
            Write-Verbose "Using bearer token authentication"
        }
        else {
            Write-Error "Not authenticated. Run Connect-NMMHiddenApi or Set-NMMHiddenApiCookie first."
            return
        }

        try {
            # Build URI based on parameter set
            if ($PSCmdlet.ParameterSetName -eq 'Uri') {
                # Use the full URI directly
                $requestUri = $Uri
                Write-Verbose "Using direct URI: $requestUri"
            }
            else {
                # Build URI from BaseUri + Endpoint
                if ([string]::IsNullOrEmpty($BaseUri)) {
                    try {
                        $config = Get-ConfigData -ErrorAction Stop
                        if ($config.HiddenApiBaseUri) {
                            $BaseUri = $config.HiddenApiBaseUri
                            Write-Verbose "Using HiddenApiBaseUri from ConfigData.json: $BaseUri"
                        }
                        else {
                            Write-Error "HiddenApiBaseUri not configured in ConfigData.json. Please add it to Private/Data/ConfigData.json"
                            return
                        }
                    }
                    catch {
                        Write-Error "Could not read ConfigData.json. Please configure HiddenApiBaseUri in Private/Data/ConfigData.json"
                        return
                    }
                }

                $requestUri = "$BaseUri/$($Endpoint.TrimStart('/'))"

                # Add query parameters if provided
                if ($QueryParameters -and $QueryParameters.Count -gt 0) {
                    $queryString = ($QueryParameters.GetEnumerator() | ForEach-Object {
                        "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))"
                    }) -join "&"
                    $requestUri = "$requestUri?$queryString"
                }
            }

            Write-Verbose "Request URI: $requestUri"
            Write-Verbose "Method: $Method"

            # Build headers based on auth method
            $headers = @{
                'Accept' = 'application/json'
            }

            # Build request parameters
            $requestParams = @{
                Uri         = $requestUri
                Method      = $Method
                Headers     = $headers
                ContentType = 'application/json'
            }

            # Add authentication based on method
            if ($authMethod -eq 'Bearer') {
                $headers['Authorization'] = "Bearer $($Script:HiddenApiToken.AccessToken)"
                Write-Verbose "Added Bearer token to Authorization header"
            }
            elseif ($authMethod -eq 'Cookie') {
                # Build cookie string
                $cookieString = ($Script:HiddenApiCookies.GetEnumerator() | ForEach-Object {
                    "$($_.Key)=$($_.Value)"
                }) -join "; "
                $headers['Cookie'] = $cookieString
                Write-Verbose "Added cookies to request: $($Script:HiddenApiCookies.Keys -join ', ')"

                # Add XSRF token as header if present (required by ASP.NET Core)
                $xsrfToken = $Script:HiddenApiCookies['XSRF-TOKEN']
                if ($xsrfToken) {
                    $headers['X-XSRF-TOKEN'] = $xsrfToken
                    $headers['RequestVerificationToken'] = $xsrfToken
                    Write-Verbose "Added XSRF token to headers"
                }

                # Use WebSession for better cookie handling
                $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
                foreach ($cookie in $Script:HiddenApiCookies.GetEnumerator()) {
                    $cookieObj = New-Object System.Net.Cookie
                    $cookieObj.Name = $cookie.Key
                    $cookieObj.Value = $cookie.Value
                    $cookieObj.Domain = ([System.Uri]$requestUri).Host
                    $session.Cookies.Add($cookieObj)
                }
                $requestParams['WebSession'] = $session
            }

            # Add body for POST/PUT/PATCH
            if ($Body -and $Method -in @('POST', 'PUT', 'PATCH')) {
                $jsonBody = $Body | ConvertTo-Json -Depth 10
                $requestParams.Body = $jsonBody
                Write-Verbose "Request body: $jsonBody"
            }

            # Execute request
            $response = Invoke-RestMethod @requestParams -ErrorAction Stop

            return $response
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.value__

            Write-Error "API request failed: $($_.Exception.Message)"
            Write-Verbose "Status code: $statusCode"

            # Try to get error details
            if ($_.ErrorDetails.Message) {
                Write-Verbose "Error details: $($_.ErrorDetails.Message)"
            }

            throw
        }
    }
}
