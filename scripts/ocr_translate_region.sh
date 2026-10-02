#!/usr/bin/env bash
# OCR and Translate Selected Region (Google Lens style for Hyprland)

# Exit if slurp is already running (prevent multiple overlapping crosshairs)
if pgrep -x slurp >/dev/null; then
    exit 0
fi

# 1. Select region with slurp
GEOM=$(slurp -d -b "#00000088" -c "#89b4fa" 2>/dev/null)
if [ -z "$GEOM" ]; then
    exit 0
fi

TMP_IMG=$(mktemp /tmp/ocr_crop_XXXXXX.png)

# 2. Take screenshot of selected region
if ! grim -g "$GEOM" "$TMP_IMG" 2>/dev/null; then
    rm -f "$TMP_IMG"
    exit 1
fi

# 3. Upscale 2x for much higher OCR accuracy on UI and web fonts
if command -v magick >/dev/null 2>&1; then
    magick "$TMP_IMG" -resize 200% "$TMP_IMG" 2>/dev/null
fi

# 4. Run Tesseract OCR with both English and Russian models
export TESSDATA_PREFIX="/home/qubert/.local/share/tessdata"
TEXT=$(tesseract "$TMP_IMG" stdout -l eng+rus --oem 1 2>/dev/null)
rm -f "$TMP_IMG"

# 5. Clean up text and filter out noise
# Remove empty lines and trim spaces
CLEAN_TEXT=$(echo "$TEXT" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | grep -v '^[[:space:]]*$')

# Check if recognized text contains at least one meaningful word/letter (ignore pure noise/brackets)
LETTER_COUNT=$(echo "$CLEAN_TEXT" | tr -cd '[:alpha:]' | wc -m)

if [ -z "$CLEAN_TEXT" ] || [ "$LETTER_COUNT" -lt 2 ]; then
    notify-send -u low -a "Переводчик" -t 2500 "Переводчик" "Текст в выделенной области не обнаружен"
    exit 0
fi

# 6. Copy clean text to clipboard and primary selection
printf "%s" "$CLEAN_TEXT" | wl-copy --type text/plain --primary
printf "%s" "$CLEAN_TEXT" | wl-copy --type text/plain

# 7. Open translator popup with the recognized text
qs -c end4-pC ipc call translatorService translateText "$CLEAN_TEXT" 2>/dev/null || qs -c end4-pC ipc call translator open
