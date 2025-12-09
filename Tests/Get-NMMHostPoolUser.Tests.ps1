BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ id = "user-1"; displayName = "John Doe"; userPrincipalName = "john@contoso.com" }
            @{ id = "user-2"; displayName = "Jane Smith"; userPrincipalName = "jane@contoso.com" }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostPoolUser" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostPoolUser -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/assigned-users" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return assigned users" {
            $result = Get-NMMHostPoolUser -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.Count | Should -Be 2
            $result[0].displayName | Should -Be "John Doe"
        }
    }
}
