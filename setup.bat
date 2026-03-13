@echo off
setlocal enabledelayedexpansion

echo checking for python...
py --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=py"
) else (
    python --version >nul 2>&1
    if %errorlevel% equ 0 (
        set "PYTHON_CMD=python"
    ) else (
        echo error: python is not installed or not in PATH. please install python.
        pause
        exit /b 1
    )
)

for /f "delims=" %%i in ('%PYTHON_CMD% -c "import sys; print(sys.executable)"') do set "PYTHON_CMD=%%i"

echo checking for node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo error: node.js is not installed or not in PATH.
    echo install nodejs from https://nodejs.org/
    pause & exit /b 1
)

echo setting up python venv and installing dependencies...
cd cortex
"%PYTHON_CMD%" -m venv venv
set "VENV_PYTHON=venv\Scripts\python.exe"
%VENV_PYTHON% -m pip install --upgrade pip >nul 2>&1
%VENV_PYTHON% -m pip install -r requirements.txt
cd ..

echo setting up node.js dependencies...
if exist "inflow" (
    cd inflow
    call npm install
    cd ..
)

echo downloading yt-dlp for youtube streaming...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' -OutFile 'yt-dlp.exe'"

echo setup complete!
pause