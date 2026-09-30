# Apipatch Windows Installer (PowerShell)
# Usage: irm https://apipatch.fix2ship.dev/install.ps1 | iex

$ErrorActionPreference = 'Stop'

$Repo = "fix2ship/apipatch"
$InstallDir = Join-Path $HOME ".apipatch\bin"
$ExePath = Join-Path $InstallDir "apipatch.exe"

Write-Host "Installing apipatch CLI for Windows..." -ForegroundColor Cyan

# 1. Detect architecture
$Arch = if ([System.Environment]::Is64BitOperatingSystem) {
    if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq [System.Runtime.InteropServices.Architecture]::Arm64) {
        "arm64"
    } else {
        "x64"
    }
} else {
    Write-Error "Unsupported architecture: 32-bit Windows is not supported."
    exit 1
}

# 2. Ensure install directory exists
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# 3. Determine the latest release download URL
try {
    $ReleaseApi = "https://api.github.com/repos/$Repo/releases/latest"
    $Headers = @{ "User-Agent" = "apipatch-installer" }
    $ReleaseInfo = Invoke-RestMethod -Uri $ReleaseApi -Headers $Headers
    $Asset = $ReleaseInfo.assets | Where-Object { $_.name -like "apipatch-windows-$Arch*.exe" } | Select-Object -First 1

    if ($Asset) {
        $DownloadUrl = $Asset.browser_download_url
    } else {
        $Tag = $ReleaseInfo.tag_name
        $DownloadUrl = "https://github.com/$Repo/releases/download/$Tag/apipatch-windows-$Arch.exe"
    }
} catch {
    Write-Warning "Could not query GitHub API, falling back to latest release direct URL..."
    $DownloadUrl = "https://github.com/$Repo/releases/latest/download/apipatch-windows-$Arch.exe"
}

# 4. Download executable
Write-Host "Downloading $DownloadUrl..." -ForegroundColor Gray
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
