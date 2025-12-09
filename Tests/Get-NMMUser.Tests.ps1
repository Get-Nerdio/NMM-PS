BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            id                = "user-guid-123"
            displayName       = "John Doe"
            userPrincipalName = "john@contoso.com"
            mail              = "john@contoso.com"
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMUser" {
    Context "Parameter Validation" {
        It "Should have 'id' alias for UserId" {
            (Get-Command Get-NMMUser).Parameters['UserId'].Aliases |
                Should -Contain 'id'
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMUser -AccountId 123 -UserId "user-guid-123"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/users/user-guid-123" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return user details" {
            $result = Get-NMMUser -AccountId 123 -UserId "user-guid-123"
            $result.displayName | Should -Be "John Doe"
            $result.userPrincipalName | Should -Be "john@contoso.com"
        }
    }
}
