# 🌐 Hypr-Translator & Screen Lens for Hyprland

Умный и быстрый переводчик текста и экрана для **Hyprland + Quickshell**, оптимизированный под программистов и разработчиков.

![Bash](https://img.shields.io/badge/Language-Bash%20%7C%20QML%20%7C%20JS-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Wayland](https://img.shields.io/badge/Wayland-Hyprland-orange)

---

## ⚡ Особенности

* 🎯 **Перевод выделенного текста (`Super + T`)**: Просто выделите любой текст мышкой в любой программе (браузер, IDE, Telegram, терминал) и нажмите `Super + T` — переводчик мгновенно откроется с готовым переводом.
* 📷 **Перевод области экрана (`Super + Shift + T`)**: Как в Google Lens / ножницах Windows. Обведите мышкой фрагмент экрана, картинку, субтитр или окно ошибки — система распознает текст через `Tesseract` (поддерживает и светлую, и тёмную тему) и переведет его.
* 💻 **Режим «IT-сленг»**: Встроенная база 100+ профессиональных понятий и умный постпроцессор. Исправляет машинные ошибки:
  * `boilerplate` → *шаблонный код (бойлерплейт)* (а не «пластина котла»)
  * `deprecated` → *устарело / не рекомендуется* (а не «осуждаемый метод»)
  * `thread pool` → *пул потоков* (а не «бассейн нитей»)
  * `race condition` → *состояние гонки* (а не «состояние расы»)
  * `out of the box` → *из коробки*
  * `PR`, `MR`, `LGTM`, `WIP`, `middleware`, `payload`, `stack trace`, `deadlock`, `handler`, `refactoring` и т.д.
* 🌐 **Двуязычный OCR (ENG + RUS)**: Распознает как английский, так и русский текст без мусора и артефактов.
* ⌨️ **Работает в любой раскладке**: Бинды срабатывают как в английской, так и в русской раскладке клавиатуры.

---

## 🚀 Быстрая установка (в одну команду)

Просто откройте терминал на компьютере и выполните:

```bash
curl -sSL https://raw.githubusercontent.com/qubertuwu/hypr-translator/main/install.sh | bash
```

*Или через ручное клонирование:*
```bash
git clone https://github.com/qubertuwu/hypr-translator.git
cd hypr-translator
./install.sh
```

---

## 📦 Системные зависимости

Скрипт установки сам проверит и предложит установить их, но при желании можно поставить заранее:

* **Arch Linux / CachyOS / Manjaro:**
  ```bash
  sudo pacman -S tesseract tesseract-data-eng tesseract-data-rus grim slurp imagemagick wl-clipboard
  ```
* **Ubuntu / Debian / Linux Mint:**
  ```bash
  sudo apt install tesseract-ocr tesseract-ocr-eng tesseract-ocr-rus grim slurp imagemagick wl-clipboard
  ```
* **Fedora:**
  ```bash
  sudo dnf install tesseract tesseract-langpack-eng tesseract-langpack-rus grim slurp ImageMagick wl-clipboard
  ```

---

## ⌨️ Горячие клавиши

| Комбинация | Действие |
|---|---|
| **`Super + T`** | Быстрый перевод выделенного мышью текста |
| **`Super + Shift + T`** | Выделение прямоугольной области на экране для перевода (Esc для отмены) |
| **`Esc`** | Закрыть окно переводчика |

---

## 📄 Лицензия
MIT License. Свободно для использования и модификации.
