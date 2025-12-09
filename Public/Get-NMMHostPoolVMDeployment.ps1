function Get-NMMHostPoolVMDeployment {
    <#
    .SYNOPSIS
        Get VM deployment settings for a host pool.
    .DESCRIPTION
        Retrieves the virtual machine deployment configuration for a specific host pool,
        including VM size, image reference, naming prefix, and network settings.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER SubscriptionId
        The Azure subscription ID.
    .PARAMETER ResourceGroup
        The Azure resource group name.
    .PARAMETER PoolName
        The host pool name.
    .EXAMPLE
        Get-NMMHostPoolVMDeployment -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
    .EXAMPLE
        # Pipeline from Get-NMMHostPool
        Get-NMMHostPool -AccountId 123 | ForEach-Object {
            Get-NMMHostPoolVMDeployment -AccountId 123 -SubscriptionId $_.subscription -ResourceGroup $_.resourceGroup -PoolName $_.hostPoolName
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
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/host-pool/$SubscriptionId/$ResourceGroup/$PoolName/vm-deployment"
    }
}
