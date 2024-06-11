function Set-LogSettings {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()
    if ($PSCmdlet.ShouldProcess("Log settings file", "Create/Update")) {

        $logSettingsFilePath = (Get-LogSettings).LogSettingsJsonPath

        if (Test-Path -Path $logSettingsFilePath) {
            Write-Verbose "Log Settings File Found: $logSettingsFilePath"
        }
        else {
            Write-Output "Log settings file not found at path: $logSettingsFilePath"
            New-Item -Path $logSettingsFilePath -ItemType File
            #Set default log settings
            $DefaultJson = @{
                LogPathWindows = "%WINDIR%\Temp\NMMLogs"
                LogPathMacOS   = "/tmp/NMMLogs"
                EnableLogging  = $false
            } | ConvertTo-Json

            Set-Content -Path $logSettingsFilePath -Value $DefaultJson
            return
        }   


        $currentSettings = Get-Content -Path $logSettingsFilePath -Raw | ConvertFrom-Json

        if ($null -eq $currentSettings) {
            Write-LogError -Message "Failed to retrieve log settings."
            return
        }
        Write-Verbose "Log Settings File Path: $logSettingsFilePath"

        # Display current settings to the user
        Write-Output "Current Log Settings:"
        Write-Output "Windows Log Path: $($currentSettings.LogPathWindows)"
        Write-Output "macOS Log Path: $($currentSettings.LogPathMacOS)"
        Write-Output "Logging Enabled: $($currentSettings.EnableLogging)"
    
        # Ask the user if they want to edit the settings
        $edit = Read-Host "Do you want to edit these settings? (Yes/No)"
        if ($edit -ne "Yes") {
            Write-Output "No changes made."
            return
        }

        # Interactive prompts for new settings
        $newLogPathWindows = Read-Host "Enter new Windows Log Path (leave blank to keep current)"
        $newLogPathMacOS = Read-Host "Enter new macOS Log Path (leave blank to keep current)"
        $newEnableLogging = Read-Host "Enable Logging? (True/False)"

        try {

            # Update the settings based on input, only if new values were provided
            if (-not [string]::IsNullOrWhiteSpace($newLogPathWindows)) {
                $currentSettings.LogPathWindows = $newLogPathWindows
            }
            if (-not [string]::IsNullOrWhiteSpace($newLogPathMacOS)) {
                $currentSettings.LogPathMacOS = $newLogPathMacOS
            }
            if (-not [string]::IsNullOrWhiteSpace($newEnableLogging)) {
                $currentSettings.EnableLogging = [bool]::Parse($newEnableLogging)
            }

            # Convert the updated settings back to JSON and write to the file
            $json = $currentSettings | ConvertTo-Json -Depth 5
            Set-Content -Path $logSettingsFilePath -Value $json
            Write-Output "Log settings updated successfully."
        }
        catch {
            Write-LogError -Message "An error occurred while updating the log settings: $($_.Exception.Message)"
        }
        finally {
        
            Write-Verbose "Log settings updated successfully."
        }
    }
}
