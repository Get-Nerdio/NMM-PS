# Define the GitHub repository URL
$repoUrl = "https://github.com/Get-Nerdio/NMM-PS"
$zipUrl = "$repoUrl/archive/refs/heads/main.zip"

# Current directory where the script is run
$currentDir = Get-Location

# Path for the downloaded ZIP file
$zipPath = Join-Path $currentDir "NMM-PS.zip"

# Destination folder for extraction
$extractPath = Join-Path $currentDir "NMM-PS-main"

try {
    Write-Host "Downloading repository from $zipUrl..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -ErrorAction Stop

    Write-Host "Download complete. Extracting contents to $currentDir..." -ForegroundColor Cyan
    Expand-Archive -Path $zipPath -DestinationPath $currentDir -Force

    Write-Host "Extraction complete. The repository is now available in the '$extractPath' folder." -ForegroundColor Green

    # Clean up: Remove the ZIP file
    Remove-Item $zipPath -Force
    Write-Host "Temporary ZIP file removed." -ForegroundColor Yellow
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}