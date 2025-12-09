function Get-NMMUserMFA {
    <#
    .SYNOPSIS
        Get MFA status for a specific user.
    .DESCRIPTION
        Retrieves the Multi-Factor Authentication registration status
        for a specific Azure AD user.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER UserId
        The Azure AD user ID (GUID).
    .EXAMPLE
        Get-NMMUserMFA -AccountId 123 -UserId "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        # Check MFA status for all users
        $users = Get-NMMUsers -AccountId 123
        $users.items | ForEach-Object { Get-NMMUserMFA -AccountId 123 -UserId $_.id }
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
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/users/mfaStatus/$UserId"
    }
}
