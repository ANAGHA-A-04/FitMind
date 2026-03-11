@echo off
echo ================================================
echo   Adding Firewall Rules for FitMind Servers
echo ================================================
echo.
echo This will allow incoming connections on ports 5000 and 5001
echo.

netsh advfirewall firewall add rule name="FitMind Auth Backend" dir=in action=allow protocol=TCP localport=5000
netsh advfirewall firewall add rule name="FitMind Chatbot" dir=in action=allow protocol=TCP localport=5001

if errorlevel 1 (
    echo.
    echo ERROR: Failed to add firewall rules
    echo Please run this script as Administrator:
    echo 1. Right-click this file
    echo 2. Select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo ================================================
echo   SUCCESS! Firewall rules added.
echo ================================================
echo.
echo Now start both servers:
echo   1. Node.js Auth: node backend\server.js
echo   2. Python Chat:  python fitmind_chatbot\app.py
echo.
pause
