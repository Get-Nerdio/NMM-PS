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
        [string]$KeychainPath = 'login.keychain-db'
    )

    process {
        switch ($Source) {
            'CertStore' {
                return Get-CertificateFromStore -Thumbprint $Thumbprint -Subject $Subject -StoreLocation $StoreLocation -StoreName $StoreName
            }
            'Keychain' {
                return Get-CertificateFromKeychain -Thumbprint $Thumbprint -Subject $Subject -KeychainPath $KeychainPath
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
    #>
    [CmdletBinding()]
    param(
        [string]$Thumbprint,
        [string]$Subject,
        [string]$KeychainPath
    )

    # Check if running on macOS
    if (-not $IsMacOS) {
        throw "Keychain is only available on macOS. Use -Source CertStore on Windows or -Source PfxFile for cross-platform."
    }

    if (-not $Subject -and -not $Thumbprint) {
        throw "Either -Thumbprint or -Subject must be specified for Keychain source."
    }

    Write-Verbose "Searching macOS Keychain: $KeychainPath"

    # Use security command to find and export certificate
    $searchCriteria = if ($Subject) { $Subject } else { $Thumbprint }

    try {
        # Find the certificate identity (cert + private key)
        $identityOutput = & security find-identity -v -p codesigning "$KeychainPath" 2>&1

        # Search for our certificate in the output
        $matchingLine = $identityOutput | Where-Object { $_ -match $searchCriteria }

        if (-not $matchingLine) {
            # Try searching all identities
            $identityOutput = & security find-identity -v "$KeychainPath" 2>&1
            $matchingLine = $identityOutput | Where-Object { $_ -match $searchCriteria }
        }

        if (-not $matchingLine) {
            throw "Certificate with criteria '$searchCriteria' not found in Keychain '$KeychainPath'"
        }

        # Export the certificate and private key to a temporary PKCS12
        $tempPfx = [System.IO.Path]::GetTempFileName() + ".pfx"
        $tempPassword = [guid]::NewGuid().ToString()

        try {
            # Export identity to PKCS12
            & security export -k "$KeychainPath" -t identities -f pkcs12 -P "$tempPassword" -o "$tempPfx" 2>&1 | Out-Null

            if (-not (Test-Path $tempPfx)) {
                throw "Failed to export certificate from Keychain"
            }

            # Load the PKCS12 into X509Certificate2
            $securePassword = ConvertTo-SecureString -String $tempPassword -AsPlainText -Force
            $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new(
                $tempPfx,
                $securePassword,
                [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
            )

            # Verify it's the right certificate
            if ($Thumbprint -and $cert.Thumbprint -ne $Thumbprint) {
                throw "Exported certificate thumbprint doesn't match requested thumbprint"
            }

            Write-Verbose "Found certificate: $($cert.Subject) [Thumbprint: $($cert.Thumbprint)]"
            return $cert
        }
        finally {
            # Clean up temp file
            if (Test-Path $tempPfx) {
                Remove-Item $tempPfx -Force
            }
        }
    }
    catch {
        throw "Failed to retrieve certificate from Keychain: $_"
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
