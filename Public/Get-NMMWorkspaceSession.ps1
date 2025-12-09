function Get-NMMWorkspaceSession {
    <#
    .SYNOPSIS
        Get active user sessions in a workspace.
    .DESCRIPTION
        Retrieves all active user sessions for a specific AVD workspace,
        including session state, user information, and connection details.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER SubscriptionId
        The Azure subscription ID.
    .PARAMETER ResourceGroup
        The Azure resource group name.
    .PARAMETER WorkspaceName
        The AVD workspace name.
    .EXAMPLE
        Get-NMMWorkspaceSession -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -WorkspaceName "ws-prod"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$AccountId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('subscription')]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ResourceGroup,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('name')]
        [string]$WorkspaceName
    )

    process {
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/workspace/$SubscriptionId/$ResourceGroup/$WorkspaceName/sessions"
    }
}
