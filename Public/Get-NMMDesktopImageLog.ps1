function Get-NMMDesktopImageLog {
    <#
    .SYNOPSIS
        Get change log for a desktop image.
    .DESCRIPTION
        Retrieves the change history/log for a specific desktop image,
        including version changes, updates, and modifications.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER SubscriptionId
        The Azure subscription ID where the image is located.
    .PARAMETER ResourceGroup
        The Azure resource group name.
    .PARAMETER ImageName
        The desktop image name.
    .EXAMPLE
        Get-NMMDesktopImageLog -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-images" -ImageName "img-win11"
    .EXAMPLE
        # Pipeline from Get-NMMDesktopImage
        Get-NMMDesktopImage -AccountId 123 | ForEach-Object {
            Get-NMMDesktopImageLog -AccountId 123 -SubscriptionId $_.subscription -ResourceGroup $_.resourceGroup -ImageName $_.name
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
        [Alias('name')]
        [string]$ImageName
    )

    process {
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/desktop-image/$SubscriptionId/$ResourceGroup/$ImageName/change-log"
    }
}
