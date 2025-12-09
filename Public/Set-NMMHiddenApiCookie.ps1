function Set-NMMHiddenApiCookie {
    <#
    .SYNOPSIS
        Set authentication cookies for NMM Hidden API access.
    .DESCRIPTION
        Uses cookies captured from a browser session to authenticate to NMM's internal APIs.

        RECOMMENDED: Use Cookie-Editor browser extension
        1. Install "Cookie-Editor" extension for Chrome/Edge
        2. Log into NMM web portal
        3. Click Cookie-Editor icon > Export > "Header String"
        4. Paste in PowerShell: Set-NMMHiddenApiCookie -CookieString "<paste>"

        Note: Cookies expire when your browser session ends. You'll need to re-export
        cookies after logging in again.
    .PARAMETER Cookies
        Hashtable of cookie name/value pairs.
    .PARAMETER CookieString
        Cookie header string (format: "name1=value1;name2=value2").
        Export this from Cookie-Editor extension using "Header String" format.
    .EXAMPLE
        # Using Cookie-Editor "Header String" export (RECOMMENDED)
        Set-NMMHiddenApiCookie -CookieString ".AspNetCore.Cookies=abc123;XSRF-TOKEN=xyz789;ARRAffinity=abc"

    .EXAMPLE
        Set-NMMHiddenApiCookie -Cookies @{ ".AspNetCore.Cookies" = "abc123"; "XSRF-TOKEN" = "xyz" }

        Sets cookies from a hashtable.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Hashtable')]
        [hashtable]$Cookies,

        [Parameter(Mandatory = $true, ParameterSetName = 'String')]
        [string]$CookieString
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'String') {
            # Parse cookie string into hashtable
            $Cookies = @{}

            # Handle different formats (semicolon with or without space)
            $CookieString -split ';' | ForEach-Object {
                $trimmed = $_.Trim()
                if ($trimmed -match '^([^=]+)=(.+)$') {
                    $name = $matches[1].Trim()
                    $value = $matches[2].Trim()
                    if ($name -and $value) {
                        $Cookies[$name] = $value
                        Write-Verbose "Parsed cookie: $name"
                    }
                }
            }

            if ($Cookies.Count -eq 0) {
                Write-Warning "No cookies parsed from string. Make sure format is: name=value; name2=value2"
                Write-Warning "Tip: In browser console, run: copy(document.cookie)"
                return $null
            }
        }

        # Store cookies for use by Invoke-HiddenApiRequest
        $Script:HiddenApiCookies = $Cookies
        $Script:HiddenApiAuthMethod = 'Cookie'

        Write-Host ""
        Write-Host "  ✓ Cookies set for Hidden API authentication" -ForegroundColor Green
        Write-Host "    Cookie count: $($Cookies.Count)" -ForegroundColor Gray
        Write-Host "    Cookies: $($Cookies.Keys -join ', ')" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Use Invoke-HiddenApiRequest to call APIs." -ForegroundColor DarkGray
        Write-Host ""

        return [PSCustomObject]@{
            AuthMethod  = 'Cookie'
            CookieCount = $Cookies.Count
            CookieNames = [array]$Cookies.Keys
        }
    }
}
