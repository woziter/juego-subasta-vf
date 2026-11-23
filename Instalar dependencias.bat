@echo off
setlocal
cd /d "%~dp0"

where node.exe >nul 2>nul
if errorlevel 1 (
  echo No se encontro Node.js. Instala Node.js 18 o posterior y volve a intentarlo.
  pause
  exit /b 1
)

where npm.cmd >nul 2>nul
if errorlevel 1 (
  echo No se encontro npm. Reinstala Node.js con npm incluido y volve a intentarlo.
  pause
  exit /b 1
)

call npm.cmd install
if errorlevel 1 (
  echo No se pudieron instalar las dependencias.
  pause
  exit /b 1
)

echo Dependencias instaladas correctamente.
pause
