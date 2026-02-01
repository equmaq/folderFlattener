@echo off
setlocal

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This installer requires administrative privileges.
    echo Please run as administrator.
    pause
    exit /b
)
if not exist "C:\Program Files\folderFlattener" mkdir "C:\Program Files\folderFlattener"
copy "%~dp0flatten.ico" "C:\Program Files\folderFlattener\flatten.ico"
copy "%~dp0main.ps1" "C:\Program Files\folderFlattener\main.ps1"
copy "%~dp0uninstall.bat" "C:\Program Files\folderFlattener\uninstall.bat"
copy "%~dp0undoregconf.reg" "C:\Program Files\folderFlattener\undoregconf.reg"

regedit.exe /s "%~dp0regconf.reg"

taskkill /f /im explorer.exe
start explorer.exe

