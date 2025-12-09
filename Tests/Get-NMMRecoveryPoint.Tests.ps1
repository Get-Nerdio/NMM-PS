BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ id = "rp-1"; timestamp = "2024-01-15T00:00:00Z"; type = "Full" }
            @{ id = "rp-2"; timestamp = "2024-01-16T00:00:00Z"; type = "Incremental" }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMRecoveryPoint" {
    Context "Parameter Validation" {
        It "Should have 'id' alias for AccountId" {
            (Get-Command Get-NMMRecoveryPoint).Parameters['AccountId'].Aliases |
                Should -Contain 'id'
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMRecoveryPoint -AccountId 123

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/backup/recoveryPoints" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return recovery points" {
            $result = Get-NMMRecoveryPoint -AccountId 123
            $result.Count | Should -Be 2
            $result[0].type | Should -Be "Full"
        }
    }
}
