@echo off
REM Local SwapStyle setup without Docker
REM Requires: PostgreSQL installed locally, Node.js, Memurai files in workspace

setlocal EnableExtensions

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "API_DIR=%ROOT%\api"
set "POSTGRES_PATH=C:\Program Files\PostgreSQL\17\bin\psql.exe"
if not exist "%POSTGRES_PATH%" set "POSTGRES_PATH=C:\Program Files\PostgreSQL\16\bin\psql.exe"

set "MEMURAI_DIR=%ROOT%\Memurai-Developer-v4.1.2\SourceDir\Memurai"
if not exist "%MEMURAI_DIR%\memurai.exe" set "MEMURAI_DIR=%ROOT%\tools\memurai\extracted\SourceDir\Memurai"
set "MEMURAI_EXE=%MEMURAI_DIR%\memurai.exe"
set "MEMURAI_CLI=%MEMURAI_DIR%\memurai-cli.exe"

set "API_PORT=3001"
set "REDIS_PORT=6380"
set "PGPASSWORD=postgres"

echo ===========================================
echo SwapStyle Local Setup (No Docker)
echo ===========================================

for /f %%i in ('powershell -NoProfile -Command "$ip=(Get-NetIPAddress -AddressFamily IPv4 ^| Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254*' -and $_.PrefixOrigin -ne 'WellKnown' } ^| Select-Object -First 1 -ExpandProperty IPAddress); if($ip){$ip}"') do set "LAN_IP=%%i"
if "%LAN_IP%"=="" set "LAN_IP=127.0.0.1"

echo LAN IP: %LAN_IP%
echo API URL: http://%LAN_IP%:%API_PORT%/api/v1
echo Swagger: http://localhost:%API_PORT%/api
echo Redis port: %REDIS_PORT%
echo.

echo Checking PostgreSQL...
if not exist "%POSTGRES_PATH%" (
  echo ERROR: psql not found at expected locations.
  echo Checked:
  echo   C:\Program Files\PostgreSQL\17\bin\psql.exe
  echo   C:\Program Files\PostgreSQL\16\bin\psql.exe
  exit /b 1
)

"%POSTGRES_PATH%" -U postgres -c "SELECT 1;" >nul 2>&1
if errorlevel 1 (
  echo ERROR: PostgreSQL not found or not running.
  exit /b 1
)
echo OK: PostgreSQL is running

echo Creating swapstyle database if needed...
"%POSTGRES_PATH%" -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'swapstyle';" | findstr /C:"1" >nul
if errorlevel 1 (
  "%POSTGRES_PATH%" -U postgres -c "CREATE DATABASE swapstyle WITH ENCODING 'UTF8';"
  echo OK: Created swapstyle database
) else (
  echo OK: swapstyle database already exists
)

echo Enabling PostGIS extension...
"%POSTGRES_PATH%" -U postgres -d swapstyle -c "CREATE EXTENSION IF NOT EXISTS postgis;" >nul 2>&1
"%POSTGRES_PATH%" -U postgres -d swapstyle -tc "SELECT 1 FROM pg_extension WHERE extname = 'postgis';" | findstr /C:"1" >nul
if errorlevel 1 (
  echo WARNING: PostGIS extension is not installed on this system.
  echo WARNING: Discovery will use fallback distance mode.
) else (
  echo OK: PostGIS extension enabled
)

echo Checking Redis-compatible runtime on %REDIS_PORT%...
set "REDIS_PID="
for /f %%p in ('powershell -NoProfile -Command "$p=(Get-NetTCPConnection -State Listen -LocalPort %REDIS_PORT% -ErrorAction SilentlyContinue ^| Select-Object -First 1 -ExpandProperty OwningProcess); if($p){$p}"') do set "REDIS_PID=%%p"

if defined REDIS_PID (
  echo OK: Redis-compatible runtime already running (PID %REDIS_PID%)
) else (
  if not exist "%MEMURAI_EXE%" (
    echo ERROR: Memurai executable not found.
    echo Expected: %MEMURAI_EXE%
    exit /b 1
  )

  echo Starting Memurai on port %REDIS_PORT%...
  start "SwapStyle Memurai" /MIN "%MEMURAI_EXE%" --port %REDIS_PORT%
)

if exist "%MEMURAI_CLI%" (
  set "PING_OK=0"
  for /L %%n in (1,1,5) do (
    "%MEMURAI_CLI%" -p %REDIS_PORT% ping >nul 2>&1
    if not errorlevel 1 set "PING_OK=1"
    timeout /t 1 /nobreak >nul
  )

  if "%PING_OK%"=="0" (
    echo ERROR: Memurai did not respond to ping on port %REDIS_PORT%.
    exit /b 1
  )
  echo OK: Memurai responds to ping
) else (
  echo WARNING: memurai-cli.exe not found, skipping ping check.
)

cd /d "%API_DIR%"
echo.
echo Running Prisma migrations...
call npx prisma migrate deploy
if errorlevel 1 (
  echo ERROR: Prisma migration failed.
  exit /b 1
)
echo OK: Prisma migrations complete

echo.
echo ===========================================
echo Starting NestJS API on 0.0.0.0:%API_PORT%
echo ===========================================
echo.

npm run start:dev

endlocal
