function Get-NMMCertificate {
    <#
    .SYNOPSIS
        Retrieves a certificate from various storage locations.
    .DESCRIPTION
        Cross-platform certificate retrieval supporting:
        - Windows Certificate Store (CurrentUser/LocalMachine)
        - macOS Keychain
        - PFX file
        - Azure Key Vault

        The function auto-detects the platform and uses the appropriate method.
    .PARAMETER Thumbprint
        Certificate thumbprint to find.
    .PARAMETER Subject
        Certificate subject name to find (alternative to thumbprint).
    .PARAMETER Source
        Certificate storage source: CertStore, Keychain, PfxFile, KeyVault.
    .PARAMETER StoreLocation
        Windows cert store location: CurrentUser or LocalMachine.
    .PARAMETER StoreName
        Windows cert store name (default: My).
    .PARAMETER PfxPath
        Path to PFX file.
    .PARAMETER PfxPassword
        Password for PFX file (SecureString).
    .PARAMETER VaultName
        Azure Key Vault name.
    .PARAMETER CertificateName
        Certificate name in Key Vault.
    .PARAMETER KeychainPath
        macOS Keychain path (default: login.keychain-db).
    .OUTPUTS
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
    .EXAMPLE
        Get-NMMCertificate -Thumbprint "ABC123" -Source CertStore
    .EXAMPLE
        Get-NMMCertificate -PfxPath "/path/to/cert.pfx" -PfxPassword $securePass -Source PfxFile
    #>
    [CmdletBinding(DefaultParameterSetName = 'CertStore')]
    [OutputType([System.Security.Cryptography.X509Certificates.X509Certificate2])]
    param(
        [Parameter(ParameterSetName = 'CertStore')]
        [Parameter(ParameterSetName = 'Keychain')]
        [string]$Thumbprint,

        [Parameter(ParameterSetName = 'CertStore')]
        [Parameter(ParameterSetName = 'Keychain')]
        [string]$Subject,

        [Parameter(Mandatory = $true)]
        [ValidateSet('CertStore', 'Keychain', 'PfxFile', 'KeyVault')]
        [string]$Source,

        [Parameter(ParameterSetName = 'CertStore')]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string]$StoreLocation = 'CurrentUser',

        [Parameter(ParameterSetName = 'CertStore')]
        [string]$StoreName = 'My',

        [Parameter(Mandatory = $true, ParameterSetName = 'PfxFile')]
        [string]$PfxPath,

        [Parameter(ParameterSetName = 'PfxFile')]
        [SecureString]$PfxPassword,

        [Parameter(Mandatory = $true, ParameterSetName = 'KeyVault')]
        [string]$VaultName,

        [Parameter(Mandatory = $true, ParameterSetName = 'KeyVault')]
        [string]$CertificateName,

        [Parameter(ParameterSetName = 'Keychain')]
        [string]$KeychainPath = 'login.keychain-db',

        [Parameter(ParameterSetName = 'Keychain')]
        [string]$FallbackPfxPath,

        [Parameter(ParameterSetName = 'Keychain')]
        [SecureString]$FallbackPfxPassword
    )

    process {
        switch ($Source) {
            'CertStore' {
                return Get-CertificateFromStore -Thumbprint $Thumbprint -Subject $Subject -StoreLocation $StoreLocation -StoreName $StoreName
            }
            'Keychain' {
                return Get-CertificateFromKeychain -Thumbprint $Thumbprint -Subject $Subject -KeychainPath $KeychainPath -FallbackPfxPath $FallbackPfxPath -FallbackPfxPassword $FallbackPfxPassword
            }
            'PfxFile' {
                return Get-CertificateFromPfx -PfxPath $PfxPath -PfxPassword $PfxPassword
            }
            'KeyVault' {
                return Get-CertificateFromKeyVault -VaultName $VaultName -CertificateName $CertificateName
            }
        }
    }
}

function Get-CertificateFromStore {
    <#
    .SYNOPSIS
        Retrieves certificate from Windows Certificate Store.
    #>
    [CmdletBinding()]
    param(
        [string]$Thumbprint,
        [string]$Subject,
        [string]$StoreLocation,
        [string]$StoreName
    )

    # Check if running on Windows
    if (-not ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop')) {
        throw "Certificate Store is only available on Windows. Use -Source PfxFile or Keychain on other platforms."
    }

    $certPath = "Cert:\$StoreLocation\$StoreName"
    Write-Verbose "Searching certificate store: $certPath"

    $cert = $null

    if ($Thumbprint) {
        $cert = Get-ChildItem -Path $certPath | Where-Object { $_.Thumbprint -eq $Thumbprint } | Select-Object -First 1
        if (-not $cert) {
            throw "Certificate with thumbprint '$Thumbprint' not found in $certPath"
        }
    }
    elseif ($Subject) {
        $cert = Get-ChildItem -Path $certPath | Where-Object { $_.Subject -like "*$Subject*" } | Select-Object -First 1
        if (-not $cert) {
            throw "Certificate with subject containing '$Subject' not found in $certPath"
        }
    }
    else {
        throw "Either -Thumbprint or -Subject must be specified for CertStore source."
    }

    if (-not $cert.HasPrivateKey) {
        throw "Certificate found but does not have a private key. Ensure you have the private key installed."
    }

    Write-Verbose "Found certificate: $($cert.Subject) [Thumbprint: $($cert.Thumbprint)]"
    return $cert
}

function Get-CertificateFromKeychain {
    <#
    .SYNOPSIS
        Retrieves certificate from macOS Keychain.
    .DESCRIPTION
        Uses Swift scripts to properly access macOS Keychain identities, including
        the modern data protection keychain. Falls back to PFX file if provided.

        The standard 'security' command-line tool cannot access identities in the
        data protection keychain, so we use Swift with the Security framework.
    #>
    [CmdletBinding()]
    param(
        [string]$Thumbprint,
        [string]$Subject,
        [string]$KeychainPath,
        [string]$FallbackPfxPath,
        [SecureString]$FallbackPfxPassword
    )

    # Check if running on macOS
    if (-not $IsMacOS) {
        throw "Keychain is only available on macOS. Use -Source CertStore on Windows or -Source PfxFile for cross-platform."
    }

    if (-not $Subject -and -not $Thumbprint) {
        throw "Either -Thumbprint or -Subject must be specified for Keychain source."
    }

    Write-Verbose "Searching macOS Keychain for certificate"

    # Get path to Swift tools
    $toolsPath = Join-Path $PSScriptRoot "Tools"
    $exportScript = Join-Path $toolsPath "ExportIdentity.swift"

    # Check if Swift is available
    $swiftPath = Get-Command swift -ErrorAction SilentlyContinue
    if (-not $swiftPath) {
        Write-Warning "Swift not found. Install Xcode Command Line Tools: xcode-select --install"
        Write-Warning "Falling back to PFX file if available..."

        if ($FallbackPfxPath -and (Test-Path $FallbackPfxPath)) {
            return Get-CertificateFromPfx -PfxPath $FallbackPfxPath -PfxPassword $FallbackPfxPassword
        }
        throw "Swift is required for Keychain access on macOS. Install with: xcode-select --install"
    }

    # Check if our Swift export script exists
    if (-not (Test-Path $exportScript)) {
        Write-Warning "Swift export tool not found at $exportScript"

        if ($FallbackPfxPath -and (Test-Path $FallbackPfxPath)) {
            Write-Verbose "Falling back to PFX file: $FallbackPfxPath"
            return Get-CertificateFromPfx -PfxPath $FallbackPfxPath -PfxPassword $FallbackPfxPassword
        }
        throw "Keychain export tool not found and no fallback PFX provided."
    }

    try {
        # Export identity to temp PFX using Swift
        $tempPfx = [System.IO.Path]::GetTempFileName() + ".pfx"
        $tempPassword = [guid]::NewGuid().ToString()

        $searchParam = if ($Thumbprint) { $Thumbprint.ToUpper() } else { $Subject }

        Write-Verbose "Exporting identity from Keychain using Swift..."
        $result = & swift $exportScript $searchParam $tempPfx $tempPassword 2>&1

        if ($result -match '^SUCCESS:([^:]+):(.+)$') {
            $foundThumbprint = $Matches[1]
            $foundSubject = $Matches[2]
            Write-Verbose "Found identity: $foundSubject [Thumbprint: $foundThumbprint]"

            # Load the exported PFX
            if (Test-Path $tempPfx) {
                $securePassword = ConvertTo-SecureString -String $tempPassword -AsPlainText -Force
                $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new(
                    $tempPfx,
                    $securePassword,
                    [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
                )

                Write-Verbose "Loaded certificate: $($cert.Subject) [Thumbprint: $($cert.Thumbprint)]"
                return $cert
            }
        }
        elseif ($result -match '^ERROR:(.+)$') {
            $errorMsg = $Matches[1]
            Write-Verbose "Swift export failed: $errorMsg"

            # Try fallback to PFX
            if ($FallbackPfxPath -and (Test-Path $FallbackPfxPath)) {
                Write-Warning "Identity not found in Keychain. Falling back to PFX file."
                return Get-CertificateFromPfx -PfxPath $FallbackPfxPath -PfxPassword $FallbackPfxPassword
            }

            throw "Identity not found in Keychain: $errorMsg"
        }
        else {
            Write-Verbose "Unexpected Swift output: $result"

            if ($FallbackPfxPath -and (Test-Path $FallbackPfxPath)) {
                Write-Warning "Keychain access failed. Falling back to PFX file."
                return Get-CertificateFromPfx -PfxPath $FallbackPfxPath -PfxPassword $FallbackPfxPassword
            }

            throw "Failed to export identity from Keychain: $result"
        }
    }
    finally {
        # Clean up temp file securely
        if (Test-Path $tempPfx) {
            [System.IO.File]::WriteAllBytes($tempPfx, [byte[]]::new(1024))
            Remove-Item $tempPfx -Force -ErrorAction SilentlyContinue
        }
    }
}

function Get-CertificateFromPfx {
    <#
    .SYNOPSIS
        Loads certificate from PFX file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PfxPath,

        [SecureString]$PfxPassword
    )

    if (-not (Test-Path $PfxPath)) {
        throw "PFX file not found: $PfxPath"
    }

    Write-Verbose "Loading certificate from PFX: $PfxPath"

    try {
        $flags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable

        if ($PfxPassword) {
            $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($PfxPath, $PfxPassword, $flags)
        }
        else {
            $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($PfxPath, $null, $flags)
        }

        if (-not $cert.HasPrivateKey) {
            throw "PFX file does not contain a private key."
        }

        Write-Verbose "Loaded certificate: $($cert.Subject) [Thumbprint: $($cert.Thumbprint)]"
        return $cert
    }
    catch {
        throw "Failed to load PFX file: $_"
    }
}

function Get-CertificateFromKeyVault {
    <#
    .SYNOPSIS
        Retrieves certificate from Azure Key Vault.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$VaultName,

        [Parameter(Mandatory)]
        [string]$CertificateName
    )

    Write-Verbose "Retrieving certificate '$CertificateName' from Key Vault '$VaultName'"

    # Check if Az.KeyVault module is available
    if (-not (Get-Module -ListAvailable -Name Az.KeyVault)) {
        throw "Az.KeyVault module is required for Key Vault certificate retrieval. Install with: Install-Module Az.KeyVault"
    }

    try {
        # Import module if not already loaded
        Import-Module Az.KeyVault -ErrorAction Stop

        # Get certificate with private key
        $kvCert = Get-AzKeyVaultCertificate -VaultName $VaultName -Name $CertificateName -ErrorAction Stop

        if (-not $kvCert) {
            throw "Certificate '$CertificateName' not found in Key Vault '$VaultName'"
        }

        # Get the secret (contains private key)
        $secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $CertificateName -AsPlainText -ErrorAction Stop

        # Convert from base64 to certificate
        $certBytes = [System.Convert]::FromBase64String($secret)
        $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new(
            $certBytes,
            [string]::Empty,
            [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
        )

        if (-not $cert.HasPrivateKey) {
            throw "Key Vault certificate does not contain a private key."
        }

        Write-Verbose "Retrieved certificate: $($cert.Subject) [Thumbprint: $($cert.Thumbprint)]"
        return $cert
    }
    catch {
        throw "Failed to retrieve certificate from Key Vault: $_"
    }
}
