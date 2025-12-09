function Get-NMMHostPoolTag {
    <#
    .SYNOPSIS
        Get Azure tags for a host pool.
    .DESCRIPTION
        Retrieves the Azure resource tags configured for a specific host pool
        and its associated resources.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER SubscriptionId
        The Azure subscription ID.
    .PARAMETER ResourceGroup
        The Azure resource group name.
    .PARAMETER PoolName
        The host pool name.
    .EXAMPLE
        Get-NMMHostPoolTag -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
    .EXAMPLE
        # Pipeline from Get-NMMHostPool
        Get-NMMHostPool -AccountId 123 | ForEach-Object {
            Get-NMMHostPoolTag -AccountId 123 -SubscriptionId $_.subscription -ResourceGroup $_.resourceGroup -PoolName $_.hostPoolName
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
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/host-pool/$SubscriptionId/$ResourceGroup/$PoolName/tags"
    }
}
