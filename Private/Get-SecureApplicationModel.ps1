function Get-SecureApplicationModel {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('KeyVault', 'ConfigFile')]
        [string]$Source = 'ConfigFile',

        [Parameter()]
        [string]$KeyVaultName
    )

    begin {
        Write-Verbose "Initializing SAM credential retrieval from $Source"
    }

    process {
        try {
            switch ($Source) {
                'KeyVault' {
                    if (-not $KeyVaultName) {
                        throw "KeyVaultName parameter is required when using KeyVault source"
                    }

                    Write-Verbose "Retrieving credentials from Azure KeyVault: $KeyVaultName"
                    
                    # Ensure Az.KeyVault module is available
                    if (-not (Get-Module -ListAvailable Az.KeyVault)) {
                        throw "Az.KeyVault module is required for KeyVault operations"
                    }

                    $samCredentials = @{
                        ApplicationId       = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name 'ApplicationId').SecretValue
                        ApplicationSecret   = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name 'ApplicationSecret').SecretValue
                        TenantId           = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name 'TenantId').SecretValue
                        RefreshToken       = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name 'RefreshToken').SecretValue
                    }
                }

                'ConfigFile' {
                    Write-Verbose "Retrieving credentials from ConfigData"
                    
                    $config = Get-ConfigData
                    
                    if (-not $config.SAM) {
                        throw "SAM configuration not found in ConfigData"
                    }

                    $samCredentials = @{
                        ApplicationId       = $config.SAM.ApplicationId
                        ApplicationSecret   = $config.SAM.ApplicationSecret
                        TenantId           = $config.SAM.MSPTenantId
                        RefreshToken       = $config.SAM.RefreshToken
                    }
                }
            }

            return ([PSCustomObject]$samCredentials)
        }
        catch {
            Write-Error "Failed to retrieve SAM credentials: $_"
            throw
        }
    }
}
