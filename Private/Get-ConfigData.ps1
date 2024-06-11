function Get-ConfigData {
    try {
        # Determine the base directory using either $MyInvocation or $PSScriptRoot depending on the context
        $baseDirectory = $MyInvocation.MyCommand.Path
        $baseDirectory = if ([string]::IsNullOrEmpty($baseDirectory)) { $PSScriptRoot } else { Split-Path $baseDirectory -Parent }

        Write-Verbose "Base Directory: $baseDirectory"

        if (-not [string]::IsNullOrWhiteSpace($baseDirectory)) {
            $dataFolderPath = Join-Path -Path $baseDirectory -ChildPath "Data"
            Write-Verbose "Data Folder Path: $dataFolderPath"

            $configDataFilePath = Join-Path -Path $dataFolderPath -ChildPath "ConfigData.json"
            Write-Verbose "Config Data File Path: $configDataFilePath"

            if (Test-Path -Path $configDataFilePath) {
                $jsonData = Get-Content -Path $configDataFilePath -Raw | ConvertFrom-Json
                return $jsonData
            }
            else {
                throw "ConfigData.json was not found at the path: $configDataFilePath"
            }
        }
        else {
            throw "The base directory could not be determined. Ensure the script or module is correctly located or accessed."
        }
    }
    catch {
        Write-LogError -Message "Error encountered: $_" -Severity "WARN"
        throw $_  # Re-throw the caught exception after logging it for further handling up the call stack
    }
    finally {
        Write-Output "Attempt to load config data completed."
    }
}

