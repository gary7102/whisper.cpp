import requests
import json

def send_to_llm_studio(transcript):
    # 設定 LM Studio API 的地址
    url = "http://192.168.50.36:1234/v1/chat/completions"

    # 構造 POST 請求的資料
    payload = {
        "model": "causallm-14b",  # 使用你的模型名稱
        "messages": [
            {"role": "user", "content": transcript}
        ],
        "temperature": 0.7  # 可調整生成的隨機性
    }

    headers = {
        "Content-Type": "application/json"
    }

    try:
        # 發送 POST 請求
        response = requests.post(url, headers=headers, data=json.dumps(payload))

        # 處理回應
        if response.status_code == 200:
            result = response.json()
            return result["choices"][0]["message"]["content"]  # 返回生成的回應
        else:
            return f"API 錯誤：{response.status_code}，{response.text}"

    except Exception as e:
        return f"無法連接到 API：{str(e)}"


if __name__ == "__main__":
    # 測試：讀取 `transcript.txt` 並發送到 LLM Studio
    with open("transcript.txt", "r", encoding="utf-8") as f:
        transcript = f.read().strip()
        reply = send_to_llm_studio(transcript)
        print(f"LLM Studio 的回應：{reply}")

