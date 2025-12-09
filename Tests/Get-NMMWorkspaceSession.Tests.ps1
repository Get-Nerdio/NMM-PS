BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @(
            @{ sessionId = "session-1"; userPrincipalName = "john@contoso.com"; sessionState = "Active" }
        )
    } -ModuleName NMM-PS
}

Describe "Get-NMMWorkspaceSession" {
    Context "Parameter Validation" {
        It "Should have 'name' alias for WorkspaceName" {
            (Get-Command Get-NMMWorkspaceSession).Parameters['WorkspaceName'].Aliases |
                Should -Contain 'name'
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMWorkspaceSession -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -WorkspaceName "ws-prod"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/workspace/sub-123/rg-test/ws-prod/sessions" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Output" {
        It "Should return workspace sessions" {
            $result = @(Get-NMMWorkspaceSession -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -WorkspaceName "ws")
            $result[0].sessionState | Should -Be "Active"
        }
    }
}
