function Get-NMMDesktopImageDetail {
    <#
    .SYNOPSIS
        Get detailed information for a specific desktop image.
    .DESCRIPTION
        Retrieves detailed configuration and status for a specific desktop image,
        including VM settings, image version, and deployment configuration.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER SubscriptionId
        The Azure subscription ID where the image is located.
    .PARAMETER ResourceGroup
        The Azure resource group name.
    .PARAMETER ImageName
        The desktop image name.
    .EXAMPLE
        Get-NMMDesktopImageDetail -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-images" -ImageName "img-win11"
    .EXAMPLE
        # Pipeline from Get-NMMDesktopImage
        Get-NMMDesktopImage -AccountId 123 | ForEach-Object {
            Get-NMMDesktopImageDetail -AccountId 123 -SubscriptionId $_.subscription -ResourceGroup $_.resourceGroup -ImageName $_.name
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
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/desktop-image/$SubscriptionId/$ResourceGroup/$ImageName"
    }
}
