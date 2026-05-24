#!/bin/bash
set -e

echo "=== setup.sh: התקנת whisper.cpp ==="

if [ -d "whisper.cpp" ]; then
    if [ ! -f "whisper.cpp/main" ]; then
        echo "הבינארי חסר, מוחק ומקלון מחדש..."
        rm -rf whisper.cpp
    fi
fi

if [ ! -d "whisper.cpp" ]; then
    echo "מוריד את whisper.cpp..."
    git clone --depth 1 https://github.com/ggerganov/whisper.cpp
fi

cd whisper.cpp

if [ ! -f "main" ]; then
    echo "מהדר את whisper.cpp..."
    make -j$(nproc)
fi

if [ ! -f "main" ]; then
    echo "שגיאה: קומפילציה נכשלה, main לא נוצר"
    ls -la
    exit 1
fi

MODEL="ggml-tiny.bin"
if [ ! -f "models/$MODEL" ]; then
    echo "מוריד את מודל $MODEL..."
    mkdir -p models
    wget -q -O "models/$MODEL" "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/$MODEL"
fi

echo "תוכן whisper.cpp:"
ls -la main

cd ..
echo "=== setup.sh: הושלם ==="
