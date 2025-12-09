BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            name         = "img-win11"
            vmSize       = "Standard_D4s_v3"
            imageVersion = "1.0.0"
            status       = "Ready"
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMDesktopImageDetail" {
    Context "Parameter Validation" {
        It "Should have 'name' alias for ImageName" {
            (Get-Command Get-NMMDesktopImageDetail).Parameters['ImageName'].Aliases |
                Should -Contain 'name'
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMDesktopImageDetail -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-images" -ImageName "img-win11"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/desktop-image/sub-123/rg-images/img-win11" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return image details" {
            $result = Get-NMMDesktopImageDetail -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -ImageName "img"
            $result.name | Should -Be "img-win11"
            $result.status | Should -Be "Ready"
        }
    }
}
