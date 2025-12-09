function Get-NMMAutoscaleProfile {
    <#
    .SYNOPSIS
        Get autoscale profiles.
    .DESCRIPTION
        Retrieves autoscale profiles from NMM. Use -Scope to choose between
        account-level profiles or global (MSP-level) profiles.
    .PARAMETER AccountId
        The NMM account ID. Required when Scope is 'Account'.
    .PARAMETER Scope
        The scope of autoscale profiles to retrieve.
        - Account: Account-specific profiles (default)
        - Global: MSP-level profiles shared across accounts
    .PARAMETER ProfileId
        Optional. The ID of a specific autoscale profile to retrieve.
    .EXAMPLE
        Get-NMMAutoscaleProfile -AccountId 123
    .EXAMPLE
        Get-NMMAutoscaleProfile -AccountId 123 -ProfileId 456
    .EXAMPLE
        Get-NMMAutoscaleProfile -Scope Global
    .EXAMPLE
        Get-NMMAutoscaleProfile -Scope Global -ProfileId 789
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [int]$AccountId,

        [Parameter()]
        [ValidateSet('Account', 'Global')]
        [string]$Scope = 'Account',

        [Parameter()]
        [int]$ProfileId
    )

    process {
        if ($Scope -eq 'Global') {
            if ($ProfileId) {
                Invoke-APIRequest -Method 'GET' -Endpoint "autoscale-profiles/$ProfileId"
            }
            else {
                Invoke-APIRequest -Method 'GET' -Endpoint "autoscale-profiles"
            }
        }
        else {
            if (-not $AccountId) {
                throw "AccountId is required when Scope is 'Account'"
            }
            if ($ProfileId) {
                Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/autoscale-profiles/$ProfileId"
            }
            else {
                Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/autoscale-profiles"
            }
        }
    }
}
