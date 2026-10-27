@echo off
chcp 65001 >nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\DEPLOY_WINDOWS.ps1"
if errorlevel 1 echo Falha no deploy. O Worker anterior permanece publicado se a etapa de deploy nao concluiu.
pause
