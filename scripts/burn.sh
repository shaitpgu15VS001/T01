#!/bin/bash
set -e

VIDEO_FILE="$1"
SUBS_FILE="$2"
OUTPUT_FILE="$3"

if [ ! -f "$VIDEO_FILE" ]; then
    echo "שגיאה: הסרטון לא נמצא: $VIDEO_FILE"
    exit 1
fi
if [ ! -f "$SUBS_FILE" ]; then
    echo "שגיאה: קובץ הכתוביות לא נמצא: $SUBS_FILE"
    exit 1
fi

EXT="${SUBS_FILE##*.}"
echo "=== burn.sh: צורב כתוביות על הסרטון ==="
echo "פורמט: $EXT"

case "${EXT,,}" in
    ass) VF="ass=$SUBS_FILE" ;;
    srt|vtt) VF="subtitles=$SUBS_FILE" ;;
    *)
        echo "פורמט לא נתמך: $EXT"
        exit 1
        ;;
esac

ffmpeg -i "$VIDEO_FILE" -vf "$VF" -c:a copy -c:v libx264 -preset fast -crf 23 "$OUTPUT_FILE" -y 2>&1

echo "סרטון עם כתוביות: $OUTPUT_FILE"
ls -lh "$OUTPUT_FILE"
echo "=== burn.sh: הושלם ==="
