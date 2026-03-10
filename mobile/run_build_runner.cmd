@echo off
set FLUTTER_ROOT=C:\flutter
set PATH=C:\flutter\bin\cache\dart-sdk\bin;%PATH%
cd /d C:\swapstyle\mobile
echo Starting build_runner... > C:\swapstyle\mobile\build_runner.log
dart.exe --packages="C:\flutter\packages\flutter_tools\.dart_tool\package_config.json" "C:\flutter\packages\flutter_tools\bin\flutter_tools.dart" pub run build_runner build --delete-conflicting-outputs >> C:\swapstyle\mobile\build_runner.log 2>&1
echo EXIT=%ERRORLEVEL% >> C:\swapstyle\mobile\build_runner.log
