import requests

def send_to_llm_studio(transcript):
    url = "http://<LLM_API_IP>:<PORT>/api/chat"
    payload = {"message": transcript}
    try:
        response = requests.post(url, data=payload)
        if response.status_code == 200:
            return response.json().get("response", "無法獲取回應")
        else:
            return f"API 錯誤：{response.status_code}"
    except Exception as e:
        return f"無法連接到 API：{str(e)}"

if __name__ == "__main__":
    with open("transcript.txt", "r", encoding="utf-8") as f:
        transcript = f.read().strip()
	print(f"transcript before lm studio = {transcript}")
        reply = send_to_llm_studio(transcript)
        print(f"LLM Studio 的回應：{reply}")

