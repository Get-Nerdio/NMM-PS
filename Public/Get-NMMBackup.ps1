function Get-NMMBackup {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$AccountId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Item')]
        [string]$ProtectedItemId,

        [Parameter(ParameterSetName = 'List')]
        [switch]$ListProtected,

        [Parameter(ParameterSetName = 'List')]
        [string]$FriendlyName,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet("AzureFileShare", "VM")]
        [string]$ProtectedItemType,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet("Protected", "ProtectionStopped", "IRPending", "ProtectionPaused")]
        [string]$ProtectionState,

        [Parameter(ParameterSetName = 'List')]
        [string]$LastBackupStatus,

        [Parameter(ParameterSetName = 'List')]
        [datetime]$LastRestorePoint,

        [Parameter(ParameterSetName = 'List')]
        [bool]$SoftDeleted,

        [Parameter(ParameterSetName = 'List')]
        [string]$RecoveryVault,

        [Parameter(ParameterSetName = 'List')]
        [string]$PolicyName,

        [Parameter(ParameterSetName = 'List')]
        [bool]$VaultIsManaged,

        [Parameter(ParameterSetName = 'List')]
        [bool]$IsBackupInProgress,

        [Parameter(ParameterSetName = 'List')]
        [string]$ResourceGroupName,

        [Parameter(ParameterSetName = 'List')]
        [bool]$ReturnRecoveryPoints = $false
    )
    
    $begin = Get-Date


    try {
        $resultsBag = [System.Collections.Concurrent.ConcurrentBag[psobject]]::new()
    
        if ($ListProtected) {
            $results = Invoke-APIRequest -Method 'Get' -Endpoint "/accounts/$AccountId/backup/protectedItems"
    
            $filteredResults = @($results) | Where-Object {
                (!$FriendlyName -or $_.friendlyName -like "*$FriendlyName*") -and
                (!$ProtectedItemType -or $_.protectedItemType -eq $ProtectedItemType) -and
                (!$ProtectionState -or $_.protectionState -eq $ProtectionState) -and
                (!$LastBackupStatus -or $_.lastBackupStatus -eq $LastBackupStatus) -and
                (!$LastRestorePoint -or $_.lastRestorePoint.ToShortDateString() -eq $LastRestorePoint.ToShortDateString()) -and
                (!$SoftDeleted -or $_.softDeleted -eq $SoftDeleted) -and
                (!$RecoveryVault -or $_.recoveryVault -eq $RecoveryVault) -and
                (!$PolicyName -or $_.policyName -eq $PolicyName) -and
                (!$VaultIsManaged -or $_.vaultIsManaged -eq $VaultIsManaged) -and
                (!$IsBackupInProgress -or $_.isBackupInProgress -eq $IsBackupInProgress) -and
                (!$ResourceGroupName -or $_.resourceGroupName -eq $ResourceGroupName)
            }
    
            $FunctionInvokeAPI = ${function:Invoke-APIRequest}.ToString()
            $FunctionWriteLogError = ${function:Invoke-APIRequest}.ToString()
            $FunctionStructureData = ${function:ConvertTo-StructuredData}.ToString()

            $filteredResults | ForEach-Object -Parallel {

                $script:CachedToken = $using:CachedToken
                ${function:Invoke-APIRequest} = $using:FunctionInvokeAPI
                ${function:Write-LogError} = $using:FunctionWriteLogError
                ${function:ConvertTo-StructuredData} = $using:FunctionStructureData
                
                try {
                    if ($using:ReturnRecoveryPoints) {
                        Write-Verbose "Fetching recovery points for item with ID: $($_.id)"
                        $recoveryPoints = Invoke-APIRequest -Method 'Get' -Endpoint "/accounts/$using:AccountId/backup/recoveryPoints" -Query 'protectedItemId' -Filter "$($_.id)"
            
                        if ($null -ne $recoveryPoints -and $recoveryPoints.Count -gt 0) {
                            Write-Verbose "Processing non-null recovery points..."
                            $structuredRecoveryPoints = $recoveryPoints | ForEach-Object {
                                $FunctionStructureData = ${function:ConvertTo-StructuredData}.ToString()
                                ${function:ConvertTo-StructuredData} = $using:FunctionStructureData

                                $structuredData = ConvertTo-StructuredData -String $_.id
                                $structuredData | Add-Member -NotePropertyName "DateTime" -NotePropertyValue $_.dateTime -Force
                                return $structuredData
                            }
                            $_ | Add-Member -NotePropertyName 'RecoveryPoints' -NotePropertyValue $structuredRecoveryPoints -Force
                        }
                        else {
                            Write-Verbose "No recovery points found for item, adding placeholder.."
                            $_ | Add-Member -NotePropertyName 'RecoveryPoints' -NotePropertyValue 'No Recovery Points' -Force
                        }
                    }
                }
                catch {
                    Write-LogError -Message "Failed to process recovery points for item with ID: $($_.id): $_"
                }
                # Add each item to the results bag
                ($using:resultsBag).Add($_)
            } -ThrottleLimit 10  # Control the number of concurrent threads
            
            $arrayResults = $resultsBag.ToArray()
            return $arrayResults
            
        }
        elseif ($ProtectedItemId) {
            $result = Invoke-APIRequest -Method 'Get' -Endpoint "/accounts/$AccountId/backup/recoveryPoints" -Query 'protectedItemId' -Filter "$($ProtectedItemId)"
            Write-Verbose "Recovery Points for Item $($ProtectedItemId) : "
            return $result
        }
        else {
            Write-LogError "You must specify either -ListProtected or provide a -ProtectedItemId."
        }
    
        $arrayResults = $resultsBag.ToArray()
        return $arrayResults
    
    }
    catch {
        Write-LogError "Failed to retrieve data: $_"
    }
    finally {
        $runtime = New-TimeSpan -Start $begin -End (Get-Date)
        Write-Verbose "Execution completed in $runtime"
    }
    
}