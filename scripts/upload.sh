#!/bin/bash
set -e

UPLOAD_DIR="$1"
DROPBOX_TOKEN="${DROPBOX_TOKEN:-}"
DROPBOX_PATH="${DROPBOX_PATH:-/תמלול ותרגום}"

if [ -z "$DROPBOX_TOKEN" ]; then
    echo "אין DROPBOX_TOKEN, מדלג על העלאה ל-Dropbox"
    exit 0
fi

echo "מעלה ל-Dropbox: $DROPBOX_PATH"

for file in "$UPLOAD_DIR"/*; do
    [ ! -f "$file" ] && continue
    filename=$(basename "$file")
    echo "מעלה: $filename"

    dropbox_arg=$(DROPBOX_PATH="$DROPBOX_PATH" FILENAME="$filename" python3 -c "
import os, json
arg = {'path': os.environ['DROPBOX_PATH'] + '/' + os.environ['FILENAME'],
       'mode': 'overwrite', 'autorename': True}
print(json.dumps(arg))
")

    resp=$(curl -s -X POST https://content.dropboxapi.com/2/files/upload \
        -H "Authorization: Bearer $DROPBOX_TOKEN" \
        -H "Dropbox-API-Arg: $dropbox_arg" \
        -H "Content-Type: application/octet-stream" \
        --data-binary "@$file")

    name=$(echo "$resp" | python3 -c "import sys,json; print(json.load(sys.stdin).get('name','?'))" 2>/dev/null)
    echo "  OK: $name"
done

echo "העלאה ל-Dropbox הושלמה"
