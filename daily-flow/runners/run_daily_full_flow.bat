@echo off
setlocal
cd /d "%~dp0"

rem Cumartesi 22:00 ana akisini atla: Cumartesi tam akis 23:59'da calisir
rem (run_daily_diyarbakir_results.bat -> --saturday-full --site-upload).
rem Manuel cagri (%1 dolu) ise atlanmaz.
set "DOW="
for /f %%i in ('powershell -NoProfile -Command "(Get-Date).DayOfWeek"') do set "DOW=%%i"
if /i "%DOW%"=="Saturday" if "%~1"=="" (
  echo Cumartesi: 22:00 ana akis atlandi, 23:59 tam akisi beklenecek.
  exit /b 0
)

set "PYEXE=C:\Users\Monster\AppData\Local\Programs\Python\Python313\python.exe"
if exist "C:\Users\Monster\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe" (
  set "PYEXE=C:\Users\Monster\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
)
if exist "%PYEXE%" (
  "%PYEXE%" run_daily_full_flow.py %*
) else (
  py -3 run_daily_full_flow.py %*
)

endlocal