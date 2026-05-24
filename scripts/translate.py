#!/usr/bin/env python3
import sys
import json
import os
import time

import requests

SRC_SRT = sys.argv[1]
DST_SRT = sys.argv[2]
SRC_LANG = sys.argv[3] if len(sys.argv) > 3 else "auto"
TGT_LANG = sys.argv[4] if len(sys.argv) > 4 else "he"
API_URL = os.environ.get("LIBRETRANSLATE_URL", "https://libretranslate.com/translate")
CHUNK_SIZE = int(os.environ.get("LIBRE_CHUNK_SIZE", "20"))
RATE_LIMIT = float(os.environ.get("LIBRE_RATE_LIMIT", "1.0"))

with open(SRC_SRT, encoding="utf-8") as f:
    srt_text = f.read().strip()

if not srt_text:
    print("קובץ SRT ריק, מעתיק כמות שהוא")
    with open(DST_SRT, "w", encoding="utf-8") as f:
        f.write("")
    sys.exit(0)

entries = srt_text.split("\n\n")
translated_parts = []

for i in range(0, len(entries), CHUNK_SIZE):
    chunk = "\n\n".join(entries[i:i + CHUNK_SIZE])
    payload = {
        "q": chunk,
        "source": SRC_LANG if SRC_LANG != "auto" else "auto",
        "target": TGT_LANG,
        "format": "srt"
    }
    print(f"מתרגם מקטע {i // CHUNK_SIZE + 1}/{(len(entries) + CHUNK_SIZE - 1) // CHUNK_SIZE}...")
    resp = requests.post(API_URL, json=payload, timeout=120)
    if resp.status_code != 200:
        print(f"שגיאה: {resp.status_code} {resp.text}", file=sys.stderr)
        sys.exit(1)
    result = resp.json()
    translated_parts.append(result["translatedText"])

    if i + CHUNK_SIZE < len(entries):
        time.sleep(RATE_LIMIT)

full = "\n\n".join(translated_parts)
with open(DST_SRT, "w", encoding="utf-8") as f:
    f.write(full)
if not full.endswith("\n"):
    with open(DST_SRT, "a", encoding="utf-8") as f:
        f.write("\n")

print(f"תורגם ל: {DST_SRT}")
