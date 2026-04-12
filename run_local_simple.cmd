@echo off
REM Local SwapStyle setup without Docker
REM Requires: PostgreSQL 16 installed locally, Node.js

setlocal

set "ROOT=C:\swapstyle"
set "POSTGRES_PATH=C:\Program Files\PostgreSQL\17\bin\psql.exe"

echo ===========================================
echo SwapStyle Local Setup (No Docker)
echo ===========================================

REM Detect LAN IP
for /f %%i in ('powershell -NoProfile -Command "$ip=(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254*' -and $_.PrefixOrigin -ne 'WellKnown' } | Select-Object -First 1 -ExpandProperty IPAddress); if($ip){$ip}"') do set "LAN_IP=%%i"
if "%LAN_IP%"=="" set "LAN_IP=127.0.0.1"

REM Set PostgreSQL password for non-interactive access
set "PGPASSWORD=postgres"

echo LAN IP: %LAN_IP%
echo API will be at: http://%LAN_IP%:3000/api/v1
echo.

REM Check PostgreSQL
echo Checking PostgreSQL...
"%POSTGRES_PATH%" -U postgres -c "SELECT 1;" >nul 2>&1
if errorlevel 1 (
  echo ERROR: PostgreSQL not found or not running
  echo.
  echo Fix: Install PostgreSQL 16 from https://www.postgresql.org/download/windows/
  echo    Or use: choco install postgresql14 (if you have chocolatey)
  exit /b 1
)
echo ✓ PostgreSQL is running

REM Create database if not exists
echo Creating swapstyle database if needed...
"%POSTGRES_PATH%" -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'swapstyle';" | findstr /C:"1" >nul
if errorlevel 1 (
  "%POSTGRES_PATH%" -U postgres -c "CREATE DATABASE swapstyle WITH ENCODING 'UTF8';"
  echo ✓ Created swapstyle database
) else (
  echo ✓ swapstyle database already exists
)

REM Install PostGIS extension
echo Installing PostGIS extension...
"%POSTGRES_PATH%" -U postgres -d swapstyle -c "CREATE EXTENSION IF NOT EXISTS postgis;" 2>nul
echo ✓ PostGIS extension enabled

REM Start Redis if available (optional)
echo.
echo Note: Redis is optional. If not installed, app will use in-memory cache.
echo Attempting to start Redis...
tasklist | findstr /I "redis-server" >nul
if errorlevel 1 (
  echo ℹ Redis not running (OK - app will use fallback)
) else (
  echo ✓ Redis is running
)

REM Run migrations
cd /d %ROOT%\api
echo.
echo Running Prisma migrations...
call npx prisma migrate deploy
if errorlevel 1 (
  echo ERROR: Migration failed. Check database connection.
  exit /b 1
)
echo ✓ Migrations complete

REM Start API
echo.
echo ===========================================
echo Starting NestJS API on 0.0.0.0:3000
echo ===========================================
echo.
npm run start:dev

endlocal
