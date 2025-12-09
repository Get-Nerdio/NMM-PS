# Authentication

NMM-PS supports multiple authentication methods to connect to the NMM API.

## Authentication Methods

| Method | Security | Use Case |
|--------|----------|----------|
| Client Secret | Standard | Development, simple automation |
| Certificate | High | Production, CI/CD pipelines |

## Client Secret Authentication

The simplest method uses a client secret stored in `ConfigData.json`:

```json
{
    "BaseUri": "https://your-instance.nerdio.net",
    "TenantId": "your-tenant-id",
    "ClientId": "your-client-id",
    "Scope": "api://your-app-id/.default",
    "ClientSecret": "your-client-secret"
}
```

Connect using:

```powershell
Connect-NMMApi
```

Or pass credentials directly:

```powershell
Connect-NMMApi -ClientId "your-id" -ClientSecret "your-secret" -TenantId "your-tenant"
```

## Certificate Authentication

Certificate authentication is more secure and recommended for production use.

### Step 1: Create a Certificate

Use `New-NMMApiCertificate` to generate a self-signed certificate:

```powershell
# Create certificate and upload to Azure AD
New-NMMApiCertificate -ExportToPfx "./nmm-cert.pfx" `
                      -ExportToCertStore `
                      -Upload `
                      -UploadMethod DeviceCode `
                      -UpdateConfig
```

This will:

1. Generate a self-signed certificate
2. Export to a PFX file (backup)
3. Import to Windows Certificate Store or macOS Keychain
4. Upload public key to your Azure AD app registration
5. Update `ConfigData.json` with certificate details

### Step 2: Configure for Certificate Auth

After running `New-NMMApiCertificate -UpdateConfig`, your config will be updated:

```json
{
    "BaseUri": "https://your-instance.nerdio.net",
    "TenantId": "your-tenant-id",
    "ClientId": "your-client-id",
    "Scope": "api://your-app-id/.default",
    "AuthMethod": "Certificate",
    "Certificate": {
        "Source": "PfxFile",
        "Path": "./nmm-cert.pfx",
        "Thumbprint": "ABC123DEF456..."
    }
}
```

### Certificate Storage Options

=== "Windows Certificate Store"

    ```json
    "Certificate": {
        "Source": "CertStore",
        "Thumbprint": "ABC123DEF456...",
        "StoreLocation": "CurrentUser",
        "StoreName": "My"
    }
    ```

=== "macOS Keychain"

    ```json
    "Certificate": {
        "Source": "Keychain",
        "Thumbprint": "ABC123DEF456...",
        "KeychainPath": "login.keychain-db"
    }
    ```

=== "PFX File"

    ```json
    "Certificate": {
        "Source": "PfxFile",
        "Path": "/path/to/cert.pfx",
        "Password": "pfx-password"
    }
    ```

=== "Azure Key Vault"

    ```json
    "Certificate": {
        "Source": "KeyVault",
        "VaultName": "my-keyvault",
        "CertificateName": "nmm-api-cert"
    }
    ```

### Connect with Certificate

Once configured, simply run:

```powershell
Connect-NMMApi
```

Or specify the certificate directly:

```powershell
# By thumbprint (Windows/macOS)
Connect-NMMApi -CertificateThumbprint "ABC123DEF456..."

# By PFX file
$password = ConvertTo-SecureString "password" -AsPlainText -Force
Connect-NMMApi -CertificatePath "./cert.pfx" -CertificatePassword $password
```

## Token Caching

After successful authentication, the token is cached in memory:

```powershell
# First call authenticates
Connect-NMMApi

# Subsequent calls use cached token (until expiry)
Connect-NMMApi  # Returns cached token
```

To force re-authentication, restart your PowerShell session.

## View Current Token

Check your current authentication status:

```powershell
$token = Get-NMMApiToken
$token

# Output:
# Expiry      : 12/9/2025 8:30:00 PM
# TokenType   : Bearer
# APIUrl      : https://your-instance.nerdio.net/rest-api/v1
# AuthMethod  : Certificate
```

## Troubleshooting

### "Not authenticated" Error

Run `Connect-NMMApi` before calling other cmdlets:

```powershell
Connect-NMMApi
Get-NMMAccount  # Now works
```

### "Token expired" Error

The token has expired. Re-run `Connect-NMMApi`:

```powershell
Connect-NMMApi
```

### Certificate Not Found

Ensure the certificate is installed in the correct store:

```powershell
# Windows - Check certificate store
Get-ChildItem Cert:\CurrentUser\My | Where-Object Thumbprint -eq "ABC123..."

# macOS - Check keychain
security find-certificate -a -c "NMM-API"
```

### Invalid Client Secret

Verify your `ConfigData.json` has the correct secret and that it hasn't expired in Azure AD.
