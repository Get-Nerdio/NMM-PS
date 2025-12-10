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
        Uses the macOS security command-line tool to find and export a certificate
        with its private key from the Keychain. The certificate can be found by
        thumbprint (SHA-1 hash) or subject name.

        Note: macOS Keychain has known issues with PKCS12 import where the private key
        may not be properly associated with the certificate. If the identity is not found
        but a PfxPath and PfxPassword are provided in the config, it will fall back to
        loading directly from the PFX file.
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

    Write-Verbose "Searching macOS Keychain: $KeychainPath"

    try {
        # First, check if the certificate exists in the keychain at all
        $certExists = $false
        if ($Thumbprint) {
            $certCheck = & security find-certificate -a -Z "$KeychainPath" 2>&1
            if ($certCheck -match $Thumbprint) {
                $certExists = $true
                Write-Verbose "Certificate with thumbprint $Thumbprint found in keychain"
            }
        }

        # Find all identities (cert + private key pairs) in the keychain
        $identityOutput = & security find-identity -v "$KeychainPath" 2>&1

        if ($LASTEXITCODE -ne 0 -and $identityOutput -notmatch "0 valid identities found") {
            throw "Failed to search Keychain: $identityOutput"
        }

        # Parse the identity output to find matching certificate
        # Format: "  1) HASH "Subject Name (details)""
        $identityHash = $null
        $identityName = $null

        foreach ($line in $identityOutput) {
            if ($line -match '^\s*\d+\)\s+([A-F0-9]{40})\s+"(.+)"') {
                $hash = $Matches[1]
                $name = $Matches[2]

                if ($Thumbprint -and $hash -eq $Thumbprint.ToUpper()) {
                    $identityHash = $hash
                    $identityName = $name
                    break
                }
                elseif ($Subject -and $name -like "*$Subject*") {
                    $identityHash = $hash
                    $identityName = $name
                    break
                }
            }
        }

        # If no identity found but certificate exists, the private key wasn't properly imported
        if (-not $identityHash -and $certExists) {
            Write-Warning "Certificate found in Keychain but private key is not associated (common macOS import issue)."

            # Try fallback to PFX if provided
            if ($FallbackPfxPath -and (Test-Path $FallbackPfxPath)) {
                Write-Verbose "Falling back to PFX file: $FallbackPfxPath"
                return Get-CertificateFromPfx -PfxPath $FallbackPfxPath -PfxPassword $FallbackPfxPassword
            }

            throw "Certificate exists in Keychain but has no associated private key. This is a known macOS issue. Workaround: Use Source='PfxFile' instead, or provide FallbackPfxPath in your configuration."
        }

        if (-not $identityHash) {
            $searchCriteria = if ($Thumbprint) { "thumbprint '$Thumbprint'" } else { "subject '$Subject'" }

            # Provide helpful error message
            $errorMsg = "Certificate identity with $searchCriteria not found in Keychain '$KeychainPath'."
            if ($identityOutput -match "0 valid identities found") {
                $errorMsg += "`n`nNo valid identities (certificate + private key pairs) exist in this keychain."
                $errorMsg += "`nThis can happen when:`n  1. The PFX import didn't include the private key`n  2. The certificate was imported without its private key`n  3. Access permissions prevent reading the private key"
                $errorMsg += "`n`nRecommendation: Use Source='PfxFile' for more reliable certificate loading on macOS."
            }
            else {
                $errorMsg += "`n`nAvailable identities:`n$identityOutput"
            }
            throw $errorMsg
        }

        Write-Verbose "Found identity: $identityName [Hash: $identityHash]"

        # Export the specific identity to a temporary PKCS12
        $tempPfx = [System.IO.Path]::GetTempFileName() + ".pfx"
        $tempPassword = [guid]::NewGuid().ToString()

        try {
            # Export all identities from keychain (we'll filter after loading)
            $exportResult = & security export -k "$KeychainPath" -t identities -f pkcs12 -P "$tempPassword" -o "$tempPfx" 2>&1

            if (-not (Test-Path $tempPfx) -or (Get-Item $tempPfx).Length -eq 0) {
                throw "Failed to export certificate from Keychain. You may need to allow access in Keychain Access app."
            }

            # Load the PKCS12
            $pfxCollection = [System.Security.Cryptography.X509Certificates.X509Certificate2Collection]::new()
            $pfxCollection.Import($tempPfx, $tempPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

            # Find the matching certificate in the collection
            $cert = $null
            foreach ($c in $pfxCollection) {
                if ($c.HasPrivateKey) {
                    if ($Thumbprint -and $c.Thumbprint -eq $Thumbprint.ToUpper()) {
                        $cert = $c
                        break
                    }
                    elseif ($Subject -and $c.Subject -like "*$Subject*") {
                        $cert = $c
                        break
                    }
                    elseif ($c.Thumbprint -eq $identityHash) {
                        $cert = $c
                        break
                    }
                }
            }

            if (-not $cert) {
                # If exact match not found, try the first cert with private key
                $cert = $pfxCollection | Where-Object { $_.HasPrivateKey } | Select-Object -First 1
            }

            if (-not $cert) {
                throw "No certificate with private key found in exported PKCS12"
            }

            Write-Verbose "Loaded certificate: $($cert.Subject) [Thumbprint: $($cert.Thumbprint)]"
            return $cert
        }
        finally {
            # Clean up temp file securely
            if (Test-Path $tempPfx) {
                # Overwrite with zeros before deleting
                [System.IO.File]::WriteAllBytes($tempPfx, [byte[]]::new(1024))
                Remove-Item $tempPfx -Force -ErrorAction SilentlyContinue
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
