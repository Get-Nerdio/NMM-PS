BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            deviceId    = "device-guid"
            bitLockerKeys = @(
                @{ driveType = "OperatingSystem"; recoveryKey = "******-******-******-******" }
            )
        }
    } -ModuleName NMM-PS

    Mock Write-Warning {} -ModuleName NMM-PS
}

Describe "Get-NMMDeviceBitLocker" {
    Context "Parameter Validation" {
        It "Should support ShouldProcess" {
            (Get-Command Get-NMMDeviceBitLocker).Parameters.Keys | Should -Contain 'WhatIf'
            (Get-Command Get-NMMDeviceBitLocker).Parameters.Keys | Should -Contain 'Confirm'
        }

        It "Should have High ConfirmImpact" {
            $cmdletBinding = (Get-Command Get-NMMDeviceBitLocker).ScriptBlock.Attributes |
                Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletBinding.ConfirmImpact | Should -Be 'High'
        }
    }

    Context "Security Warning" {
        It "Should display warning about sensitive data" {
            Get-NMMDeviceBitLocker -AccountId 123 -DeviceId "device-1" -Confirm:$false

            Should -Invoke Write-Warning -ModuleName NMM-PS -Times 1
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL when confirmed" {
            Get-NMMDeviceBitLocker -AccountId 123 -DeviceId "device-guid" -Confirm:$false

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/devices/device-guid/bitlocker-keys" -and
                $Method -eq "GET" -and
                $ApiVersion -eq "v1-beta"
            }
        }

        It "Should not call API with -WhatIf" {
            Get-NMMDeviceBitLocker -AccountId 123 -DeviceId "device-guid" -WhatIf

            Should -Not -Invoke Invoke-APIRequest -ModuleName NMM-PS
        }
    }

    Context "Output" {
        It "Should return BitLocker keys when confirmed" {
            $result = Get-NMMDeviceBitLocker -AccountId 123 -DeviceId "device-guid" -Confirm:$false
            $result.bitLockerKeys | Should -Not -BeNullOrEmpty
        }
    }
}
