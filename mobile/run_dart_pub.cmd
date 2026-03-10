@echo off
set FLUTTER_ROOT=C:\flutter
set PATH=C:\flutter\bin\cache\dart-sdk\bin;%PATH%
cd /d C:\swapstyle\mobile
echo Starting dart pub get via flutter_tools... > C:\swapstyle\mobile\dart_direct.log
dart.exe --packages="C:\flutter\packages\flutter_tools\.dart_tool\package_config.json" "C:\flutter\packages\flutter_tools\bin\flutter_tools.dart" pub get >> C:\swapstyle\mobile\dart_direct.log 2>&1
echo EXIT=%ERRORLEVEL% >> C:\swapstyle\mobile\dart_direct.log
if exist pubspec.lock (echo LOCK=YES >> C:\swapstyle\mobile\dart_direct.log) else (echo LOCK=NO >> C:\swapstyle\mobile\dart_direct.log)
