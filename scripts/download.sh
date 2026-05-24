#!/bin/bash
set -e

VIDEO_URL="$1"
OUTPUT_DIR="$2"
FILENAME="${3:-input.mp4}"

mkdir -p "$OUTPUT_DIR"

if [[ "$VIDEO_URL" == *"dropbox.com"* ]]; then
    echo "מזהה קישור Dropbox..."
    if [[ "$VIDEO_URL" == *"?dl=0" ]]; then
        VIDEO_URL="${VIDEO_URL/?dl=0/?dl=1}"
    elif [[ "$VIDEO_URL" != *"?dl=1" ]]; then
        VIDEO_URL="$VIDEO_URL?dl=1"
    fi
fi

echo "מוריד מ: $VIDEO_URL"
wget -q -O "$OUTPUT_DIR/$FILENAME" "$VIDEO_URL"

echo "קובץ נשמר: $OUTPUT_DIR/$FILENAME"
ls -lh "$OUTPUT_DIR/$FILENAME"
