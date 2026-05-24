#!/bin/bash
set -e

INPUT_FILE="$1"
OUTPUT_DIR="$2"
LANG="${3:-auto}"
MODEL="${4:-tiny}"
MODEL_FILE="ggml-${MODEL}.bin"

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
MODEL_PATH="$WHISPER_DIR/models/$MODEL_FILE"

if [ ! -f "$MODEL_PATH" ]; then
    MODEL_PATH="./whisper.cpp/models/$MODEL_FILE"
fi

if [ ! -f "$MODEL_PATH" ]; then
    echo "שגיאה: מודל לא נמצא ב-$MODEL_PATH"
    exit 1
fi

echo "=== transcribe.sh: מתמלל עם whisper.cpp (דגם $MODEL) ==="
echo "בינארי: $WHISPER_BIN"
echo "מודל: $MODEL_PATH"
echo "קובץ: $INPUT_FILE"
echo "שפה: $LANG"

cp "$INPUT_FILE" "./audio_tmp.wav"

"$WHISPER_BIN" -f "./audio_tmp.wav" \
    -m "$MODEL_PATH" \
    -osrt -oj \
    -l "$LANG" \
    -t "$(nproc)" 2>&1

echo "קבצים שנוצרו:"
ls -la ./audio_tmp.wav.* 2>/dev/null || echo "לא נמצאו קבצי פלט"

if [ -f "./audio_tmp.wav.srt" ]; then
    mv "./audio_tmp.wav.srt" "$OUTPUT_DIR/source.srt"
    echo "נוצר: $OUTPUT_DIR/source.srt"
fi

if [ -f "./audio_tmp.wav.json" ]; then
    mv "./audio_tmp.wav.json" "$OUTPUT_DIR/source.json"
    echo "נוצר: $OUTPUT_DIR/source.json"
fi

rm -f "./audio_tmp.wav"

if [ ! -f "$OUTPUT_DIR/source.srt" ]; then
    echo "שגיאה: קובץ SRT לא נוצר"
    exit 1
fi

echo "=== transcribe.sh: הושלם ==="
