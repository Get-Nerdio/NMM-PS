BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ id = 1; name = "Daily Restart"; enabled = $true }
            @{ id = 2; name = "Weekly Update"; enabled = $false }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostPoolSchedule" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostPoolSchedule -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/schedule-configurations" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return schedule configurations" {
            $result = Get-NMMHostPoolSchedule -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.Count | Should -Be 2
            $result[0].name | Should -Be "Daily Restart"
        }
    }
}
