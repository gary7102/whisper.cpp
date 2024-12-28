#!/usr/bin/env bash

# 0) rm old .wav and .txt
# rm transcript.wav
# rm transcript.wav.txt

# 1) 錄音：按下空白鍵或 Ctrl+C 手動中斷
echo "開始錄音... (按 Ctrl+C 或空白鍵中斷)"
arecord -D hw:3,0 -f S16_LE -c 1 -r 16000 transcript.wav

# 2) (可選) 若需要轉成單聲道 16kHz
# ffmpeg -i transcript.wav -ac 1 -ar 16000 transcript.wav
# 如果已經是單聲道/16kHz，可跳過此步

# 3) Whisper.cpp 語音轉文字
./build/bin/main \
  -m ./models/ggml-tiny.bin \
  -f transcript.wav \
  -otxt --no-timestamps

TRANSCRIPT=$(cat transcript.wav.txt)
echo "轉寫結果：$TRANSCRIPT"

# 4) 呼叫 LM Studio API
#   以 chat 形式提交
#   注意：如果是 /v1/completions endpoint，請改用 OpenAI Completions 格式
#         如果是 /v1/chat/completions endpoint，則用 ChatCompletion 格式
#   下例以 ChatCompletion 為範例
RESPONSE=$(curl -s -X POST http://192.168.50.196:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "causallm-14b",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "'"$TRANSCRIPT"'"}
    ]
  }')

# 解析回傳 JSON，取得助手回覆的文字
ASSISTANT_REPLY=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')
echo "模型回應：$ASSISTANT_REPLY"

# 5) (選擇性) 用 TTS 工具讀出聲音
#    例如 espeak:
espeak "$ASSISTANT_REPLY"

