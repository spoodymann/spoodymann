@echo off
setlocal
cd /d "%~dp0"
if not exist logs mkdir logs

rem 23:59 CUMARTESI TAM AKISI:
rem Diyarbakir sonuclari 22:00'de hazir olmadigi icin ana akis 23:59'a alindi.
rem Bu gorev TUM sehirleri (Diyarbakir dahil) isler, yarinin raporlarini uretir,
rem kilit yaris + istatistik+galop hattini calistirir ve EN SON siteyi yukler
rem (site-yukle-22-30.ps1 -Force; tum taze raporlar siteye ciksin diye
rem  site yuklemesi en sonda yapilir).
rem Diyarbakir sonuclari gecikirse 40 dk bekleyip yeniden dener (run_daily_full_flow.py).
rem NOT: 22:00 gunluk ana akis (run_daily_full_flow.bat) Cumartesi atlanir.

rem Istatistik hedefi: bu an yarin olan yaris gunu (23:59'da cumartesi -> pazar).
rem Zincir gece yarisini gecerse varsayilan "yarin" kaymasin diye acikca verilir.
set "IST_TARIH="
for /f %%i in ('powershell -NoProfile -Command "(Get-Date).AddDays(1).ToString('yyyyMMdd')"') do set "IST_TARIH=%%i"
set "IST_ISO="
for /f %%i in ('powershell -NoProfile -Command "(Get-Date).AddDays(1).ToString('yyyy-MM-dd')"') do set "IST_ISO=%%i"

set "PYEXE=C:\Users\Monster\AppData\Local\Programs\Python\Python313\python.exe"
if exist "C:\Users\Monster\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe" (
  set "PYEXE=C:\Users\Monster\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
)

set "RC=0"

rem 1) Sonuclar + yarinin raporlari (site yuklemesi YOK - en sonda yapilacak)
if exist "%PYEXE%" (
  "%PYEXE%" run_daily_full_flow.py --saturday-full >> logs\daily_diyarbakir.log 2>&1
) else (
  python run_daily_full_flow.py --saturday-full >> logs\daily_diyarbakir.log 2>&1
)
if errorlevel 1 set "RC=1"

rem 2) Kilit yaris (yarinin programi artik hazir)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Monster\Documents\Codex\kilit_yaris_projesi\run_daily_kilit_yaris_after_beyer.ps1" -Zorla -Tarih "%IST_ISO%" >> logs\daily_diyarbakir.log 2>&1
if errorlevel 1 set "RC=1"

rem 3) Istatistik + galop (bugunun sonuclari artik DB'de)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Monster\Documents\Codex\istatistik_projesi\run_daily_pipeline_serialized.ps1" -CumartesiZorla -Tarih "%IST_TARIH%" >> logs\daily_diyarbakir.log 2>&1
if errorlevel 1 set "RC=1"

rem 4) Site yukleme (kilit + istatistik dahil tum taze raporlar)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Monster\OneDrive\Belgeler\GitHub\spoodyman\scripts\site-yukle-22-30.ps1" -Force >> logs\daily_diyarbakir.log 2>&1
if errorlevel 1 set "RC=1"

exit /b %RC%
