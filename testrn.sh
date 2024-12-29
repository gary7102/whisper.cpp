#!/usr/bin/env bash

# 這只是範例，請根據你的實際環境調整
# 例如 IP、model、messages 等參數。
# 特別要注意 'stream': true

curl -sN -X POST http://192.168.50.196:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "causallm-14b",
    "messages": [
      {
        "role": "system",
        "content": "You are a helpful jokester."
      },
      {
        "role": "user",
        "content": "Tell me a joke."
      }
    ],
    "temperature": 1,
    "max_tokens": 50,
    "stream": true
  }' |
 
while IFS= read -r line; do

    # 1) check if "[DONE]" ：
    if [[ "$line" == "data: [DONE]" ]]; then
      echo
      #echo "Done streaming!"
      break
    fi

    # 2) 你可以在這裡做進一步處理
    #    比如只抓取 "content" 的部分，或把 JSON 解析下來
    #    (可用 jq 處理。不過 SSE 會帶 "data: " 前綴，需先去掉再用 jq)

	 # 去掉"data: " 前綴
         chunk=$(echo "$line" | sed 's/^data: //')

  	 # 解析 content
         content=$(echo "$chunk" | jq -r '.choices[0].delta.content // empty')

         echo -n "$content"
done

