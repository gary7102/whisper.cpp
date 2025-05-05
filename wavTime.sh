#!/usr/bin/env bash

ffprobe -v error \
  -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 transcript.wav

ffprobe -v error \
  -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 test_mono.wav

