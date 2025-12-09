BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ id = 1; name = "Restart Schedule"; enabled = $true }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostSchedule" {
    Context "Parameter Validation" {
        It "Should have 'name' alias for HostName" {
            (Get-Command Get-NMMHostSchedule).Parameters['HostName'].Aliases |
                Should -Contain 'name'
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostSchedule -AccountId 123 -HostName "vm-avd-0.contoso.local"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/hosts/vm-avd-0.contoso.local/schedule-configurations" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return host schedules" {
            $result = @(Get-NMMHostSchedule -AccountId 123 -HostName "vm-avd-0.contoso.local")
            $result[0].name | Should -Be "Restart Schedule"
        }
    }
}
