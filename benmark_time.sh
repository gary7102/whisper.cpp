#!/usr/bin/env bash

# benchmark_wavs.sh
# 依序將資料夾內所有 WAV 轉單聲道，再測各模型推理時間，最後輸出表格

set -euo pipefail

# 要測試的模型 (不含 .bin)
MODELS=(
  "ggml-fp16"
  "ggml-q8_0"
  "ggml-q5_0"
  "ggml-q4_0"
)

# 原始 WAV 檔資料夾
WAV_DIR="../../Downloads/sec10"
# 單聲道 WAV 輸出資料夾
MONO_DIR="mono_10sec_wav"


# 準備 mono 資料夾
mkdir -p "$MONO_DIR"

# 刪除已經存在的wav form
for delete in "$MONO_DIR"/*.wav; do
  fname=$(basename "$delete")
  rm "$MONO_DIR"/$fname
done
echo "刪除舊檔案"
echo

# 1) 將所有 WAV 轉成單聲道
echo "轉單聲道中..."
for src in "$WAV_DIR"/*.wav; do
  fname=$(basename "$src")
  dst="$MONO_DIR/$fname"
  ffmpeg -i "$src" -ac 1 -ar 16000 "$dst"
done
echo "單聲道轉換完成。"
echo

# 2) Benchmark 推理時間
declare -A TIME_SEC

echo "開始 Benchmark 推理時間..."
for model in "${MODELS[@]}"; do
  echo "模型：$model"
  for wav in "$MONO_DIR"/*.wav; do
    base=$(basename "$wav" .wav)
    # 測 elapsed time (秒)
    /usr/bin/time -f "%e" -o time.log \
      ./build/bin/main -m "./models/${model}.bin" -f "$wav" -l zh\
      2> /dev/null
    t=$(<time.log)
    TIME_SEC["$model|$base"]=$t
    echo "  $base : ${t}s"
  done
  echo
done

# 3) 列印結果表格
# 收集所有 WAV 名稱（不含 .wav）
mapfile -t FILES < <(for f in "$MONO_DIR"/*.wav; do basename "$f" .wav; done)

# 印表頭
printf "%-12s" "Model"
for f in "${FILES[@]}"; do
  printf " %-10s" "$f"
done
printf "\n"

# 印分隔線
printf "%-12s" "------------"
for _ in "${FILES[@]}"; do
  printf " ----------"
done
printf "\n"

# 印各模型時間
for model in "${MODELS[@]}"; do
  printf "%-12s" "$model"
  for f in "${FILES[@]}"; do
    printf " %-10s" "${TIME_SEC[$model|$f]}"
  done
  printf "\n"
done

