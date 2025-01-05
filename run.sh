#!/usr/bin/env bash

# 0) 刪除transcript.wav , transcript.wav.txt
#rm transcript.wav
#rm transcript.wav.txt

# 1) 錄音：按下空白鍵或 Ctrl+C 手動中斷
echo "開始錄音... (按 Ctrl+C 結束)"
arecord -D hw:3,0 -f S16_LE -c 1 -r 16000 transcript.wav

# 2) (可選) 若需要轉成單聲道 16kHz
echo "開始轉檔成channel 1 且 sample rate 16Khz"
#ffmpeg -i transcript_before.wav -ac 1 -ar 16000 test_mono.wav
# 如果已經是單聲道/16kHz，可跳過此步

# 3) Whisper.cpp 語音轉文字
#  -otxt 會將transcript.wav的內容寫入transcript.wav.txt
echo "語音轉換為文字：..."
./build/bin/main \
  -m ./models/ggml-tiny.bin \
  -f transcript.wav -l zh  \
  -otxt --no-timestamps


TRANSCRIPT=$(cat transcript.wav.txt)
# echo "Input ：$TRANSCRIPT"
echo

# 4) 呼叫 LM Studio API
#   以 chat 形式提交
#   注意：如果是 /v1/completions endpoint，請改用 OpenAI Completions 格式
#         如果是 /v1/chat/completions endpoint，則用 ChatCompletion 格式
#   下例以 ChatCompletion 為範例
#   curl -s : 為隱藏傳輸進度，可以刪掉-s 來看進度條
#   POST http://........ 為 lm studio 之 server ip + api

curl -sN -X POST http://172.20.10.8:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "causallm-14b",
    "messages": [
      {"role": "system", "content": "You are a extremely smart answer chatbox"},
      {"role": "user", "content": "'"$TRANSCRIPT"'"}
    ],
    "temperature":0.7,
    "max_tokens":100,
    "stream":true
    }' |

# 5) 處理stream 回傳的json 資料

while IFS= read -r line; do

    # 如果遇到 [DONE] 表示串流結束
    if [[ "$line" == "data: [DONE]" ]]; then
      echo
      echo "=== (DONE) ==="
      echo
      break
    fi

    # 去掉 SSE 前綴 "data: "
    chunk=$(echo "$line" | sed 's/^data: //')

    # 用 jq 抓取每個 chunk 的 content (若沒有則給空字串)
    content=$(echo "$chunk" | jq -r '.choices[0].delta.content // empty')

    # -n 表示不自動換行，讓所有內容即時接續在同一行
    echo -n "$content"
done

