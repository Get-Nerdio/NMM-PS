function Get-NMMGroup {
    <#
    .SYNOPSIS
        Get a specific Azure AD group by ID.
    .DESCRIPTION
        Retrieves detailed information for a specific Azure AD group by its group ID.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER GroupId
        The Azure AD group ID (GUID).
    .EXAMPLE
        Get-NMMGroup -AccountId 123 -GroupId "00000000-0000-0000-0000-000000000000"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$AccountId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [string]$GroupId
    )

    process {
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/groups/$GroupId"
    }
}
