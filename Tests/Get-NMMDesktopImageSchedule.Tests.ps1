BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ id = 1; name = "Monthly Update"; enabled = $true }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMDesktopImageSchedule" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMDesktopImageSchedule -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-images" -ImageName "img-win11"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/desktop-image/sub-123/rg-images/img-win11/schedule-configurations" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return image schedules" {
            $result = @(Get-NMMDesktopImageSchedule -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -ImageName "img")
            $result[0].name | Should -Be "Monthly Update"
        }
    }
}
