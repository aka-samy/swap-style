@echo off
set FLUTTER_ROOT=C:\flutter
set PATH=C:\flutter\bin\cache\dart-sdk\bin;C:\flutter\bin;%PATH%
cd /d C:\swapstyle\mobile
echo Creating Android platform files... > C:\swapstyle\mobile\flutter_create.log
dart.exe --packages="C:\flutter\packages\flutter_tools\.dart_tool\package_config.json" "C:\flutter\packages\flutter_tools\bin\flutter_tools.dart" create --platforms android --org com.swapstyle . >> C:\swapstyle\mobile\flutter_create.log 2>&1
echo EXIT=%ERRORLEVEL% >> C:\swapstyle\mobile\flutter_create.log
