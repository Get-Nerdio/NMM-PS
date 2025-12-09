# Configuration

NMM-PS uses a JSON configuration file to store API credentials and settings.

## Configuration File Location

The configuration file is located at:

```
<module-path>/Private/Data/ConfigData.json
```

For local development, set the environment variable `NMM_DEV_MODE=true` to use `ConfigData-Local.json` instead.

## Configuration Structure

Create or edit `ConfigData.json` with your NMM API credentials:

```json
{
    "BaseUri": "https://your-nerdio-instance.nerdio.net",
    "TenantId": "your-azure-tenant-id",
    "ClientId": "your-app-registration-client-id",
    "Scope": "api://your-app-id/.default",
    "ClientSecret": "your-client-secret"
}
```

### Required Fields

| Field | Description | Example |
|-------|-------------|---------|
| `BaseUri` | Your NMM instance URL | `https://contoso.nerdio.net` |
| `TenantId` | Azure AD tenant ID | `d26d1e01-5e94-4110-848b-ecba9ee44f60` |
| `ClientId` | App registration client ID | `7ee590b9-bea3-4d65-b6da-2cfa33ff8faa` |
| `Scope` | OAuth2 scope | `api://31d1c288-f4d8-46b9-88bd-aab9abac37d5/.default` |
| `ClientSecret` | Client secret (or use certificate) | `90.8Q~...` |

## Certificate Authentication

For enhanced security, you can use certificate-based authentication instead of a client secret:

```json
{
    "BaseUri": "https://your-nerdio-instance.nerdio.net",
    "TenantId": "your-azure-tenant-id",
    "ClientId": "your-app-registration-client-id",
    "Scope": "api://your-app-id/.default",
    "AuthMethod": "Certificate",
    "Certificate": {
        "Source": "CertStore",
        "Thumbprint": "ABC123DEF456...",
        "StoreLocation": "CurrentUser",
        "StoreName": "My"
    }
}
```

See [Authentication](authentication.md) for more details on certificate setup.

## Environment Variables

For CI/CD pipelines or containerized environments, you can override configuration with environment variables:

```bash
export NMM_BASE_URI="https://contoso.nerdio.net"
export NMM_TENANT_ID="your-tenant-id"
export NMM_CLIENT_ID="your-client-id"
export NMM_CLIENT_SECRET="your-secret"
```

## Development Mode

For local development, create a `ConfigData-Local.json` file and enable dev mode:

```powershell
$env:NMM_DEV_MODE = 'true'
Import-Module ./NMM-PS.psm1
```

This keeps production credentials separate from development credentials.

## Validate Configuration

Test your configuration by connecting to the API:

```powershell
Import-Module NMM-PS
Connect-NMMApi -Verbose
```

A successful connection returns a token object:

```
VERBOSE: Using secret authentication
VERBOSE: Successfully authenticated with client secret
```

## Next Steps

Learn about the different [authentication methods](authentication.md) available.
