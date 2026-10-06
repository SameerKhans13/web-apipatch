@echo off
setlocal enabledelayedexpansion

echo Installing apipatch CLI for Windows...

set "REPO=SameerKhans13/web-apipatch"
set "INSTALL_DIR=%USERPROFILE%\.apipatch\bin"
set "EXE_PATH=%INSTALL_DIR%\apipatch.exe"
set "ZIP_PATH=%USERPROFILE%\.apipatch\apipatch.zip"

:: 1. Ensure install directory exists
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: 2. Download compressed zip package
echo Downloading apipatch CLI package...
curl -fsSL "https://github.com/%REPO%/releases/latest/download/apipatch-windows-x64.zip" -o "%ZIP_PATH%"
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to download package.
    exit /b 1
)

:: 3. Extract binary via tar (built into Windows 10/11) or PowerShell fallback
echo Extracting binary...
tar -xf "%ZIP_PATH%" -C "%INSTALL_DIR%" >nul 2>&1
if not exist "%INSTALL_DIR%\apipatch-windows-x64.exe" (
    powershell -NoProfile -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%INSTALL_DIR%' -Force" >nul 2>&1
)

if exist "%INSTALL_DIR%\apipatch-windows-x64.exe" (
    move /y "%INSTALL_DIR%\apipatch-windows-x64.exe" "%EXE_PATH%" >nul
)

if exist "%ZIP_PATH%" del /f /q "%ZIP_PATH%" >nul

:: 4. Add to User PATH if not present
echo %PATH% | findstr /i /c:"%INSTALL_DIR%" >nul
if %ERRORLEVEL% neq 0 (
    echo Adding %INSTALL_DIR% to user PATH...
    for /f "tokens=2*" %%a in ('reg query HKCU\Environment /v Path 2^>nul') do set "USER_PATH=%%b"
    if defined USER_PATH (
        setx Path "!USER_PATH!;%INSTALL_DIR%" >nul
    ) else (
        setx Path "%INSTALL_DIR%" >nul
    )
    set "PATH=%PATH%;%INSTALL_DIR%"
)

echo.
echo Successfully installed apipatch to: %EXE_PATH%
echo Run 'apipatch --help' to get started.
