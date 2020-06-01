@ECHO OFF
cd %~dp0
powershell -ExecutionPolicy Bypass -File ReplaceFiles.ps1
pause