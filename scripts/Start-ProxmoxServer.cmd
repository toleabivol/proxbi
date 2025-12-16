@echo off
REM Launches the Start-ProxmoxServer PowerShell script while bypassing execution policy checks.
REM This is useful on systems where unsigned scripts are blocked by default.

setlocal
set "SCRIPT_DIR=%~dp0"

where pwsh.exe >NUL 2>&1
if errorlevel 1 (
    echo [ERROR] PowerShell 7 (pwsh.exe) is required but was not found in PATH.
    echo Install it from https://aka.ms/pscore6 and then re-run this shortcut.
    exit /b 1
)

set "POWERSHELL_EXE=pwsh.exe"

"%POWERSHELL_EXE%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Start-ProxmoxServer.ps1" %*
endlocal
