function Add-PartnerCenterAccounts {
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    param (
        [Parameter(ParameterSetName = 'CSV')]
        [string]$CsvPath,

        [Parameter(Mandatory = $true, ParameterSetName = 'KeyVault')]
        [Parameter(Mandatory = $true, ParameterSetName = 'KeyVaultCSV')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SAMConfig')]
        [ValidateSet('KeyVault', 'ConfigFile', 'SAMConfig')]
        [string]$CredentialSource = 'ConfigFile',

        [Parameter(Mandatory = $true, ParameterSetName = 'KeyVault')]
        [Parameter(Mandatory = $true, ParameterSetName = 'KeyVaultCSV')]
        [string]$KeyVaultName,

        [Parameter(Mandatory = $true, ParameterSetName = 'SAMConfig')]
        [PSObject]$SAMCredentials,

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [string[]]$ExcludeTenants,

        [Parameter()]
        [int]$ThrottleLimit = 4,

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
            $samCredentials = switch ($CredentialSource) {
                'KeyVault' { 
                    Get-SecureApplicationModel -Source KeyVault -KeyVaultName $KeyVaultName 
                }
                'SAMConfig' { 
                    $SAMCredentials 
                }
                default { 
                    Get-SecureApplicationModel -Source ConfigFile 
                }
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

        # Ensure all necessary variables are initialized
        if (-not $samCredentials) {
            throw "SAM credentials are not initialized."
        }

        $applicationId = $samCredentials.ApplicationId
        $applicationSecret = $samCredentials.ApplicationSecret
        $refreshToken = $samCredentials.RefreshToken

        if (-not $applicationId -or -not $applicationSecret -or -not $refreshToken) {
            throw "One or more SAM credential components are not initialized."
        }

    }

    process {
        try {
            # Get existing accounts first
            Write-Verbose "Getting existing accounts"
            $existingAccounts = Get-Accounts
            $existingTenantIds = $existingAccounts.tenantId
            Write-Verbose "Found these accounts in NMM: $($existingAccounts)"

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
                Write-Verbose "Found these Tenants `n $($tenants)"

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

            
            $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\NMM-ps.psm1'

            $tenantsToProcess | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
                # Import the module in the parallel runspace
                Import-Module -Name $using:modulePath -Force
               

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
                        ApplicationSecret = $using:applicationSecret
                        ApplicationId     = $using:applicationId
                        RefreshToken      = $using:refreshToken
                        Scope             = 'https://graph.microsoft.com/Directory.AccessAsUser.All'
                    }

                    $graphCustomerToken = Connect-GraphApiSAM @graphCustomerTokenParams

                    # Get Azure token for the tenant
                    $azureTokenParams = @{
                        TenantId          = $tenant.customerId
                        ApplicationSecret = $using:applicationSecret
                        ApplicationId     = $using:applicationId
                        RefreshToken      = $using:refreshToken
                    }
                    $azureToken = Connect-AzureApiSAM @azureTokenParams

                    $body = @{
                        subscriptionId           = $null
                        azureAccessToken         = $azureToken.Authorization.Replace("Bearer ", "")
                        graphAccessToken         = $graphCustomerToken.Authorization.Replace("Bearer ", "")
                        companyName              = $tenant.displayName
                        activeDirectoryType      = $using:ActiveDirectoryType
                        limitedAccessEnabled     = $using:LimitedAccessEnabled
                        desktopDeploymentOptions = $using:deploymentOptions
                    }

                    $response = Invoke-APIRequest -Method 'POST' -Endpoint 'accountprovisioning/LinkTenant' -Body $body
                    $result.Status = 'Success'
                }
                catch {
                    $result.Status = 'Failed'
                    $result.Error = $_.Exception.Message
                }

                # Add each result to the results collection
                ($using:results).Add($result)
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