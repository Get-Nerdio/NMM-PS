BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            Environment = "Production"
            CostCenter  = "IT-123"
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostPoolTag" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostPoolTag -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/tags" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return Azure tags" {
            $result = Get-NMMHostPoolTag -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.Environment | Should -Be "Production"
        }
    }
}
