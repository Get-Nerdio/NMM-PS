function Write-LogError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [bool]$WriteToConsole = $true,

        [Parameter(Mandatory = $false)]
        [ValidateSet('INFO', 'WARN', 'ERROR', 'CRITICAL')]
        [string]$Severity = 'ERROR'
    )

    $logSettings = Get-LogSettings

    # Define the log entry as a custom object
    $logEntry = [PSCustomObject]@{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Severity  = $Severity
        OS        = $logSettings.OS
        PSVersion = $logSettings.PowershellVersion
        Message   = $Message
    }

    if ($logSettings -and $logSettings.EnableLogging) {
        $logPath = $logSettings.LogPath
        $logFile = Join-Path -Path $logPath -ChildPath "error_log.txt"

        # Ensure log directory exists
        if (-Not (Test-Path $logPath)) {
            New-Item -ItemType Directory -Path $logPath -Force
        }

        # Convert log entry object to a JSON string for file logging
        $logEntryString = $logEntry | ConvertTo-Json -Compress

        # Write to log file
        try {
            Add-Content -Path $logFile -Value $logEntryString -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to write to log file: $logFile. Error: $_"
        }
    }

    # Optionally write to the console
    if ($WriteToConsole) {
        $consoleColor = switch ($Severity) {
            'INFO' { 'Green' }
            'WARN' { 'Yellow' }
            'ERROR' { 'Red' }
            'CRITICAL' { 'Red' }
        }
        $logEntry | Format-Table | Out-String | Write-Host -ForegroundColor $consoleColor
    }
}
