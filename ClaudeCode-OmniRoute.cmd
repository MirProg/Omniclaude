@echo off
title Claude Code x OmniRoute
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ClaudeCode-OmniRoute.ps1"
echo.
echo Batch file finished. Check launcher.log for errors.
pause
