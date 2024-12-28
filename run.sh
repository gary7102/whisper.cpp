#!/bin/bash

echo "請按空白鍵開始說話，完成後再次按空白鍵結束錄音。"

# 等待按鍵輸入
read -n 1

arecord -D hw:3,0 -f S16_LE -c 1 -r 16000 user_input.wav
echo "錄音完成，正在處理user_input.wav..."

# 轉換成channel 1 且 sample_rate 16K
ffmpeg -i user_input.wav -ac 1 -ar 16000 processed_input.wav

# start process and store it to transcript.txt
./build/bin/main -m ./models/ggml-tiny-q5_1.bin -f processed_input.wav -l zh > transcript.txt


