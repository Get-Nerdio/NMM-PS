BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ appName = "Legacy App"; errorCode = "0x80070005"; errorMessage = "Access denied" }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMDeviceAppFailure" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMDeviceAppFailure -AccountId 123 -DeviceId "device-guid"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/devices/device-guid/apps/failures" -and
                $Method -eq "GET" -and
                $ApiVersion -eq "v1-beta"
            }
        }
    }

    Context "Output" {
        It "Should return app failures" {
            $result = @(Get-NMMDeviceAppFailure -AccountId 123 -DeviceId "device-guid")
            $result[0].appName | Should -Be "Legacy App"
            $result[0].errorCode | Should -Be "0x80070005"
        }
    }
}
