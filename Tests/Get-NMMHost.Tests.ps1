BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ name = "vm-avd-0.contoso.local"; status = "Available"; assignedUser = "john@contoso.com" }
            @{ name = "vm-avd-1.contoso.local"; status = "Available"; assignedUser = $null }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMHost" {
    Context "Parameter Validation" {
        It "Should have 'subscription' alias for SubscriptionId" {
            (Get-Command Get-NMMHost).Parameters['SubscriptionId'].Aliases |
                Should -Contain 'subscription'
        }

        It "Should have 'hostPoolName' alias for PoolName" {
            (Get-Command Get-NMMHost).Parameters['PoolName'].Aliases |
                Should -Contain 'hostPoolName'
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHost -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/hosts" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return session hosts" {
            $result = Get-NMMHost -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.Count | Should -Be 2
            $result[0].name | Should -Be "vm-avd-0.contoso.local"
        }
    }
}
