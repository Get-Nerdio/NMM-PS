function Get-NMMScriptedActionSchedule {
    <#
    .SYNOPSIS
        Get schedule for a scripted action.
    .DESCRIPTION
        Retrieves the schedule configuration for a specific scripted action.
        Use -Scope to access account-level or global scripted action schedules.
    .PARAMETER AccountId
        The NMM account ID. Required when Scope is 'Account'.
    .PARAMETER ScriptedActionId
        The ID of the scripted action.
    .PARAMETER Scope
        The scope of the scripted action.
        - Account: Account-specific scripted action (default)
        - Global: MSP-level scripted action
    .EXAMPLE
        Get-NMMScriptedActionSchedule -AccountId 123 -ScriptedActionId 456
    .EXAMPLE
        Get-NMMScriptedActionSchedule -Scope Global -ScriptedActionId 789
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$AccountId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [int]$ScriptedActionId,

        [Parameter()]
        [ValidateSet('Account', 'Global')]
        [string]$Scope = 'Account'
    )

    process {
        if ($Scope -eq 'Global') {
            Invoke-APIRequest -Method 'GET' -Endpoint "scripted-actions/$ScriptedActionId/schedule"
        }
        else {
            if (-not $AccountId) {
                throw "AccountId is required when Scope is 'Account'"
            }
            Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/scripted-actions/$ScriptedActionId/schedule"
        }
    }
}
