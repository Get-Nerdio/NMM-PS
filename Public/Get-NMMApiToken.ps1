function Get-NMMApiToken {
    try {
        Write-Host "Getting current API token..."
        $script:cachedToken
    }
    catch {
        Write-Error "Failed to get current API token: $_, Please run Connect-NMMApi to get a new token."
    }
}