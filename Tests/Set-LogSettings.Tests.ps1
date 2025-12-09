Describe "Set-LogSettings Tests" {
    BeforeAll {
        # Import module
        Import-Module "$PSScriptRoot/../NMM-PS.psm1" -Force
    }

    BeforeEach {
        # Reset call counter before each test
        $script:readHostCallCount = 0
    }

    It "Should check if the log settings file exists" {
        Mock Get-LogSettings { return @{ LogSettingsJsonPath = "path/to/logSettings.json" } } -ModuleName NMM-PS
        Mock Test-Path { $true } -ModuleName NMM-PS
        Mock Get-Content { '{"LogPathWindows": "C:\\Logs", "LogPathMacOS": "/var/logs", "EnableLogging": false}' } -ModuleName NMM-PS
        Mock Write-Output {} -ModuleName NMM-PS
        Mock Read-Host { "No" } -ModuleName NMM-PS

        Set-LogSettings -Confirm:$false
        Should -Invoke Test-Path -Exactly 1 -Scope It -ModuleName NMM-PS
    }

    It "Should create a new file if it does not exist" {
        Mock Get-LogSettings { return @{ LogSettingsJsonPath = "path/to/logSettings.json" } } -ModuleName NMM-PS
        Mock Test-Path { $false } -ModuleName NMM-PS
        Mock New-Item {} -ModuleName NMM-PS
        Mock Set-Content {} -ModuleName NMM-PS
        Mock Write-Output {} -ModuleName NMM-PS

        Set-LogSettings -Confirm:$false
        Should -Invoke New-Item -Exactly 1 -Scope It -ModuleName NMM-PS
    }

    It "Should not change settings if user opts out" {
        Mock Get-LogSettings { return @{ LogSettingsJsonPath = "path/to/logSettings.json" } } -ModuleName NMM-PS
        Mock Test-Path { $true } -ModuleName NMM-PS
        Mock Get-Content { '{"LogPathWindows": "C:\\Logs", "LogPathMacOS": "/var/logs", "EnableLogging": false}' } -ModuleName NMM-PS
        Mock Set-Content {} -ModuleName NMM-PS
        Mock Write-Output {} -ModuleName NMM-PS
        Mock Read-Host { "No" } -ModuleName NMM-PS

        Set-LogSettings -Confirm:$false
        Should -Invoke Set-Content -Exactly 0 -Scope It -ModuleName NMM-PS
    }

    It "Should update settings when user opts to edit them" {
        Mock Get-LogSettings { return @{ LogSettingsJsonPath = "path/to/logSettings.json" } } -ModuleName NMM-PS
        Mock Test-Path { $true } -ModuleName NMM-PS
        Mock Get-Content { '{"LogPathWindows": "C:\\Logs", "LogPathMacOS": "/var/logs", "EnableLogging": false}' } -ModuleName NMM-PS
        Mock Set-Content {} -ModuleName NMM-PS
        Mock Write-Output {} -ModuleName NMM-PS

        $script:readHostCallCount = 0
        Mock Read-Host {
            $script:readHostCallCount++
            switch ($script:readHostCallCount) {
                1 { return "Yes" }
                2 { return "C:\New\Logs" }
                3 { return "/new/var/logs" }
                4 { return "True" }
            }
        } -ModuleName NMM-PS

        Set-LogSettings -Confirm:$false
        Should -Invoke Set-Content -Exactly 1 -Scope It -ModuleName NMM-PS
    }

    It "Should handle exceptions correctly when updating settings" {
        Mock Get-LogSettings { return @{ LogSettingsJsonPath = "path/to/logSettings.json" } } -ModuleName NMM-PS
        Mock Test-Path { $true } -ModuleName NMM-PS
        Mock Get-Content { '{"LogPathWindows": "C:\\Logs", "LogPathMacOS": "/var/logs", "EnableLogging": false}' } -ModuleName NMM-PS
        Mock Write-Output {} -ModuleName NMM-PS
        Mock Write-LogError {} -ModuleName NMM-PS

        $script:readHostCallCount = 0
        Mock Read-Host {
            $script:readHostCallCount++
            switch ($script:readHostCallCount) {
                1 { return "Yes" }
                2 { return "C:\New\Logs" }
                3 { return "/new/var/logs" }
                4 { return "True" }
            }
        } -ModuleName NMM-PS
        Mock Set-Content { throw "error" } -ModuleName NMM-PS

        Set-LogSettings -Confirm:$false
        Should -Invoke Write-LogError -Exactly 1 -Scope It -ModuleName NMM-PS
    }
}
