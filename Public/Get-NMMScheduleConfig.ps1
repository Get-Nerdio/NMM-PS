function Get-NMMScheduleConfig {
    <#
    .SYNOPSIS
        Get configuration for a specific schedule.
    .DESCRIPTION
        Retrieves the detailed configuration for a specific schedule,
        including trigger settings and associated actions.
    .PARAMETER AccountId
        The NMM account ID. Required when Scope is 'Account'.
    .PARAMETER ScheduleId
        The ID of the schedule.
    .PARAMETER Scope
        The scope of the schedule.
        - Account: Account-specific schedule (default)
        - Global: MSP-level schedule
    .EXAMPLE
        Get-NMMScheduleConfig -AccountId 123 -ScheduleId 456
    .EXAMPLE
        Get-NMMScheduleConfig -Scope Global -ScheduleId 789
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$AccountId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [int]$ScheduleId,

        [Parameter()]
        [ValidateSet('Account', 'Global')]
        [string]$Scope = 'Account'
    )

    process {
        if ($Scope -eq 'Global') {
            Invoke-APIRequest -Method 'GET' -Endpoint "schedules/$ScheduleId/configurations"
        }
        else {
            if (-not $AccountId) {
                throw "AccountId is required when Scope is 'Account'"
            }
            Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/schedules/$ScheduleId/configurations"
        }
    }
}
