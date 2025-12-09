BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            userId       = "user-guid-123"
            mfaRegistered = $true
            methods      = @("Authenticator App", "Phone")
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMUserMFA" {
    Context "Parameter Validation" {
        It "Should have 'id' alias for UserId" {
            (Get-Command Get-NMMUserMFA).Parameters['UserId'].Aliases |
                Should -Contain 'id'
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMUserMFA -AccountId 123 -UserId "user-guid-123"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/users/mfaStatus/user-guid-123" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return MFA status" {
            $result = Get-NMMUserMFA -AccountId 123 -UserId "user-guid-123"
            $result.mfaRegistered | Should -Be $true
            $result.methods | Should -Contain "Authenticator App"
        }
    }
}
