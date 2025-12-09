BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            idleTimeout       = 60
            disconnectTimeout = 30
            logoffBehavior    = "Logoff"
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostPoolTimeout" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostPoolTimeout -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/session-timeouts" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return timeout settings" {
            $result = Get-NMMHostPoolTimeout -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.idleTimeout | Should -Be 60
        }
    }
}
