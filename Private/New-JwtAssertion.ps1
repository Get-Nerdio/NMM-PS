function New-JwtAssertion {
    <#
    .SYNOPSIS
        Creates a signed JWT assertion for certificate-based authentication.
    .DESCRIPTION
        Generates a JWT (JSON Web Token) signed with a certificate's private key
        for use in OAuth2 client_credentials flow with Azure AD.

        JWT Structure:
        - Header:  { "alg": "RS256", "typ": "JWT", "x5t": "<thumbprint>" }
        - Payload: { "iss": "<clientId>", "sub": "<clientId>", "aud": "<tokenEndpoint>",
                     "jti": "<guid>", "exp": <now+600>, "nbf": <now>, "iat": <now> }
        - Signature: RS256(header.payload, privateKey)
    .PARAMETER Certificate
        X509Certificate2 object with private key.
    .PARAMETER ClientId
        Azure AD application (client) ID.
    .PARAMETER TenantId
        Azure AD tenant ID.
    .PARAMETER ValiditySeconds
        JWT validity period in seconds (default: 600 = 10 minutes).
    .OUTPUTS
        [string] - The signed JWT assertion.
    .EXAMPLE
        $cert = Get-Item Cert:\CurrentUser\My\ABC123
        $jwt = New-JwtAssertion -Certificate $cert -ClientId "xxx" -TenantId "yyy"
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter()]
        [int]$ValiditySeconds = 600
    )

    process {
        # Validate certificate has private key
        if (-not $Certificate.HasPrivateKey) {
            throw "Certificate does not contain a private key. Certificate-based authentication requires the private key."
        }

        # Get the private key (cross-platform compatible)
        $privateKey = $null

        # Try GetRSAPrivateKey() first (newer .NET)
        if ($Certificate.PSObject.Methods.Name -contains 'GetRSAPrivateKey') {
            $privateKey = $Certificate.GetRSAPrivateKey()
        }

        # Fallback to PrivateKey property (older approach)
        if (-not $privateKey -and $Certificate.PrivateKey) {
            $privateKey = $Certificate.PrivateKey
        }

        if (-not $privateKey) {
            throw "Failed to get RSA private key from certificate. Ensure the certificate uses RSA encryption and includes the private key."
        }

        # Calculate x5t (X.509 certificate SHA-1 thumbprint, base64url encoded)
        $thumbprintBytes = [System.Convert]::FromHexString($Certificate.Thumbprint)
        $x5t = ConvertTo-Base64UrlString -Bytes $thumbprintBytes

        # Build JWT Header
        $header = @{
            alg = "RS256"
            typ = "JWT"
            x5t = $x5t
        }

        # Calculate timestamps
        $now = [DateTimeOffset]::UtcNow
        $nbf = [long]$now.ToUnixTimeSeconds()
        $iat = $nbf
        $exp = [long]$now.AddSeconds($ValiditySeconds).ToUnixTimeSeconds()

        # Build JWT Payload
        $tokenEndpoint = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
        $payload = @{
            aud = $tokenEndpoint
            iss = $ClientId
            sub = $ClientId
            jti = [guid]::NewGuid().ToString()
            nbf = $nbf
            iat = $iat
            exp = $exp
        }

        # Convert to JSON and Base64URL encode
        $headerJson = $header | ConvertTo-Json -Compress
        $payloadJson = $payload | ConvertTo-Json -Compress

        $headerBase64 = ConvertTo-Base64UrlString -Text $headerJson
        $payloadBase64 = ConvertTo-Base64UrlString -Text $payloadJson

        # Create signature input
        $signatureInput = "$headerBase64.$payloadBase64"
        $signatureInputBytes = [System.Text.Encoding]::UTF8.GetBytes($signatureInput)

        # Sign with RSA-SHA256
        $signatureBytes = $privateKey.SignData(
            $signatureInputBytes,
            [System.Security.Cryptography.HashAlgorithmName]::SHA256,
            [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
        )

        $signatureBase64 = ConvertTo-Base64UrlString -Bytes $signatureBytes

        # Construct final JWT
        $jwt = "$headerBase64.$payloadBase64.$signatureBase64"

        Write-Verbose "Created JWT assertion for client '$ClientId' valid for $ValiditySeconds seconds"
        Write-Verbose "JWT x5t (thumbprint): $x5t"

        return $jwt
    }
}

function ConvertTo-Base64UrlString {
    <#
    .SYNOPSIS
        Converts bytes or text to Base64URL encoding.
    .DESCRIPTION
        Base64URL encoding is Base64 with:
        - '+' replaced with '-'
        - '/' replaced with '_'
        - Trailing '=' padding removed
    #>
    [CmdletBinding(DefaultParameterSetName = 'Bytes')]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Bytes')]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true, ParameterSetName = 'Text')]
        [string]$Text
    )

    if ($PSCmdlet.ParameterSetName -eq 'Text') {
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    }

    $base64 = [System.Convert]::ToBase64String($Bytes)

    # Convert to Base64URL
    $base64Url = $base64 -replace '\+', '-' -replace '/', '_' -replace '=+$', ''

    return $base64Url
}
