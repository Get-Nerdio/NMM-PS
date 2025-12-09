function Get-NMMProtectedItem {
    <#
    .SYNOPSIS
        Get backup protected items for an account.
    .DESCRIPTION
        Retrieves all Azure Backup protected items (VMs, file shares, etc.)
        configured for a specific NMM account.
    .PARAMETER AccountId
        The NMM account ID.
    .EXAMPLE
        Get-NMMProtectedItem -AccountId 123
    .EXAMPLE
        Get-NMMAccount | Get-NMMProtectedItem
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [int]$AccountId
    )

    process {
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/backup/protectedItems"
    }
}
