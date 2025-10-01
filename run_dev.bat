@echo off
echo Starting development environment...

:: Start the proxy server in a new window
start "Proxy Server" cmd /k "dart run dev_proxy.dart"

:: Wait a moment for the proxy to start
timeout /t 2 /nobreak >nul

:: Start the Flutter web app in a new window
start "Flutter Web" cmd /k "flutter run -d chrome --web-port=3001"

echo Development environment started!
