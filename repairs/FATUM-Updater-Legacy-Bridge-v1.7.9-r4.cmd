@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "OUTER_ROOT=%~dp0"
if "%OUTER_ROOT:~-1%"=="\" set "OUTER_ROOT=%OUTER_ROOT:~0,-1%"

set "INSTALL_ROOT="
if exist "%OUTER_ROOT%\FATUM.exe" set "INSTALL_ROOT=%OUTER_ROOT%"
if not defined INSTALL_ROOT if exist "%OUTER_ROOT%\FATUM Desktop\FATUM.exe" set "INSTALL_ROOT=%OUTER_ROOT%\FATUM Desktop"

if not defined INSTALL_ROOT (
  echo [FATUM] FATUM.exe was not found.
  echo Put this file next to UPDATE_FATUM.cmd in the main FATUM folder and run it again.
  echo.
  pause
  exit /b 2
)

set "FATUM_EXE=%INSTALL_ROOT%\FATUM.exe"
set "UPDATER_JS=%INSTALL_ROOT%\updater\update.js"
if not exist "%UPDATER_JS%" set "UPDATER_JS=%INSTALL_ROOT%\resources\app\updater\update.js"

if not exist "%UPDATER_JS%" (
  echo [FATUM] updater\update.js was not found.
  echo Expected near: "%INSTALL_ROOT%"
  echo.
  pause
  exit /b 3
)

rem Repair the public wrapper too. This script is intentionally a valid permanent wrapper:
rem it forwards all arguments and forces consent for explicit UPDATE_FATUM launches.
if /I not "%~nx0"=="UPDATE_FATUM.cmd" (
  copy /Y "%~f0" "%OUTER_ROOT%\UPDATE_FATUM.cmd" >nul
  if errorlevel 1 (
    echo [FATUM] Warning: could not replace UPDATE_FATUM.cmd.
    echo The update can still continue from this repair file.
  ) else (
    echo [FATUM] UPDATE_FATUM.cmd repaired.
  )
  echo.
)

set "ELECTRON_RUN_AS_NODE=1"
"%FATUM_EXE%" "%UPDATER_JS%" --yes %*
set "RC=%ERRORLEVEL%"

if not "%RC%"=="0" (
  echo.
  echo FATUM updater failed with error code %RC%.
) else (
  echo.
  echo FATUM updater finished successfully.
)

pause
exit /b %RC%
