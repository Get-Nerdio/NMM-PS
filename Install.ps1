Begin {
    # Define the GitHub repository URL
    $repoUrl = "https://github.com/Get-Nerdio/NMM-PS"
    $zipUrl = "$repoUrl/archive/refs/heads/main.zip"

    # Current directory where the script is run
    $currentDir = Get-Location

    # Path for the downloaded ZIP file
    $zipPath = Join-Path $currentDir "NMM-PS.zip"

    # Destination folder for extraction
    $extractPath = Join-Path $currentDir "NMM-PS"
}

Process {
    try {
        Write-Output "Downloading repository from $zipUrl..."
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -ErrorAction Stop

        Write-Output "Download complete. Extracting contents to $currentDir..."
        Expand-Archive -Path $zipPath -DestinationPath $currentDir -Force

        Write-Output "Extraction complete. The repository is now available in the '$extractPath' folder."
    }
    catch {
        Write-Output "An error occurred: $($_.Exception.Message)"
        return
    }
}

End {
    try {
        # Clean up: Remove the ZIP file
        Remove-Item $zipPath -Force
        Write-Output "Temporary ZIP file removed."

        # Import the module
        $moduleFile = Join-Path $currentDir "NMM-PS\NMM-PS.psm1"
        Import-Module $moduleFile -Force -ErrorAction Stop
        Write-Output "NMM-PS module successfully imported."
    }
    catch {
        Write-Output "Failed to import module: $($_.Exception.Message)"
    }
}