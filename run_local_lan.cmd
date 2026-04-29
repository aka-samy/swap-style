@echo off
setlocal

set "ROOT=C:\swapstyle"

for /f %%i in ('powershell -NoProfile -Command "$ip=(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254*' -and $_.PrefixOrigin -ne 'WellKnown' } | Select-Object -First 1 -ExpandProperty IPAddress); if($ip){$ip}"') do set "LAN_IP=%%i"
if "%LAN_IP%"=="" set "LAN_IP=127.0.0.1"

echo ===========================================
echo SwapStyle local LAN mode
echo API URL for devices: http://%LAN_IP%:3001/api/v1
echo ===========================================

cd /d %ROOT%
echo Starting Postgres and Redis (docker compose)...
docker compose up -d postgres redis
if errorlevel 1 (
  echo Docker compose failed. If you use local services, continue.
)

cd /d %ROOT%\api
echo Running prisma migrate deploy...
npx prisma migrate deploy
if errorlevel 1 (
  echo Prisma migration failed. Fix DB first, then rerun this script.
  exit /b 1
)

echo Starting API on 0.0.0.0:3001...
npm run start:dev

endlocal
