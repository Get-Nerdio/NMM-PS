BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            enabled        = $true
            minActiveHosts = 1
            maxActiveHosts = 10
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostPoolAutoscale" {
    Context "Parameter Validation" {
        It "Should have AccountId as mandatory parameter" {
            (Get-Command Get-NMMHostPoolAutoscale).Parameters['AccountId'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                ForEach-Object { $_.Mandatory | Should -Be $true }
        }

        It "Should have 'subscription' alias for SubscriptionId" {
            (Get-Command Get-NMMHostPoolAutoscale).Parameters['SubscriptionId'].Aliases |
                Should -Contain 'subscription'
        }

        It "Should have 'hostPoolName' alias for PoolName" {
            (Get-Command Get-NMMHostPoolAutoscale).Parameters['PoolName'].Aliases |
                Should -Contain 'hostPoolName'
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostPoolAutoscale -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/autoscale-settings" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return autoscale settings" {
            $result = Get-NMMHostPoolAutoscale -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.enabled | Should -Be $true
            $result.minActiveHosts | Should -Be 1
        }
    }
}
