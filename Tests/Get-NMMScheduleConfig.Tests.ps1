BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            id          = 1
            triggerType = "Scheduled"
            cronExpression = "0 2 * * *"
            actions     = @("RestartHosts", "UpdateImage")
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMScheduleConfig" {
    Context "API Call - Account Scope" {
        It "Should construct account-level endpoint" {
            Get-NMMScheduleConfig -AccountId 123 -ScheduleId 456

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/schedules/456/configurations" -and
                $Method -eq "GET"
            }
        }
    }

    Context "API Call - Global Scope" {
        It "Should construct global endpoint" {
            Get-NMMScheduleConfig -Scope Global -ScheduleId 789

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "schedules/789/configurations" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return schedule configuration" {
            $result = Get-NMMScheduleConfig -AccountId 123 -ScheduleId 456
            $result.triggerType | Should -Be "Scheduled"
            $result.actions | Should -Contain "RestartHosts"
        }
    }
}
