@echo off
echo ================================================
echo     Starting FitMind Backend Servers
echo ================================================
echo.
echo Port 5000: Node.js Auth Backend (login/register)
echo Port 5001: Python Chatbot (AI chat)
echo.
echo Press Ctrl+C to stop servers
echo ================================================
echo.

start "FitMind Auth Backend" cmd /k "cd backend && node server.js"
timeout /t 2 /nobreak >nul

start "FitMind Chatbot" cmd /k "cd fitmind_chatbot && python app.py"
timeout /t 2 /nobreak >nul

start "FitMind Wellness Model" cmd /k "cd wellness_model && python app.py"

echo.
echo Both servers are starting in separate windows...
echo.
pause
