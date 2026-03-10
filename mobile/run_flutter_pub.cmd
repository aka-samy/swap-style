@echo off
setlocal enabledelayedexpansion

REM Set Flutter path
set PATH=C:\flutter\bin;C:\flutter\bin\cache\dart-sdk\bin;%PATH%

REM Run pub get with timeout
echo Running flutter pub get...
flutter pub get > flutter_pub_output.txt 2>&1
echo %errorlevel% > flutter_pub_exit_code.txt

echo Done
