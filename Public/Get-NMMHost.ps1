function Get-NMMHost {
    <#
    .SYNOPSIS
        Get all session hosts in a host pool.
    .DESCRIPTION
        Retrieves all AVD session hosts for a specific host pool,
        including their status, assigned users, and health information.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER SubscriptionId
        The Azure subscription ID.
    .PARAMETER ResourceGroup
        The Azure resource group name.
    .PARAMETER PoolName
        The host pool name.
    .EXAMPLE
        Get-NMMHost -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
    .EXAMPLE
        # Pipeline from Get-NMMHostPool
        Get-NMMHostPool -AccountId 123 | ForEach-Object {
            Get-NMMHost -AccountId 123 -SubscriptionId $_.subscription -ResourceGroup $_.resourceGroup -PoolName $_.hostPoolName
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
        $result = Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/host-pool/$SubscriptionId/$ResourceGroup/$PoolName/hosts"

        # Add PSTypeName for report template matching
        foreach ($host in @($result)) {
            $host.PSObject.TypeNames.Insert(0, 'NMM.Host')
        }
        $result
    }
}
