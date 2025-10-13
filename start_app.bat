@echo off
echo ====================================
echo  Ocean Pet - Auto Start Script
echo ====================================
echo.

REM Kiểm tra xem backend đã chạy chưa
echo Checking if backend is already running...
netstat -ano | findstr ":3000" >nul
if %errorlevel% equ 0 (
    echo Backend is already running on port 3000
) else (
    echo Starting Node.js backend...
    start "Ocean Pet Backend" cmd /k "cd /d %~dp0 && node lib/backend/server.js"
    timeout /t 3 /nobreak >nul
    echo Backend started!
)

echo.
echo Starting Flutter app...
flutter run

pause
