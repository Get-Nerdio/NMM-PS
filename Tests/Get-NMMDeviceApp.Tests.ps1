BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ appName = "Microsoft Office"; version = "16.0"; installState = "Installed" }
            @{ appName = "Adobe Reader"; version = "23.0"; installState = "Installed" }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMDeviceApp" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMDeviceApp -AccountId 123 -DeviceId "device-guid"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/devices/device-guid/apps" -and
                $Method -eq "GET" -and
                $ApiVersion -eq "v1-beta"
            }
        }
    }

    Context "Output" {
        It "Should return installed apps" {
            $result = Get-NMMDeviceApp -AccountId 123 -DeviceId "device-guid"
            $result.Count | Should -Be 2
            $result[0].appName | Should -Be "Microsoft Office"
        }
    }
}
