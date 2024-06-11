function Get-LogSettings {
    [CmdletBinding()]
    param()

    try {
        $baseDirectory = $MyInvocation.MyCommand.Path
        $baseDirectory = if ([string]::IsNullOrEmpty($baseDirectory)) { $PSScriptRoot } else { Split-Path $baseDirectory -Parent }

        Write-Verbose "Base Directory: $baseDirectory"

        if (-not [string]::IsNullOrWhiteSpace($baseDirectory)) {
            $dataFolderPath = Join-Path -Path $baseDirectory -ChildPath "Data"

            # Ensure the data folder exists
            if (-not (Test-Path -Path $dataFolderPath)) {
                New-Item -Path $dataFolderPath -ItemType Directory
            }

            Write-Verbose "Data Folder Path: $dataFolderPath"
            $logSettingsFilePath = Join-Path -Path $dataFolderPath -ChildPath "LogSettings.json"
            Write-Verbose "Log Settings File Path: $logSettingsFilePath"

            if (-not (Test-Path -Path $logSettingsFilePath)) {
                Write-Output "LogSettings.json was not found at the path: $logSettingsFilePath, creating default settings."

                # Set default log settings
                $defaultJson = @{
                    LogPathWindows = "%WINDIR%\Temp\NMMLogs"
                    LogPathMacOS   = "/tmp/NMMLogs"
                    EnableLogging  = $false
                } | ConvertTo-Json -Depth 5

                Set-Content -Path $logSettingsFilePath -Value $defaultJson
            }

            $jsonSettings = Get-Content -Path $logSettingsFilePath -Raw | ConvertFrom-Json
            # Determine OS and select appropriate log path
            $osType = if ($IsWindows) { "Windows" } else { "MacOS" }
            $logPathKey = "LogPath$osType"
            $logPath = [Environment]::ExpandEnvironmentVariables($jsonSettings.$logPathKey)

            return @{
                LogPath             = $logPath
                EnableLogging       = $jsonSettings.EnableLogging
                OS                  = $osType
                PowershellVersion   = $PSVersionTable.PSVersion.Major
                LogSettingsJsonPath = $logSettingsFilePath
            }
        }
        else {
            throw "The base directory could not be determined. Ensure the script or module is correctly located or accessed."
        }
    }
    catch {
        Write-LogError "An error occurred: $($_.Exeception.Message)"
    }
    finally {
        Write-Verbose "Completed attempting to load log settings."
    }
}
