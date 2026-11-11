@echo off
setlocal
cd /d "%~dp0"
dart tool\check_env.dart %*
exit /b %ERRORLEVEL%
