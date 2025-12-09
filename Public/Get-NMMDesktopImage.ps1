function Get-NMMDesktopImage {
    <#
    .SYNOPSIS
        Get all desktop images for an account.
    .DESCRIPTION
        Retrieves a list of all desktop images (golden images) configured
        for a specific NMM account.
    .PARAMETER AccountId
        The NMM account ID.
    .EXAMPLE
        Get-NMMDesktopImage -AccountId 123
    .EXAMPLE
        Get-NMMAccount | Get-NMMDesktopImage
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [int]$AccountId
    )

    process {
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/desktop-image"
    }
}
