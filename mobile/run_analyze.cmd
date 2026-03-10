@echo off
set FLUTTER_ROOT=C:\flutter
set PATH=C:\flutter\bin\cache\dart-sdk\bin;%PATH%
cd /d C:\swapstyle\mobile
echo Running dart analyze... > C:\swapstyle\mobile\analyze.log
dart.exe --packages="C:\flutter\packages\flutter_tools\.dart_tool\package_config.json" "C:\flutter\packages\flutter_tools\bin\flutter_tools.dart" analyze >> C:\swapstyle\mobile\analyze.log 2>&1
echo EXIT=%ERRORLEVEL% >> C:\swapstyle\mobile\analyze.log
