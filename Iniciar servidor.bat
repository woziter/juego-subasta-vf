@echo off
setlocal
cd /d "%~dp0"

where node.exe >nul 2>nul
if errorlevel 1 (
  echo No se encontro Node.js. Instala Node.js 18 o posterior y volve a intentarlo.
  pause
  exit /b 1
)

if not exist "node_modules\express\package.json" (
  echo Faltan dependencias. Ejecuta "Instalar dependencias.bat" primero.
  pause
  exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\crear-certificado-local.ps1"
if errorlevel 1 (
  pause
  exit /b 1
)

set HTTPS_ENABLED=true
set "HTTPS_KEY_PATH=%~dp0.certificates\lan-server-key.pem"
set "HTTPS_CERT_PATH=%~dp0.certificates\lan-server-cert.pem"
node backend/server.js
if errorlevel 1 pause
