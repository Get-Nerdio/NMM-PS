function Get-NMMDesktopImageSchedule {
    <#
    .SYNOPSIS
        Get scheduled jobs for a desktop image.
    .DESCRIPTION
        Retrieves the schedule configurations (scheduled tasks/jobs) associated
        with a specific desktop image, such as automated updates or maintenance.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER SubscriptionId
        The Azure subscription ID where the image is located.
    .PARAMETER ResourceGroup
        The Azure resource group name.
    .PARAMETER ImageName
        The desktop image name.
    .EXAMPLE
        Get-NMMDesktopImageSchedule -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-images" -ImageName "img-win11"
    .EXAMPLE
        # Pipeline from Get-NMMDesktopImage
        Get-NMMDesktopImage -AccountId 123 | ForEach-Object {
            Get-NMMDesktopImageSchedule -AccountId 123 -SubscriptionId $_.subscription -ResourceGroup $_.resourceGroup -ImageName $_.name
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
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/desktop-image/$SubscriptionId/$ResourceGroup/$ImageName/schedule-configurations"
    }
}
