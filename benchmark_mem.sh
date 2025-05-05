#!/usr/bin/env bash

# benchmark_all.sh
# 測量多個 whisper.cpp 模型的真實記憶體佔用 (Max RSS) 及推理時間 (Real elapsed)

set -euo pipefail

# 要測試的模型名稱 (不含副檔名 .bin)
MODELS=(
  #"ggml-fp16"
  #"ggml-q8_0"
  ##"ggml-q5_1"
  #"ggml-q5_0"
  "ggml-q4_0"
  ##"ggml-q4_1"
)

TEST_WAV="$1"


# 結果暫存
declare -A MEM_KB
declare -A TIME_SEC

echo "開始 benchmark："
echo

for model in "${MODELS[@]}"; do
  echo "測試模型：$model"

  ## 測記憶體佔用
  ## -v: 詳細模式，-o: 輸出到 log
  /usr/bin/time -v -o mem_${model}.log \
    build/bin/main -m ./models/${model}.bin -l zh -f "$TEST_WAV" --no-timestamps --audio-ctx 0

  ## 從 log 抽取 Maximum resident set size (kbytes)
  mem=$(grep "Maximum resident set size" mem_${model}.log | awk '{print $6}')
  MEM_KB[$model]=$mem

  # 測推理時間
  # -f "Real: %e" 只印出 real time，-o 輸出到 time log
  /usr/bin/time -f "Real: %e" -o time_${model}.log \
    build/bin/main -m ./models/${model}.bin -l zh -f "$TEST_WAV"  --audio-ctx 0 

  # 從 time log 抽取秒數
  t=$(grep "Real:" time_${model}.log | awk '{print $2}')
  TIME_SEC[$model]=$t

  echo "  Max RSS  = ${mem} kB"
  echo "  Elapsed  = ${t} sec"
  echo
done

# 列印總表
echo "========== Benchmark 結果 =========="
printf "%-12s %-15s %-15s\n" "Model" "Max RSS (kB)" "Elapsed (s)"
for model in "${MODELS[@]}"; do
  printf "%-12s %-15s %-15s\n" \
    "$model" "${MEM_KB[$model]}" "${TIME_SEC[$model]}"
done
