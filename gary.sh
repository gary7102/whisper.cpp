#!/usr/bin/env bash


echo "start testing ggml-tiny.bin"
echo "start clock"

./build/bin/main \
	-m ./models/ggml-tiny.q5_0.bin \
	-f transcript.wav \
	-l zh \
	#--no-timestamps


