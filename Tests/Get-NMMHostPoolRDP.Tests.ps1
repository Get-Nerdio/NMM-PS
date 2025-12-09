BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            audioPlaybackMode  = "Enabled"
            printerRedirection = $true
            clipboardRedirection = $true
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostPoolRDP" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostPoolRDP -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/rdp-settings" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return RDP settings" {
            $result = Get-NMMHostPoolRDP -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.audioPlaybackMode | Should -Be "Enabled"
            $result.printerRedirection | Should -Be $true
        }
    }
}
