function Get-NMMRecoveryPoint {
    <#
    .SYNOPSIS
        Get backup recovery points for an account.
    .DESCRIPTION
        Retrieves all available Azure Backup recovery points
        for protected items in a specific NMM account.
    .PARAMETER AccountId
        The NMM account ID.
    .EXAMPLE
        Get-NMMRecoveryPoint -AccountId 123
    .EXAMPLE
        Get-NMMAccount | Get-NMMRecoveryPoint
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [int]$AccountId
    )

    process {
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/backup/recoveryPoints"
    }
}
