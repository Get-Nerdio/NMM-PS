BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ id = 1; name = "Business Hours"; minHosts = 2; maxHosts = 10 }
            @{ id = 2; name = "After Hours"; minHosts = 1; maxHosts = 3 }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMAutoscaleProfile" {
    Context "API Call - Account Scope" {
        It "Should construct account-level endpoint without ProfileId" {
            Get-NMMAutoscaleProfile -AccountId 123

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/autoscale-profiles" -and
                $Method -eq "GET"
            }
        }

        It "Should construct account-level endpoint with ProfileId" {
            Get-NMMAutoscaleProfile -AccountId 123 -ProfileId 456

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/autoscale-profiles/456" -and
                $Method -eq "GET"
            }
        }
    }

    Context "API Call - Global Scope" {
        It "Should construct global endpoint without ProfileId" {
            Get-NMMAutoscaleProfile -Scope Global

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "autoscale-profiles" -and
                $Method -eq "GET"
            }
        }

        It "Should construct global endpoint with ProfileId" {
            Get-NMMAutoscaleProfile -Scope Global -ProfileId 789

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "autoscale-profiles/789" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return autoscale profiles" {
            $result = Get-NMMAutoscaleProfile -AccountId 123
            $result.Count | Should -Be 2
            $result[0].name | Should -Be "Business Hours"
        }
    }
}
