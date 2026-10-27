@echo off
chcp 65001 >nul
cd /d "%~dp0"
if not exist node_modules call npm install
if errorlevel 1 pause & exit /b 1
call npx wrangler d1 execute aura-cloud-db --local --file=./schema.sql
if errorlevel 1 pause & exit /b 1
start "" "http://127.0.0.1:8787"
call npx wrangler dev --local
pause
