BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            enabled     = $true
            profileType = "Container"
            vhdLocation = "\\storage\profiles"
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostPoolFSLogix" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostPoolFSLogix -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/fslogix" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return FSLogix configuration" {
            $result = Get-NMMHostPoolFSLogix -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.enabled | Should -Be $true
            $result.profileType | Should -Be "Container"
        }
    }
}
