#!/bin/bash
set -e

INPUT_FILE="$1"
OUTPUT_DIR="$2"
LANG="${3:-auto}"

BASENAME=$(basename "$INPUT_FILE")
WHISPER_CPP="./whisper.cpp"

echo "=== transcribe.sh: מתמלל עם whisper.cpp (דגם tiny) ==="
echo "קובץ: $INPUT_FILE"
echo "שפה: $LANG"

"$WHISPER_CPP/main" -f "$INPUT_FILE" \
    -m "$WHISPER_CPP/models/ggml-tiny.bin" \
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
