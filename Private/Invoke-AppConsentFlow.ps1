function Invoke-AppConsentFlow {
    <#
    .SYNOPSIS
    Initiates the app consent flow for Microsoft Partner Center API access across customer tenants.

    .DESCRIPTION
    This function automates the process of obtaining admin consent for Partner Center API permissions 
    across specified customer tenants or all customer tenants. It handles the OAuth2 authorization flow,
    including opening the consent page in a browser and capturing the authorization response.

    .PARAMETER tenantId
    The tenant ID of the Microsoft Partner (MSP) organization.

    .PARAMETER appId 
    The application (client) ID of the registered application in Azure AD.

    .PARAMETER redirectUri
    The redirect URI configured in the app registration. Defaults to 'http://localhost:8400'.

    .PARAMETER scope
    The permission scope requested. Defaults to 'https://api.partnercenter.microsoft.com/.default'.

    .PARAMETER customerTenants
    A hashtable containing customer tenant IDs as keys and display names as values.
    Required when not using -AllCustomers switch.

    .PARAMETER AllCustomers
    Switch to process consent flow for all customers. When specified, the function will retrieve
    all customer tenants from Partner Center automatically.

    .PARAMETER AddSAM
    Switch to use SAM configuration for tenantId and appId.

    .PARAMETER samDisplayName
    The display name of the SAM configuration.

    .EXAMPLE
    # Process specific customers
    $customers = @{
        "tenant-id-1" = "Customer1 Name"
        "tenant-id-2" = "Customer2 Name"
    }
    Invoke-AppConsentFlow -tenantId "msp-tenant-id" -appId "app-id" -customerTenants $customers

    .EXAMPLE
    # Process all customers
    Invoke-AppConsentFlow -tenantId "msp-tenant-id" -appId "app-id" -AllCustomers

    .NOTES
    Requires appropriate Partner Center API permissions and admin consent from customer tenants.
    #>

    [CmdletBinding(DefaultParameterSetName = 'Specific')]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Specific')]
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [string]$tenantId,

        [Parameter(Mandatory = $false, ParameterSetName = 'Specific')]
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [string]$appId,

        [Parameter(ParameterSetName = 'Specific')]
        [Parameter(ParameterSetName = 'All')]
        [string]$redirectUri = 'http://localhost:8400', #Needs to match redirect uri of your app registration

        [Parameter(ParameterSetName = 'Specific')]
        [Parameter(ParameterSetName = 'All')]
        [string]$scope = 'https://api.partnercenter.microsoft.com/.default',

        [Parameter(Mandatory, ParameterSetName = 'Specific')]
        [hashtable]$customerTenants, #Hashtable of CustomerTenantId and DisplayName

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch]$AllCustomers,

        [Parameter(ParameterSetName = 'Specific')]
        [Parameter(ParameterSetName = 'All')]
        [string]$samDisplayName,

        [Parameter(ParameterSetName = 'Specific')]
        [Parameter(ParameterSetName = 'All')]
        [switch]$AddSAM
    )

    # Get SAM configuration
    $samConfig = (Get-ConfigData).SAM
    if (-not $samConfig) {
        Write-Output "Error: Unable to retrieve SAM configuration"
        return
    }

    # Set tenantId, appId, and samDisplayName if using AddSAM switch
    if ($AddSAM) {
        $tenantId = $samConfig.MSPTenantId
        $appId = $samConfig.ApplicationId
        $appSecret = $samConfig.ApplicationSecret
        $samDisplayName = $samConfig.SAMDisplayName
    }
    
    # Validate required parameters if not using AddSAM
    if (-not $AddSAM -and (-not $tenantId -or -not $appId)) {
        Write-Output "Error: When not using -AddSAM, both -tenantId and -appId parameters are required"
        return
    }

    try {
        
        if ($AllCustomers) {
            # Get MSP token
            $graphParams = @{
                ApplicationId     = $samConfig.ApplicationId
                ApplicationSecret = $samConfig.ApplicationSecret
                RefreshToken      = $samConfig.RefreshToken
                TenantID          = $samConfig.MSPTenantId
            }
            $MSPtoken = Connect-GraphApiSAM @graphParams

            Write-Output "Retrieving all customers from Partner Center..."
            $tenants = (Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/contracts?`$top=999" -Method GET -Headers $MSPtoken).value
            $customerTenants = @{}
            foreach ($tenant in $tenants) {
                $customerTenants[$tenant.customerId] = $tenant.displayName
            }
            Write-Output "Found $($customerTenants.Count) customers"
        }
    }
    catch {
        Write-Output "Error connecting to Graph API: $_"
        return
    }

    # Get authorization code if not already present
    if (-not $script:authCode) {
        try {
            $authParams = @{
                tenantId     = $tenantId
                appId        = $appId
                appSecret    = $appSecret
                redirectUri  = $redirectUri
                scope        = $scope
            }
            $script:authCode = Get-SAMAuthorizationCode @authParams
            
            Write-Output "Authorization Code obtained successfully"
        }
        catch {
            Write-Output "Error obtaining authorization code: $_"
            return
        }
    }

    $headers = @{
        Authorization = $script:authCode.Authorization  # Using the Authorization property directly
        'Accept'      = 'application/json'
    }

    # Process each customer tenant
    $customerTenants.GetEnumerator() | ForEach-Object {
        $currentTenant = $_
        Write-Output "Processing tenant: $($currentTenant.Value)"

        $body = @{
            applicationGrants = @(
                @{
                    enterpriseApplicationId = "00000003-0000-0000-c000-000000000000"
                    scope                   = "Directory.AccessAsUser.All,Application.ReadWrite.All,Directory.ReadWrite.All"
                },
                @{
                    enterpriseApplicationId = "797f4846-ba00-4fd7-ba43-dac1f8f63013"
                    scope                   = "user_impersonation"
                }
            )
            applicationId     = $appId
            displayName      = $samDisplayName
        } | ConvertTo-Json -Compress

        $uri = "https://api.partnercenter.microsoft.com/v1/customers/$($currentTenant.Key)/applicationconsents"

        try {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method POST -Body $body -ContentType 'application/json' -ErrorAction Stop
            Write-Output "Successfully processed tenant $($currentTenant.Value)"
            Write-Output $response
        }
        catch {
            $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
            Write-Output "Error processing tenant $($currentTenant.Value):"
            Write-Output "Status Code: $($_.Exception.Response.StatusCode.value__)"
            Write-Output "Error Message: $($errorDetails.message)"
            Write-Output "Activity ID: $($errorDetails.activityId)"
        }
    }
}