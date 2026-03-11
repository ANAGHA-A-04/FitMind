@echo off
echo ================================================
echo    FitMind Chatbot Server - Quick Start
echo ================================================
echo.

cd fitmind_chatbot

echo [1/3] Checking Python installation...
python --version
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.7+ from https://www.python.org/
    pause
    exit /b 1
)
echo.

echo [2/3] Installing dependencies...
echo This may take a minute on first run...
pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo.

echo [3/3] Training chatbot model...
python train_model.py
if errorlevel 1 (
    echo ERROR: Failed to train model
    pause
    exit /b 1
)
echo.

echo ================================================
echo    Starting FitMind Chatbot Server...
echo ================================================
echo.
echo Server will run on: http://0.0.0.0:5000
echo.
echo IMPORTANT: Find your IP address with 'ipconfig'
echo            Update it in: lib/services/chatbot_service.dart
echo.
echo Press Ctrl+C to stop the server
echo ================================================
echo.

python app.py
