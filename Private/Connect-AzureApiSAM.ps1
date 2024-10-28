function Connect-AzureApiSAM {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $false)]
        [ValidateNotNullOrEmpty()][String]$ApplicationId,
         
        [parameter(Position = 1, Mandatory = $false)]
        [ValidateNotNullOrEmpty()][String]$ApplicationSecret,
         
        [parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$TenantID,
 
        [parameter(Position = 3, Mandatory = $false)]
        [ValidateNotNullOrEmpty()][String]$RefreshToken
 
    )
    
    Write-Verbose "Logging into Azure API"
    try {
        if ($ApplicationId) {
            Write-Verbose "   using the entered credentials"
            $AuthBody = @{
                client_id     = $ApplicationId
                client_secret = $ApplicationSecret
                scope         = 'https://management.azure.com/user_impersonation'
                refresh_token = $RefreshToken
                grant_type    = "refresh_token"
                
            }
             
        }
        else {
            Write-Verbose "   using the cached credentials"
            $AuthBody = @{
                client_id     = $script:ApplicationId
                client_secret = $Script:ApplicationSecret
                scope         = 'https://management.azure.com/user_impersonation'
                refresh_token = $script:RefreshToken
                grant_type    = "refresh_token"
                
            }
        }
        $AccessToken = (Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$($tenantid)/oauth2/v2.0/token" -Body $Authbody -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop).access_token
 
        $AzurehHeader = @{ Authorization = "Bearer $($AccessToken)" }

        return $AzurehHeader
    }
    catch {
        Write-Host "Could not log into the Azure API for tenant $($TenantID): $($_.Exception.Message)" -ForegroundColor Red
    }
 
}


