BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath/NMM-PS.psm1" -Force

    Mock Invoke-APIRequest {
        return @{
            maxSessionLimit       = 10
            loadBalancerType      = "BreadthFirst"
            validationEnvironment = $false
        }
    } -ModuleName NMM-PS
}

Describe "Get-NMMHostPoolSettings" {
    Context "Parameter Validation" {
        It "Should have AccountId as mandatory parameter" {
            (Get-Command Get-NMMHostPoolSettings).Parameters['AccountId'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                ForEach-Object { $_.Mandatory | Should -Be $true }
        }

        It "Should have SubscriptionId as mandatory parameter" {
            (Get-Command Get-NMMHostPoolSettings).Parameters['SubscriptionId'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                ForEach-Object { $_.Mandatory | Should -Be $true }
        }

        It "Should have ResourceGroup as mandatory parameter" {
            (Get-Command Get-NMMHostPoolSettings).Parameters['ResourceGroup'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                ForEach-Object { $_.Mandatory | Should -Be $true }
        }

        It "Should have PoolName as mandatory parameter" {
            (Get-Command Get-NMMHostPoolSettings).Parameters['PoolName'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                ForEach-Object { $_.Mandatory | Should -Be $true }
        }

        It "Should have 'subscription' alias for SubscriptionId" {
            (Get-Command Get-NMMHostPoolSettings).Parameters['SubscriptionId'].Aliases |
                Should -Contain 'subscription'
        }

        It "Should have 'hostPoolName' alias for PoolName" {
            (Get-Command Get-NMMHostPoolSettings).Parameters['PoolName'].Aliases |
                Should -Contain 'hostPoolName'
        }
    }

    Context "API Call" {
        It "Should construct correct endpoint URL" {
            Get-NMMHostPoolSettings -AccountId 123 -SubscriptionId "sub-123" -ResourceGroup "rg-test" -PoolName "pool-01"

            Should -Invoke Invoke-APIRequest -ModuleName NMM-PS -ParameterFilter {
                $Endpoint -eq "accounts/123/host-pool/sub-123/rg-test/pool-01/avd" -and
                $Method -eq "GET"
            }
        }
    }

    Context "Pipeline Input" {
        It "Should accept pipeline input with proper aliases" {
            $mockPool = [PSCustomObject]@{
                subscription  = "sub-123"
                resourceGroup = "rg-test"
                hostPoolName  = "pool-01"
            }

            { $mockPool | Get-NMMHostPoolSettings -AccountId 123 } | Should -Not -Throw
        }
    }

    Context "Output" {
        It "Should return host pool settings object" {
            $result = Get-NMMHostPoolSettings -AccountId 123 -SubscriptionId "sub" -ResourceGroup "rg" -PoolName "pool"
            $result.maxSessionLimit | Should -Be 10
            $result.loadBalancerType | Should -Be "BreadthFirst"
        }
    }
}
