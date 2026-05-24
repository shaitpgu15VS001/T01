#!/usr/bin/env python3
import sys
import os
import shutil

SRC_SRT = sys.argv[1]
TGT_SRT = sys.argv[2]
OUTPUT_DIR = sys.argv[3]
FONT_NAME = sys.argv[4] if len(sys.argv) > 4 else "Arial"
FONT_SIZE = sys.argv[5] if len(sys.argv) > 5 else "20"
FONT_COLOR = sys.argv[6] if len(sys.argv) > 6 else "&H00FFFFFF"
POSITION = sys.argv[7] if len(sys.argv) > 7 else "bottom"

os.makedirs(OUTPUT_DIR, exist_ok=True)

def parse_srt(filepath):
    entries = []
    with open(filepath, encoding="utf-8") as f:
        text = f.read().strip()
    for block in text.split("\n\n"):
        lines = block.strip().split("\n")
        if len(lines) >= 3:
            time_range = lines[1]
            txt = "\n".join(lines[2:])
            entries.append((time_range, txt))
    return entries

src_entries = parse_srt(SRC_SRT)
tgt_entries = parse_srt(TGT_SRT)

def write_vtt(entries, filepath):
    with open(filepath, "w", encoding="utf-8") as f:
        f.write("WEBVTT\n\n")
        for time_range, text in entries:
            vtt_time = time_range.replace(",", ".")
            f.write(f"{vtt_time}\n{text}\n\n")

write_vtt(src_entries, os.path.join(OUTPUT_DIR, "source.vtt"))
write_vtt(tgt_entries, os.path.join(OUTPUT_DIR, "target.vtt"))

align = 2
margin_v = 50
if POSITION == "top":
    align = 8
    margin_v = 20

ass_path = os.path.join(OUTPUT_DIR, "subtitles.ass")
with open(ass_path, "w", encoding="utf-8") as f:
    f.write("[Script Info]\n")
    f.write("ScriptType: v4.00+\n")
    f.write("ScaledBorderAndShadow: yes\n\n")
    f.write("[V4+ Styles]\n")
    f.write("Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, "
            "OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, "
            "ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, "
            "Alignment, MarginL, MarginR, MarginV, Encoding\n")
    f.write(f"Style: Source,{FONT_NAME},{FONT_SIZE},{FONT_COLOR},"
            f"&H000000FF,&H00000000,&H80000000,0,0,0,0,100,100,0,0,1,1.5,1,"
            f"{align},10,10,{margin_v},1\n")
    f.write(f"Style: Target,{FONT_NAME},{str(int(FONT_SIZE)+2)},{FONT_COLOR},"
            f"&H000000FF,&H00000000,&H80000000,-1,0,0,0,100,100,0,0,1,1.5,1,"
            f"{align},10,10,{margin_v + 10 if POSITION != 'top' else margin_v},1\n\n")
    f.write("[Events]\n")
    f.write("Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n")
    for (src_time, src_text), (tgt_time, tgt_text) in zip(src_entries, tgt_entries):
        ass_start = src_time.split(" --> ")[0].replace(",", ".")
        ass_end = src_time.split(" --> ")[1].replace(",", ".")
        src_esc = src_text.replace("\n", "\\N")
        tgt_esc = tgt_text.replace("\n", "\\N")
        f.write(f"Dialogue: 0,{ass_start},{ass_end},Source,,0,0,0,,{src_esc}\n")
        f.write(f"Dialogue: 0,{ass_start},{ass_end},Target,,0,0,0,,{tgt_esc}\n\n")

shutil.copy(SRC_SRT, os.path.join(OUTPUT_DIR, "source.srt"))
shutil.copy(TGT_SRT, os.path.join(OUTPUT_DIR, "target.srt"))

print(f"נוצרו קבצים ב: {OUTPUT_DIR}")
print("  - source.srt / target.srt")
print("  - source.vtt / target.vtt")
print("  - subtitles.ass (לצריבה)")
