BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            id          = "group-guid-123"
            displayName = "AVD Users"
            memberCount = 25
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMGroup" {
    Context "Parameter Validation" {
        It "Should have 'id' alias for GroupId" {
            (Get-Command Get-NMMGroup).Parameters['GroupId'].Aliases |
                Should -Contain 'id'
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMGroup -AccountId 123 -GroupId "group-guid-123"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/groups/group-guid-123" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return group details" {
            $result = Get-NMMGroup -AccountId 123 -GroupId "group-guid-123"
            $result.displayName | Should -Be "AVD Users"
            $result.memberCount | Should -Be 25
        }
    }
}
