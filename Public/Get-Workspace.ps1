function Get-Workspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AccountId
    )

    process {
        $apiPath = "accounts/$AccountId/workspace"
        $method = "GET"

        try {
            $response = Invoke-APIRequest -Method $method -Endpoint $apiPath
            return $response
        }
        catch {
            Write-Error "Failed to get workspace: $_"
        }
    }
}