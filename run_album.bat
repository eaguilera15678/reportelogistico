@echo off
cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -File ".\run_album.ps1"
pause
