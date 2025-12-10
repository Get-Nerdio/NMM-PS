function Get-NMMUsers {
    <#
    .SYNOPSIS
        Get Azure AD users for an account.
    .DESCRIPTION
        Retrieves a paginated list of Azure AD users from the NMM API.
        Note: This endpoint uses POST with a body for filtering/pagination.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER Top
        Number of users to return (default 100).
    .PARAMETER Skip
        Number of users to skip for pagination.
    .PARAMETER Search
        Search string to filter users.
    .EXAMPLE
        Get-NMMUsers -AccountId 123
    .EXAMPLE
        Get-NMMUsers -AccountId 123 -Top 50 -Search "john"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [int]$AccountId,

        [Parameter()]
        [int]$Top = 100,

        [Parameter()]
        [int]$Skip = 0,

        [Parameter()]
        [string]$Search
    )

    process {
        $body = @{
            pageSize           = $Top
            pageNum            = [int][math]::Floor($Skip / $Top)
            searchTerm         = $Search
            activityTypes      = @()  # Required but can be empty
            identityTypes      = @()  # Required but can be empty
            assignments        = @()  # Required but can be empty
            entraIdRoleOptions = @()  # Required but can be empty
            mfaRegisteredStates = @() # Required but can be empty
            riskStates         = @()  # Required but can be empty
        }

        $response = Invoke-APIRequest -Method 'POST' -Endpoint "accounts/$AccountId/users" -Body $body

        # API returns { users: [...], totalUsers, ... stats ... }, extract the users array
        $result = if ($response.users) {
            $response.users
        }
        else {
            $response
        }

        # Add PSTypeName for report template matching
        foreach ($user in @($result)) {
            $user.PSObject.TypeNames.Insert(0, 'NMM.User')
        }
        $result
    }
}
