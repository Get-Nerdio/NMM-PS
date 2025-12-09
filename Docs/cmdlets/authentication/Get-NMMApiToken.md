# Get-NMMApiToken

Gets the current cached API access token.

## Syntax

```powershell
Get-NMMApiToken [<CommonParameters>]
```

## Description

The `Get-NMMApiToken` cmdlet returns the currently cached access token from a previous `Connect-NMMApi` call. This is useful for checking authentication status and token expiration.

## Examples

### Example 1: Get current token

```powershell
Get-NMMApiToken
```

```
Expiry      : 12/9/2025 8:30:00 PM
TokenType   : Bearer
APIUrl      : https://contoso.nerdio.net/rest-api/v1
AccessToken : eyJ0eXAiOiJKV1QiLC...
AuthMethod  : Certificate
```

### Example 2: Check if token is expired

```powershell
$token = Get-NMMApiToken
if ($token.Expiry -lt (Get-Date)) {
    Write-Host "Token expired, reconnecting..."
    Connect-NMMApi
}
```

## Outputs

**PSCustomObject** or **$null** if not authenticated.

| Property | Type | Description |
|----------|------|-------------|
| Expiry | DateTime | Token expiration time |
| TokenType | String | Always "Bearer" |
| APIUrl | String | API base URL |
| AccessToken | String | The access token |
| AuthMethod | String | Authentication method used |

## Notes

- Returns `$null` if `Connect-NMMApi` hasn't been called
- The token is stored in module scope and persists for the PowerShell session

## Related Links

- [Connect-NMMApi](Connect-NMMApi.md)
