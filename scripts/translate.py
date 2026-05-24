#!/usr/bin/env python3
import sys
import os
import json
import shutil

SRC_SRT = sys.argv[1]
DST_SRT = sys.argv[2]
SRC_LANG = sys.argv[3] if len(sys.argv) > 3 else "auto"
TGT_LANG = sys.argv[4] if len(sys.argv) > 4 else "he"
SRC_JSON = sys.argv[5] if len(sys.argv) > 5 else ""

if SRC_LANG == "auto" and SRC_JSON and os.path.exists(SRC_JSON):
    with open(SRC_JSON) as f:
        data = json.load(f)
    if isinstance(data, dict) and "language" in data:
        SRC_LANG = data["language"]

print(f"שפת מקור: {SRC_LANG} → שפת יעד: {TGT_LANG}")

if SRC_LANG == TGT_LANG or not SRC_LANG:
    shutil.copy(SRC_SRT, DST_SRT)
    print("שפות זהות או לא ידועות, מעתיק כמות שהוא")
    sys.exit(0)

import argostranslate.package
import argostranslate.translate

try:
    argostranslate.package.update_package_index()
except Exception as e:
    print(f"אזהרה: {e}")

installed = argostranslate.translate.get_installed_languages()
installed_codes = {l.code for l in installed}

if SRC_LANG not in installed_codes or TGT_LANG not in installed_codes:
    available = argostranslate.package.get_available_packages()
    pkg = next(
        (p for p in available if p.from_code == SRC_LANG and p.to_code == TGT_LANG),
        None
    )
    if not pkg:
        print(f"שגיאה: לא נמצא מודל {SRC_LANG}→{TGT_LANG}")
        sys.exit(1)
    print(f"מוריד מודל: {pkg}")
    argostranslate.package.install_from_path(pkg.download())

translation = argostranslate.translate.get_translation_from_codes(SRC_LANG, TGT_LANG)

with open(SRC_SRT, encoding="utf-8") as f:
    raw = f.read().strip()

blocks = raw.split("\n\n")
out_lines = []

for i, block in enumerate(blocks):
    lines = block.strip().split("\n")
    if len(lines) >= 3:
        num, time_line = lines[0], lines[1]
        text = "\n".join(lines[2:])
        translated = translation.translate(text)
        if i > 0:
            out_lines.append("")
        out_lines.extend([num, time_line, translated])
    else:
        if i > 0:
            out_lines.append("")
        out_lines.append(block.strip())

with open(DST_SRT, "w", encoding="utf-8") as f:
    f.write("\n".join(out_lines) + "\n")

print(f"תורגם ל: {DST_SRT}")
