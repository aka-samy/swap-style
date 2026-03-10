@echo off
cd /d C:\swapstyle\mobile
set PATH=C:\flutter\bin;%PATH%
echo Running flutter pub get... > C:\swapstyle\mobile\flutter_run.log
call flutter.bat pub get >> C:\swapstyle\mobile\flutter_run.log 2>&1
echo EXIT_CODE=%ERRORLEVEL% >> C:\swapstyle\mobile\flutter_run.log
if exist C:\swapstyle\mobile\pubspec.lock (
    echo PUBSPEC_LOCK=YES >> C:\swapstyle\mobile\flutter_run.log
) else (
    echo PUBSPEC_LOCK=NO >> C:\swapstyle\mobile\flutter_run.log
)
echo DONE >> C:\swapstyle\mobile\flutter_run.log
