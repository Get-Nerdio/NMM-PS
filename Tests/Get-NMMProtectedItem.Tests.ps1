BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ id = "item-1"; name = "vm-avd-0"; protectionStatus = "Protected" }
            @{ id = "item-2"; name = "fileshare-profiles"; protectionStatus = "Protected" }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMProtectedItem" {
    Context "Parameter Validation" {
        It "Should have 'id' alias for AccountId" {
            (Get-Command Get-NMMProtectedItem).Parameters['AccountId'].Aliases |
                Should -Contain 'id'
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMProtectedItem -AccountId 123

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/backup/protectedItems" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return protected items" {
            $result = Get-NMMProtectedItem -AccountId 123
            $result.Count | Should -Be 2
            $result[0].protectionStatus | Should -Be "Protected"
        }
    }
}
