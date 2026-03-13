# Stream Transcriptor

This project transcribes live YouTube videos in real time. 
Youtube audio feed is streamed with ffmpeg to a local RTMP server.
The audio samples are given to faster_whisper for transcription.
Additionnally, Gemini is used to make periodic summaries of the transcription using the Google GenAI API.

## How it works

1. Run setup.bat to install everything.
2. Run run_all.bat to start the system, it will prompt you for a youtube URL.
3. ffmpeg streams the audio from youtube to the local running RTMP server.
4. Cortex reads the audio from RTMP.
5. faster_whisper transcribes the audio to text.
6. when enough text is collected, Gemini makes a summary.

## Installation

1. Checkout the repository.
2. Run setup.bat. It sets up Python venv, installs dependencies, downloads yt-dlp, sets up node.js.
3. Set GEMINI_API_KEY in environment variables.