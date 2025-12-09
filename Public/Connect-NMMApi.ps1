function Connect-NMMApi {
    <#
    .SYNOPSIS
        Authenticates to the NMM API and caches the access token.
    .DESCRIPTION
        Connects to the NMM API using either client secret or certificate-based authentication.

        Authentication Methods:
        1. Client Secret (default) - Traditional OAuth2 client_credentials flow
        2. Certificate - JWT assertion signed with certificate private key

        Configuration is loaded from ConfigData.json. The AuthMethod field determines
        which authentication method to use:
        - "Secret" or not specified: Uses ClientSecret
        - "Certificate": Uses certificate from configured location

        Certificate storage options:
        - Windows Certificate Store
        - macOS Keychain
        - PFX file
        - Azure Key Vault
    .PARAMETER BaseURI
        NMM API base URI.
    .PARAMETER TenantId
        Azure AD tenant ID.
    .PARAMETER ClientId
        Azure AD application (client) ID.
    .PARAMETER ClientSecret
        Client secret for secret-based auth.
    .PARAMETER Scope
        OAuth2 scope (typically "{app-id}/.default").
    .PARAMETER CertificateThumbprint
        Certificate thumbprint for certificate-based auth (Windows/macOS).
    .PARAMETER CertificatePath
        Path to PFX file for certificate-based auth.
    .PARAMETER CertificatePassword
        Password for PFX file (SecureString).
    .PARAMETER CertificateKeyVault
        Key Vault name containing the certificate.
    .PARAMETER CertificateName
        Certificate name in Key Vault.
    .PARAMETER UseKeyVault
        Load credentials from Azure Key Vault.
    .PARAMETER SaveToKeyVault
        Save credentials to Azure Key Vault.
    .PARAMETER VaultName
        Key Vault name for credential storage.
    .PARAMETER SecretName
        Secret name prefix in Key Vault.
    .EXAMPLE
        Connect-NMMApi
        # Uses configuration from ConfigData.json
    .EXAMPLE
        Connect-NMMApi -CertificateThumbprint "ABC123DEF456"
        # Uses certificate from Windows Cert Store / macOS Keychain
    .EXAMPLE
        Connect-NMMApi -CertificatePath "/path/to/cert.pfx" -CertificatePassword $securePass
        # Uses certificate from PFX file
    #>
    [CmdletBinding(DefaultParameterSetName = 'Auto')]
    param(
        [Parameter(Mandatory = $false)]
        [string]$BaseURI,

        [Parameter(Mandatory = $false)]
        [string]$TenantId,

        [Parameter(Mandatory = $false)]
        [string]$ClientId,

        [Parameter(Mandatory = $false, ParameterSetName = 'Auto')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Secret')]
        [string]$ClientSecret,

        [Parameter(Mandatory = $false)]
        [string]$Scope,

        # Certificate from Store/Keychain
        [Parameter(Mandatory = $true, ParameterSetName = 'CertificateThumbprint')]
        [string]$CertificateThumbprint,

        # Certificate from PFX file
        [Parameter(Mandatory = $true, ParameterSetName = 'CertificatePfx')]
        [string]$CertificatePath,

        [Parameter(Mandatory = $false, ParameterSetName = 'CertificatePfx')]
        [SecureString]$CertificatePassword,

        # Certificate from Key Vault
        [Parameter(Mandatory = $true, ParameterSetName = 'CertificateKeyVault')]
        [string]$CertificateKeyVault,

        [Parameter(Mandatory = $true, ParameterSetName = 'CertificateKeyVault')]
        [string]$CertificateName,

        # Legacy Key Vault credential storage
        [Parameter(Mandatory = $false, ParameterSetName = 'Auto')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Secret')]
        [bool]$UseKeyVault = $false,

        [Parameter(Mandatory = $false, ParameterSetName = 'Auto')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Secret')]
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
        if ([string]::IsNullOrEmpty($BaseURI)) { $BaseURI = $config.BaseUri }
        if ([string]::IsNullOrEmpty($ClientId)) { $ClientId = $config.ClientId }
        if ([string]::IsNullOrEmpty($Scope)) { $Scope = $config.Scope }
        if ([string]::IsNullOrEmpty($TenantId)) { $TenantId = $config.TenantId }

        # Only load secret if not using certificate auth
        if ($PSCmdlet.ParameterSetName -in @('Auto', 'Secret')) {
            if ([string]::IsNullOrEmpty($ClientSecret)) { $ClientSecret = $config.ClientSecret }
        }
    }
    else {
        Write-Warning "No configuration file found."
    }

    # Determine authentication method
    $authMethod = $null

    if ($PSCmdlet.ParameterSetName -eq 'CertificateThumbprint') {
        $authMethod = 'Certificate'
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'CertificatePfx') {
        $authMethod = 'Certificate'
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'CertificateKeyVault') {
        $authMethod = 'Certificate'
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'Secret') {
        $authMethod = 'Secret'
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'Auto') {
        # Auto-detect from config
        if ($config -and $config.AuthMethod -eq 'Certificate' -and $config.Certificate) {
            $authMethod = 'Certificate'
            Write-Verbose "Auto-detected certificate authentication from config"
        }
        elseif (-not [string]::IsNullOrEmpty($ClientSecret)) {
            $authMethod = 'Secret'
            Write-Verbose "Using secret authentication"
        }
        else {
            # Check if certificate is configured even without explicit AuthMethod
            if ($config -and $config.Certificate -and $config.Certificate.Thumbprint) {
                $authMethod = 'Certificate'
                Write-Verbose "Found certificate configuration, using certificate authentication"
            }
        }
    }

    # Interactive prompts for required fields
    if ([string]::IsNullOrEmpty($BaseURI)) {
        $BaseURI = Read-Host "Enter the API Base URI"
    }
    if ([string]::IsNullOrEmpty($ClientId)) {
        $ClientId = Read-Host "Enter the Client ID"
    }
    if ([string]::IsNullOrEmpty($Scope)) {
        $Scope = Read-Host "Enter the Scope"
    }
    if ([string]::IsNullOrEmpty($TenantId)) {
        $TenantId = Read-Host "Enter the Tenant ID"
    }

    # If still no auth method determined, prompt for secret
    if (-not $authMethod) {
        if ([string]::IsNullOrEmpty($ClientSecret)) {
            $ClientSecret = Read-Host "Enter the Client Secret"
        }
        $authMethod = 'Secret'
    }

    # Retrieve or save credentials with Azure Key Vault (legacy support)
    if ($UseKeyVault) {
        if ($Identity) {
            Connect-AzAccount -Identity
        }
        else {
            Connect-AzAccount
        }
        $URL = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_URL").SecretValueText
        $ClientID = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientID").SecretValueText
        $ClientSecret = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientSecret").SecretValueText
        $authMethod = 'Secret'
    }
    elseif ($SaveToKeyVault) {
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

        if ($authMethod -eq 'Certificate') {
            # Certificate-based authentication
            Write-Verbose "Authenticating with certificate..."

            # Get the certificate
            $cert = $null

            if ($PSCmdlet.ParameterSetName -eq 'CertificateThumbprint') {
                # Determine platform and get from appropriate store
                if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                    $cert = Get-NMMCertificate -Thumbprint $CertificateThumbprint -Source 'CertStore'
                }
                elseif ($IsMacOS) {
                    $cert = Get-NMMCertificate -Thumbprint $CertificateThumbprint -Source 'Keychain'
                }
                else {
                    throw "Certificate thumbprint authentication requires Windows or macOS. Use -CertificatePath for Linux."
                }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'CertificatePfx') {
                $cert = Get-NMMCertificate -PfxPath $CertificatePath -PfxPassword $CertificatePassword -Source 'PfxFile'
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'CertificateKeyVault') {
                $cert = Get-NMMCertificate -VaultName $CertificateKeyVault -CertificateName $CertificateName -Source 'KeyVault'
            }
            elseif ($config -and $config.Certificate) {
                # Load from config
                $cert = Get-CertificateFromConfig -CertConfig $config.Certificate
            }
            else {
                throw "No certificate specified and no certificate configuration found."
            }

            # Create JWT assertion
            $jwtAssertion = New-JwtAssertion -Certificate $cert -ClientId $ClientId -TenantId $TenantId

            # Request token with certificate assertion
            $tokenResponse = Invoke-RestMethod -Uri $tokenUri -Method 'POST' -Body @{
                client_id             = $ClientId
                client_assertion      = $jwtAssertion
                client_assertion_type = 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
                grant_type            = 'client_credentials'
                scope                 = $Scope
            }

            Write-Verbose "Successfully authenticated with certificate"
        }
        else {
            # Secret-based authentication (existing flow)
            Write-Verbose "Authenticating with client secret..."

            $tokenResponse = Invoke-RestMethod -Uri $tokenUri -Method 'POST' -Body @{
                client_id     = $ClientId
                client_secret = $ClientSecret
                grant_type    = 'client_credentials'
                scope         = $Scope
            }

            Write-Verbose "Successfully authenticated with client secret"
        }

        # Store the token in a script-scoped cache variable
        $script:cachedToken = [PSCustomObject]@{
            Expiry      = (Get-Date).AddSeconds($tokenResponse.expires_in)
            TokenType   = $tokenResponse.token_type
            APIUrl      = "$BaseURI/rest-api/v1"
            AccessToken = $tokenResponse.access_token
            AuthMethod  = $authMethod
        }

        return $script:cachedToken
    }
    catch {
        Write-Error "Failed to retrieve API token: $_"
    }
}

function Get-CertificateFromConfig {
    <#
    .SYNOPSIS
        Loads certificate based on ConfigData.json Certificate section.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$CertConfig
    )

    $source = $CertConfig.Source

    switch ($source) {
        'CertStore' {
            $params = @{
                Source        = 'CertStore'
                StoreLocation = if ($CertConfig.StoreLocation) { $CertConfig.StoreLocation } else { 'CurrentUser' }
                StoreName     = if ($CertConfig.StoreName) { $CertConfig.StoreName } else { 'My' }
            }
            if ($CertConfig.Thumbprint) { $params.Thumbprint = $CertConfig.Thumbprint }
            if ($CertConfig.Subject) { $params.Subject = $CertConfig.Subject }

            return Get-NMMCertificate @params
        }
        'Keychain' {
            $params = @{
                Source       = 'Keychain'
                KeychainPath = if ($CertConfig.KeychainPath) { $CertConfig.KeychainPath } else { 'login.keychain-db' }
            }
            if ($CertConfig.Thumbprint) { $params.Thumbprint = $CertConfig.Thumbprint }
            if ($CertConfig.Subject) { $params.Subject = $CertConfig.Subject }

            return Get-NMMCertificate @params
        }
        'PfxFile' {
            $params = @{
                Source  = 'PfxFile'
                PfxPath = $CertConfig.Path
            }

            # Handle password from Key Vault or direct
            if ($CertConfig.PasswordKeyVault) {
                $vaultParts = $CertConfig.PasswordKeyVault -split '/'
                if ($vaultParts.Count -eq 2) {
                    $vaultName = $vaultParts[0]
                    $secretName = $vaultParts[1]
                    $passwordPlain = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName -AsPlainText
                    $params.PfxPassword = ConvertTo-SecureString -String $passwordPlain -AsPlainText -Force
                }
            }
            elseif ($CertConfig.Password) {
                $params.PfxPassword = ConvertTo-SecureString -String $CertConfig.Password -AsPlainText -Force
            }

            return Get-NMMCertificate @params
        }
        'KeyVault' {
            return Get-NMMCertificate -Source 'KeyVault' -VaultName $CertConfig.VaultName -CertificateName $CertConfig.CertificateName
        }
        default {
            throw "Unknown certificate source: $source. Valid values: CertStore, Keychain, PfxFile, KeyVault"
        }
    }
}
