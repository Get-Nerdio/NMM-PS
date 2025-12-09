function Get-NMMHostSchedule {
    <#
    .SYNOPSIS
        Get scheduled jobs for a specific session host.
    .DESCRIPTION
        Retrieves the schedule configurations (scheduled tasks/jobs) associated
        with a specific session host VM.
    .PARAMETER AccountId
        The NMM account ID.
    .PARAMETER HostName
        The session host name (e.g., "vm-avd-0.domain.local").
    .EXAMPLE
        Get-NMMHostSchedule -AccountId 123 -HostName "vm-avd-0.contoso.local"
    .EXAMPLE
        # Pipeline from Get-NMMHost
        Get-NMMHost -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool" |
            ForEach-Object { Get-NMMHostSchedule -AccountId 123 -HostName $_.name }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$AccountId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('name')]
        [string]$HostName
    )

    process {
        Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/hosts/$HostName/schedule-configurations"
    }
}
