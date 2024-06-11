function Connect-NMMApi {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$BaseURI,

        [Parameter(Mandatory = $false)]
        [string]$TenantId,

        [Parameter(Mandatory = $false)]
        [string]$ClientId,

        [Parameter(Mandatory = $false)]
        [string]$ClientSecret,

        [Parameter(Mandatory = $false)]
        [string]$Scope,

        [Parameter(Mandatory = $false)]
        [bool]$UseKeyVault = $false,

        [Parameter(Mandatory = $false)]
        [bool]$SaveToKeyVault = $false,

        [Parameter(Mandatory = $false)]
        [string]$VaultName,

        [Parameter(Mandatory = $false)]
        [string]$SecretName
    )

    # Check for cached token
    if ($script:cachedToken -and $script:cachedToken.Expiry -gt (Get-Date)) {
        Write-Verbose "Using cached token."
        return $script:cachedToken
    }

    # Configuration file loading 
    $config = Get-ConfigData
    
    if ($config) {
        $BaseURI = $config.BaseUri
        $ClientId = $config.ClientId
        $ClientSecret = $config.ClientSecret
        $Scope = $config.Scope
        $TenantId = $config.TenantId
    }
    else {
        Write-Warning "No configuration file found."
    }

    # Interactive prompts if necessary
    if ([string]::IsNullOrEmpty($BaseURI)) {
        $BaseURI = Read-Host "Enter the API Base URI"
    }  
    if ([string]::IsNullOrEmpty($ClientId)) {
        $ClientId = Read-Host "Enter the Client ID"
    }
    if ([string]::IsNullOrEmpty($ClientSecret)) {
        $ClientSecret = Read-Host "Enter the Client Secret"
    }
    if ([string]::IsNullOrEmpty($Scope)) {
        $Scope = Read-Host "Enter the Scope"
    }
    if ([string]::IsNullOrEmpty($TenantId)) {
        $TenantId = Read-Host "Enter the Tenant ID"
    }

    # Retrieve or save credentials with Azure Key Vault
    if ($UseKeyVault) {
        # If the Identity parameter is specified, use it to connect.
        # Otherwise, fall back to interactive login.
        if ($Identity) {
            Connect-AzAccount -Identity
        }
        else {
            Connect-AzAccount
        }
        $URL = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_URL").SecretValueText
        $ClientID = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientID").SecretValueText
        $ClientSecret = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientSecret").SecretValueText
    }
    elseif ($SaveToKeyVault) {
        # Save the URL, ClientID, and ClientSecret to the Azure Key Vault.
        if ($Identity) {
            Connect-AzAccount -Identity
        }
        else {
            Connect-AzAccount
        }
        $URL_Secret = ConvertTo-SecureString -String $URL -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_URL" -SecretValue $URL_Secret

        $ClientID_Secret = ConvertTo-SecureString -String $ClientID -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientID" -SecretValue $ClientID_Secret

        $ClientSecret_Secret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientSecret" -SecretValue $ClientSecret_Secret
    }

    try {
        $tokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
        $tokenResponse = Invoke-RestMethod -Uri $tokenUri -Method 'POST' -Body @{
            client_id     = $ClientId
            client_secret = $ClientSecret
            grant_type    = 'client_credentials'
            scope         = $Scope
        }
        # Store the token in a script-scoped cache variable
        $script:cachedToken = [PSCustomObject]@{
            Expiry      = (Get-Date).AddSeconds($tokenResponse.expires_in)
            TokenType   = $tokenResponse.token_type
            APIUrl      = "$BaseURI/rest-api/v1"
            AccessToken = $tokenResponse.access_token
        }
        return $script:cachedToken
    }
    catch {
        Write-Error "Failed to retrieve API token: $_"
    }
}

