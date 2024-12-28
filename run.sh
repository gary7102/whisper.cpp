#!/bin/bash

echo "請按空白鍵開始說話，完成後再次按空白鍵結束錄音。"

# 等待按鍵輸入
read -n 1

arecord -D hw:3,0 -f S16_LE -c 1 -r 16000 user_input.wav

echo "錄音完成，正在處理音頻..."

