@echo off
setlocal

set "LAN_IP=%~1"
if "%LAN_IP%"=="" (
  for /f %%i in ('powershell -NoProfile -Command "$ip=(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254*' -and $_.PrefixOrigin -ne 'WellKnown' } | Select-Object -First 1 -ExpandProperty IPAddress); if($ip){$ip}"') do set "LAN_IP=%%i"
)

if "%LAN_IP%"=="" (
  echo Could not detect LAN IPv4. Pass it manually:
  echo   run_build_apk_lan.cmd 192.168.1.23
  exit /b 1
)

echo Detected LAN IP: %LAN_IP%
set "API_BASE_URL=http://%LAN_IP%:3000/api/v1"
echo Building APK with API_BASE_URL=%API_BASE_URL%
call C:\swapstyle\mobile\run_build_apk.cmd %API_BASE_URL%

endlocal
