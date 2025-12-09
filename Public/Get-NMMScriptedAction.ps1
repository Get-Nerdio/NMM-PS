function Get-NMMScriptedAction {
    <#
    .SYNOPSIS
        Get scripted actions.
    .DESCRIPTION
        Retrieves scripted actions from NMM. Use -Scope to choose between
        account-level scripted actions or global (MSP-level) scripted actions.
    .PARAMETER AccountId
        The NMM account ID. Required when Scope is 'Account'.
    .PARAMETER Scope
        The scope of scripted actions to retrieve.
        - Account: Account-specific scripted actions (default)
        - Global: MSP-level scripted actions shared across accounts
    .PARAMETER ScriptedActionId
        Optional. The ID of a specific scripted action to retrieve.
    .EXAMPLE
        Get-NMMScriptedAction -AccountId 123
    .EXAMPLE
        Get-NMMScriptedAction -AccountId 123 -ScriptedActionId 456
    .EXAMPLE
        Get-NMMScriptedAction -Scope Global
    .EXAMPLE
        Get-NMMScriptedAction -Scope Global -ScriptedActionId 789
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
        [int]$ScriptedActionId
    )

    process {
        if ($Scope -eq 'Global') {
            if ($ScriptedActionId) {
                Invoke-APIRequest -Method 'GET' -Endpoint "scripted-actions/$ScriptedActionId"
            }
            else {
                Invoke-APIRequest -Method 'GET' -Endpoint "scripted-actions"
            }
        }
        else {
            if (-not $AccountId) {
                throw "AccountId is required when Scope is 'Account'"
            }
            if ($ScriptedActionId) {
                Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/scripted-actions/$ScriptedActionId"
            }
            else {
                Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/scripted-actions"
            }
        }
    }
}
