# פרויקט תמלול ותרגום סרטונים

## מה זה עושה?

מקבל סרטון וידאו / קובץ אודיו (דרך קישור או Dropbox), מתמלל אותו לאנגלית (או שפת המקור) ומתרגם לעברית (או שפה אחרת).
ניתן לבחור:
- **כתוביות בלבד**: הורדת קבצי SRT / VTT לשפות המקור והתרגום
- **צריבה על הסרטון**: הכתוביות מוטמעות לתוך הסרטון עצמו

## טכנולוגיות

| רכיב | טכנולוגיה |
|------|-----------|
| תמלול | Whisper.cpp (דגם tiny, רץ על CPU) |
| תרגום | Argos Translate (מקומי) / Google Translate (דרך האינטרנט) |
| צריבת כתוביות | FFmpeg + ASS |
| תשתית | GitHub Actions (ubuntu-latest, 2 ליבות) |

## דרישות מקדימות

1. חשבון GitHub (גם חינמי מתאים)
2. קישור לסרטון (URL ישיר או קישור שיתוף מ-Dropbox)
3. **אופציונלי**: Access Token של Dropbox להעלאה אוטומטית

## הגדרה ראשונית

### 1. יצירת העתק (Fork) של הפרויקט

```bash
git clone https://github.com/החשבון-שלך/פרוייקט-תמלול-ותרגום
cd פרוייקט-תמלול-ותרגום
```

### 2. הוספת Dropbox Token (אופציונלי)

אם רוצים שהקבצים יועלו אוטומטית ל-Dropbox:

1. היכנסו ל-https://www.dropbox.com/developers/apps
2. צרו App חדש מסוג **Dropbox API** → **Scoped Access**
3. תחת **Permissions** סמנו: `files.content.write`
4. צרו Access Token (Generated Access Token)
5. הוסיפו אותו כ-Secret ב-GitHub:
   ```
   Settings → Secrets and variables → Actions → New repository secret
   Name: DROPBOX_TOKEN
   Value: (הטוקן שיצרתם)
   ```

## איך מפעילים?

### דרך ממשק GitHub

1. היכנסו ל-Repository ב-GitHub
2. לחצו על **Actions** → **תמלול ותרגום סרטונים**
3. לחצו על **Run workflow**
4. מלאו את הפרמטרים:

| פרמטר | תיאור | חובה | ברירת מחדל |
|--------|-------|------|------------|
| `video_url` | קישור ישיר לסרטון *או* קישור שיתוף Dropbox | ✅ | — |
| `source_lang` | שפת מקור (`auto` לזיהוי אוטומטי) | ❌ | `auto` |
| `target_lang` | שפת יעד (קוד שפה בן 2 אותיות) | ❌ | `he` |
| `action` | `subtitles` (רק כתוביות) / `burn` (צרוב על הסרטון) | ❌ | `subtitles` |
| `font_size` | גודל גופן (אם צריבה) | ❌ | `20` |
| `font_color` | צבע טקסט בהקס (אם צריבה) | ❌ | `&H00FFFFFF` |
| `position` | מיקום: `bottom` או `top` (אם צריבה) | ❌ | `bottom` |
| `translation_engine` | מנוע תרגום: `argos` (מקומי) / `google` | ❌ | `argos` |

### דוגמאות לקישורים

```
# קישור ישיר
https://example.com/video.mp4

# קישור Dropbox (כולל תיקייה משותפת)
https://www.dropbox.com/s/abc123/myvideo.mp4
```

## פלט (מה מקבלים)

אחרי הריצה, תוכלו להוריד מה-Artefacts:

### מצב `subtitles`
- `source.srt` / `source.vtt` — כתוביות בשפת המקור
- `target.srt` / `target.vtt` — כתוביות מתורגמות
- `subtitles.ass` — כתוביות לעיצוב (ניתן לצרוב לבד)

### מצב `burn`
- כל הקבצים ממצב `subtitles`
- `סרטון-מסומן.mp4` — הסרטון עם כתוביות מוטמעות

אם הגדרתם `DROPBOX_TOKEN`, כל הקבצים יעלו אוטומטית לתיקיית `/תמלול ותרגום` ב-Dropbox.

## שפות נתמכות

### Whisper (תמלול)
תומך ב-39 שפות כולל: אנגלית, עברית, ערבית, רוסית, צרפתית, ספרדית, גרמנית, איטלקית, פורטוגזית, יפנית, סינית, קוריאנית ועוד.

**הערה**: הדיוק משתנה בין שפות. מומלץ להשתמש ב-`auto` לזיהוי אוטומטי.

### Argos Translate / Google Translate (תרגום)
- **Argos** — תרגום מקומי (ללא אינטרנט), תומך בכ-30 שפות
- **Google** — תרגום דרך האינטרנט, איכות גבוהה, תומך בלמעלה מ-100 שפות

## מגבלות

| מגבלה | הסבר |
|-------|-------|
| **מהירות** | Whisper על CPU איטי — סרטון 10 דקות עשוי לקחת 30-60 דקות |
| **אורך סרטון** | GitHub Actions מוגבל ל-6 שעות ריצה (מותר עד ~30 דקות וידאו) |
| **גודל קובץ** | GitHub Files מוגבל ל-10GB |
| **תרגום (Google)** | Google Translate הא-רשמי עלול להיחסם לעיתים נדירות |
| **דיוק** | דגם tiny פחות מדויק מדגמים גדולים (ניתן לשדרוג) |

## התאמה אישית

### שדרוג מודל התמלול

ב-`config/settings.json` ניתן לשנות לשם מודל אחר, ואז `setup.sh` יוריד אותו אוטומטית:

| דגם | גודל | דיוק |
|-----|------|-------|
| `tiny` | ~75MB | בסיסי |
| `base` | ~150MB | סביר |
| `small` | ~500MB | טוב |
| `medium` | ~1.5GB | מצוין |

### הגדרות עיצוב כתוביות

ב-`config/settings.json` תוכלו לשנות ברירות מחדל ל:
- שם גופן, גודל, צבע, מיקום

## מבנה התיקיות

```
.
├── .github/workflows/
│   └── process-video.yml    # הגדרת ה-GitHub Action
├── scripts/
│   ├── setup.sh             # התקנת whisper.cpp + מודל
│   ├── download.sh          # הורדת סרטון מ-URL/Dropbox
│   ├── transcribe.sh        # תמלול עם whisper.cpp
│   ├── translate.py         # תרגום SRT (Argos / Google)
│   ├── gen-subtitles.py     # יצירת SRT/VTT/ASS
│   ├── burn.sh              # צריבת כתוביות על הסרטון
│   └── upload.sh            # העלאה ל-Dropbox
├── config/
│   └── settings.json        # הגדרות ברירת מחדל
└── README.md
```

## פתרון בעיות

**ה-Action נכשל ב-Setup**: נסו להריץ שוב — ייתכן כשל זמני בהורדת המודל.

**תרגום Google נכשל**: נסו לעבור ל-`argos`. **תרגום Argos נכשל**: נסו לעבור ל-`google`.

**הסרטון לא יורד**: ודאו שהקישור נגיש לציבור (ללא סיסמה).

## רישיון

MIT
