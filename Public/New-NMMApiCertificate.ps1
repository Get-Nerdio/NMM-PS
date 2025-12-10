function New-NMMApiCertificate {
    <#
    .SYNOPSIS
        Creates a self-signed certificate for NMM API authentication.
    .DESCRIPTION
        Generates a self-signed certificate for certificate-based authentication with Azure AD.
        Supports multiple export destinations and optional upload to Azure AD app registration.

        Export Options:
        - PFX file (-ExportToPfx)
        - PEM file (-ExportToPem)
        - Windows Certificate Store / macOS Keychain (-ExportToCertStore)
        - Azure Key Vault (-ExportToKeyVault)

        Azure AD Upload:
        - Use -Upload to automatically add the certificate to your app registration
        - Choose upload authentication method with -UploadMethod (DeviceCode, Interactive, Secret)
    .PARAMETER CertificateName
        Display name for the certificate (default: "NMM-API-Certificate").
    .PARAMETER ValidityMonths
        Certificate validity period in months (default: 12).
    .PARAMETER ExportToPfx
        Path to export PFX file.
    .PARAMETER PfxPassword
        Password for PFX file (SecureString). If not provided, a random password is generated.
    .PARAMETER ExportToPem
        Path to export PEM file (public certificate only).
    .PARAMETER ExportToCertStore
        Export to Windows Certificate Store or macOS Keychain.
    .PARAMETER StoreLocation
        Windows cert store location: CurrentUser or LocalMachine (default: CurrentUser).
    .PARAMETER ExportToKeyVault
        Export to Azure Key Vault.
    .PARAMETER VaultName
        Key Vault name (required with -ExportToKeyVault).
    .PARAMETER Upload
        Upload public certificate to Azure AD app registration.
    .PARAMETER UploadMethod
        Authentication method for upload: DeviceCode, Interactive, or Secret.
    .PARAMETER ApplicationId
        Target Azure AD application ID (default: from ConfigData.json).
    .PARAMETER TenantId
        Azure AD tenant ID (default: from ConfigData.json).
    .PARAMETER UpdateConfig
        Update ConfigData.json with certificate details.
    .OUTPUTS
        PSCustomObject with certificate details.
    .EXAMPLE
        New-NMMApiCertificate -ExportToCertStore -UpdateConfig
        # Creates cert, stores in cert store, updates config
    .EXAMPLE
        New-NMMApiCertificate -ExportToPfx "./nmm-cert.pfx" -Upload -UploadMethod DeviceCode
        # Creates cert, exports to PFX, uploads to Azure AD
    .EXAMPLE
        New-NMMApiCertificate -ExportToKeyVault -VaultName "my-keyvault" -Upload -UploadMethod Secret
        # Creates cert, stores in Key Vault, uploads using existing client secret
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [string]$CertificateName = 'NMM-API-Certificate',

        [Parameter()]
        [int]$ValidityMonths = 12,

        [Parameter()]
        [string]$ExportToPfx,

        [Parameter()]
        [SecureString]$PfxPassword,

        [Parameter()]
        [string]$ExportToPem,

        [Parameter()]
        [switch]$ExportToCertStore,

        [Parameter()]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string]$StoreLocation = 'CurrentUser',

        [Parameter()]
        [switch]$ExportToKeyVault,

        [Parameter()]
        [string]$VaultName,

        [Parameter()]
        [switch]$Upload,

        [Parameter()]
        [ValidateSet('DeviceCode', 'Interactive', 'Secret')]
        [string]$UploadMethod = 'DeviceCode',

        [Parameter()]
        [string]$ApplicationId,

        [Parameter()]
        [string]$TenantId,

        [Parameter()]
        [switch]$UpdateConfig
    )

    begin {
        # Load config for defaults
        $config = Get-ConfigData

        if (-not $ApplicationId -and $config) {
            $ApplicationId = $config.ClientId
        }
        if (-not $TenantId -and $config) {
            $TenantId = $config.TenantId
        }

        # Validate requirements
        if ($ExportToKeyVault -and -not $VaultName) {
            throw "-VaultName is required when using -ExportToKeyVault"
        }

        if ($Upload -and -not $ApplicationId) {
            throw "-ApplicationId is required for upload (or configure ClientId in ConfigData.json)"
        }

        if ($Upload -and -not $TenantId) {
            throw "-TenantId is required for upload (or configure TenantId in ConfigData.json)"
        }

        # Track export destinations
        $exportedTo = @()
    }

    process {
        Write-Host "Creating self-signed certificate: $CertificateName" -ForegroundColor Cyan

        # Calculate validity dates
        $notBefore = [DateTime]::UtcNow
        $notAfter = $notBefore.AddMonths($ValidityMonths)

        # Create certificate
        $cert = New-SelfSignedCertificateInternal -CertificateName $CertificateName -NotBefore $notBefore -NotAfter $notAfter

        Write-Host "Certificate created successfully" -ForegroundColor Green
        Write-Host "  Subject: $($cert.Subject)" -ForegroundColor Gray
        Write-Host "  Thumbprint: $($cert.Thumbprint)" -ForegroundColor Gray
        Write-Host "  Valid until: $($cert.NotAfter)" -ForegroundColor Gray

        # Export to PFX
        if ($ExportToPfx) {
            Write-Host "Exporting to PFX: $ExportToPfx" -ForegroundColor Cyan

            if (-not $PfxPassword) {
                # Generate random password (cross-platform)
                $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*'
                $randomPassword = -join ((1..16) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
                $PfxPassword = ConvertTo-SecureString -String $randomPassword -AsPlainText -Force
                Write-Warning "Generated PFX password: $randomPassword (save this securely!)"
            }

            $pfxBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $PfxPassword)
            [System.IO.File]::WriteAllBytes($ExportToPfx, $pfxBytes)
            $exportedTo += "PFX:$ExportToPfx"
            Write-Host "  Exported to PFX" -ForegroundColor Green
        }

        # Export to PEM
        if ($ExportToPem) {
            Write-Host "Exporting public certificate to PEM: $ExportToPem" -ForegroundColor Cyan

            $pemContent = "-----BEGIN CERTIFICATE-----`n"
            $pemContent += [System.Convert]::ToBase64String($cert.RawData, [System.Base64FormattingOptions]::InsertLineBreaks)
            $pemContent += "`n-----END CERTIFICATE-----"

            [System.IO.File]::WriteAllText($ExportToPem, $pemContent)
            $exportedTo += "PEM:$ExportToPem"
            Write-Host "  Exported public certificate to PEM" -ForegroundColor Green
        }

        # Export to Certificate Store / Keychain
        if ($ExportToCertStore) {
            if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                Write-Host "Importing to Windows Certificate Store ($StoreLocation\My)" -ForegroundColor Cyan

                $store = [System.Security.Cryptography.X509Certificates.X509Store]::new(
                    [System.Security.Cryptography.X509Certificates.StoreName]::My,
                    [System.Security.Cryptography.X509Certificates.StoreLocation]::$StoreLocation
                )
                $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
                $store.Add($cert)
                $store.Close()

                $exportedTo += "CertStore:$StoreLocation\My"
                Write-Host "  Imported to Certificate Store" -ForegroundColor Green
            }
            elseif ($IsMacOS) {
                Write-Host "Importing to macOS Keychain" -ForegroundColor Cyan

                # Export to temp PFX first
                $tempPfx = [System.IO.Path]::GetTempFileName() + ".pfx"
                $tempPassword = [guid]::NewGuid().ToString()
                $tempSecurePassword = ConvertTo-SecureString -String $tempPassword -AsPlainText -Force

                try {
                    $pfxBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $tempSecurePassword)
                    [System.IO.File]::WriteAllBytes($tempPfx, $pfxBytes)

                    # Use Swift tool for proper keychain import (handles data protection keychain)
                    $swiftImportScript = Join-Path $PSScriptRoot "../Private/Tools/ImportP12ToKeychain.swift"
                    if (Test-Path $swiftImportScript) {
                        $result = & swift $swiftImportScript $tempPfx $tempPassword 2>&1
                        if ($result -match '^SUCCESS:') {
                            $exportedTo += "Keychain:DataProtection"
                            Write-Host "  Imported to Keychain (data protection)" -ForegroundColor Green
                        }
                        else {
                            Write-Warning "Swift import failed: $result"
                            # Fall back to security command
                            & security import $tempPfx -k login.keychain-db -P $tempPassword -T /usr/bin/codesign 2>&1 | Out-Null
                            $exportedTo += "Keychain:login.keychain-db"
                            Write-Host "  Imported to Keychain (file-based)" -ForegroundColor Yellow
                        }
                    }
                    else {
                        # Fall back to security command
                        & security import $tempPfx -k login.keychain-db -P $tempPassword -T /usr/bin/codesign 2>&1 | Out-Null
                        $exportedTo += "Keychain:login.keychain-db"
                        Write-Host "  Imported to Keychain" -ForegroundColor Green
                    }
                }
                finally {
                    if (Test-Path $tempPfx) {
                        [System.IO.File]::WriteAllBytes($tempPfx, [byte[]]::new(1024))
                        Remove-Item $tempPfx -Force
                    }
                }
            }
            else {
                Write-Warning "Certificate Store export not supported on Linux. Use -ExportToPfx instead."
            }
        }

        # Export to Key Vault
        if ($ExportToKeyVault) {
            Write-Host "Importing to Azure Key Vault: $VaultName" -ForegroundColor Cyan

            # Check for Az.KeyVault module
            if (-not (Get-Module -ListAvailable -Name Az.KeyVault)) {
                throw "Az.KeyVault module is required. Install with: Install-Module Az.KeyVault"
            }

            Import-Module Az.KeyVault -ErrorAction Stop

            # Export cert to temp PFX for import
            $tempPfx = [System.IO.Path]::GetTempFileName() + ".pfx"
            $tempPassword = [guid]::NewGuid().ToString()
            $tempSecurePassword = ConvertTo-SecureString -String $tempPassword -AsPlainText -Force

            try {
                $pfxBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $tempSecurePassword)
                [System.IO.File]::WriteAllBytes($tempPfx, $pfxBytes)

                # Import to Key Vault
                Import-AzKeyVaultCertificate -VaultName $VaultName -Name $CertificateName -FilePath $tempPfx -Password $tempSecurePassword -ErrorAction Stop | Out-Null

                $exportedTo += "KeyVault:$VaultName/$CertificateName"
                Write-Host "  Imported to Key Vault" -ForegroundColor Green
            }
            finally {
                if (Test-Path $tempPfx) {
                    Remove-Item $tempPfx -Force
                }
            }
        }

        # Upload to Azure AD
        $uploadedToAzureAD = $false
        if ($Upload) {
            Write-Host "Uploading certificate to Azure AD app registration" -ForegroundColor Cyan
            $uploadedToAzureAD = Publish-CertificateToAzureAD -Certificate $cert -ApplicationId $ApplicationId -TenantId $TenantId -UploadMethod $UploadMethod -Config $config
        }

        # Update ConfigData.json
        if ($UpdateConfig) {
            Write-Host "Updating ConfigData.json" -ForegroundColor Cyan
            Update-ConfigDataWithCertificate -Certificate $cert -ExportedTo $exportedTo -VaultName $VaultName -StoreLocation $StoreLocation
        }

        # Return result
        $result = [PSCustomObject]@{
            Thumbprint        = $cert.Thumbprint
            Subject           = $cert.Subject
            NotBefore         = $cert.NotBefore
            NotAfter          = $cert.NotAfter
            ExportedTo        = $exportedTo
            UploadedToAzureAD = $uploadedToAzureAD
        }

        Write-Host "`nCertificate setup complete!" -ForegroundColor Green

        return $result
    }
}

function New-SelfSignedCertificateInternal {
    <#
    .SYNOPSIS
        Creates a self-signed certificate cross-platform.
    #>
    [CmdletBinding()]
    param(
        [string]$CertificateName,
        [DateTime]$NotBefore,
        [DateTime]$NotAfter
    )

    if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
        # Use Windows cmdlet
        $cert = New-SelfSignedCertificate `
            -Subject "CN=$CertificateName" `
            -CertStoreLocation "Cert:\CurrentUser\My" `
            -KeyExportPolicy Exportable `
            -KeySpec Signature `
            -KeyLength 2048 `
            -KeyAlgorithm RSA `
            -HashAlgorithm SHA256 `
            -NotBefore $NotBefore `
            -NotAfter $NotAfter

        return $cert
    }
    else {
        # Cross-platform using .NET cryptography
        $rsa = [System.Security.Cryptography.RSA]::Create(2048)

        $subjectName = [System.Security.Cryptography.X509Certificates.X500DistinguishedName]::new("CN=$CertificateName")

        $request = [System.Security.Cryptography.X509Certificates.CertificateRequest]::new(
            $subjectName,
            $rsa,
            [System.Security.Cryptography.HashAlgorithmName]::SHA256,
            [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
        )

        # Add key usage extension
        $request.CertificateExtensions.Add(
            [System.Security.Cryptography.X509Certificates.X509KeyUsageExtension]::new(
                [System.Security.Cryptography.X509Certificates.X509KeyUsageFlags]::DigitalSignature,
                $true
            )
        )

        # Create self-signed certificate
        $cert = $request.CreateSelfSigned($NotBefore, $NotAfter)

        return $cert
    }
}

function Publish-CertificateToAzureAD {
    <#
    .SYNOPSIS
        Publishes certificate public key to Azure AD app registration via Graph API.
    #>
    [CmdletBinding()]
    param(
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,
        [string]$ApplicationId,
        [string]$TenantId,
        [string]$UploadMethod,
        [PSCustomObject]$Config
    )

    try {
        # Get access token for Graph API
        $graphToken = $null

        switch ($UploadMethod) {
            'DeviceCode' {
                Write-Host "  Starting device code authentication..." -ForegroundColor Yellow
                $graphToken = Get-GraphTokenDeviceCode -TenantId $TenantId
            }
            'Interactive' {
                Write-Host "  Starting interactive authentication..." -ForegroundColor Yellow
                $graphToken = Get-GraphTokenInteractive -TenantId $TenantId
            }
            'Secret' {
                if (-not $Config -or -not $Config.ClientSecret) {
                    throw "Client secret required for Secret upload method. Configure ClientSecret in ConfigData.json"
                }
                Write-Host "  Using client secret authentication..." -ForegroundColor Yellow
                $graphToken = Get-GraphTokenClientCredentials -TenantId $TenantId -ClientId $ApplicationId -ClientSecret $Config.ClientSecret
            }
        }

        if (-not $graphToken) {
            throw "Failed to obtain Graph API access token"
        }

        # First, get the application's object ID (different from client ID)
        Write-Host "  Looking up application in Azure AD..." -ForegroundColor Gray
        $appResponse = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/applications?`$filter=appId eq '$ApplicationId'" `
            -Headers @{ Authorization = "Bearer $graphToken" } `
            -Method GET

        if (-not $appResponse.value -or $appResponse.value.Count -eq 0) {
            throw "Application with ID '$ApplicationId' not found in Azure AD"
        }

        $appObjectId = $appResponse.value[0].id
        $existingKeyCredentials = $appResponse.value[0].keyCredentials

        # Prepare key credential
        $keyCredential = @{
            type             = 'AsymmetricX509Cert'
            usage            = 'Verify'
            key              = [System.Convert]::ToBase64String($Certificate.RawData)
            displayName      = $Certificate.Subject
            startDateTime    = $Certificate.NotBefore.ToUniversalTime().ToString('o')
            endDateTime      = $Certificate.NotAfter.ToUniversalTime().ToString('o')
        }

        # Combine with existing credentials
        $allKeyCredentials = @($existingKeyCredentials) + @($keyCredential)

        # Update application
        Write-Host "  Uploading certificate to app registration..." -ForegroundColor Gray
        $body = @{
            keyCredentials = $allKeyCredentials
        } | ConvertTo-Json -Depth 10

        Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/applications/$appObjectId" `
            -Headers @{
            Authorization  = "Bearer $graphToken"
            'Content-Type' = 'application/json'
        } `
            -Method PATCH `
            -Body $body

        Write-Host "  Certificate uploaded to Azure AD successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to upload certificate to Azure AD: $_"
        return $false
    }
}

function Get-GraphTokenDeviceCode {
    <#
    .SYNOPSIS
        Gets Graph API token using device code flow.
    #>
    [CmdletBinding()]
    param([string]$TenantId)

    $clientId = '14d82eec-204b-4c2f-b7e8-296a70dab67e'  # Microsoft Graph PowerShell
    $scope = 'https://graph.microsoft.com/.default offline_access'

    # Request device code
    $deviceCodeResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/devicecode" `
        -Method POST `
        -Body @{
        client_id = $clientId
        scope     = $scope
    }

    Write-Host "`n$($deviceCodeResponse.message)" -ForegroundColor Yellow

    # Poll for token
    $interval = $deviceCodeResponse.interval
    $expiresIn = $deviceCodeResponse.expires_in
    $startTime = Get-Date

    while ((Get-Date) -lt $startTime.AddSeconds($expiresIn)) {
        Start-Sleep -Seconds $interval

        try {
            $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
                -Method POST `
                -Body @{
                client_id   = $clientId
                grant_type  = 'urn:ietf:params:oauth:grant-type:device_code'
                device_code = $deviceCodeResponse.device_code
            }

            return $tokenResponse.access_token
        }
        catch {
            $errorMessage = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($errorMessage.error -eq 'authorization_pending') {
                continue
            }
            throw
        }
    }

    throw "Device code authentication timed out"
}

function Get-GraphTokenInteractive {
    <#
    .SYNOPSIS
        Gets Graph API token using interactive browser flow.
    #>
    [CmdletBinding()]
    param([string]$TenantId)

    # Check if MSAL.PS module is available
    if (-not (Get-Module -ListAvailable -Name MSAL.PS)) {
        throw "MSAL.PS module is required for interactive authentication. Install with: Install-Module MSAL.PS"
    }

    Import-Module MSAL.PS -ErrorAction Stop

    $clientId = '14d82eec-204b-4c2f-b7e8-296a70dab67e'  # Microsoft Graph PowerShell

    $token = Get-MsalToken -ClientId $clientId `
        -TenantId $TenantId `
        -Scopes 'https://graph.microsoft.com/.default' `
        -Interactive

    return $token.AccessToken
}

function Get-GraphTokenClientCredentials {
    <#
    .SYNOPSIS
        Gets Graph API token using client credentials.
    #>
    [CmdletBinding()]
    param(
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret
    )

    $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -Method POST `
        -Body @{
        client_id     = $ClientId
        client_secret = $ClientSecret
        grant_type    = 'client_credentials'
        scope         = 'https://graph.microsoft.com/.default'
    }

    return $tokenResponse.access_token
}

function Update-ConfigDataWithCertificate {
    <#
    .SYNOPSIS
        Updates ConfigData.json with certificate configuration.
    #>
    [CmdletBinding()]
    param(
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,
        [string[]]$ExportedTo,
        [string]$VaultName,
        [string]$StoreLocation
    )

    # Determine config file path
    $configPath = if ($env:NMM_DEV_MODE -eq 'true') {
        Join-Path $PSScriptRoot "..\Private\Data\ConfigData-Local.json"
    }
    else {
        Join-Path $PSScriptRoot "..\Private\Data\ConfigData.json"
    }

    if (-not (Test-Path $configPath)) {
        Write-Warning "ConfigData.json not found at $configPath. Cannot update."
        return
    }

    $config = Get-Content $configPath -Raw | ConvertFrom-Json

    # Determine certificate source based on export
    $certConfig = @{
        Thumbprint = $Certificate.Thumbprint
    }

    if ($ExportedTo -match 'KeyVault:') {
        $certConfig.Source = 'KeyVault'
        $certConfig.VaultName = $VaultName
        $certConfig.CertificateName = $Certificate.Subject -replace '^CN=', ''
    }
    elseif ($ExportedTo -match 'CertStore:') {
        $certConfig.Source = 'CertStore'
        $certConfig.StoreLocation = $StoreLocation
        $certConfig.StoreName = 'My'
    }
    elseif ($ExportedTo -match 'Keychain:') {
        $certConfig.Source = 'Keychain'
        $certConfig.KeychainPath = 'login.keychain-db'
    }
    elseif ($ExportedTo -match 'PFX:') {
        $pfxPath = ($ExportedTo -match 'PFX:(.+)')[0] -replace '^PFX:', ''
        $certConfig.Source = 'PfxFile'
        $certConfig.Path = $pfxPath
    }

    # Update config object
    $config | Add-Member -NotePropertyName 'AuthMethod' -NotePropertyValue 'Certificate' -Force
    $config | Add-Member -NotePropertyName 'Certificate' -NotePropertyValue ([PSCustomObject]$certConfig) -Force

    # Save config
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8

    Write-Host "  ConfigData.json updated with certificate configuration" -ForegroundColor Green
}
