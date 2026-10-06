# Apipatch Windows Installer (PowerShell)
# Usage: irm https://apipatch.fix2ship.dev/install.ps1 | iex

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Repo = "SameerKhans13/web-apipatch"
$InstallDir = "$HOME\.apipatch\bin"
$ExePath = "$InstallDir\apipatch.exe"
$ZipPath = "$HOME\.apipatch\apipatch.zip"

Write-Host "Installing apipatch CLI for Windows..." -ForegroundColor Cyan

# 1. Detect architecture
$Arch = "x64"
if ([System.Environment]::Is64BitOperatingSystem -eq $false) {
    Write-Error "Unsupported architecture: 32-bit Windows is not supported."
    exit 1
}

# 2. Ensure install directory exists
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# 3. Download compressed zip archive (Fast & lightweight)
$DownloadUrl = "https://github.com/$Repo/releases/latest/download/apipatch-windows-$Arch.zip"

Write-Host "Downloading apipatch CLI package..." -ForegroundColor Gray
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath -UseBasicParsing

# 4. Extract executable & clean up zip
Write-Host "Extracting binary..." -ForegroundColor Gray
Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force
if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

# Ensure file name is apipatch.exe
$ExtractedFile = Join-Path $InstallDir "apipatch-windows-$Arch.exe"
if (Test-Path $ExtractedFile) {
    Move-Item -Path $ExtractedFile -Destination $ExePath -Force
}

# 5. Add to User PATH if not present
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    Write-Host "Adding $InstallDir to user PATH..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    $env:Path = "$env:Path;$InstallDir"
}

Write-Host ""
Write-Host "Successfully installed apipatch to: $ExePath" -ForegroundColor Green
Write-Host "Run 'apipatch --help' to get started." -ForegroundColor Cyan
