BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            domainName = "contoso.local"
            ouPath     = "OU=AVD,DC=contoso,DC=local"
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostPoolAD" {
    Context "Parameter Validation" {
        It "Should have all mandatory parameters" {
            $cmd = Get-Command Get-NMMHostPoolAD
            $cmd.Parameters['AccountId'].Attributes.Mandatory | Should -Contain $true
            $cmd.Parameters['SubscriptionId'].Attributes.Mandatory | Should -Contain $true
            $cmd.Parameters['ResourceGroup'].Attributes.Mandatory | Should -Contain $true
            $cmd.Parameters['PoolName'].Attributes.Mandatory | Should -Contain $true
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostPoolAD -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/active-directory" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return AD configuration" {
            $result = Get-NMMHostPoolAD -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.domainName | Should -Be "contoso.local"
        }
    }
}
