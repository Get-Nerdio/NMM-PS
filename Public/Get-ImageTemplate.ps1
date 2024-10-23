function Get-ImageTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AccountId
    )

    process {
        $apiPath = "accounts/$AccountId/desktop-image"
        $method = "GET"

        try {
            $response = Invoke-APIRequest -Method $method -Endpoint $apiPath
            return $response
        }
        catch {
            Write-Error "Failed to get image template: $_"
        }
    }
}