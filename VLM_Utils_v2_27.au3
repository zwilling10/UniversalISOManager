; ==========================================
; Module: VLM_Utils.au3
; Part of UniversalISOManager
; ==========================================

#include-once

Func _ApplyBaseDir($sBase)
    ; Setzt alle Pfad-Variablen relativ zum gewählten Basisordner.
    ; TMP liegt im ISOs-Unterordner → kein Cross-Drive-Copy beim Verschieben.
    $DOWNLOAD_DIR     = $sBase & "\ISOs"
    $TMP_DOWNLOAD_DIR = $sBase & "\ISOs\.tmp"
    $VENTOY_TMP_DIR   = $sBase & "\vlm_ventoy_setup"
    $VENTOY_ZIP       = $VENTOY_TMP_DIR & "\ventoy_latest.zip"
    $LOG_FILE         = $sBase & "\vlm_log.txt"
    $ISO_DB_INI       = $sBase & "\vlm_isos.ini"
    $URL_INI          = $sBase & "\vlm_user_urls.ini"
EndFunc

Func _UpdateFolderPreview($hLbl, $sBase)
    ; Aktualisiert die Vorschau-Liste im Setup-Dialog.
    Local $sT = _
        "  ISO-Downloads:    " & $sBase & "\ISOs"         & @LF & _
        "  ISO-Datenbank:    " & $sBase & "\vlm_isos.ini" & @LF & _
        "  Protokolldatei:   " & $sBase & "\vlm_log.txt"  & @LF & _
        "  URL-Einstellungen:" & $sBase & "\vlm_user_urls.ini"
    GUICtrlSetData($hLbl, $sT)
EndFunc

Func _Init()
    ; Array-Initialisierung (ISO_MAX statt fester Größe)
    Local $__c
    For $__c = 0 To 7
        $g_abCatLast[$__c] = False
    Next
    Local $__i
    For $__i = 0 To $ISO_MAX - 1
        $g_aiUSBStatus[$__i]  = 0
        $g_asUSBSize[$__i]    = ""
        $g_abURLOK[$__i]      = False
        $g_abURLChecked[$__i] = False
        $g_asUpdateVer[$__i]  = ""
        $g_asUpdateURL[$__i]  = ""
        $g_asUpdateFile[$__i] = ""
        $g_ahNodes[$__i]           = 0
        $g_abNodeLast[$__i]        = False
        $g_aiNodeColor[$__i]       = 0
        $g_abImportedFromStick[$__i] = False
        $g_abMemBoot[$__i]           = False
    Next

    ; ISO-Datenbank laden (notwendig für GUI-Aufbau)
    _LoadIsoDB()

    ; curl.exe prüfen
    If _CurlPath() = "" Then
        MsgBox(16, "Fehler", "curl.exe nicht gefunden!")
        Exit 1
    EndIf

    ; Experten-Modus laden
    $g_bExpertMode = (IniRead($SETTINGS_INI, "App", "ExpertMode", "0") = "1")
    
    _Log("Basis-Initialisierung abgeschlossen.")
EndFunc

Func _PostInit()
    ; Diese Aufgaben können laufen, wenn das GUI bereits sichtbar ist (v2.27)
    _Log("Post-Initialisierung läuft...")
    
    ; v2.27 Optimierung: Background Speedtest immer starten
    _StartBackgroundSpeedTest()
    
    If Not $g_bSkipIntro Then
        Local $aDrives = DriveGetDrive("REMOVABLE")
        If IsArray($aDrives) And $aDrives[0] > 0 Then
            ; Stick vorhanden -> Ventoy Suche & Auto-Scan
            _StartupVentoyDetect()
        Else
            ; Kein Stick -> Nur Distro-Updates aus der DB prüfen
            _Log("Kein USB-Stick erkannt -> starte Distro-Update-Check (DB)")
            _OnUpdates()
        EndIf
    EndIf
    
    If Not FileExists($DOWNLOAD_DIR)     Then DirCreate($DOWNLOAD_DIR)
    If Not FileExists($TMP_DOWNLOAD_DIR) Then DirCreate($TMP_DOWNLOAD_DIR)
    
    _CleanupIncompleteTmp()
    
    ; MemBoot-Defaults setzen
    For $__mb = 0 To $ISO_COUNT - 1
        Local $__mbN = $g_aISOs[$__mb][0]
        If StringInStr($__mbN, "SystemRescue") Or StringInStr($__mbN, "GParted") Or _
           StringInStr($__mbN, "Clonezilla") Or StringInStr($__mbN, "Finnix") Or _
           StringInStr($__mbN, "Tails") Then
            $g_abMemBoot[$__mb] = True
        EndIf
    Next
    _LoadMemBootSettings()
    _LoadUserURLs()
    
    ; Versions-Check-Zeitstempel prüfen
    Local $sLastCheckDate = IniRead($SETTINGS_INI, "App", "LastVersionCheck", "")
    If $sLastCheckDate = "" Or _DaysSinceDate($sLastCheckDate) >= $AUTO_CHECK_INTERVAL_DAYS Then
        $g_bAutoVersionCheck    = True
        $g_iAutoVersionCheckIdx = 0
        $g_tAutoVersionStep     = TimerInit()
        _Log("Auto-Versionscheck im Hintergrund geplant.")
    EndIf
    _Log("Post-Initialisierung abgeschlossen.")
EndFunc

Func _UpdateUIMode()
    Local $iState = ($g_bExpertMode ? $GUI_SHOW : $GUI_HIDE)
    
    ; Buttons im Header (Ventoy)
    GUICtrlSetState($g_hBtnVentoy, $iState)
    
    ; Checkbox Secure Boot (nur im Experten-Modus)
    GUICtrlSetState($g_hChkSecureBoot, $iState)
    
    ; Erweiterte Aktionen in Zeile 2
    GUICtrlSetState($g_hBtnCheckURLs, $iState)
    GUICtrlSetState($g_hBtnISOSearch, $iState)
    GUICtrlSetState($g_hBtnEditDB, $iState)    
    ; Protokoll-Tab (nur im Experten-Modus)
    If $g_bExpertMode Then
        GUICtrlSetState($g_hLogEdit, $GUI_SHOW)
        If _GUICtrlTab_GetItemCount($g_hTab) = 1 Then
            _GUICtrlTab_InsertItem($g_hTab, 1, "   Protokoll   ")
        EndIf
    Else
        ; Zurück auf den ersten Tab schalten, falls der Log-Tab aktiv war
        GUICtrlSetState($g_hTabItemISO, $GUI_SHOW)
        GUICtrlSetState($g_hLogEdit, $GUI_HIDE)
        If _GUICtrlTab_GetItemCount($g_hTab) > 1 Then
            _GUICtrlTab_DeleteItem($g_hTab, 1)
        EndIf
    EndIf
    
    ; TreeView immer auf volle Breite setzen
    GUICtrlSetPos($g_hTreeView, 18, 208, 980 - 36, 780 - 373)
    
    ; Button-Text und Farbe anpassen (v2.27)
    If $g_bExpertMode Then
        GUICtrlSetData($g_hBtnModeToggle, "Modus: Experte 🛠️")
        GUICtrlSetBkColor($g_hBtnModeToggle, 0xD35400) ; Kräftiges Orange/Amber
        GUICtrlSetColor($g_hBtnModeToggle, 0xFFFFFF)    ; Weißer Text
    Else
        GUICtrlSetData($g_hBtnModeToggle, "Modus: Anwender 👤")
        GUICtrlSetBkColor($g_hBtnModeToggle, 0x2A4B7C) ; Navy Blau
        GUICtrlSetColor($g_hBtnModeToggle, 0xFFFFFF)    ; Weißer Text
    EndIf
    
    _Log("UI-Modus aktualisiert: " & ($g_bExpertMode ? "Experte" : "Anwender"))
EndFunc

Func _PopShow($sTitle, $sSub, $bCancel = False)
    _HideTooltip()   ; Tooltip vor Popup ausblenden (war immer im Vordergrund)
    If $g_hPop <> 0 Then _PopClose()
    Local $iW = 540, $iH = 270

    $g_hPop = GUICreate($sTitle & " — Universal ISO Manager", $iW, $iH, -1, -1, _
        BitOR($WS_CAPTION, $WS_SYSMENU), _
        $WS_EX_DROPSHADOW, $g_hMain)
    GUISetBkColor($C_W)
    GUISetFont(9, 400, 0, "Segoe UI")

    ; Glary-style: schmaler Akzentstreifen oben (Glary Corporate Blue)
    GUICtrlCreateLabel("", 0, 0, $iW, 4)
    GUICtrlSetBkColor(-1, $C_BLUE)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; Weißer Inhaltsbereich
    GUICtrlCreateLabel("", 0, 4, $iW, $iH - 4)
    GUICtrlSetBkColor(-1, $C_W)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; Logo-Box (Glary: kompaktes Icon-Box simuliert durch Label)
    GUICtrlCreateLabel("", 18, 16, 44, 44)
    GUICtrlSetBkColor(-1, $C_LBLU)
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUICtrlCreateLabel("VL", 24, 25, 32, 22)
    GUICtrlSetFont(-1, 11, 800, 0, "Segoe UI Black")
    GUICtrlSetColor(-1, $C_BLUE)
    GUICtrlSetBkColor(-1, $C_LBLU)

    ; Titel — Glary Popup-Label (Segoe UI Semibold)
    $g_hPopTitle = GUICtrlCreateLabel($sTitle, 74, 14, $iW - 92, 22)
    GUICtrlSetFont(-1, 11, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, $C_W)

    ; Subtitle — Glary secondaryLabel
    $g_hPopSub = GUICtrlCreateLabel($sSub, 74, 38, $iW - 92, 16)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_W)

    ; Separator
    GUICtrlCreateLabel("", 18, 68, $iW - 36, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; Prozentzahl (Glary: große, mutige Schrift — Segoe UI Black)
    $g_hPopPct = GUICtrlCreateLabel("0%", $iW - 96, 76, 78, 44)
    GUICtrlSetFont(-1, 26, 800, 0, "Segoe UI Black")
    GUICtrlSetColor(-1, $C_BLUE)
    GUICtrlSetBkColor(-1, $C_W)
    GUICtrlSetStyle(-1, BitOR($SS_RIGHT, $SS_CENTERIMAGE))

    ; Fortschrittsbalken-Hintergrund (Glary: flacher, moderner Balken)
    Local $iBarW = $iW - 118
    GUICtrlCreateLabel("", 18, 86, $iBarW, 14)
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetState(-1, $GUI_DISABLE)
    ; Füll-Label (dynamisch)
    $g_hPopFill = GUICtrlCreateLabel("", 18, 86, 1, 14)
    GUICtrlSetBkColor(-1, $C_BLUE)
    ; Standard Windows-Progressbar
    $g_hPopBar = GUICtrlCreateProgress(18, 104, $iBarW, 8)
    GUICtrlSetColor(-1, $C_BLUE)

    ; Detail-Zeile — Glary tertiaryLabel, Monospace
    $g_hPopDetail = GUICtrlCreateLabel("", 18, 118, $iW - 36, 16)
    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, $C_W)

    ; Hinweis-Separator
    GUICtrlCreateLabel("", 18, 140, $iW - 36, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUICtrlCreateLabel("Das Fenster kann per Titelleiste verschoben werden.", 18, 147, $iW - 36, 13)
    GUICtrlSetFont(-1, 7, 400, 2, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, $C_W)

    ; Abbrechen-Button — Glary: klares Rot (destruktive Aktion)
    $g_hPopCancel = 0
    If $bCancel Then
        $g_hPopCancel = GUICtrlCreateButton("  ✕  Abbrechen", $iW - 132, $iH - 48, 114, 32)
        GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI Semibold")
        GUICtrlSetBkColor(-1, $C_LRED)
        GUICtrlSetColor(-1, $C_RED)
        GUICtrlSetTip(-1, "Laufenden Vorgang abbrechen")
    EndIf

    GUISetState(@SW_SHOW, $g_hPop)
EndFunc

Func _PopUpdate($iPct, $sDetail = "", $sSub = "")
    If $g_hPop = 0 Then Return
    If $iPct < 0   Then $iPct = 0
    If $iPct > 100 Then $iPct = 100

    ; Automatische Anpassung für den globalen Download- und Kopierfortschritt
    Local $iDisplayPct = $iPct
    If $g_iJobTotalDL > 0 And $g_iJobNrDL >= 0 Then
        If $g_bCopyToStickDL Then
            Local $iPhaseOffset = $g_bIsCopyPhaseDL ? 1 : 0
            $iDisplayPct = Int(( ($g_iJobNrDL * 2 + $iPhaseOffset) * 100 + $iPct ) / ($g_iJobTotalDL * 2))
        Else
            $iDisplayPct = Int(( $g_iJobNrDL * 100 + $iPct ) / $g_iJobTotalDL)
        EndIf
        If $iDisplayPct > 99 And $iPct < 100 Then $iDisplayPct = 99
        
        ; Titel mit Gesamtfortschritt ergänzen
        If $sSub <> "" And Not StringInStr($sSub, "Gesamt:") Then
            $sSub &= " (Gesamt: " & $iDisplayPct & "%)"
        EndIf
    EndIf

    GUICtrlSetData($g_hPopPct,    $iDisplayPct & "%")
    GUICtrlSetData($g_hPopBar,    $iDisplayPct)
    If $sSub    <> "" Then GUICtrlSetData($g_hPopSub,    $sSub)
    If $sDetail <> "" Then GUICtrlSetData($g_hPopDetail, $sDetail)

    ; Füllbalken (max Breite = 540-118-18 = 404px)
    Local $iMaxW  = 404
    Local $iFillW = Int($iMaxW * $iDisplayPct / 100)
    If $iFillW < 1 Then $iFillW = 1
    ControlMove($g_hPop, "", GUICtrlGetHandle($g_hPopFill), 18, 88, $iFillW, 16)

    If $iDisplayPct >= 100 Then
        GUICtrlSetColor($g_hPopPct,   $C_GRN)
        GUICtrlSetBkColor($g_hPopFill, $C_GRN)
        GUICtrlSetColor($g_hPopBar,   $C_GRN)
    EndIf

    ; Events beider Fenster abfragen
    _CheckBackgroundSpeedTest() ; v2.27 Background Speedtest Monitor
    Local $ev = GUIGetMsg()
    If $ev = $GUI_EVENT_CLOSE      Then _Quit()
    If $ev = $g_hBtnCancel        Then $g_bCancel = True
    If $g_hPopCancel <> 0 And $ev = $g_hPopCancel Then $g_bCancel = True
EndFunc

Func _PopClose()
    If $g_hPop = 0 Then Return
    GUIDelete($g_hPop)
    $g_hPop=0 
$g_hPopTitle=0
$g_hPopSub=0
    $g_hPopPct=0 
$g_hPopBar=0
$g_hPopFill=0
    $g_hPopDetail=0 
$g_hPopCancel=0
EndFunc

Func _RunProcessWithProgress($sCmd, $sWorkDir, $iStartPct, $iEndPct, $sSubTask, $iTimeoutSec = 300)
    ; Startet einen Prozess und aktualisiert das Popup-Fenster während des Wartens.
    ; Ermöglicht auch das Abbrechen durch den Nutzer. (FIXED: Keine Resource Leaks)
    _Log(" [RunEx] Start: " & $sCmd)
    Local $iPID = Run($sCmd, $sWorkDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
    If $iPID = 0 Then
        _Log(" [RunEx] FEHLER: Konnte Prozess nicht starten.")
        Return -1
    EndIf

    ; Prozess-Handle öffnen, um später den ExitCode abzufragen
    Local $hProcess = DllCall("kernel32.dll", "ptr", "OpenProcess", "dword", 0x1000, "bool", False, "dword", $iPID)
    $hProcess = (IsArray($hProcess) ? $hProcess[0] : 0)
    $g_iCurrentProcessPID = $iPID
    Local $tStart = TimerInit()
    Local $sOut = ""
    Local $iRange = $iEndPct - $iStartPct

    While ProcessExists($iPID)
        ; Output lesen (verhindert Buffer-Overflow / Hänger)
        $sOut &= StdoutRead($iPID)
        $sOut &= StderrRead($iPID)
        
        ; UI aktualisieren & Events verarbeiten
        Local $iElapsed = TimerDiff($tStart)
        Local $iSimPct = $iStartPct + Int($iRange * (Min($iElapsed / ($iTimeoutSec * 1000 / 2), 1))) ; Simulation bis zur Hälfte der Zeit
        _PopUpdate($iSimPct, "Warte auf Abschluss ...", $sSubTask)

        ; --- FIX: Handle-Schließung bei manuellem Abbruch integriert ---
        If $g_bCancel Then
            _Log(" [RunEx] Abbruch durch Nutzer (PID " & $iPID & ").")
            If ProcessExists($iPID) Then ProcessClose($iPID)
            If $hProcess <> 0 Then DllCall("kernel32.dll", "bool", "CloseHandle", "ptr", $hProcess) ; Handle sicher schließen!
            $g_iCurrentProcessPID = 0
            Return -2
        EndIf

        ; --- FIX: Handle-Schließung bei Timeout integriert ---
        If $iElapsed > $iTimeoutSec * 1000 Then
            _Log(" [RunEx] Timeout nach " & $iTimeoutSec & "s (PID " & $iPID & ").")
            If ProcessExists($iPID) Then ProcessClose($iPID)
            If $hProcess <> 0 Then DllCall("kernel32.dll", "bool", "CloseHandle", "ptr", $hProcess) ; Handle sicher schließen!
            $g_iCurrentProcessPID = 0
            Return -3
        EndIf

        Sleep(200)
    WEnd

    ; Letzten Rest lesen
    $sOut &= StdoutRead($iPID)
    $sOut &= StderrRead($iPID)

    Local $iExitCode = -1
    If $hProcess <> 0 Then
        ; Echten ExitCode von Windows abfragen
        Local $aRetExit = DllCall("kernel32.dll", "bool", "GetExitCodeProcess", "ptr", $hProcess, "dword*", 0)
        If IsArray($aRetExit) Then $iExitCode = $aRetExit[2]
        DllCall("kernel32.dll", "bool", "CloseHandle", "ptr", $hProcess) ; Regulärer Abschluss
    EndIf

    $g_iCurrentProcessPID = 0
    _Log(" [RunEx] Prozess beendet (ExitCode: " & $iExitCode & ").")
    
    ; Wir geben ein Array zurück: [ExitCode, Output]
    Local $aRet[2] = [$iExitCode, $sOut]
    Return $aRet
EndFunc

Func Min($a, $b)
    Return ($a < $b ? $a : $b)
EndFunc

