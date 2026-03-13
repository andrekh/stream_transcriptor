import subprocess
import numpy as np
import os
import logging
from faster_whisper import WhisperModel
from google import genai
from google.genai import types

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logging.getLogger("google.genai").setLevel(logging.WARNING)
logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger('faster_whisper').setLevel(logging.WARNING)
logger = logging.getLogger(__name__)

GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY environment variable is required.")

MODEL_ID = "gemini-3.1-flash-lite-preview"
RTMP_URL = "rtmp://127.0.0.1/live/test"
BUFFER_LIMIT = 40

client = genai.Client(api_key=GEMINI_API_KEY)

transcript_buffer = []
logger.info("CORTEX: Loading Whisper (CPU/INT8)...")
try:
    whisper_model = WhisperModel("base.en", device="cpu", compute_type="int8")
except Exception as e:
    print(f"CORTEX: error loading Whisper model: {e}")
    exit(1)

def generate_summary(text_block):
    print("\n" + "="*50)
    print("CORTEX: REQUESTING CLOUD SUMMARY...")
    
    prompt = f"summarize this live audio transcript into 3 concise bullet points. No intro/outro.\n\nTranscript: {text_block}"
    
    try:
        response_stream = client.models.generate_content_stream(
            model=MODEL_ID,
            contents=prompt,
            config=types.GenerateContentConfig(
                system_instruction="you are a real-time data extraction engine. output raw bullet points only.",
                thinking_config=types.ThinkingConfig(thinking_level="MINIMAL")
            ),
        )
        
        print("SUMMARY:")
        for chunk in response_stream:
            if chunk.text:
                print(chunk.text, end="", flush=True)
        print("\n") 
    except Exception as e:
        logger.error(f"CORTEX: cloud error: {e}")
    
    print("="*50 + "\n")

def start_engine():
    cmd_str = f'ffmpeg -loglevel quiet -probesize 32 -analyzeduration 0 -i {RTMP_URL} -vn -f s16le -acodec pcm_s16le -ar 16000 -ac 1 -'
    process = subprocess.Popen(cmd_str, stdout=subprocess.PIPE, shell=True)
    
    logger.info(f"CORTEX: monitoring stream: {RTMP_URL}")
    
    try:
        while True:
            seconds = 7
            raw_audio = process.stdout.read(16000 * 2 * seconds)
            if not raw_audio:
                continue
            
            audio_np = np.frombuffer(raw_audio, dtype=np.int16).astype(np.float32) / 32768.0
            segments, _ = whisper_model.transcribe(audio_np, beam_size=1)
            
            for segment in segments:
                text = segment.text.strip()
                if text:
                    print(f"[LIVE] {text}")
                    transcript_buffer.append(text)
                    
                    if len(transcript_buffer) >= BUFFER_LIMIT:
                        full_context = " ".join(transcript_buffer)
                        generate_summary(full_context)
                        transcript_buffer.clear()
                        
    except KeyboardInterrupt:
        logger.info("CORTEX: shuting down...")
        process.terminate()

if __name__ == "__main__":
    start_engine()