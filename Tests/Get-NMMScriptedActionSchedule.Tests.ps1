BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            id        = 1
            enabled   = $true
            frequency = "Daily"
            time      = "02:00"
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMScriptedActionSchedule" {
    Context "API Call - Account Scope" {
        It "Should construct account-level endpoint" {
            Get-NMMScriptedActionSchedule -AccountId 123 -ScriptedActionId 456

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/scripted-actions/456/schedule" -and
                $Method -eq "GET"
            }
        }
    }

    Context "API Call - Global Scope" {
        It "Should construct global endpoint" {
            Get-NMMScriptedActionSchedule -Scope Global -ScriptedActionId 789

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "scripted-actions/789/schedule" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return schedule configuration" {
            $result = Get-NMMScriptedActionSchedule -AccountId 123 -ScriptedActionId 456
            $result.enabled | Should -Be $true
            $result.frequency | Should -Be "Daily"
        }
    }
}
