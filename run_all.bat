@echo off
setlocal enabledelayedexpansion
set "script_dir=%~dp0"

echo starting rtmp server...
start "inflow server" cmd /k "cd /d %script_dir%inflow && node server.js"
timeout /t 3 /nobreak > nul

echo starting cortex...
start "cortex ai" cmd /k "cd /d %script_dir%cortex && venv\scripts\activate && py main.py"
timeout /t 5 /nobreak > nul

echo.
set /p youtube_url="enter a youtube url: "

echo fetching audio url (please wait)...
for /f "delims=" %%i in ('yt-dlp --js-runtime node -f bestaudio -g "%youtube_url%"') do set "audio_url=%%i"

if not defined audio_url (
    echo [error] could not fetch audio url. make sure node.js and yt-dlp are updated.
    pause
    exit /b
)

echo.
echo starting mp3 stream to rtmp server...
start "ffmpeg streamer" cmd /k "ffmpeg -re -user_agent "mozilla/5.0" -i "!audio_url!" -vn -c:a aac -b:a 128k -f flv rtmp://localhost/live/test"

echo all systems launched.
pause