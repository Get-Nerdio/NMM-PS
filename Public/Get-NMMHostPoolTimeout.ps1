function Get-NMMHostPoolTimeout {
    <#
    .SYNOPSIS
        Get session timeout settings for a host pool.
    .DESCRIPTION
        Retrieves the session timeout configuration for a specific host pool,
        including idle timeout, disconnect timeout, and logoff behavior.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER SubscriptionId
        The Azure subscription ID.
    .PARAMETER ResourceGroup
        The Azure resource group name.
    .PARAMETER PoolName
        The host pool name.
    .EXAMPLE
        Get-NMMHostPoolTimeout -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
    .EXAMPLE
        # Pipeline from Get-NMMHostPool
        Get-NMMHostPool -AccountId 123 | ForEach-Object {
            Get-NMMHostPoolTimeout -AccountId 123 -SubscriptionId $_.subscription -ResourceGroup $_.resourceGroup -PoolName $_.hostPoolName
        }
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
        [Alias('hostPoolName')]
        [string]$PoolName
    )

    process {
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/host-pool/$SubscriptionId/$ResourceGroup/$PoolName/session-timeouts"
    }
}
