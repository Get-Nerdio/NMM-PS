function Add-PartnerCenterAccounts {
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    param (
        [Parameter(ParameterSetName = 'CSV')]
        [string]$CsvPath,

        [Parameter(Mandatory = $true, ParameterSetName = 'KeyVault')]
        [Parameter(Mandatory = $true, ParameterSetName = 'KeyVaultCSV')]
        [ValidateSet('KeyVault')]
        [string]$CredentialSource = 'ConfigFile',

        [Parameter(Mandatory = $true, ParameterSetName = 'KeyVault')]
        [Parameter(Mandatory = $true, ParameterSetName = 'KeyVaultCSV')]
        [string]$KeyVaultName,

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [string[]]$ExcludeTenants,

        [Parameter()]
        [int]$ThrottleLimit = 5,

        [Parameter()]
        [ValidateSet('NewADDS', 'ExistingADDS', 'ExistingADFSFed', 'AzureAD')]
        [string]$ActiveDirectoryType = 'AzureAD',

        [Parameter()]
        [bool]$LimitedAccessEnabled = $false,

        [Parameter()]
        [bool]$EnableWVD = $false,

        [Parameter()]
        [bool]$EnableSelfManagedCloudPC = $false,
  
        [Parameter()]
        [bool]$EnableEndpointManagedCloudPC = $false,

        [Parameter()]
        [bool]$EnableEndpointManagedWithIntune = $true,

        [Parameter(ParameterSetName = 'SingleTenant')]
        [string]$TenantId
    )

    begin {
        Write-Verbose "Initializing tenant provisioning using $CredentialSource"
        
        # Get SAM credentials
        try {
            $samCredentials = if ($CredentialSource -eq 'KeyVault') {
                Get-SecureApplicationModel -Source KeyVault -KeyVaultName $KeyVaultName
            }
            else {
                Get-SecureApplicationModel -Source ConfigFile
            }
        }
        catch {
            throw "Failed to retrieve SAM credentials: $_"
        }

        # Initialize collections
        $tenantsToProcess = [System.Collections.Generic.List[object]]::new()
        $results = [System.Collections.Generic.List[object]]::new()

        # Create deployment options object
        $deploymentOptions = @{
            wvd                       = $EnableWVD
            selfManagedCloudPc        = $EnableSelfManagedCloudPC
            endpointManagedCloudPc    = $EnableEndpointManagedCloudPC
            endpointManagedWithIntune = $EnableEndpointManagedWithIntune
        }
    }

    process {
        try {
            # Get existing accounts first
            Write-Verbose "Getting existing accounts"
            $existingAccounts = Get-Accounts
            $existingTenantIds = $existingAccounts.tenantId

            # Get Graph token for MSP tenant
            Write-Verbose "Getting Graph token for MSP tenant"
            if (-not $Script:GraphHeader) {
                Write-Verbose "No existing Graph token found, connecting to Graph API"
                $graphParams = @{
                    ApplicationId     = $samCredentials.ApplicationId
                    ApplicationSecret = $samCredentials.ApplicationSecret 
                    TenantID         = $samCredentials.TenantId
                    RefreshToken     = $samCredentials.RefreshToken
                }
                $graphToken = Connect-GraphApiSAM @graphParams
            }
            else {
                Write-Verbose "Using existing Graph token"
                $graphToken = $Script:GraphHeader
            }

            # Get tenants to process
            if ($PSCmdlet.ParameterSetName -eq 'CSV') {
                Write-Verbose "Processing tenants from CSV: $CsvPath"
                $tenantsToProcess.AddRange(@(Import-Csv -Path $CsvPath))
            }
            else {
                Write-Verbose "Retrieving customers from Graph API"
                $params = @{
                    Uri     = "https://graph.microsoft.com/v1.0/contracts?`$top=999"
                    Method  = "GET"
                    Headers = $graphToken
                }
                $tenants = Invoke-RestMethod @params

                if ($TenantId) {
                    Write-Verbose "Filtering for specific tenant: $TenantId"
                    $newTenants = @($tenants.value | Where-Object { 
                        $_.customerId -eq $TenantId -and $_.customerId -notin $existingTenantIds 
                    })
                }
                else {
                    # Filter out existing tenants and add the rest
                    $newTenants = @($tenants.value | Where-Object { 
                        $_.customerId -notin $existingTenantIds 
                    })
                }
                Write-Verbose "Found $($tenants.value.Count) total tenants, $($newTenants.Count) new tenants to process"
                
                if ($newTenants.Count -gt 0) {
                    $tenantsToProcess.AddRange($newTenants)
                }
            }

            # Filter out excluded tenants
            if ($ExcludeTenants) {
                $tenantsToProcess = $tenantsToProcess | Where-Object { $_.defaultDomainName -notin $ExcludeTenants }
            }

            Write-Verbose "Processing $($tenantsToProcess.Count) tenants"

            # Early exit if no tenants to process
            if ($tenantsToProcess.Count -eq 0) {
                Write-Output "No new tenants to process. Exiting..."
                return
            }

            # Process tenants using ForEach-Object
            $tenantsToProcess | ForEach-Object {
                $tenant = $_
                $result = [PSCustomObject]@{
                    TenantId = $tenant.customerId
                    Domain   = $tenant.defaultDomainName
                    Status   = 'Processing'
                    Error    = $null
                }

                try {
                    # Get Graph token for the tenant
                    $graphCustomerTokenParams = @{
                        TenantId          = $tenant.customerId
                        ApplicationSecret = $samCredentials.ApplicationSecret
                        ApplicationId     = $samCredentials.ApplicationId 
                        RefreshToken      = $samCredentials.RefreshToken
                        Scope             = 'https://graph.microsoft.com/Directory.AccessAsUser.All'
                    }

                    $graphCustomerToken = Connect-GraphApiSAM @graphCustomerTokenParams

                    # Get Azure token for the tenant
                    $azureTokenParams = @{
                        TenantId          = $tenant.customerId
                        ApplicationSecret = $samCredentials.ApplicationSecret
                        ApplicationId     = $samCredentials.ApplicationId 
                        RefreshToken      = $samCredentials.RefreshToken
                    }
                    $azureToken = Connect-AzureApiSAM @azureTokenParams

                    $body = @{
                        subscriptionId           = $null
                        azureAccessToken         = $azureToken.Authorization.Replace("Bearer ", "")
                        graphAccessToken         = $graphCustomerToken.Authorization.Replace("Bearer ", "")
                        companyName              = $tenant.displayName
                        activeDirectoryType      = $ActiveDirectoryType
                        limitedAccessEnabled     = $LimitedAccessEnabled
                        desktopDeploymentOptions = $deploymentOptions
                    }

                    $response = Invoke-APIRequest -Method 'POST' -Endpoint 'accountprovisioning/LinkTenant' -Body $body
                    $result.Status = 'Success'
                }
                catch {
                    $result.Status = 'Failed'
                    $result.Error = $_.Exception.Message
                }

                $result
            } | ForEach-Object {
                $results.Add($_)
            }
        }
        catch {
            Write-Error "Failed to process tenant accounts: $_"
        }
    }

    end {
        # Output results
        Write-Output $results
    }
}
