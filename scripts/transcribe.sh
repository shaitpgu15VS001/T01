#!/bin/bash
set -e

INPUT_FILE="$1"
OUTPUT_DIR="$2"
LANG="${3:-auto}"

BASENAME=$(basename "$INPUT_FILE")

WHISPER_BIN=""
for candidate in \
    "./whisper.cpp/build/bin/whisper-cli" \
    "./whisper.cpp/main" \
    "./whisper.cpp/build/bin/main"; do
    if [ -f "$candidate" ]; then
        WHISPER_BIN="$candidate"
        break
    fi
done

if [ -z "$WHISPER_BIN" ]; then
    echo "שגיאה: לא נמצא בינארי של whisper.cpp"
    ls -la ./whisper.cpp/build/bin/ 2>/dev/null || echo "build/bin/ לא קיים"
    ls -la ./whisper.cpp/ 2>/dev/null
    exit 1
fi

WHISPER_DIR=$(dirname "$(dirname "$WHISPER_BIN")")
MODEL_FILE="$WHISPER_DIR/models/ggml-tiny.bin"

if [ ! -f "$MODEL_FILE" ]; then
    MODEL_FILE="./whisper.cpp/models/ggml-tiny.bin"
fi

if [ ! -f "$MODEL_FILE" ]; then
    echo "שגיאה: מודל לא נמצא ב-$MODEL_FILE"
    exit 1
fi

echo "=== transcribe.sh: מתמלל עם whisper.cpp (דגם tiny) ==="
echo "בינארי: $WHISPER_BIN"
echo "מודל: $MODEL_FILE"
echo "קובץ: $INPUT_FILE"
echo "שפה: $LANG"

"$WHISPER_BIN" -f "$INPUT_FILE" \
    -m "$MODEL_FILE" \
    -osrt -oj \
    -l "$LANG" \
    -t "$(nproc)" 2>&1

if [ -f "$BASENAME.srt" ]; then
    mv "$BASENAME.srt" "$OUTPUT_DIR/source.srt"
    echo "נוצר: $OUTPUT_DIR/source.srt"
fi

if [ -f "$BASENAME.json" ]; then
    mv "$BASENAME.json" "$OUTPUT_DIR/source.json"
    echo "נוצר: $OUTPUT_DIR/source.json"
fi

echo "=== transcribe.sh: הושלם ==="
