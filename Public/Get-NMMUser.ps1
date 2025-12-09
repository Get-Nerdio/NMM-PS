function Get-NMMUser {
    <#
    .SYNOPSIS
        Get a specific user by ID.
    .DESCRIPTION
        Retrieves detailed information for a specific Azure AD user by their user ID.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER UserId
        The Azure AD user ID (GUID).
    .EXAMPLE
        Get-NMMUser -AccountId 123 -UserId "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        # Get user details from a search result
        $users = Get-NMMUsers -AccountId 123 -Search "john"
        $users.items | ForEach-Object { Get-NMMUser -AccountId 123 -UserId $_.id }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$AccountId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/users/$UserId"
    }
}
