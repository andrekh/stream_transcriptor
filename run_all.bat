@echo off
setlocal
set "SCRIPT_DIR=%~dp0"

echo starting RTMP server...
start "INFLOW SERVER" cmd /k "cd /d %SCRIPT_DIR%inflow && node server.js"
timeout /t 3 /nobreak > nul

echo starting cortex...
start "CORTEX AI" cmd /k "cd /d %SCRIPT_DIR%cortex && venv\Scripts\activate && py main.py"
timeout /t 5 /nobreak > nul

echo starting MP3 stream to RTMP server...
set /p YOUTUBE_URL="Enter a YouTube URL: "
for /f "delims=" %%i in ('yt-dlp -f bestaudio --get-url "%YOUTUBE_URL%"') do set AUDIO_URL=%%i
start "FFMPEG STREAMER" cmd /k "ffmpeg -re -i "%AUDIO_URL%" -vn -c:a aac -b:a 128k -f flv rtmp://localhost/live/test"

echo all systems launched.
pause