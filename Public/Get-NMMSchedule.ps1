function Get-NMMSchedule {
    <#
    .SYNOPSIS
        Get schedules.
    .DESCRIPTION
        Retrieves schedules from NMM. Use -Scope to choose between
        account-level schedules or global (MSP-level) schedules.
    .PARAMETER AccountId
        The NMM account ID. Required when Scope is 'Account'.
    .PARAMETER Scope
        The scope of schedules to retrieve.
        - Account: Account-specific schedules (default)
        - Global: MSP-level schedules shared across accounts
    .PARAMETER ScheduleId
        Optional. The ID of a specific schedule to retrieve.
    .EXAMPLE
        Get-NMMSchedule -AccountId 123
    .EXAMPLE
        Get-NMMSchedule -AccountId 123 -ScheduleId 456
    .EXAMPLE
        Get-NMMSchedule -Scope Global
    .EXAMPLE
        Get-NMMSchedule -Scope Global -ScheduleId 789
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [int]$AccountId,

        [Parameter()]
        [ValidateSet('Account', 'Global')]
        [string]$Scope = 'Account',

        [Parameter()]
        [int]$ScheduleId
    )

    process {
        if ($Scope -eq 'Global') {
            if ($ScheduleId) {
                Invoke-APIRequest -Method 'GET' -Endpoint "schedules/$ScheduleId"
            }
            else {
                Invoke-APIRequest -Method 'GET' -Endpoint "schedules"
            }
        }
        else {
            if (-not $AccountId) {
                throw "AccountId is required when Scope is 'Account'"
            }
            if ($ScheduleId) {
                Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/schedules/$ScheduleId"
            }
            else {
                Invoke-APIRequest -Method 'GET' -Endpoint "accounts/$AccountId/schedules"
            }
        }
    }
}
