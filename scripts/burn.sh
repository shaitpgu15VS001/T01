#!/bin/bash
set -e

VIDEO_FILE="$1"
ASS_FILE="$2"
OUTPUT_FILE="$3"

echo "=== burn.sh: צורב כתוביות על הסרטון ==="

if [ ! -f "$VIDEO_FILE" ]; then
    echo "שגיאה: הסרטון לא נמצא: $VIDEO_FILE"
    exit 1
fi

if [ ! -f "$ASS_FILE" ]; then
    echo "שגיאה: קובץ הכתוביות לא נמצא: $ASS_FILE"
    exit 1
fi

ffmpeg -i "$VIDEO_FILE" \
    -vf "ass=$ASS_FILE" \
    -c:a copy \
    -c:v libx264 \
    -preset fast \
    -crf 23 \
    "$OUTPUT_FILE" -y 2>&1

echo "סרטון עם כתוביות: $OUTPUT_FILE"
ls -lh "$OUTPUT_FILE"
echo "=== burn.sh: הושלם ==="
