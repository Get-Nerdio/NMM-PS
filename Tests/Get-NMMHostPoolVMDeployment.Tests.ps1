BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            vmSize       = "Standard_D4s_v3"
            namingPrefix = "avd"
            diskType     = "Premium_LRS"
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostPoolVMDeployment" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostPoolVMDeployment -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/vm-deployment" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return VM deployment settings" {
            $result = Get-NMMHostPoolVMDeployment -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.vmSize | Should -Be "Standard_D4s_v3"
        }
    }
}
