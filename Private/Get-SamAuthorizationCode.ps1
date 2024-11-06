function Get-SAMAuthorizationCode {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    # .SYNOPSIS
    # Gets an authorization code and token from Microsoft Partner Center using OAuth 2.0 authorization code flow.
    #
    # .DESCRIPTION
    # This function initiates an OAuth 2.0 authorization code flow to obtain an access token for Microsoft Partner Center.
    # It opens a browser window for user authentication, starts a local HTTP listener to receive the callback,
    # and exchanges the authorization code for an access token.
    #
    # .PARAMETER tenantId
    # The Microsoft Partner Center tenant ID (MSP Tenant ID)
    #
    # .PARAMETER appId
    # The application ID of the SAM application (client ID) registered in Entra AD
    #
    # .PARAMETER redirectUri
    # The redirect URI configured for the application (default: http://localhost:8400)
    #
    # .PARAMETER scope
    # The requested scope for the access token (default: https://api.partnercenter.microsoft.com/.default)
    #
    # .EXAMPLE
    # $params = @{
    #     tenantId = "12345678-1234-1234-1234-123456789012"
    #     appId = "87654321-4321-4321-4321-210987654321"
    #     redirectUri = "http://localhost:8400"
    #     scope = "https://api.partnercenter.microsoft.com/.default"
    # }
    # $token = Get-SAMAuthorizationCode @params
    #
    # .EXAMPLE
    # # Using SAM configuration data
    # $samConfig = (Get-ConfigData).SAM
    # $token = Get-SAMAuthorizationCode -tenantId $samConfig.MSPTenantId -appId $samConfig.ApplicationId -appSecret $samConfig.ApplicationSecret
    #
    # .NOTES
    # The function requires the System.Web assembly for URL parsing.
    # Make sure the redirect URI matches what is configured in your Azure AD application.

    param (
        [string]$tenantId, #MSPTenantId
        [string]$appId, #SAMApplicationId
        [string]$appSecret, #SAMApplicationSecret
        [string]$redirectUri = 'http://localhost:8400',
        [string]$scope = 'https://api.partnercenter.microsoft.com/.default'
    )
    
    # Add assembly for HttpUtility
    Add-Type -AssemblyName System.Web
    
    # Create HTTP Listener
    $listener = $null
    try {
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://localhost:8400/")
        $listener.Start()

        # Construct auth URL
        $authEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize?" + `
            "client_id=$appId&" + `
            "response_type=code&" + `
            "redirect_uri=$redirectUri&" + `
            "scope=$scope"

        # Open default browser
        Start-Process $authEndpoint

        # Wait for the callback
        $context = $listener.GetContext()
        $requestUrl = $context.Request.Url
        
        # Send a response to close the browser window
        $response = $context.Response
        $responseString = "<html><body><h1>Authorization complete. You can close this window.</h1></body></html>"
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseString)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()

        # Extract the authorization code and get token
        $code = [System.Web.HttpUtility]::ParseQueryString($requestUrl.Query)["code"]
        
        $body = "grant_type=authorization_code&client_id=$appId&client_secret=$appSecret&code=$code&redirect_uri=$redirectUri&scope=$scope"
        $headers = @{ 'Content-Type' = 'application/x-www-form-urlencoded' }
        $tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/token"
        $response = Invoke-RestMethod -Method POST -Uri $tokenEndpoint -Body $body -Headers $headers

        $AccessToken = @{ Authorization = "Bearer $($response.Access_Token)" }
        return $AccessToken
    }
    catch {
        Write-Error "Authorization failed: $_"
        throw
    }
    finally {
        if ($null -ne $listener -and $listener.IsListening) {
            $listener.Stop()
            $listener.Close()
        }
    }
}