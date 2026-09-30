# Apipatch Windows Installer (PowerShell)
# Usage: irm https://apipatch.fix2ship.dev/install.ps1 | iex

$ErrorActionPreference = 'Stop'

$Repo = "SameerKhans13/web-apipatch"
$InstallDir = "$HOME\.apipatch\bin"
$ExePath = "$InstallDir\apipatch.exe"

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

# 3. Determine download URL
$DownloadUrl = "https://github.com/$Repo/releases/download/v1.0.0/apipatch-windows-$Arch.exe"

# 4. Download binary
Write-Host "Downloading apipatch CLI ($Arch)..." -ForegroundColor Gray
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $DownloadUrl -OutFile $ExePath -UseBasicParsing

# 5. Add to User PATH if not present
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    Write-Host "Adding $InstallDir to user PATH..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    $env:Path = "$env:Path;$InstallDir"
}

Write-Host "`n✓ apipatch successfully installed to $ExePath!" -ForegroundColor Green
Write-Host "Run 'apipatch --help' to get started." -ForegroundColor Cyan
