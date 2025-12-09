# Connect-NMMApi

Authenticates to the NMM API and caches the access token.

## Syntax

```powershell
Connect-NMMApi
    [-BaseURI <String>]
    [-TenantId <String>]
    [-ClientId <String>]
    [-ClientSecret <String>]
    [-Scope <String>]
    [<CommonParameters>]

Connect-NMMApi
    -CertificateThumbprint <String>
    [-BaseURI <String>]
    [-TenantId <String>]
    [-ClientId <String>]
    [-Scope <String>]
    [<CommonParameters>]

Connect-NMMApi
    -CertificatePath <String>
    [-CertificatePassword <SecureString>]
    [-BaseURI <String>]
    [-TenantId <String>]
    [-ClientId <String>]
    [-Scope <String>]
    [<CommonParameters>]
```

## Description

The `Connect-NMMApi` cmdlet authenticates to the NMM API using either client secret or certificate-based authentication. Upon successful authentication, the access token is cached for subsequent API calls.

## Parameters

### -BaseURI

The NMM API base URL.

| | |
|---|---|
| Type | String |
| Required | False |
| Default | From ConfigData.json |

### -TenantId

Azure AD tenant ID.

| | |
|---|---|
| Type | String |
| Required | False |
| Default | From ConfigData.json |

### -ClientId

Azure AD application (client) ID.

| | |
|---|---|
| Type | String |
| Required | False |
| Default | From ConfigData.json |

### -ClientSecret

Client secret for authentication.

| | |
|---|---|
| Type | String |
| Required | False |
| Default | From ConfigData.json |

### -Scope

OAuth2 scope.

| | |
|---|---|
| Type | String |
| Required | False |
| Default | From ConfigData.json |

### -CertificateThumbprint

Certificate thumbprint for certificate-based authentication.

| | |
|---|---|
| Type | String |
| Required | True (CertificateThumbprint set) |

### -CertificatePath

Path to PFX certificate file.

| | |
|---|---|
| Type | String |
| Required | True (CertificatePfx set) |

### -CertificatePassword

Password for PFX file.

| | |
|---|---|
| Type | SecureString |
| Required | False |

## Examples

### Example 1: Connect using ConfigData.json

```powershell
Connect-NMMApi
```

Connects using credentials stored in ConfigData.json.

### Example 2: Connect with explicit credentials

```powershell
Connect-NMMApi -ClientId "your-id" -ClientSecret "your-secret" -TenantId "your-tenant"
```

### Example 3: Connect with certificate thumbprint

```powershell
Connect-NMMApi -CertificateThumbprint "ABC123DEF456789"
```

### Example 4: Connect with PFX file

```powershell
$password = ConvertTo-SecureString "pfx-password" -AsPlainText -Force
Connect-NMMApi -CertificatePath "./cert.pfx" -CertificatePassword $password
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| Expiry | DateTime | Token expiration time |
| TokenType | String | Always "Bearer" |
| APIUrl | String | API base URL |
| AccessToken | String | The access token |
| AuthMethod | String | "Secret" or "Certificate" |

## Notes

- The token is cached in memory and reused for subsequent cmdlet calls
- Token expires after ~1 hour; re-run `Connect-NMMApi` to refresh
- Certificate auth is recommended for production environments

## Related Links

- [Get-NMMApiToken](Get-NMMApiToken.md)
- [New-NMMApiCertificate](New-NMMApiCertificate.md)
- [Configuration Guide](../../getting-started/configuration.md)
