BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            manufacturer = "Dell"
            model        = "Latitude 5520"
            serialNumber = "ABC123"
            totalMemory  = 16384
            processorType = "Intel Core i7"
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMDeviceHardware" {
    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMDeviceHardware -AccountId 123 -DeviceId "device-guid"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/devices/device-guid/hardware" -and
                $Method -eq "GET" -and
                $ApiVersion -eq "v1-beta"
            }
        }
    }

    Context "Output" {
        It "Should return hardware info" {
            $result = Get-NMMDeviceHardware -AccountId 123 -DeviceId "device-guid"
            $result.manufacturer | Should -Be "Dell"
            $result.model | Should -Be "Latitude 5520"
        }
    }
}
