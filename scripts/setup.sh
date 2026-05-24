#!/bin/bash
set -e

echo "=== setup.sh: התקנת whisper.cpp ==="

WHISPER_DIR="whisper.cpp"
WHISPER_BIN="$WHISPER_DIR/build/bin/whisper-cli"

if [ -d "$WHISPER_DIR" ]; then
    if [ ! -f "$WHISPER_BIN" ]; then
        echo "הבינארי חסר, מוחק ומקלון מחדש..."
        rm -rf "$WHISPER_DIR"
    fi
fi

if [ ! -d "$WHISPER_DIR" ]; then
    echo "מוריד את whisper.cpp..."
    git clone --depth 1 https://github.com/ggerganov/whisper.cpp
fi

cd "$WHISPER_DIR"

if [ ! -f "build/bin/whisper-cli" ]; then
    echo "מהדר את whisper.cpp (cmake)..."
    cmake -B build
    cmake --build build --config release -j$(nproc)
fi

if [ ! -f "build/bin/whisper-cli" ]; then
    echo "שגיאה: קומפילציה נכשלה, whisper-cli לא נוצר"
    ls -la build/bin/ 2>/dev/null || echo "build/bin/ לא קיים"
    exit 1
fi

MODEL="ggml-tiny.bin"
if [ ! -f "models/$MODEL" ]; then
    echo "מוריד את מודל $MODEL..."
    mkdir -p models
    wget -q -O "models/$MODEL" "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/$MODEL"
fi

echo "תוכן build/bin/:"
ls -la build/bin/

cd ..
echo "=== setup.sh: הושלם ==="
