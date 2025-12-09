Describe "Get-NMMCommand" {
    BeforeAll {
        Import-Module "$PSScriptRoot/../NMM-PS.psm1" -Force
    }

    Context "Parameter Validation" {
        It "Should accept valid Category values" {
            { Get-NMMCommand -Category HostPool -AsObject } | Should -Not -Throw
            { Get-NMMCommand -Category Device -AsObject } | Should -Not -Throw
            { Get-NMMCommand -Category Account -AsObject } | Should -Not -Throw
        }

        It "Should reject invalid Category values" {
            { Get-NMMCommand -Category InvalidCategory } | Should -Throw
        }

        It "Should accept valid Verb values" {
            { Get-NMMCommand -Verb Get -AsObject } | Should -Not -Throw
            { Get-NMMCommand -Verb Set -AsObject } | Should -Not -Throw
        }

        It "Should reject invalid Verb values" {
            { Get-NMMCommand -Verb InvalidVerb } | Should -Throw
        }
    }

    Context "Output - AsObject Mode" {
        It "Should return objects when -AsObject is specified" {
            $result = Get-NMMCommand -AsObject
            $result | Should -BeOfType [PSCustomObject]
        }

        It "Should return objects with Name, Category, and Description properties" {
            $result = @(Get-NMMCommand -AsObject)
            $result[0].PSObject.Properties.Name | Should -Contain 'Name'
            $result[0].PSObject.Properties.Name | Should -Contain 'Category'
            $result[0].PSObject.Properties.Name | Should -Contain 'Description'
        }

        It "Should return multiple cmdlets" {
            $result = @(Get-NMMCommand -AsObject)
            $result.Count | Should -BeGreaterThan 30
        }
    }

    Context "Filtering" {
        It "Should filter by Category" {
            $result = @(Get-NMMCommand -Category Device -AsObject)
            $result | ForEach-Object { $_.Category | Should -Be 'Device' }
            $result.Count | Should -BeGreaterThan 0
        }

        It "Should filter by Verb" {
            $result = @(Get-NMMCommand -Verb Get -AsObject)
            $result | ForEach-Object { $_.Name | Should -BeLike 'Get-*' }
        }

        It "Should combine Category and Verb filters" {
            $result = @(Get-NMMCommand -Category HostPool -Verb Get -AsObject)
            $result | ForEach-Object {
                $_.Category | Should -Be 'HostPool'
                $_.Name | Should -BeLike 'Get-*'
            }
        }
    }

    Context "Formatted Output" {
        It "Should not throw when displaying formatted output" {
            { Get-NMMCommand } | Should -Not -Throw
        }

        It "Should not throw when filtering by Category" {
            { Get-NMMCommand -Category Backup } | Should -Not -Throw
        }
    }
}
