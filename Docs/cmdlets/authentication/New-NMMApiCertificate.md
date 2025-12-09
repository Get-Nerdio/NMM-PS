# New-NMMApiCertificate

Creates a self-signed certificate for NMM API authentication.

## Syntax

```powershell
New-NMMApiCertificate
    [-CertificateName <String>]
    [-ValidityMonths <Int32>]
    [-ExportToPfx <String>]
    [-PfxPassword <SecureString>]
    [-ExportToPem <String>]
    [-ExportToCertStore]
    [-StoreLocation <String>]
    [-ExportToKeyVault]
    [-VaultName <String>]
    [-Upload]
    [-UploadMethod <String>]
    [-ApplicationId <String>]
    [-TenantId <String>]
    [-UpdateConfig]
    [<CommonParameters>]
```

## Description

The `New-NMMApiCertificate` cmdlet creates a self-signed certificate for certificate-based authentication with Azure AD. It supports multiple export destinations and can automatically upload the public key to your app registration.

## Parameters

### -CertificateName

Display name for the certificate.

| | |
|---|---|
| Type | String |
| Required | False |
| Default | "NMM-API-Certificate" |

### -ValidityMonths

Certificate validity period in months.

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Default | 12 |

### -ExportToPfx

Path to export PFX file.

| | |
|---|---|
| Type | String |
| Required | False |

### -ExportToCertStore

Export to Windows Certificate Store or macOS Keychain.

| | |
|---|---|
| Type | Switch |
| Required | False |

### -Upload

Upload public certificate to Azure AD app registration.

| | |
|---|---|
| Type | Switch |
| Required | False |

### -UploadMethod

Authentication method for upload: `DeviceCode`, `Interactive`, or `Secret`.

| | |
|---|---|
| Type | String |
| Required | False |
| Default | DeviceCode |

### -UpdateConfig

Update ConfigData.json with certificate details.

| | |
|---|---|
| Type | Switch |
| Required | False |

## Examples

### Example 1: Create and store in certificate store

```powershell
New-NMMApiCertificate -ExportToCertStore -UpdateConfig
```

Creates a certificate, imports to local cert store, and updates config.

### Example 2: Full setup with Azure AD upload

```powershell
New-NMMApiCertificate -ExportToPfx "./nmm-cert.pfx" `
                      -ExportToCertStore `
                      -Upload `
                      -UploadMethod DeviceCode `
                      -UpdateConfig
```

Creates certificate, exports to PFX, imports to store, uploads to Azure AD, and updates config.

### Example 3: Export to Key Vault

```powershell
New-NMMApiCertificate -ExportToKeyVault -VaultName "my-keyvault" -UpdateConfig
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| Thumbprint | String | Certificate thumbprint |
| Subject | String | Certificate subject (CN=...) |
| NotBefore | DateTime | Validity start date |
| NotAfter | DateTime | Expiration date |
| ExportedTo | String[] | Export locations |
| UploadedToAzureAD | Boolean | Upload success status |

## Notes

- Requires appropriate permissions to upload to Azure AD (Application.ReadWrite.All or Application.ReadWrite.OwnedBy)
- Device code flow requires user interaction in a browser
- The generated password for PFX is displayed once; save it securely

## Related Links

- [Connect-NMMApi](Connect-NMMApi.md)
- [Authentication Guide](../../getting-started/authentication.md)
