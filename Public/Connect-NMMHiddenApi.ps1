function Connect-NMMHiddenApi {
    <#
    .SYNOPSIS
        Start HTTP listener and open browser for NMM Hidden API authentication.
    .DESCRIPTION
        Starts a local HTTP server that listens for cookies from the NMM-PS browser extension.
        Opens the NMM portal in your default browser where you can log in, then click the
        extension button to send cookies back to PowerShell.

        Workflow:
        1. Run Connect-NMMHiddenApi
        2. Log into NMM in the browser that opens
        3. Click the NMM-PS extension icon
        4. Click "Send Cookies to PowerShell"
        5. The function completes and you can use Invoke-HiddenApiRequest

        Requires the NMM-PS browser extension to be installed.
        See BrowserExtension/README.md for installation instructions.
    .PARAMETER Port
        The port to listen on for cookie delivery. Default: 19847
    .PARAMETER Timeout
        How long to wait for cookies in seconds. Default: 120 (2 minutes)
    .PARAMETER NoBrowser
        Don't open the browser automatically. Use this if you're already logged in.
    .PARAMETER BaseUri
        Override the NMM portal URL. If not specified, reads from ConfigData.json.
    .EXAMPLE
        Connect-NMMHiddenApi

        Opens browser to NMM portal, waits for extension to send cookies.
    .EXAMPLE
        Connect-NMMHiddenApi -NoBrowser

        Just starts the listener without opening a browser.
    .EXAMPLE
        Connect-NMMHiddenApi -Timeout 300

        Waits up to 5 minutes for cookies.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$Port = 19847,

        [Parameter()]
        [int]$Timeout = 120,

        [Parameter()]
        [switch]$NoBrowser,

        [Parameter()]
        [string]$BaseUri
    )

    process {
        # Determine NMM portal URL
        if ([string]::IsNullOrEmpty($BaseUri)) {
            try {
                $config = Get-ConfigData -ErrorAction Stop
                if ($config.BaseUri) {
                    $BaseUri = $config.BaseUri.TrimEnd('/')
                }
                elseif ($config.HiddenApiBaseUri) {
                    # Extract base domain from API URL
                    $uri = [System.Uri]$config.HiddenApiBaseUri
                    $BaseUri = "$($uri.Scheme)://$($uri.Host)"
                }
            }
            catch {
                Write-Warning "Could not read ConfigData.json. Please specify -BaseUri parameter."
                return
            }
        }

        if ([string]::IsNullOrEmpty($BaseUri)) {
            Write-Error "No NMM portal URL found. Specify -BaseUri or configure BaseUri in ConfigData.json"
            return
        }

        Write-Host ""
        Write-Host "  NMM Hidden API Authentication" -ForegroundColor Cyan
        Write-Host "  ─────────────────────────────" -ForegroundColor DarkGray
        Write-Host ""

        # Create HTTP listener
        $listener = New-Object System.Net.HttpListener
        $prefix = "http://localhost:$Port/"

        try {
            $listener.Prefixes.Add($prefix)
            $listener.Start()
            Write-Host "  [1/3] " -ForegroundColor DarkGray -NoNewline
            Write-Host "Listening on port $Port" -ForegroundColor Green
        }
        catch {
            if ($_.Exception.Message -like "*access*denied*" -or $_.Exception.Message -like "*permission*") {
                Write-Error "Cannot bind to port $Port. Try a different port with -Port parameter."
            }
            else {
                Write-Error "Failed to start HTTP listener: $($_.Exception.Message)"
            }
            return
        }

        # Open browser
        if (-not $NoBrowser) {
            Write-Host "  [2/3] " -ForegroundColor DarkGray -NoNewline
            Write-Host "Opening browser to: " -ForegroundColor Yellow -NoNewline
            Write-Host $BaseUri -ForegroundColor White

            try {
                if ($IsMacOS) {
                    Start-Process "open" -ArgumentList $BaseUri
                }
                elseif ($IsLinux) {
                    Start-Process "xdg-open" -ArgumentList $BaseUri
                }
                else {
                    Start-Process $BaseUri
                }
            }
            catch {
                Write-Warning "Could not open browser. Please navigate to $BaseUri manually."
            }
        }
        else {
            Write-Host "  [2/3] " -ForegroundColor DarkGray -NoNewline
            Write-Host "Browser not opened (-NoBrowser specified)" -ForegroundColor Yellow
        }

        # Extract domain from BaseUri for status endpoint
        $expectedDomain = ([System.Uri]$BaseUri).Host

        Write-Host "  [3/3] " -ForegroundColor DarkGray -NoNewline
        Write-Host "Waiting for cookies (auto-send enabled)..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Expected domain: " -ForegroundColor DarkGray -NoNewline
        Write-Host $expectedDomain -ForegroundColor White
        Write-Host "  Timeout: $Timeout seconds" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  The extension will auto-send cookies when you log in." -ForegroundColor Gray
        Write-Host "  Or click the extension icon to send manually." -ForegroundColor Gray
        Write-Host ""

        # Request handling loop - handles /status and /cookies
        $startTime = Get-Date
        $cookiesReceived = $false

        while (-not $cookiesReceived) {
            # Check timeout
            $elapsed = (Get-Date) - $startTime
            if ($elapsed.TotalSeconds -ge $Timeout) {
                $listener.Stop()
                Write-Warning "Timeout waiting for cookies. Make sure:"
                Write-Host "  - The NMM-PS extension is installed" -ForegroundColor Yellow
                Write-Host "  - You're logged into NMM at $expectedDomain" -ForegroundColor Yellow
                return
            }

            # Calculate remaining time for this iteration
            $remainingMs = [int](($Timeout - $elapsed.TotalSeconds) * 1000)
            if ($remainingMs -le 0) { $remainingMs = 1000 }
            if ($remainingMs -gt 5000) { $remainingMs = 5000 }  # Check every 5 seconds max

            $timeoutTask = [System.Threading.Tasks.Task]::Delay($remainingMs)
            $contextTask = $listener.GetContextAsync()

            $completedTask = [System.Threading.Tasks.Task]::WhenAny($contextTask, $timeoutTask).GetAwaiter().GetResult()

            if ($completedTask -eq $timeoutTask) {
                # No request yet, continue waiting
                continue
            }

            # Process the request
            $context = $contextTask.GetAwaiter().GetResult()
            $request = $context.Request
            $response = $context.Response

            # Add CORS headers
            $response.Headers.Add("Access-Control-Allow-Origin", "*")
            $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type")

            # Handle OPTIONS preflight
            if ($request.HttpMethod -eq "OPTIONS") {
                $response.StatusCode = 200
                $response.Close()
                continue
            }

            # Handle GET /status - returns listener info for auto-send
            if ($request.HttpMethod -eq "GET" -and $request.Url.LocalPath -eq "/status") {
                $statusJson = @{
                    listening = $true
                    domain    = $expectedDomain
                    port      = $Port
                    baseUri   = $BaseUri
                } | ConvertTo-Json

                $buffer = [System.Text.Encoding]::UTF8.GetBytes($statusJson)
                $response.ContentType = "application/json"
                $response.ContentLength64 = $buffer.Length
                $response.StatusCode = 200
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                $response.Close()

                Write-Verbose "Status check from extension"
                continue
            }

            # Handle POST /cookies
            if ($request.HttpMethod -eq "POST" -and $request.Url.LocalPath -eq "/cookies") {
                # Read request body
                $reader = New-Object System.IO.StreamReader($request.InputStream)
                $body = $reader.ReadToEnd()
                $reader.Close()

                try {
                    $data = $body | ConvertFrom-Json

                    if ($data.cookies) {
                        # Store cookies using Set-NMMHiddenApiCookie logic
                        $cookies = @{}
                        $data.cookies -split ';' | ForEach-Object {
                            $trimmed = $_.Trim()
                            if ($trimmed -match '^([^=]+)=(.+)$') {
                                $name = $matches[1].Trim()
                                $value = $matches[2].Trim()
                                if ($name -and $value) {
                                    $cookies[$name] = $value
                                }
                            }
                        }

                        if ($cookies.Count -gt 0) {
                            $Script:HiddenApiCookies = $cookies
                            $Script:HiddenApiAuthMethod = 'Cookie'

                            # Send success response
                            $responseJson = @{
                                success     = $true
                                message     = "Cookies received"
                                cookieCount = $cookies.Count
                            } | ConvertTo-Json

                            $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
                            $response.ContentType = "application/json"
                            $response.ContentLength64 = $buffer.Length
                            $response.StatusCode = 200
                            $response.OutputStream.Write($buffer, 0, $buffer.Length)
                            $response.Close()

                            $cookiesReceived = $true
                            $listener.Stop()

                            Write-Host "  ✓ " -ForegroundColor Green -NoNewline
                            Write-Host "Received $($cookies.Count) cookies from extension" -ForegroundColor White
                            Write-Host ""
                            Write-Host "  Cookies: " -ForegroundColor Gray -NoNewline
                            Write-Host ($cookies.Keys -join ', ') -ForegroundColor DarkGray
                            Write-Host ""
                            Write-Host "  You can now use " -ForegroundColor Gray -NoNewline
                            Write-Host "Invoke-HiddenApiRequest" -ForegroundColor Cyan -NoNewline
                            Write-Host " to call APIs." -ForegroundColor Gray
                            Write-Host ""

                            return [PSCustomObject]@{
                                Success     = $true
                                AuthMethod  = 'Cookie'
                                CookieCount = $cookies.Count
                                CookieNames = [array]$cookies.Keys
                                Domain      = $data.domain
                            }
                        }
                    }

                    # No cookies in request
                    $errorJson = @{ success = $false; message = "No cookies in request" } | ConvertTo-Json
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($errorJson)
                    $response.ContentType = "application/json"
                    $response.StatusCode = 400
                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                    $response.Close()
                    # Don't stop listener - continue waiting for valid cookies
                    Write-Warning "Received request but no cookies were included. Still waiting..."
                    continue
                }
                catch {
                    $errorJson = @{ success = $false; message = "Invalid request" } | ConvertTo-Json
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($errorJson)
                    $response.ContentType = "application/json"
                    $response.StatusCode = 400
                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                    $response.Close()
                    Write-Warning "Failed to parse cookie data: $($_.Exception.Message)"
                    continue
                }
            }
            else {
                # Unknown endpoint - return 404 but keep listening
                $response.StatusCode = 404
                $response.Close()
                Write-Verbose "Unknown request: $($request.HttpMethod) $($request.Url.LocalPath)"
                continue
            }
        }
    }
}
