pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import "TechGlossary.js" as TechGlossary

Scope {
    id: root

    IpcHandler {
        target: "translatorService"

        function translateText(text: string): void {
            GlobalStates.translatorOpen = true;
            let clean = text ? text.trim() : "";
            if (clean.length > 0) {
                let hasCyrillic = /[а-яёА-ЯЁ]/.test(clean);
                if (hasCyrillic) {
                    card.sourceLang = "ru";
                    card.targetLang = "en";
                } else {
                    card.sourceLang = "en";
                    card.targetLang = "ru";
                }
                sourceInput.text = clean;
                sourceInput.selectAll();
                card.translate();
            }
        }
    }

    readonly property real popupWidth: 480
    readonly property real popupHeight: 520
    readonly property real popupRounding: Appearance.rounding.window

    PanelWindow {
        id: panelWindow
        visible: GlobalStates.translatorOpen
        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.namespace: "quickshell:googleTranslator"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: GlobalStates.translatorOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        onVisibleChanged: {
            if (visible) {
                pastePrimaryProc.running = true;
                Qt.callLater(() => {
                    sourceInput.forceActiveFocus();
                });
            }
        }

        // Clicking outside the card closes the translator
        MouseArea {
            anchors.fill: parent
            onClicked: {
                GlobalStates.translatorOpen = false;
            }
        }

        // Main Glassmorphic Container Card matching shell theme
        Rectangle {
            id: card
            anchors.centerIn: parent
            width: root.popupWidth
            height: root.popupHeight
            radius: root.popupRounding
            color: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.96)
            border.color: Appearance.colors.colLayer0Border
            border.width: 1

            layer.enabled: true
            layer.effect: DropShadow {
                color: "#60000000"
                radius: 24
                samples: 25
                horizontalOffset: 0
                verticalOffset: 8
            }

            // Consume clicks inside card
            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    GlobalStates.translatorOpen = false;
                    event.accepted = true;
                }
            }

            // Internal state
            property string sourceLang: GlobalStates.translatorSourceLang || "en"
            property string targetLang: GlobalStates.translatorTargetLang || "ru"
            property string translatedText: ""
            property bool isTranslating: false
            property bool showCopied: false
            property bool itMode: true

            function translate() {
                let text = sourceInput.text ? sourceInput.text.trim() : "";
                if (text.length === 0) {
                    card.translatedText = "";
                    card.isTranslating = false;
                    return;
                }
                card.isTranslating = true;
                let url = "https://clients5.google.com/translate_a/t?client=dict-chrome-ex"
                    + "&sl=" + encodeURIComponent(card.sourceLang)
                    + "&tl=" + encodeURIComponent(card.targetLang)
                    + "&q=" + encodeURIComponent(text);

                let xhr = new XMLHttpRequest();
                xhr.open("GET", url);
                xhr.setRequestHeader("User-Agent", "Mozilla/5.0");
                xhr.timeout = 10000;
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        card.isTranslating = false;
                        if (xhr.status === 200) {
                            try {
                                let res = JSON.parse(xhr.responseText);
                                let rawResult = "";
                                if (Array.isArray(res)) {
                                    rawResult = res.join("\n");
                                } else if (typeof res === "string") {
                                    rawResult = res;
                                } else {
                                    rawResult = xhr.responseText;
                                }

                                if (card.itMode) {
                                    card.translatedText = TechGlossary.enhance(text, rawResult, card.sourceLang, card.targetLang);
                                } else {
                                    card.translatedText = rawResult;
                                }
                            } catch(e) {
                                card.translatedText = xhr.responseText;
                            }
                        } else {
                            card.translatedText = "Ошибка соединения (" + xhr.status + ")";
                        }
                    }
                };
                xhr.ontimeout = function() {
                    card.isTranslating = false;
                    card.translatedText = "Превышено время ожидания";
                };
                xhr.onerror = function() {
                    card.isTranslating = false;
                    card.translatedText = "Ошибка сети";
                };
                xhr.send();
            }

            function swap() {
                let temp = card.sourceLang;
                card.sourceLang = card.targetLang;
                card.targetLang = temp;
                GlobalStates.translatorSourceLang = card.sourceLang;
                GlobalStates.translatorTargetLang = card.targetLang;

                if (card.translatedText.length > 0) {
                    let oldTranslation = card.translatedText;
                    sourceInput.text = oldTranslation;
                    card.translate();
                } else if (sourceInput.text.trim().length > 0) {
                    card.translate();
                }
            }

            Timer {
                id: debounceTimer
                interval: 350
                repeat: false
                onTriggered: card.translate()
            }

            Timer {
                id: copiedTimer
                interval: 2000
                onTriggered: card.showCopied = false
            }

            // Clipboard process
            Process {
                id: pasteProc
                command: ["wl-paste", "--type", "text"]
                property string buffer: ""
                stdout: SplitParser {
                    onRead: data => {
                        pasteProc.buffer += data + "\n";
                    }
                }
                onExited: (code, status) => {
                    let clean = pasteProc.buffer.trim();
                    pasteProc.buffer = "";
                    if (code === 0 && clean.length > 0 && clean !== "Nothing is copied") {
                        sourceInput.text = clean;
                        sourceInput.cursorPosition = clean.length;
                        card.translate();
                    }
                }
            }

            // Primary selection process (mouse selection in any app)
            Process {
                id: pastePrimaryProc
                command: ["wl-paste", "--primary", "--type", "text"]
                property string buffer: ""
                stdout: SplitParser {
                    onRead: data => {
                        pastePrimaryProc.buffer += data + "\n";
                    }
                }
                onExited: (code, status) => {
                    let clean = pastePrimaryProc.buffer.trim();
                    pastePrimaryProc.buffer = "";
                    if (code === 0 && clean.length > 0 && clean !== "Nothing is copied") {
                        let hasCyrillic = /[а-яёА-ЯЁ]/.test(clean);
                        if (hasCyrillic) {
                            card.sourceLang = "ru";
                            card.targetLang = "en";
                        } else {
                            card.sourceLang = "en";
                            card.targetLang = "ru";
                        }
                        sourceInput.text = clean;
                        sourceInput.selectAll();
                        card.translate();
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                // ==========================================
                // 1. Header (Icon + Title + Close Button)
                // ==========================================
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: Appearance.rounding.full
                        color: Appearance.colors.colPrimaryContainer

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "g_translate"
                            iconSize: 20
                            color: Appearance.colors.colOnPrimaryContainer
                        }
                    }

                    StyledText {
                        text: "Google Переводчик"
                        font.pixelSize: Appearance.font.pixelSize.large
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colOnLayer1
                    }

                    // IT Slang mode toggle chip
                    Rectangle {
                        implicitHeight: 24
                        implicitWidth: itRow.implicitWidth + 14
                        radius: Appearance.rounding.full
                        color: card.itMode ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer1
                        border.color: card.itMode ? Appearance.colors.colPrimary : Appearance.colors.colLayer0Border
                        border.width: 1

                        RowLayout {
                            id: itRow
                            anchors.centerIn: parent
                            spacing: 4

                            MaterialSymbol {
                                text: "terminal"
                                iconSize: 13
                                color: card.itMode ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext
                            }

                            StyledText {
                                text: "IT-сленг"
                                font.pixelSize: 11
                                font.weight: Font.SemiBold
                                color: card.itMode ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                card.itMode = !card.itMode;
                                if (sourceInput.text.trim().length > 0) {
                                    card.translate();
                                }
                            }
                        }

                        StyledToolTip {
                            text: card.itMode ? "IT-режим включен (сленг программистов и термины)" : "Включить адаптацию IT-сленга"
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Close button
                    Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: Appearance.rounding.full
                        color: closeMouse.containsMouse ? Appearance.colors.colLayer1Hover : "transparent"

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "close"
                            iconSize: 18
                            color: closeMouse.containsMouse ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: GlobalStates.translatorOpen = false
                        }
                    }
                }

                // ==========================================
                // 2. Language Bar (Source ⇄ Target)
                // ==========================================
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 40
                    radius: Appearance.rounding.normal
                    color: ColorUtils.applyAlpha(Appearance.colors.colLayer2Base, 0.94)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 6

                        // Source Language Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Appearance.rounding.normal - 2
                            color: card.sourceLang === "en" ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer1

                            StyledText {
                                anchors.centerIn: parent
                                text: card.sourceLang === "en" ? "Английский (EN)" : "Русский (RU)"
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                                color: card.sourceLang === "en" ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer1
                            }
                        }

                        // Swap Button
                        Rectangle {
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: Appearance.rounding.full
                            color: swapMouse.containsMouse ? Appearance.colors.colLayer1Hover : "transparent"

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "swap_horiz"
                                iconSize: 20
                                color: Appearance.colors.colPrimary
                            }

                            MouseArea {
                                id: swapMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: card.swap()
                            }
                        }

                        // Target Language Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Appearance.rounding.normal - 2
                            color: card.targetLang === "ru" ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer1

                            StyledText {
                                anchors.centerIn: parent
                                text: card.targetLang === "ru" ? "Русский (RU)" : "Английский (EN)"
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                                color: card.targetLang === "ru" ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer1
                            }
                        }
                    }
                }

                // ==========================================
                // 3. Input Section (Source text)
                // ==========================================
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Appearance.rounding.normal
                    color: ColorUtils.applyAlpha(Appearance.colors.colLayer2Base, 0.94)
                    border.color: sourceInput.activeFocus ? Appearance.colors.colPrimary : Appearance.colors.colLayer0Border
                    border.width: sourceInput.activeFocus ? 2 : 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        // Top action row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            StyledText {
                                text: card.sourceLang === "en" ? "Исходный текст (EN)" : "Исходный текст (RU)"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.DemiBold
                                color: Appearance.colors.colSubtext
                            }

                            Item { Layout.fillWidth: true }

                            // Paste from clipboard button
                            Rectangle {
                                implicitWidth: pasteRow.implicitWidth + 12
                                implicitHeight: 26
                                radius: Appearance.rounding.full
                                color: pasteMouse.containsMouse ? Appearance.colors.colLayer1Hover : Appearance.colors.colLayer1
                                border.color: Appearance.colors.colLayer0Border
                                border.width: 1

                                RowLayout {
                                    id: pasteRow
                                    anchors.centerIn: parent
                                    spacing: 4
                                    MaterialSymbol { text: "content_paste"; iconSize: 14; color: Appearance.colors.colPrimary }
                                    StyledText { text: "Вставить"; font.pixelSize: Appearance.font.pixelSize.smaller; color: Appearance.colors.colOnLayer1 }
                                }

                                MouseArea {
                                    id: pasteMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: pasteProc.running = true
                                }
                            }

                            // Paste primary selection button
                            Rectangle {
                                implicitWidth: selRow.implicitWidth + 12
                                implicitHeight: 26
                                radius: Appearance.rounding.full
                                color: selMouse.containsMouse ? Appearance.colors.colLayer1Hover : Appearance.colors.colLayer1
                                border.color: Appearance.colors.colLayer0Border
                                border.width: 1

                                RowLayout {
                                    id: selRow
                                    anchors.centerIn: parent
                                    spacing: 4
                                    MaterialSymbol { text: "format_quote"; iconSize: 14; color: Appearance.colors.colPrimary }
                                    StyledText { text: "Выделение"; font.pixelSize: Appearance.font.pixelSize.smaller; color: Appearance.colors.colOnLayer1 }
                                }

                                MouseArea {
                                    id: selMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: pastePrimaryProc.running = true
                                }
                            }

                            // Clear button
                            Rectangle {
                                visible: sourceInput.text.length > 0
                                implicitWidth: 26
                                implicitHeight: 26
                                radius: Appearance.rounding.full
                                color: clearMouse.containsMouse ? Appearance.colors.colLayer1Hover : "transparent"

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "backspace"
                                    iconSize: 14
                                    color: Appearance.colors.colSubtext
                                }

                                MouseArea {
                                    id: clearMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        sourceInput.text = "";
                                        card.translatedText = "";
                                    }
                                }
                            }
                        }

                        // Text Area
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            TextArea {
                                id: sourceInput
                                wrapMode: TextEdit.Wrap
                                placeholderText: card.sourceLang === "en"
                                    ? "Введите или вставьте текст на английском..."
                                    : "Введите или вставьте текст на русском..."
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer2
                                placeholderTextColor: Appearance.colors.colSubtext
                                background: null
                                selectByMouse: true
                                topPadding: 4
                                bottomPadding: 4
                                leftPadding: 2
                                rightPadding: 2

                                onTextChanged: {
                                    debounceTimer.restart();
                                }

                                Keys.onReturnPressed: (event) => {
                                    if (event.modifiers === Qt.ControlModifier) {
                                        debounceTimer.stop();
                                        card.translate();
                                        event.accepted = true;
                                    } else {
                                        event.accepted = false;
                                    }
                                }
                            }
                        }

                        // Bottom info (character count)
                        RowLayout {
                            Layout.fillWidth: true
                            Item { Layout.fillWidth: true }
                            StyledText {
                                text: sourceInput.text.length + " символов"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }
                        }
                    }
                }

                // ==========================================
                // 4. Output Section (Target translation)
                // ==========================================
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Appearance.rounding.normal
                    color: ColorUtils.applyAlpha(Appearance.colors.colLayer2Base, 0.94)
                    border.color: Appearance.colors.colLayer0Border
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        // Top action row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            StyledText {
                                text: card.targetLang === "ru" ? "Перевод (Русский)" : "Перевод (Английский)"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.DemiBold
                                color: Appearance.colors.colPrimary
                            }

                            RowLayout {
                                visible: card.isTranslating
                                spacing: 4
                                MaterialSymbol {
                                    text: "sync"
                                    iconSize: 14
                                    color: Appearance.colors.colPrimary
                                    RotationAnimation on rotation {
                                        from: 0
                                        to: 360
                                        duration: 1000
                                        loops: Animation.Infinite
                                    }
                                }
                                StyledText {
                                    text: "Переводим..."
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colPrimary
                                }
                            }

                            Item { Layout.fillWidth: true }

                            // Copy button
                            Rectangle {
                                visible: card.translatedText.length > 0
                                implicitWidth: copyRow.implicitWidth + 14
                                implicitHeight: 26
                                radius: Appearance.rounding.full
                                color: card.showCopied
                                    ? Appearance.colors.colPrimary
                                    : (copyMouse.containsMouse ? Appearance.colors.colPrimaryContainerHover : Appearance.colors.colPrimaryContainer)

                                RowLayout {
                                    id: copyRow
                                    anchors.centerIn: parent
                                    spacing: 4
                                    MaterialSymbol {
                                        text: card.showCopied ? "check" : "content_copy"
                                        iconSize: 14
                                        color: card.showCopied ? Appearance.colors.colOnPrimary : Appearance.colors.colOnPrimaryContainer
                                    }
                                    StyledText {
                                        text: card.showCopied ? "Скопировано!" : "Копировать"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        font.weight: Font.Medium
                                        color: card.showCopied ? Appearance.colors.colOnPrimary : Appearance.colors.colOnPrimaryContainer
                                    }
                                }

                                MouseArea {
                                    id: copyMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Quickshell.execDetached(["wl-copy", card.translatedText]);
                                        card.showCopied = true;
                                        copiedTimer.restart();
                                    }
                                }
                            }
                        }

                        // Translation Text Display
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            TextArea {
                                readOnly: true
                                wrapMode: TextEdit.Wrap
                                text: card.translatedText
                                placeholderText: "Перевод появится здесь..."
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: card.translatedText.length > 0 ? Font.Medium : Font.Normal
                                color: card.translatedText.length > 0 ? Appearance.colors.colOnLayer2 : Appearance.colors.colSubtext
                                placeholderTextColor: Appearance.colors.colSubtext
                                background: null
                                selectByMouse: true
                                topPadding: 4
                                bottomPadding: 4
                                leftPadding: 2
                                rightPadding: 2
                            }
                        }
                    }
                }
            }
        }
    }
}
