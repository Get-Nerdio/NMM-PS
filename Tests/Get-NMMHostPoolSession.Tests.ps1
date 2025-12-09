BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ sessionId = "session-1"; userPrincipalName = "john@contoso.com"; sessionState = "Active" }
            @{ sessionId = "session-2"; userPrincipalName = "jane@contoso.com"; sessionState = "Disconnected" }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostPoolSession" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostPoolSession -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/sessions" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return user sessions" {
            $result = Get-NMMHostPoolSession -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.Count | Should -Be 2
            $result[0].sessionState | Should -Be "Active"
        }
    }
}
