Begin {
    # Define the GitHub repository URL
    $repoUrl = "https://github.com/Get-Nerdio/NMM-PS"
    $zipUrl = "$repoUrl/refs/heads/main.zip"

    # Current directory where the script is run
    $currentDir = Get-Location

    # Path for the downloaded ZIP file
    $zipPath = Join-Path $currentDir "NMM-PS.zip"

    # Destination folder for extraction
    $extractPath = Join-Path $currentDir "NMM-PS"
    $tempExtractPath = Join-Path $currentDir "NMM-PS-main"
}

Process {
    try {
        Write-Output "Downloading repository from $zipUrl..."
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -ErrorAction Stop

        Write-Output "Download complete. Extracting contents..."
        Expand-Archive -Path $zipPath -DestinationPath $currentDir -Force

        # Move contents from NMM-PS-main to NMM-PS
        if (Test-Path $tempExtractPath) {
            if (Test-Path $extractPath) {
                Remove-Item $extractPath -Recurse -Force
            }
            Rename-Item -Path $tempExtractPath -NewName "NMM-PS" -Force
            Write-Output "Extraction complete. The repository is now available in the '$extractPath' folder."
        } else {
            throw "Expected folder '$tempExtractPath' not found after extraction"
        }
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
        $moduleFile = Join-Path $extractPath "NMM-PS.psm1"
        Import-Module $moduleFile -Force -ErrorAction Stop
        Write-Output "NMM-PS module successfully imported."
    }
    catch {
        Write-Output "Failed to import module: $($_.Exception.Message)"
    }
}