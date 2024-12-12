# Define the GitHub repository URL
$repoUrl = "https://github.com/Get-Nerdio/NMM-PS"
$zipUrl = "$repoUrl/archive/refs/heads/main.zip"

# Current directory where the script is run
$currentDir = Get-Location

# Path for the downloaded ZIP file
$zipPath = Join-Path $currentDir "NMM-PS.zip"

# Destination folder for extraction
$extractPath = Join-Path $currentDir "NMM-PS"

try {
    Write-Output "Downloading repository from $zipUrl..."
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -ErrorAction Stop

    Write-Output "Download complete. Extracting contents to $currentDir..."
    Expand-Archive -Path $zipPath -DestinationPath $currentDir -Force

    Write-Output "Extraction complete. The repository is now available in the '$extractPath' folder."
    
    # Clean up: Remove the ZIP file
    Remove-Item $zipPath -Force
    Write-Output "Temporary ZIP file removed."

    # Import the module
    $moduleFile = Join-Path $extractPath "NMM-PS.psm1"
    if (Test-Path $moduleFile) {
        Import-Module $moduleFile -Force -ErrorAction Stop
        Write-Output "NMM-PS module successfully imported."
    } else {
        Write-Output "Module file '$moduleFile' not found."
    }
}
catch {
    Write-Output "An error occurred: $($_.Exception.Message)"
}