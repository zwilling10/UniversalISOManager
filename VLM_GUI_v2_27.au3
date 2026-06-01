; ==========================================
; Module: VLM_GUI.au3
; Part of UniversalISOManager
; ==========================================

#include-once

Func _FirstRunSetup()
    ; Liest BaseDir aus vlm_settings.ini.
    ; Falls bereits gesetzt und Ordner vorhanden → Pfade anwenden, fertig.
    ; Sonst: Auswahl-Dialog anzeigen (erster Start oder Ordner fehlt).
    Local $sBaseDir = IniRead($SETTINGS_INI, "Paths", "BaseDir", "")
    If $sBaseDir <> "" And FileExists($sBaseDir) Then
        _ApplyBaseDir($sBaseDir)
        Return
    EndIf

    ; ── Dialog ─────────────────────────────────────────────────────────────
    Local $sDefault = @MyDocumentsDir & "\UniversalISOManager"
    Local $iW = 580, $iH = 400
    Local $hDlg = GUICreate("UniversalISOManager — Arbeitsordner einrichten", $iW, $iH, -1, -1, _
        BitOR(0x00C00000, 0x00080000, 0x00040000), $WS_EX_DROPSHADOW)
    GUISetBkColor($C_W, $hDlg)
    GUISetFont(9, 400, 0, "Segoe UI")

    ; ── Header ──────────────────────────────────────────────────────────────
    GUICtrlCreateLabel("", 0, 0, $iW, 70)
    GUICtrlSetBkColor(-1, 0x1A2B3C)
    GUICtrlSetState(-1, $GUI_DISABLE)

    GUICtrlCreateLabel("📁  Arbeitsordner einrichten", 20, 12, $iW - 40, 24)
    GUICtrlSetFont(-1, 13, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUICtrlSetBkColor(-1, 0x1A2B3C)

    GUICtrlCreateLabel("Wählen Sie, wo ISO-Dateien und Einstellungen gespeichert werden.", 20, 44, $iW - 40, 16)
    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0xC5D5E5)
    GUICtrlSetBkColor(-1, 0x1A2B3C)

    ; ── Ordnerpfad ──────────────────────────────────────────────────────────
    GUICtrlCreateLabel("Speicherort für ISO-Downloads und Einstellungsdateien:", 20, 88, $iW - 40, 14)
    GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, $C_W)

    Local $hPath   = GUICtrlCreateInput($sDefault, 20, 108, $iW - 126, 28, 0x80)   ; ES_AUTOHSCROLL
    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_TXT)

    Local $hBrowse = GUICtrlCreateButton("📂  Durchsuchen", $iW - 98, 108, 88, 28)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")

    ; ── Trennlinie ──────────────────────────────────────────────────────────
    GUICtrlCreateLabel("", 20, 148, $iW - 40, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── Vorschau ────────────────────────────────────────────────────────────
    GUICtrlCreateLabel("Folgende Elemente werden angelegt:", 20, 158, $iW - 40, 14)
    GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, $C_W)

    Local $hPreview = GUICtrlCreateLabel("", 20, 178, $iW - 40, 80)
    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_CARD)

    ; ── Hinweis ─────────────────────────────────────────────────────────────
    GUICtrlCreateLabel("ℹ  vlm_settings.ini bleibt neben der EXE  —  alle anderen Dateien kommen in den gewählten Ordner.", _
        20, 270, $iW - 40, 14)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, $C_W)

    ; ── Trennlinie ──────────────────────────────────────────────────────────
    GUICtrlCreateLabel("", 0, $iH - 56, $iW, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── Buttons ─────────────────────────────────────────────────────────────
    Local $hOK   = GUICtrlCreateButton("✔  Ordner anlegen & starten", 20, $iH - 46, 220, 34)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, $C_W)
    GUICtrlSetBkColor(-1, $C_BLUE)

    Local $hSkip = GUICtrlCreateButton("Standard-Pfad übernehmen", $iW - 204, $iH - 46, 190, 34)
    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_TXT)

    ; ── Vorschau initialisieren ──────────────────────────────────────────────
    _UpdateFolderPreview($hPreview, $sDefault)
    GUISetState(@SW_SHOW, $hDlg)

    Local $sChosen    = $sDefault
    Local $sLastInput = $sDefault

    ; ── Ereignis-Schleife ────────────────────────────────────────────────────
    While True
        Local $nMsg = GUIGetMsg()
        Select
            Case $nMsg = $GUI_EVENT_CLOSE
                ; Fenster geschlossen → Standard verwenden
                ExitLoop
            Case $nMsg = $hSkip
                $sChosen = $sDefault
                ExitLoop
            Case $nMsg = $hBrowse
                Local $sPick = FileSelectFolder( _
                    "Ordner für UniversalISOManager wählen:", "", 1, GUICtrlRead($hPath))
                If $sPick <> "" Then
                    GUICtrlSetData($hPath, $sPick)
                    _UpdateFolderPreview($hPreview, $sPick)
                    $sLastInput = $sPick
                EndIf
            Case $nMsg = $hOK
                Local $sInput = StringStripWS(GUICtrlRead($hPath), 3)
                $sChosen = ($sInput <> "") ? $sInput : $sDefault
                ExitLoop
        EndSelect
        ; Live-Vorschau bei Texteingabe
        Local $sCur = GUICtrlRead($hPath)
        If $sCur <> $sLastInput And StringLen($sCur) > 2 Then
            _UpdateFolderPreview($hPreview, $sCur)
            $sLastInput = $sCur
        EndIf
    WEnd

    GUIDelete($hDlg)

    ; ── Ordner anlegen ───────────────────────────────────────────────────────
    If Not FileExists($sChosen)              Then DirCreate($sChosen)
    If Not FileExists($sChosen & "\ISOs")  Then DirCreate($sChosen & "\ISOs")

    ; ── Einstellung speichern ────────────────────────────────────────────────
    IniWrite($SETTINGS_INI, "Paths", "BaseDir", $sChosen)

    ; ── Pfad-Variablen anwenden ──────────────────────────────────────────────
    _ApplyBaseDir($sChosen)
EndFunc

Func _ShowWelcome()
    ; Einstellung prüfen — falls "Nicht anzeigen" aktiv, direkt zurück
    If IniRead($SETTINGS_INI, "Display", "skip_welcome", "0") = "1" Then Return

    Local $iW = 540, $iH = 530
    Local $hW = GUICreate("Willkommen — Universal ISO Manager", $iW, $iH, -1, -1, _
        BitOR(0x00C00000, 0x00080000, 0x00040000))   ; WS_CAPTION|WS_SYSMENU|WS_DLGFRAME
    GUISetBkColor(0xFFFFFF, $hW)

    ; ── Glary-style Header: weißer Hintergrund, Glary-Blau Akzentbalken ─────
    ; Hintergrund
    GUICtrlCreateLabel("", 0, 0, $iW, 80)
    GUICtrlSetBkColor(-1, 0xFFFFFF)
    GUICtrlSetState(-1, $GUI_DISABLE)
    ; Linker Akzentstreifen (Glary Corporate Blue)
    GUICtrlCreateLabel("", 0, 0, 5, 80)
    GUICtrlSetBkColor(-1, 0x0075BE)
    GUICtrlSetState(-1, $GUI_DISABLE)
    ; Trennlinie
    GUICtrlCreateLabel("", 0, 80, $iW, 1)
    GUICtrlSetBkColor(-1, 0xD1D1D6)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; Logo-Box — echtes Logo wie im Hauptfenster
    _WriteLogo($g_sLogoFile)
    GUICtrlCreatePic($g_sLogoFile, 20, 20, 40, 40)

    ; Titel — Glary: Segoe UI Semibold, dunkel auf weiss
    GUICtrlCreateLabel("Universal ISO Manager", 76, 20, 380, 24)
    GUICtrlSetFont(-1, 13, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, 0x1D1D1F)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    GUICtrlCreateLabel("USB-Stick einrichten  ·  Linux ISOs herunterladen", 76, 48, 400, 14)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0x6E6E73)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    ; ── Beschreibung ─────────────────────────────────────────────────────
    Local $sTxt = "Dieses Tool vereinfacht das Einrichten von Ventoy-USB-Sticks" & @CRLF & _
        "und das Herunterladen von Linux-Distributionen und Rescue-Systemen," & @CRLF & _
        "sortiert nach Kategorie und Popularität. (v2.27)"
    GUICtrlCreateLabel($sTxt, 22, 94, $iW - 42, 50)
    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0x1D1D1F)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    ; ── Trennlinie (Glary Separator) ─────────────────────────────────────
    GUICtrlCreateLabel("", 22, 150, $iW - 44, 1)
    GUICtrlSetBkColor(-1, 0xD1D1D6)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── Vorteile-Liste ────────────────────────────────────────────────────
    GUICtrlCreateLabel("Funktionen:", 22, 160, 300, 16)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, 0x0075BE)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    Local $aVorteile[7] = [ _
        "Ventoy auf USB-Stick installieren & aktualisieren", _
        "USB-Stick mit einem Klick als ExFAT formatieren", _
        "Kuratierte Linux-ISOs und Rescue-Systeme direkt herunterladen (mit Fortschrittsanzeige)", _
        "ISO-Dateien auf den Ventoy-Stick kopieren", _
        "Veraltete ISOs auf dem Stick automatisch erkennen und updaten", _
        "Mehrere Downloads gleichzeitig mit Gesamtfortschritt", _
        "Stabile Download-Spiegel weltweit (RWTH, FAU, dotsrc ...)"]

    Local $j
    For $j = 0 To 6
        Local $yPos = 180 + $j * 24
        ; Kleiner blauer Bullet
        GUICtrlCreateLabel("●", 22, $yPos, 14, 16)
        GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")
        GUICtrlSetColor(-1, 0x0075BE)
        GUICtrlSetBkColor(-1, 0xFFFFFF)
        GUICtrlCreateLabel($aVorteile[$j], 40, $yPos, $iW - 60, 16)
        GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
        GUICtrlSetColor(-1, 0x1D1D1F)
        GUICtrlSetBkColor(-1, 0xFFFFFF)
    Next

    ; ── Disclaimer / Haftungsausschluss ───────────────────────────────────
    GUICtrlCreateLabel("", 22, 355, $iW - 44, 66)
    GUICtrlSetBkColor(-1, 0xF9FAFB)   ; Ganz helles Grau
    GUICtrlSetState(-1, $GUI_DISABLE)
    Local $sDisclaimer = "⚠️ Wichtiger Hinweis: Die Nutzung dieser Software erfolgt auf eigene Gefahr. " & _
        "Der Ersteller übernimmt keine Haftung für Schäden am System, " & _
        "Hardwaredefekte oder Datenverluste."
    GUICtrlCreateLabel($sDisclaimer, 30, 362, $iW - 60, 52)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0x6E6E73)
    GUICtrlSetBkColor(-1, 0xF9FAFB)

    ; ── Trennlinie ────────────────────────────────────────────────────────
    GUICtrlCreateLabel("", 22, 430, $iW - 44, 1)
    GUICtrlSetBkColor(-1, 0xD1D1D6)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── v14.15: "Beim nächsten Start nicht anzeigen" Checkbox ─────────
    Local $hChkSkip = GUICtrlCreateCheckbox("Beim nächsten Start nicht anzeigen", 22, 440, 340, 22)
    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0x6E6E73)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    ; ── Trennlinie über Button ─────────────────────────────────────────
    GUICtrlCreateLabel("", 22, 470, $iW - 44, 1)
    GUICtrlSetBkColor(-1, 0xD1D1D6)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── OK-Button — Glary: Corporate Blue, primäre Aktion ─────────────────
    Local $hBtn = GUICtrlCreateButton("  Los geht's  ", $iW / 2 - 75, 482, 150, 36)
    GUICtrlSetFont(-1, 10, 700, 0, "Segoe UI Semibold")
    GUICtrlSetBkColor(-1, 0x0075BE)
    GUICtrlSetColor(-1, 0xFFFFFF)

    GUISetState(@SW_SHOW, $hW)

    ; Warte auf OK oder Schliessen
    While 1
        Local $mW = GUIGetMsg()
        If $mW = $hBtn Or $mW = $GUI_EVENT_CLOSE Then ExitLoop
    WEnd

    ; Einstellung speichern wenn Checkbox gesetzt
    If GUICtrlRead($hChkSkip) = $GUI_CHECKED Then
        IniWrite($SETTINGS_INI, "Display", "skip_welcome", "1")
    EndIf

    GUIDelete($hW)
EndFunc

Func _ShowModeSelection()
    Local $iW = 460, $iH = 260
    Local $hDlg = GUICreate("Startmodus wählen — VLM", $iW, $iH, -1, -1, BitOR($WS_CAPTION, $WS_SYSMENU), $WS_EX_DROPSHADOW)
    GUISetBkColor($C_W)
    GUISetFont(9, 400, 0, "Segoe UI")

    ; --- Header (Glary Style) ---
    GUICtrlCreateLabel("", 0, 0, $iW, 60)
    GUICtrlSetBkColor(-1, 0x122650) ; Deep Navy
    GUICtrlCreateLabel("  Wie möchten Sie das Programm heute nutzen?", 20, 18, $iW - 40, 26)
    GUICtrlSetFont(-1, 11, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUICtrlSetBkColor(-1, 0x122650)

    ; --- Auswahl-Bereich ---
    ; Anwender-Modus Karte
    Local $hBtnSimple = GUICtrlCreateButton("👤" & @CRLF & "ANWENDER" & @CRLF & "(Einfach)", 30, 85, 190, 110, $BS_MULTILINE)
    GUICtrlSetFont(-1, 10, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, 0xE1F0FF) ; Soft Blue
    GUICtrlSetColor(-1, $C_BLUE)

    ; Experten-Modus Karte
    Local $hBtnExpert = GUICtrlCreateButton("🛠️" & @CRLF & "EXPERTE" & @CRLF & "(Alle Tools)", 240, 85, 190, 110, $BS_MULTILINE)
    GUICtrlSetFont(-1, 10, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, 0xF2F4F6) ; Light Gray
    GUICtrlSetColor(-1, $C_MID)

    ; Footer Hinweis
    GUICtrlCreateLabel("ℹ Sie können den Modus jederzeit oben rechts im Programm wechseln.", 0, 215, $iW, 20, $SS_CENTER)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)

    GUISetState(@SW_SHOW, $hDlg)

    While 1
        Local $msg = GUIGetMsg()
        If $msg = $hBtnSimple Then
            $g_bExpertMode = False
            ExitLoop
        ElseIf $msg = $hBtnExpert Then
            $g_bExpertMode = True
            ExitLoop
        ElseIf $msg = $GUI_EVENT_CLOSE Then
            $g_bExpertMode = False ; Default
            ExitLoop
        EndIf
    WEnd
    
    GUIDelete($hDlg)
    IniWrite($SETTINGS_INI, "App", "ExpertMode", ($g_bExpertMode ? "1" : "0"))
EndFunc

Func _CreateGUI()
    Local $iW = 980, $iH = 780
    $g_hMain = GUICreate($APP_TITLE, $iW, $iH, -1, -1, _
        BitOR($WS_SIZEBOX,$WS_SYSMENU,$WS_CAPTION,$WS_MINIMIZEBOX,$WS_MAXIMIZEBOX))
    GUISetBkColor($C_BG)
    GUISetFont(9, 400, 0, "Segoe UI")

    ; === 1. TOP HEADER (Branding & Global Tools) ===
    $g_hHdrBg = GUICtrlCreateLabel("", 0, 0, $iW, 60)
    GUICtrlSetBkColor(-1, 0x1A3A66)
    GUICtrlSetState(-1, $GUI_DISABLE)
    $g_hHdrAccent = GUICtrlCreateLabel("", 0, 0, 5, 60)
    GUICtrlSetBkColor(-1, $C_BLUE)
    
    _WriteLogo($g_sLogoFile)
    $g_hLogoPic = GUICtrlCreatePic($g_sLogoFile, 12, 10, 40, 40)
    $g_hTitleLbl = GUICtrlCreateLabel("Universal ISO Manager", 60, 12, 300, 24)
    GUICtrlSetFont(-1, 12, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, 0xE8F4FD)
    GUICtrlSetBkColor(-1, 0x1A3A66)
    
    $g_hSubTitleLbl = GUICtrlCreateLabel("USB-Stick einrichten · Linux ISOs verwalten", 60, 36, 300, 14)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0x80B8D8)
    GUICtrlSetBkColor(-1, 0x1A3A66)

    $g_hBtnModeToggle = GUICtrlCreateButton("Modus: Anwender 👤", $iW - 180, 18, 112, 24)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, 0x2A4B7C)
    GUICtrlSetColor(-1, 0xFFFFFF)
    
    $g_hBtnHelp = GUICtrlCreateButton("❓ Hilfe", $iW - 62, 18, 50, 24)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_LBLU)
    GUICtrlSetColor(-1, $C_BLUE)

    ; === 2. DRIVE PANEL (Target Device Selection) ===
    $g_hDrivePanelBg = GUICtrlCreateLabel("", 8, 68, $iW - 16, 80)
    GUICtrlSetBkColor(-1, 0xEEF2F7) 
    GUICtrlSetState(-1, $GUI_DISABLE)
    
    $g_hDriveHdrLbl = GUICtrlCreateLabel("TARGET USB DEVICE", 20, 76, 150, 12)
    GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0x5A7A9A)
    GUICtrlSetBkColor(-1, 0xEEF2F7)

    $g_hDriveCombo = GUICtrlCreateCombo("", 20, 92, 240, 22, BitOR($CBS_DROPDOWNLIST,$CBS_SORT))
    $g_hBtnRefresh = GUICtrlCreateButton("↻", 265, 92, 28, 24)
    GUICtrlSetFont(-1, 11, 700, 0, "Segoe UI")

    $g_hBtnVentoy = GUICtrlCreateButton("Ventoy inst.", 305, 88, 120, 32)
    GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_LGRN)
    GUICtrlSetColor(-1, $C_GRN)

    $g_hChkSecureBoot = GUICtrlCreateCheckbox(" 🔒 Secure Boot", 440, 95, 110, 18)
    GUICtrlSetFont(-1, 8, 600, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0x4A6A8A)
    GUICtrlSetBkColor(-1, 0xEEF2F7)
    If $g_bSecureBoot Then GUICtrlSetState(-1, $GUI_CHECKED)

    $g_hStatusLbl = GUICtrlCreateLabel("Bereit.", 680, 85, $iW - 700, 18, $SS_RIGHT)
    GUICtrlSetFont(-1, 10, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_GRN)
    GUICtrlSetBkColor(-1, 0xEEF2F7)
    
    $g_hSpeedTestStatus = GUICtrlCreateLabel("", 680, 105, $iW - 700, 14, $SS_RIGHT)
    GUICtrlSetFont(-1, 7, 400, 2, "Segoe UI")
    GUICtrlSetColor(-1, $C_AMB)
    GUICtrlSetBkColor(-1, 0xEEF2F7)

    ; === 3. CONTENT TABS ===
    $g_hTab = GUICtrlCreateTab(8, 156, $iW - 16, $iH - 280)
    GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")

    $g_hTabItemISO = GUICtrlCreateTabItem(" ISO-Auswahl ")
    $g_hDistroLbl = GUICtrlCreateLabel("Linux-Distributionen  (Haken = Download)", 22, 186, 400, 15)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, 0x5A7A9A)
    GUICtrlSetBkColor(-1, $C_W)
    
    $g_hChkShowInfo = GUICtrlCreateCheckbox(" Info-Fenster (Mouseover) anzeigen", $iW - 240, 184, 220, 18)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0x5A7A9A)
    GUICtrlSetBkColor(-1, $C_W)
    GUICtrlSetState(-1, $GUI_CHECKED)
    
    $g_hTreeView = GUICtrlCreateTreeView(18, 208, $iW - 36, $iH - 373, _
        BitOR($TVS_HASBUTTONS,$TVS_HASLINES,$TVS_LINESATROOT,$TVS_CHECKBOXES,$TVS_SHOWSELALWAYS))
    
    $g_hSpeedLbl = GUICtrlCreateLabel("", 18, $iH - 158, 220, 15)
    GUICtrlSetColor(-1, $C_BLUE)
    GUICtrlSetBkColor(-1, $C_W)
    $g_hEtaLbl = GUICtrlCreateLabel("", 248, $iH - 158, 240, 15)
    GUICtrlSetColor(-1, $C_AMB)
    GUICtrlSetBkColor(-1, $C_W)
    $g_hProgress = GUICtrlCreateProgress(18, $iH - 140, $iW - 36, 12)

    $g_hTabItemLog = GUICtrlCreateTabItem("   Protokoll   ")
    $g_hLogEdit = GUICtrlCreateEdit("", 18, 190, $iW - 36, $iH - 330, _
        BitOR($ES_MULTILINE,$ES_READONLY,$ES_AUTOVSCROLL,$WS_VSCROLL))
    GUICtrlSetFont(-1, 9, 400, 0, "Consolas")
    GUICtrlSetBkColor(-1, $C_CARD)

    GUICtrlCreateTabItem("")

    ; === 4. ACTION BAR (Bottom) ===
    $g_hActionPanelBg = GUICtrlCreateLabel("", 0, $iH - 110, $iW, 110)
    GUICtrlSetBkColor(-1, $C_W)
    GUICtrlSetState(-1, $GUI_DISABLE)
    $g_hActionBorder = GUICtrlCreateLabel("", 0, $iH - 110, $iW, 1)
    GUICtrlSetBkColor(-1, $C_BRD)

    $g_hBtnDownload = GUICtrlCreateButton("  ⬇  Herunterladen", 18, $iH - 95, 250, 36)
    GUICtrlSetFont(-1, 10, 700, 0, "Segoe UI Semibold")
    GUICtrlSetBkColor(-1, $C_BLUE)
    GUICtrlSetColor(-1, 0xFFFFFF)

    $g_hBtnUpdates = GUICtrlCreateButton("  ↺  Updates prüfen", 276, $iH - 95, 210, 36)
    GUICtrlSetFont(-1, 10, 700, 0, "Segoe UI Semibold")
    GUICtrlSetBkColor(-1, $C_LAMB)
    GUICtrlSetColor(-1, $C_AMB)

    $g_hBtnCancel = GUICtrlCreateButton("  ✕  Stopp", 494, $iH - 95, 140, 36)
    GUICtrlSetFont(-1, 10, 700, 0, "Segoe UI Semibold")
    GUICtrlSetBkColor(-1, $C_LRED)
    GUICtrlSetColor(-1, $C_RED)

    $g_hBtnCheckURLs = GUICtrlCreateButton("URLs prüfen", 18, $iH - 50, 160, 28)
    GUICtrlSetBkColor(-1, $C_LBLU)
    GUICtrlSetColor(-1, $C_BLUE)

    $g_hBtnISOSearch = GUICtrlCreateButton("ISO suchen", 186, $iH - 50, 150, 28)
    GUICtrlSetBkColor(-1, $C_LAMB)
    GUICtrlSetColor(-1, $C_AMB)

    $g_hBtnEditDB = GUICtrlCreateButton("Datenbank", 344, $iH - 50, 140, 28)
    GUICtrlSetBkColor(-1, $C_LBLU)
    GUICtrlSetColor(-1, $C_BLUE)

    $g_hFooterLbl = GUICtrlCreateLabel("ISO-Ordner: " & $DOWNLOAD_DIR, 500, $iH - 43, $iW - 518, 14, $SS_RIGHT)
    GUICtrlSetFont(-1, 7, 400, 0, "Consolas")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, $C_W)

    GUISetState(@SW_SHOW, $g_hMain)
    DllCall("uxtheme.dll","int","SetWindowTheme","hwnd",GUICtrlGetHandle($g_hTreeView),"wstr","","wstr","")
    GUIRegisterMsg(0x004E, "_WM_NOTIFY")
    GUIRegisterMsg(0x0202, "_WM_LBUTTONUP")
    _Log("=== GUI Redesign v2.27 gestartet ===")
    _UpdateUIMode()
EndFunc

Func _FillTree()
    Local $hTV = GUICtrlGetHandle($g_hTreeView)
    _GUICtrlTreeView_DeleteAll($hTV)

    Local $aCats[8]  = ["Gaming","Sicherheit","Einsteiger","Leichtgewicht","Fortgeschrittene","Rettung","Antivirus","WinPE"]
    Local $aLabel[8] = [ _
        "  🎮  Gaming  (alle ankreuzen)", _
        "  🔒  Sicherheit & Privatsphäre  (alle ankreuzen)", _
        "  🖥  Einsteiger (Komfort & Design)  (alle ankreuzen)", _
        "  ⚡  Leichtgewicht (Geschwindigkeit & Effizienz)  (alle ankreuzen)", _
        "  🏗  Fortgeschrittene (Unabhängigkeit & Stabilität)  (alle ankreuzen)", _
        "  🛠  Rettung & Notfall-Systeme  (alle ankreuzen)", _
        "  🛡  Antivirus Live-Systeme  (alle ankreuzen)", _
        "  🪟  WinPE — Windows Preinstallation  (alle ankreuzen)"]

    For $c = 0 To 7
        $g_ahCatNodes[$c] = _GUICtrlTreeView_AddChild($hTV, 0, $aLabel[$c])
        _GUICtrlTreeView_SetBold($hTV, $g_ahCatNodes[$c], True)
        _GUICtrlTreeView_SetItemParam($hTV, $g_ahCatNodes[$c], $ISO_MAX)  ; Sentinel — Custom-Draw überspringt Kategorie-Knoten
        $g_abCatLast[$c] = False
    Next

    For $i = 0 To $ISO_COUNT - 1
        For $c = 0 To 7
            If $aCats[$c] = $g_aISOs[$i][1] Then
                Local $sFile  = $DOWNLOAD_DIR & "\" & $g_aISOs[$i][3]
                Local $sFileTmp = $TMP_DOWNLOAD_DIR & "\" & $g_aISOs[$i][3]  ; 
                Local $bLocal = (FileExists($sFile) And FileGetSize($sFile) > 1048576) Or _
                                (FileExists($sFileTmp) And FileGetSize($sFileTmp) > 1048576)  ; 
                ; URL-Check-Status
                Local $sURLStatus = ""
                If $g_abURLChecked[$i] Then
                    If $g_abURLOK[$i] Then
                        $sURLStatus = " 🌐✓"
                    Else
                        $sURLStatus = " 🌐✗"
                    EndIf
                EndIf
                ; neuere Version verfügbar
                If $g_asUpdateVer[$i] <> "" Then
                    $sURLStatus &= "  🆕 v" & $g_asUpdateVer[$i]
                EndIf
                Local $sSuffix
                If $bLocal Then
                    ; Größe aus TMP bevorzugen
                    Local $iSz = 0
                    If FileExists($sFileTmp) And FileGetSize($sFileTmp) > 1048576 Then
                        $iSz = FileGetSize($sFileTmp)
                    ElseIf FileExists($sFile) Then
                        $iSz = FileGetSize($sFile)
                    EndIf
                    $sSuffix = "     [OK geladen  " & _FmtBytes($iSz) & "]" & $sURLStatus
                Else
                    Switch $g_aiUSBStatus[$i]
                        Case 1
                            $sSuffix = "     [OK USB aktuell  " & $g_asUSBSize[$i] & "]" & $sURLStatus
                        Case 2
                            $sSuffix = "     [!] USB veraltet  " & $g_asUSBSize[$i] & "]" & $sURLStatus
                        Case 3
                            $sSuffix = "     [-] nicht auf Stick]" & $sURLStatus
                        Case Else
                            ; FIX: Falls bereits ein Scan-Laufwerk bekannt ist, aber Status 0, 
                            ;            bedeutet das 'nicht auf Stick' (statt generisch 'nicht geladen')
                            If $g_sLastScannedDrive <> "" Then
                                $sSuffix = "     [-] nicht auf Stick]" & $sURLStatus
                            Else
                                $sSuffix = "     [nicht geladen]" & $sURLStatus
                            EndIf
                    EndSwitch
                EndIf
                ; USB-Status in Anzeigefarbe einbeziehen
                ; Semantik: USB=1 → Grün (auf Stick, aktueller Dateiname)
                ;           USB=2 → Orange (auf Stick, aber Dateiname veraltet)
                ;           USB=3/0 → URL-Farbe bleibt (nicht auf Stick)
                ; $bLocal-Guard entfernt — USB-Farbe gilt unabhängig ob ISO auch
                ;         lokal heruntergeladen wurde. Verhindert orange Anzeige wenn ISO
                ;         gleichzeitig auf Stick (USB=1) UND lokal vorhanden ist.
                ; FIX: Switch → If/ElseIf, explizite Grau-Zuweisung für
                ;            kein-URL-ISOs (Stick-Imports ohne Mirror-Suche).
                ;            Verhindert Farbe=0 (Standard-Dunkelgrau statt Grau)
                ;            für frisch importierte ISOs ohne URL-Check.
                ; --- v2.23: DEFINITIVE FARBLOGIK (Berechnung aus Status-Variablen) ---
                ; v2.23: Stick-Import-Erkennung (Runtime-Flag ODER Tooltip-Marker)
                Local $bIsStickImport = $g_abImportedFromStick[$i] Or _
                    StringInStr($g_aISOs[$i][9], "Vom Stick importiert")

                Local $iColCode = 4  ; Standard: Grau

                If $bIsStickImport And Not $g_abURLChecked[$i] Then
                    ; Höchste Priorität: Stick-Import ohne URL-Bestätigung → Teal
                    $iColCode = 5
                ElseIf $g_sLastScannedDrive <> "" And ($g_aiUSBStatus[$i] = 0 Or $g_aiUSBStatus[$i] = 3) Then
                    ; 1. Priorität: Scan lief, ISO fehlt → IMMER Grau
                    $iColCode = 4
                ElseIf $g_aiUSBStatus[$i] = 1 Then
                    ; 2. Priorität: Auf Stick und aktuell → Grün
                    $iColCode = 1
                ElseIf $g_aiUSBStatus[$i] = 2 Then
                    ; 3. Priorität: Auf Stick aber veraltet → Orange
                    $iColCode = 2
                ElseIf $g_asUpdateVer[$i] <> "" Then
                    ; 4. Priorität: Update gefunden → Orange
                    $iColCode = 2
                ElseIf $g_abURLChecked[$i] Then
                    ; 5. Priorität: URL-Check Ergebnis
                    If $g_abURLOK[$i] Then
                        $iColCode = 1
                    Else
                        $iColCode = 3
                    EndIf
                Else
                    ; Fallback: kein URL gespeichert → Grau
                    If $g_aISOs[$i][2] = "" And $g_aISOs[$i][6] = "" Then
                        $iColCode = 4
                    Else
                        $iColCode = 0  ; Standard-Textfarbe
                    EndIf
                EndIf

                $g_aiNodeColor[$i] = $iColCode
                ; ---------------------------------------------------------------------

                ; v2.23: Stick-Import bekommt 📥-Präfix im Label
                Local $sImportPrefix = $bIsStickImport ? "📥 " : ""
                ; v2.24: MemBoot-Badge an $sSuffix anhängen
                If $g_abMemBoot[$i] Then $sSuffix &= "  [🧠 RAM]"
                $g_ahNodes[$i] = _GUICtrlTreeView_AddChild($hTV, $g_ahCatNodes[$c], _
                    "  " & $sImportPrefix & $g_aISOs[$i][0] & $sSuffix)
                _GUICtrlTreeView_SetItemParam($hTV, $g_ahNodes[$i], $i)
                $g_abNodeLast[$i] = False
                ExitLoop
            EndIf
        Next
    Next

    For $c = 0 To 7   ; FIX: war "0 To 6" — WinPE (Index 7) wurde nicht aufgeklappt
        _GUICtrlTreeView_Expand($hTV, $g_ahCatNodes[$c])
    Next

    ; FIX: Sicherheits-Pass — USB=1-ISOs sind IMMER grün, egal welche Farbe
    ; ein vorheriger URL-Check oder ein BG-Task gesetzt hat. Wird ausgeführt NACH
    ; _GUICtrlTreeView_AddChild / SetItemParam, sodass der nächste WM_PAINT die
    ; korrigierte Farbe liest.
    For $__sc = 0 To $ISO_COUNT - 1
        If $g_aiUSBStatus[$__sc] = 1 And $g_aiNodeColor[$__sc] <> 1 Then
            $g_aiNodeColor[$__sc] = 1
        EndIf
    Next
EndFunc

Func _SyncCategoryCheckboxes()
    If $g_ahCatNodes[0] = 0 Then Return
    Local $hTV = GUICtrlGetHandle($g_hTreeView)
    Local $aCatNames[8] = ["Gaming","Sicherheit","Einsteiger","Leichtgewicht","Fortgeschrittene","Rettung","Antivirus","WinPE"]

    ; Richtung A: Kategorie → Kinder
    Local $bCatChanged = False
    For $c = 0 To 7
        If $g_ahCatNodes[$c] = 0 Then ContinueLoop
        Local $bCatNow = _GUICtrlTreeView_GetChecked($hTV, $g_ahCatNodes[$c])
        If $bCatNow <> $g_abCatLast[$c] Then
            $g_abCatLast[$c] = $bCatNow
            $bCatChanged = True
            For $i = 0 To $ISO_COUNT - 1
                If $g_aISOs[$i][1] = $aCatNames[$c] And $g_ahNodes[$i] <> 0 Then
                    Local $bShouldCheck = $bCatNow
                    ; v2.27: Beim "Alle auswählen" (Kategorie-Haken) bereits aktuelle ISOs aussparen
                    If $bCatNow And $g_aiUSBStatus[$i] = 1 Then $bShouldCheck = False
                    
                    _GUICtrlTreeView_SetChecked($hTV, $g_ahNodes[$i], $bShouldCheck)
                    $g_abNodeLast[$i] = $bShouldCheck
                EndIf
            Next
        EndIf
    Next

    ; Richtung B: Kinder → Kategorie
    If Not $bCatChanged Then
        For $c = 0 To 7
            If $g_ahCatNodes[$c] = 0 Then ContinueLoop
            Local $bAllOn = True, $bHasAny = False
            For $i = 0 To $ISO_COUNT - 1
                If $g_aISOs[$i][1] = $aCatNames[$c] And $g_ahNodes[$i] <> 0 Then
                    $bHasAny = True
                    Local $bNodeNow = _GUICtrlTreeView_GetChecked($hTV, $g_ahNodes[$i])
                    If $bNodeNow <> $g_abNodeLast[$i] Then $g_abNodeLast[$i] = $bNodeNow
                    If Not $bNodeNow Then $bAllOn = False
                EndIf
            Next
            If $bHasAny Then
                Local $bCatTarget = $bAllOn
                If $bCatTarget <> $g_abCatLast[$c] Then
                    $g_abCatLast[$c] = $bCatTarget
                    _GUICtrlTreeView_SetChecked($hTV, $g_ahCatNodes[$c], $bCatTarget)
                EndIf
            EndIf
        Next
    EndIf
EndFunc

Func _CreateThemeBackground($sDir, $sDrive = "")
    Local $sOut   = $sDir & "\background.png"
    Local $sPS1   = @TempDir & "\vlm_theme_bg.ps1"
    Local $sOutPS = StringReplace($sOut, "'", "''")   ; PS single-quote escape

    ; ── Stick-Infos ermitteln ───────────────────────────────────────────────
    If $sDrive = "" Then $sDrive = StringLeft($sDir, 2)
    Local $sLabel = DriveGetLabel($sDrive)
    If $sLabel = "" Then $sLabel = "Ventoy Stick"
    Local $sTotal = Round(DriveSpaceTotal($sDrive) / 1024, 1)
    Local $sFree  = Round(DriveSpaceFree($sDrive) / 1024, 1)
    Local $iISOs  = $ISO_COUNT

    ; ── Kategorie-Daten als PS-Variablen aufbauen ──────────────────────────
    Local $sPSData = ""
    $sPSData &= "$driveLabel  = '" & StringReplace($sLabel,  "'", "''") & "'" & @LF
    $sPSData &= "$driveLetter = '" & StringUpper($sDrive) & "'" & @LF
    $sPSData &= "$driveTotal  = '" & $sTotal & "'" & @LF
    $sPSData &= "$driveFree   = '" & $sFree  & "'" & @LF
    $sPSData &= "$isoCount    = "  & $iISOs  & @LF
    ; alle 8 Kategorien im Hintergrundbild (+WinPE), Texte auf 38 Zeichen kürzen
    $sPSData &= "$catNames    = @('Gaming','Sicherheit','Einsteiger','Leichtgewicht','Fortgeschrittene','Rettung','Antivirus','WinPE')" & @LF
    Local $aCatKeys[8] = ["Gaming", "Sicherheit", "Einsteiger", "Leichtgewicht", "Fortgeschrittene", "Rettung", "Antivirus", "WinPE"]
    For $c = 0 To 7
        Local $sItems = ""
        For $i = 0 To $iISOs - 1
            If $g_aISOs[$i][1] = $aCatKeys[$c] Then
                ; ISO-Namen auf 38 Zeichen kürzen um Überlauf im Panel zu vermeiden
                Local $sEntry = $g_aISOs[$i][0]
                If StringLen($sEntry) > 38 Then $sEntry = StringLeft($sEntry, 35) & "..."
                If $sItems <> "" Then $sItems &= "','"
                $sItems &= StringReplace($sEntry, "'", "''")
            EndIf
        Next
        If $sItems = "" Then
            $sPSData &= "$cats" & $c & " = @()" & @LF
        Else
            $sPSData &= "$cats" & $c & " = @('" & $sItems & "')" & @LF
        EndIf
    Next

    ; ── PowerShell Drawing-Code (v14.53: einheitliches Wasserzeichen-Design) ─
    ; Dynamische Versionsangabe aus APP_TITLE (z.B. "v14.53")
    Local $aVMatch = StringRegExp($APP_TITLE, "(v[\d]+\.[\d]+)", 1)
    Local $sThemeSubtitle = @error ? "Multiboot USB Stick Manager" : ("Multiboot USB Stick Manager  " & $aVMatch[0])
    Local $sThemeFooterVer = @error ? "Universal ISO Manager" : ("Universal ISO Manager " & $aVMatch[0])
    Local $sScript = $sPSData & _
        "[void][Reflection.Assembly]::LoadWithPartialName('System.Drawing')" & @LF & _
        "[void][Reflection.Assembly]::LoadWithPartialName('System.Drawing.Drawing2D')" & @LF & _
        "$W=1920;$H=1080" & @LF & _
        "$bmp=New-Object System.Drawing.Bitmap($W,$H)" & @LF & _
        "$g=[System.Drawing.Graphics]::FromImage($bmp)" & @LF & _
        "$g.SmoothingMode=[System.Drawing.Drawing2D.SmoothingMode]::AntiAlias" & @LF & _
        "$g.TextRenderingHint=[System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit" & @LF & _
        "" & @LF & _
        "# ── Hintergrund flat dark navy ────────────────────────────────────" & @LF & _
        "$bg=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(14,24,46))" & @LF & _
        "$g.FillRectangle($bg,0,0,$W,$H);$bg.Dispose()" & @LF & _
        "" & @LF & _
        "# ── Header-Panel (y 0..118) ───────────────────────────────────────" & @LF & _
        "$hp=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(8,16,34))" & @LF & _
        "$g.FillRectangle($hp,0,0,$W,118);$hp.Dispose()" & @LF & _
        "" & @LF & _
        "# ── Akzent-Streifen oben (5px leuchtendes Blau) ─────────────────" & @LF & _
        "$ta=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(41,182,246))" & @LF & _
        "$g.FillRectangle($ta,0,0,$W,5);$ta.Dispose()" & @LF & _
        "" & @LF & _
        "# ── Header-Unterlinie (2px Blau) ─────────────────────────────────" & @LF & _
        "$hl=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(41,182,246),2)" & @LF & _
        "$g.DrawLine($hl,0,118,$W,118);$hl.Dispose()" & @LF & _
        "" & @LF & _
        "# ── Titel (weiss, 38pt Bold) ──────────────────────────────────────" & @LF & _
        "$fT=New-Object System.Drawing.Font('Segoe UI',38,[System.Drawing.FontStyle]::Bold)" & @LF & _
        "$bT=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)" & @LF & _
        "$g.DrawString('UNIVERSAL  LINUX  MANAGER',$fT,$bT,48,8)" & @LF & _
        "$fT.Dispose();$bT.Dispose()" & @LF & _
        "" & @LF & _
        "# ── Untertitel links + Stick-Info rechts ─────────────────────────" & @LF & _
        "$fS=New-Object System.Drawing.Font('Segoe UI',13,[System.Drawing.FontStyle]::Regular)" & @LF & _
        "$bS=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(96,165,210))" & @LF & _
        "$g.DrawString('" & $sThemeSubtitle & "',$fS,$bS,50,76)" & @LF & _
        "$inf=" & Chr(34) & "$driveLetter  $driveLabel  |  $driveTotal GB gesamt  |  $driveFree GB frei  |  $isoCount ISOs" & Chr(34) & @LF & _
        "$sz=$g.MeasureString($inf,$fS)" & @LF & _
        "$g.DrawString($inf,$fS,$bS,[int]($W-$sz.Width-48),76)" & @LF & _
        "$fS.Dispose();$bS.Dispose()" & @LF & _
        "" & @LF & _
        "" & @LF & _
        "# ── VENTOY Wasserzeichen (nur im Zentrum, transparent) ────────" & @LF & _
        "$sfC=New-Object System.Drawing.StringFormat" & @LF & _
        "$sfC.Alignment=[System.Drawing.StringAlignment]::Center" & @LF & _
        "$sfC.LineAlignment=[System.Drawing.StringAlignment]::Center" & @LF & _
        "$wF=New-Object System.Drawing.Font('Segoe UI',160,[System.Drawing.FontStyle]::Bold)" & @LF & _
        "$wB=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(14,41,182,246))" & @LF & _
        "$wR=[System.Drawing.RectangleF]::new(480,118,960,700)" & @LF & _
        "$g.DrawString('VENTOY',$wF,$wB,$wR,$sfC)" & @LF & _
        "$wF.Dispose();$wB.Dispose()" & @LF & _
        "$wF2=New-Object System.Drawing.Font('Segoe UI',22,[System.Drawing.FontStyle]::Regular)" & @LF & _
        "$wB2=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20,41,182,246))" & @LF & _
        "$wR2=[System.Drawing.RectangleF]::new(480,700,960,150)" & @LF & _
        "$g.DrawString('USB  MULTIBOOT  MANAGER',$wF2,$wB2,$wR2,$sfC)" & @LF & _
        "$wF2.Dispose();$wB2.Dispose();$sfC.Dispose()" & @LF & _
        "" & @LF & _
        "# --- v2.23: Clean Background (Side panels removed for TreeView clarity) ---" & @LF & _
        "" & @LF & _
        "# ── Footer-Panel (y 950..1080) ───────────────────────────────────" & @LF & _
        "$fp=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(8,16,34))" & @LF & _
        "$g.FillRectangle($fp,0,950,$W,130);$fp.Dispose()" & @LF & _
        "$fl=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(41,182,246),2)" & @LF & _
        "$g.DrawLine($fl,0,950,$W,950);$fl.Dispose()" & @LF & _
        "$fF=New-Object System.Drawing.Font('Segoe UI',13,[System.Drawing.FontStyle]::Regular)" & @LF & _
        "$bF=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(96,165,210))" & @LF & _
        "$ft=" & Chr(34) & "$isoCount ISOs bereit  *  $driveFree GB frei  *  $driveLetter  $driveLabel  *  " & $sThemeFooterVer & Chr(34) & @LF & _
        "$sfz=$g.MeasureString($ft,$fF)" & @LF & _
        "$g.DrawString($ft,$fF,$bF,[int](($W-$sfz.Width)/2),1008)" & @LF & _
        "$fF.Dispose();$bF.Dispose()" & @LF & _
        "" & @LF & _
        "# ── Akzent-Streifen unten (5px) ──────────────────────────────────" & @LF & _
        "$ba=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(41,182,246))" & @LF & _
        "$g.FillRectangle($ba,0,$H-5,$W,5);$ba.Dispose()" & @LF & _
        "" & @LF & _
        "# ── Speichern ─────────────────────────────────────────────────────" & @LF & _
        "$g.Dispose()" & @LF & _
        "$bmp.Save('" & $sOutPS & "')" & @LF & _
        "$bmp.Dispose()"

    ; Skript-Datei schreiben
    Local $hPS = FileOpen($sPS1, 2 + 8)   ; überschreiben + UTF-8
    If $hPS = -1 Then
        _Log("  background.png FEHLER: Konnte PS1-Datei nicht schreiben: " & $sPS1)
        Return
    EndIf
    FileWrite($hPS, $sScript)
    FileClose($hPS)

    ; Skript ausführen
    RunWait(@ComSpec & " /c powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File """ & $sPS1 & """", "", @SW_HIDE)

    ; Temp-Datei aufräumen
    FileDelete($sPS1)

    If FileExists($sOut) Then
        _Log("  background.png erstellt (themed VLM): " & $sOut)
    Else
        _Log("  HINWEIS: background.png nicht erstellt — desktop-color Fallback aktiv")
    EndIf
EndFunc

