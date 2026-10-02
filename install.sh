#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}     Установка Hyprland Translator + IT-Сленг       ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. Detect Source Directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"

# If run via curl pipe, clone temporarily
if [ ! -f "$SCRIPT_DIR/modules/translator/TechGlossary.js" ]; then
    echo -e "${YELLOW}--> Скачивание файлов репозитория...${NC}"
    TMP_DIR=$(mktemp -d /tmp/hypr-translator-XXXXXX)
    git clone --depth 1 https://github.com/${GITHUB_REPOSITORY:-"qubertuwu/hypr-translator"}.git "$TMP_DIR" 2>/dev/null || {
        # Fallback to direct raw downloads if git clone fails
        mkdir -p "$TMP_DIR/modules/translator" "$TMP_DIR/scripts"
        BASE_URL="https://raw.githubusercontent.com/${GITHUB_REPOSITORY:-"qubertuwu/hypr-translator"}/main"
        curl -sSL "$BASE_URL/modules/translator/TechGlossary.js" -o "$TMP_DIR/modules/translator/TechGlossary.js"
        curl -sSL "$BASE_URL/modules/translator/GoogleTranslatorPopup.qml" -o "$TMP_DIR/modules/translator/GoogleTranslatorPopup.qml"
        curl -sSL "$BASE_URL/scripts/ocr_translate_region.sh" -o "$TMP_DIR/scripts/ocr_translate_region.sh"
    }
    SCRIPT_DIR="$TMP_DIR"
fi

# 2. Check and install system dependencies
echo -e "${BLUE}--> Проверка системных утилит...${NC}"
MISSING_PKGS=()

for cmd in tesseract grim slurp magick wl-copy; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        case "$cmd" in
            tesseract) MISSING_PKGS+=("tesseract") ;;
            grim) MISSING_PKGS+=("grim") ;;
            slurp) MISSING_PKGS+=("slurp") ;;
            magick) MISSING_PKGS+=("imagemagick") ;;
            wl-copy) MISSING_PKGS+=("wl-clipboard") ;;
        esac
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo -e "${YELLOW}Не найдены необходимые утилиты: ${MISSING_PKGS[*]}${NC}"
    if command -v pacman >/dev/null 2>&1; then
        echo -e "${YELLOW}Установка через pacman (требуется sudo):${NC}"
        sudo pacman -S --needed "${MISSING_PKGS[@]}" tesseract-data-eng tesseract-data-rus
    elif command -v apt-get >/dev/null 2>&1; then
        echo -e "${YELLOW}Установка через apt (требуется sudo):${NC}"
        sudo apt-get update && sudo apt-get install -y "${MISSING_PKGS[@]}" tesseract-ocr-eng tesseract-ocr-rus
    elif command -v dnf >/dev/null 2>&1; then
        echo -e "${YELLOW}Установка через dnf (требуется sudo):${NC}"
        sudo dnf install -y "${MISSING_PKGS[@]}" tesseract-langpack-eng tesseract-langpack-rus
    else
        echo -e "${RED}Пожалуйста, установите вручную: ${MISSING_PKGS[*]}${NC}"
    fi
fi

# 3. Ensure Russian and English tessdata models are available
mkdir -p "$HOME/.local/share/tessdata"
if [ ! -f "$HOME/.local/share/tessdata/rus.traineddata" ]; then
    echo -e "${BLUE}--> Загрузка русской модели распознавания Tesseract...${NC}"
    curl -sL -o "$HOME/.local/share/tessdata/rus.traineddata" https://github.com/tesseract-ocr/tessdata_fast/raw/main/rus.traineddata || true
fi
if [ ! -f "$HOME/.local/share/tessdata/eng.traineddata" ] && [ -f "/usr/share/tessdata/eng.traineddata" ]; then
    cp "/usr/share/tessdata/eng.traineddata" "$HOME/.local/share/tessdata/" 2>/dev/null || true
fi

# 4. Copy Translator Files into Quickshell config
TARGET_MODULE_DIR="$HOME/.config/quickshell/end4-pC/modules/ii/translator"
TARGET_SCRIPT_DIR="$HOME/.config/quickshell/end4-pC/scripts"

mkdir -p "$TARGET_MODULE_DIR"
mkdir -p "$TARGET_SCRIPT_DIR"

echo -e "${BLUE}--> Копирование файлов переводчика...${NC}"
cp "$SCRIPT_DIR/modules/translator/TechGlossary.js" "$TARGET_MODULE_DIR/"
cp "$SCRIPT_DIR/modules/translator/GoogleTranslatorPopup.qml" "$TARGET_MODULE_DIR/"
cp "$SCRIPT_DIR/scripts/ocr_translate_region.sh" "$TARGET_SCRIPT_DIR/"
chmod +x "$TARGET_SCRIPT_DIR/ocr_translate_region.sh"

# 5. Configure Keybinds for Hyprland
echo -e "${BLUE}--> Настройка горячих клавиш в Hyprland...${NC}"
LUA_BINDS="$HOME/.config/hypr/hyprland/keybinds.lua"
CONF_BINDS="$HOME/.config/hypr/hyprland.conf"

if [ -f "$LUA_BINDS" ]; then
    if ! grep -q "ocr_translate_region.sh" "$LUA_BINDS"; then
        echo -e "${YELLOW}Добавление биндов в $LUA_BINDS...${NC}"
        cat << 'KEYBINDS' >> "$LUA_BINDS"

-- Google Translator (Popup - выделение или ручной ввод)
create_bind({ "SUPER + T", "SUPER + Cyrillic_ie" }, hl.dsp.exec_cmd("qs -c end4-pC ipc call translator toggle"))

-- Region OCR Translator (Выделение области экрана через slurp)
create_bind({ "SUPER + SHIFT + T", "SUPER + SHIFT + Cyrillic_ie" }, hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/quickshell/end4-pC/scripts/ocr_translate_region.sh"))
KEYBINDS
    fi
elif [ -f "$CONF_BINDS" ]; then
    if ! grep -q "ocr_translate_region.sh" "$CONF_BINDS"; then
        echo -e "${YELLOW}Добавление биндов в $CONF_BINDS...${NC}"
        cat << 'KEYBINDS' >> "$CONF_BINDS"

# Translator Keybinds
bind = SUPER, T, exec, qs -c end4-pC ipc call translator toggle
bind = SUPER SHIFT, T, exec, ~/.config/quickshell/end4-pC/scripts/ocr_translate_region.sh
KEYBINDS
    fi
fi

# Reload Hyprland
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}        Установка успешно завершена! 🎉            ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "Горячие клавиши:"
echo -e "  • ${YELLOW}Super + T${NC}       — Быстрый перевод выделенного текста"
echo -e "  • ${YELLOW}Super + Shift + T${NC} — Перевод выделенной области экрана (Google Lens)"
echo -e "  • Переключатель ${YELLOW}[ IT-сленг ]${NC} активен по умолчанию в шапке окна."
