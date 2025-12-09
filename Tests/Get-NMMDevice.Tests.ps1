BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ id = "device-1"; deviceName = "LAPTOP-001"; complianceState = "Compliant" }
            @{ id = "device-2"; deviceName = "DESKTOP-002"; complianceState = "NonCompliant" }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMDevice" {
    Context "Parameter Validation" {
        It "Should have 'id' alias for AccountId" {
            (Get-Command Get-NMMDevice).Parameters['AccountId'].Aliases |
                Should -Contain 'id'
        }
    }

    Context "API Call" {
        It "Should construct endpoint for listing all devices" {
            Get-NMMDevice -AccountId 123

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/devices" -and
                $Method -eq "GET" -and
                $ApiVersion -eq "v1-beta"
            }
        }

        It "Should construct endpoint for single device" {
            Get-NMMDevice -AccountId 123 -DeviceId "device-guid"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/devices/device-guid" -and
                $Method -eq "GET" -and
                $ApiVersion -eq "v1-beta"
            }
        }

        It "Should use v1-beta API version" {
            Get-NMMDevice -AccountId 123

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $ApiVersion -eq "v1-beta"
            }
        }
    }

    Context "Output" {
        It "Should return devices" {
            $result = Get-NMMDevice -AccountId 123
            $result.Count | Should -Be 2
            $result[0].deviceName | Should -Be "LAPTOP-001"
        }
    }
}
