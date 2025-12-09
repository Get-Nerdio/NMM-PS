BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ id = 1; name = "Install Software"; type = "PowerShell" }
            @{ id = 2; name = "Cleanup Temp"; type = "PowerShell" }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMScriptedAction" {
    Context "Parameter Validation" {
        It "Should have 'id' alias for AccountId" {
            (Get-Command Get-NMMScriptedAction).Parameters['AccountId'].Aliases |
                Should -Contain 'id'
        }

        It "Should have Scope parameter with Account and Global options" {
            $scopeParam = (Get-Command Get-NMMScriptedAction).Parameters['Scope']
            $scopeParam.Attributes.ValidValues | Should -Contain 'Account'
            $scopeParam.Attributes.ValidValues | Should -Contain 'Global'
        }
    }

    Context "API Call - Account Scope" {
        It "Should construct account-level endpoint without ScriptedActionId" {
            Get-NMMScriptedAction -AccountId 123

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/scripted-actions" -and
                $Method -eq "GET"
            }
        }

        It "Should construct account-level endpoint with ScriptedActionId" {
            Get-NMMScriptedAction -AccountId 123 -ScriptedActionId 456

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/scripted-actions/456" -and
                $Method -eq "GET"
            }
        }
    }

    Context "API Call - Global Scope" {
        It "Should construct global endpoint without ScriptedActionId" {
            Get-NMMScriptedAction -Scope Global

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "scripted-actions" -and
                $Method -eq "GET"
            }
        }

        It "Should construct global endpoint with ScriptedActionId" {
            Get-NMMScriptedAction -Scope Global -ScriptedActionId 789

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "scripted-actions/789" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return scripted actions" {
            $result = Get-NMMScriptedAction -AccountId 123
            $result.Count | Should -Be 2
            $result[0].name | Should -Be "Install Software"
        }
    }
}
