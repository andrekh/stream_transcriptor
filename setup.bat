@echo off

echo checking for python...
python --version >nul 2>&1
if errorlevel 1 (
    echo error: python is not installed or not in PATH. please install python.
    pause
    exit /b 1
)

echo checking for node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo error: node.js is not installed or not in PATH.
    echo install nodejs from https://nodejs.org/
    pause
    exit /b 1
)

echo setting up python venv and installing dependencies...
cd cortex
python -m venv venv
call venv\Scripts\activate
pip install -r requirements.txt
cd ..

echo setting up node.js dependencies...
cd inflow
npm install
cd ..

echo downloading yt-dlp for YouTube streaming...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' -OutFile 'yt-dlp.exe'"

echo setup complete!
pause