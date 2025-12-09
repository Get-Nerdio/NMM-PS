BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ id = 1; name = "Daily Maintenance"; enabled = $true }
            @{ id = 2; name = "Weekly Backup"; enabled = $true }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMSchedule" {
    Context "API Call - Account Scope" {
        It "Should construct account-level endpoint without ScheduleId" {
            Get-NMMSchedule -AccountId 123

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/schedules" -and
                $Method -eq "GET"
            }
        }

        It "Should construct account-level endpoint with ScheduleId" {
            Get-NMMSchedule -AccountId 123 -ScheduleId 456

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/schedules/456" -and
                $Method -eq "GET"
            }
        }
    }

    Context "API Call - Global Scope" {
        It "Should construct global endpoint without ScheduleId" {
            Get-NMMSchedule -Scope Global

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "schedules" -and
                $Method -eq "GET"
            }
        }

        It "Should construct global endpoint with ScheduleId" {
            Get-NMMSchedule -Scope Global -ScheduleId 789

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "schedules/789" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return schedules" {
            $result = Get-NMMSchedule -AccountId 123
            $result.Count | Should -Be 2
            $result[0].name | Should -Be "Daily Maintenance"
        }
    }
}
