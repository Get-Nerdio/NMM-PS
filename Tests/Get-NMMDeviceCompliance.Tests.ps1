BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            deviceId        = "device-guid"
            complianceState = "Compliant"
            lastCheckTime   = "2024-01-15T10:00:00Z"
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMDeviceCompliance" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMDeviceCompliance -AccountId 123 -DeviceId "device-guid"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/devices/device-guid/compliance" -and
                $Method -eq "GET" -and
                $ApiVersion -eq "v1-beta"
            }
        }
    }

    Context "Output" {
        It "Should return compliance status" {
            $result = Get-NMMDeviceCompliance -AccountId 123 -DeviceId "device-guid"
            $result.complianceState | Should -Be "Compliant"
        }
    }
}
