@echo off
set FLUTTER_ROOT=C:\flutter
set ANDROID_HOME=C:\Android\Sdk
set ANDROID_SDK_ROOT=C:\Android\Sdk
set JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.18.8-hotspot
set PATH=C:\flutter\bin\cache\dart-sdk\bin;%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%PATH%
cd /d C:\swapstyle\mobile
echo Building debug APK... > C:\swapstyle\mobile\build_apk.log
echo Environment: ANDROID_HOME=%ANDROID_HOME% JAVA_HOME=%JAVA_HOME% >> C:\swapstyle\mobile\build_apk.log
dart.exe --packages="C:\flutter\packages\flutter_tools\.dart_tool\package_config.json" "C:\flutter\packages\flutter_tools\bin\flutter_tools.dart" build apk --debug >> C:\swapstyle\mobile\build_apk.log 2>&1
echo EXIT=%ERRORLEVEL% >> C:\swapstyle\mobile\build_apk.log
