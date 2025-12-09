BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ timestamp = "2024-01-15T10:00:00Z"; action = "Created"; user = "admin@contoso.com" }
            @{ timestamp = "2024-01-16T14:30:00Z"; action = "Updated"; user = "admin@contoso.com" }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMDesktopImageLog" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMDesktopImageLog -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-images" -ImageName "img-win11"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/desktop-image/sub-123/rg-images/img-win11/change-log" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return change log entries" {
            $result = Get-NMMDesktopImageLog -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -ImageName "img"
            $result.Count | Should -Be 2
            $result[0].action | Should -Be "Created"
        }
    }
}
