#!/bin/bash
set -e

echo "=== setup.sh: התקנת whisper.cpp ==="

if [ ! -d "whisper.cpp" ]; then
    echo "מוריד את whisper.cpp..."
    git clone --depth 1 https://github.com/ggerganov/whisper.cpp
fi

cd whisper.cpp

if [ ! -f "main" ]; then
    echo "מהדר את whisper.cpp..."
    make -j$(nproc)
fi

MODEL="ggml-tiny.bin"
if [ ! -f "models/$MODEL" ]; then
    echo "מוריד את מודל $MODEL..."
    wget -q -O "models/$MODEL" "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/$MODEL"
fi

cd ..
echo "=== setup.sh: הושלם ==="
