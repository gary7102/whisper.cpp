#!/bin/bash

echo "請按空白鍵開始說話，完成後再次按空白鍵結束錄音。"
read -n 1

arecord -D hw:3,0 -f S16_LE -c 1 -r 16000 user_input.wav
echo "錄音完成，正在處理音頻..."

ffmpeg -i user_input.wav -ac 1 -ar 16000 processed_input.wav
echo "音頻處理完成，開始語音轉文字..."

./build/bin/main -m ./models/ggml-tiny-q5_1.bin -f processed_input.wav -l zh > transcript.txt
echo "文字轉錄完成，開始呼叫 LLM Studio..."

python3 call_lm_api.py

