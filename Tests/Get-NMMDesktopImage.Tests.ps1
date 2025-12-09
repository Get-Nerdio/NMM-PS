BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ name = "img-win11"; subscription = "sub-1"; resourceGroup = "rg-images" }
            @{ name = "img-win10"; subscription = "sub-1"; resourceGroup = "rg-images" }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMDesktopImage" {
    Context "Parameter Validation" {
        It "Should have 'id' alias for AccountId" {
            (Get-Command Get-NMMDesktopImage).Parameters['AccountId'].Aliases |
                Should -Contain 'id'
        }

        It "Should support pipeline input for AccountId" {
            (Get-Command Get-NMMDesktopImage).Parameters['AccountId'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                ForEach-Object { $_.ValueFromPipelineByPropertyName | Should -Be $true }
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMDesktopImage -AccountId 123

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/desktop-image" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return desktop images" {
            $result = Get-NMMDesktopImage -AccountId 123
            $result.Count | Should -Be 2
            $result[0].name | Should -Be "img-win11"
        }
    }
}
