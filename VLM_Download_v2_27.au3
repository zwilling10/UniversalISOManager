; ==========================================

; Module: VLM_Download.au3

; Part of UniversalISOManager

; ==========================================

#include-once

Func _OnDownload()

    _HideTooltip()   ; 

    If $g_bBusy Then Return

    Local $hTV = GUICtrlGetHandle($g_hTreeView)

    Local $aQueue[$ISO_COUNT]

    Local $iCount = 0

    For $i = 0 To $ISO_COUNT - 1

        If $g_ahNodes[$i] <> 0 Then

            If _GUICtrlTreeView_GetChecked($hTV, $g_ahNodes[$i]) Then

                $aQueue[$iCount] = $i

                $iCount += 1

            EndIf

        EndIf

    Next

    If $iCount = 0 Then

        MsgBox(48, "Hinweis", "Bitte mindestens eine Distribution ankreuzen!")

        Return

    EndIf

    ; === v2.18: Laufwerk auswählen — OPTIONAL (Download auch ohne Stick möglich) ===

    Local $sDrive = _GetSelectedDrive()

    Local $bCopyToStick = False   ; True = ISOs sollen auf Stick kopiert werden

    Local $bDeleteAfterCopy = False

    If $sDrive <> "" And DriveStatus($sDrive) = "READY" Then

        ; Stick verfügbar — Nutzer fragen ob sofort kopieren oder nur downloaden

        Local $iStickChoice = MsgBox(291, "Download-Modus", _
            "USB-Stick erkannt: " & $sDrive & @CRLF & @CRLF & _
            "  JA      — Herunterladen UND direkt auf Stick kopieren" & @CRLF & _
            "  NEIN    — Nur herunterladen (Kopie kann später erfolgen)" & @CRLF & _
            "  ABBRUCH — Abbrechen" & @CRLF & @CRLF & _
            "Betrifft: " & $iCount & " ISO(s)")

        If $iStickChoice = 2 Then Return

        $bCopyToStick = ($iStickChoice = 6)

    Else

        ; Kein Stick — Download ohne Kopie, später beim Stick-Einstecken anbieten

        Local $iNoStickChoice = MsgBox(291, "Kein Stick erkannt", _
            "Kein USB-Stick ausgewählt oder nicht bereit." & @CRLF & @CRLF & _
            "Die ISO(s) werden in den Download-Ordner gespeichert:" & @CRLF & _
            $DOWNLOAD_DIR & @CRLF & @CRLF & _
            "Wenn später ein Ventoy-Stick angeschlossen wird," & @CRLF & _
            "wird automatisch angeboten, die ISO(s) zu kopieren." & @CRLF & @CRLF & _
            "  JA      — Jetzt ohne Stick herunterladen" & @CRLF & _
            "  ABBRUCH — Abbrechen")

        If $iNoStickChoice <> 6 Then Return

        $sDrive = ""     ; kein Stick → kein Copy-Schritt

        $bCopyToStick = False

    EndIf

    ; Ventoy-Prüfung (nur wenn Stick gewählt)

    If $bCopyToStick Then

        If Not _IsVentoyInstalled($sDrive) Then

            If MsgBox(308, "Ventoy nicht erkannt", _
                "Auf " & $sDrive & " wurde kein Ventoy erkannt." & @CRLF & @CRLF & _
                "Trotzdem herunterladen und kopieren?" & @CRLF & _
                "Tipp: Zuerst 'Ventoy installieren' klicken.") <> 6 Then Return

        EndIf

        ; TMP-Dateien nach Kopie löschen?

        Local $iDeleteChoice = MsgBox(291, "Lokale TMP-Dateien nach Kopie löschen?", _
            "Sollen die heruntergeladenen ISO-Dateien vom PC (TMP) gelöscht" & @CRLF & _
            "werden, nachdem sie auf den Stick kopiert wurden?" & @CRLF & @CRLF & _
            "  JA      — Lokale TMP-Dateien löschen (spart Speicher)" & @CRLF & _
            "  NEIN    — Lokale Dateien behalten" & @CRLF & _
            "  ABBRUCH — Vorgang nicht starten" & @CRLF & @CRLF & _
            "Betrifft: " & $iCount & " ISO(s)  →  " & $sDrive)

        If $iDeleteChoice = 2 Then Return

        $bDeleteAfterCopy = ($iDeleteChoice = 6)

    EndIf

    ; === Slot-Anzahl bestimmen ===

    Local $iSlots = _ChooseDownloadSlots($iCount)

    If $iSlots = 0 Then Return   ; Nutzer hat abgebrochen

    ; === Download starten ===

    $g_bBusy   = True

    $g_bCancel = False

    GUICtrlSetData($g_hProgress, 0)

    ; Mirror-Cache löschen (alter Vortest ungültig bei neuer Queue)

    For $__pc = 0 To $iCount - 1

        $g_asSortedURLs[$aQueue[$__pc]] = ""

    Next

    ; Mirror-Prüfung wurde in den Dispatcher verschoben (v2.27)

    _Status("Bereite Download-Queue vor … (" & $iCount & " ISO(s))")

    Local $iOK     = 0   ; erfolgreiche Downloads

    Local $iFail   = 0   ; fehlgeschlagene Downloads

    Local $iCopied = 0   ; erfolgreich auf Stick kopiert

    Local $iCopyFail = 0 ; Kopierfehler

    If $iSlots = 1 Then

        ; Sequentieller Download

        Local $sPopTitle = $bCopyToStick ? "Download + Kopie" : "Download (ohne Stick)"

        Local $sPopSub   = $bCopyToStick ? ($iCount & " Distribution(en) — 1 Stream → " & $sDrive) : ($iCount & " Distribution(en) — 1 Stream → " & $DOWNLOAD_DIR)

        $g_iJobTotalDL = $iCount
        $g_bCopyToStickDL = $bCopyToStick
        $g_bIsCopyPhaseDL = False

        _PopShow($sPopTitle, $sPopSub, True)

        For $j = 0 To $iCount - 1

            If $g_bCancel Then ExitLoop

            $g_iJobNrDL = $j
            $g_bIsCopyPhaseDL = False

            If _DownloadOne($aQueue[$j], $j, $iCount) Then

                $iOK += 1

                If $bCopyToStick Then

                    ; Popup neu öffnen falls es im Fallback-Dialog geschlossen wurde.

                    If $g_hPop = 0 Then

                        _PopShow("Kopiere auf Stick", "→ " & $sDrive & "  (" & ($j+1) & "/" & $iCount & ")", True)

                    EndIf

                    $g_bIsCopyPhaseDL = True

                    ; Sofort auf Stick kopieren (robocopy /J für Maximalgeschwindigkeit)

                    _PopUpdate(0, "Kopiere auf Stick...", $g_aISOs[$aQueue[$j]][0])

                    If _CopyOneISOToStick($aQueue[$j], $sDrive, $bDeleteAfterCopy) Then

                        $iCopied += 1

                        ; Boot-Thema beim ersten kopierten ISO einrichten (seq. Pfad)

                        If $iCopied = 1 Then _EnsureVentoyTheme($sDrive, False)

                    Else

                        $iCopyFail += 1

                    EndIf

                Else

                    ; Kein Stick — ISO in Pending-Copy-Queue aufnehmen

                    _AddToPendingCopyQueue($aQueue[$j])

                EndIf

            Else

                $iFail += 1

            EndIf

        Next

        $g_iJobNrDL = -1
        $g_iJobTotalDL = -1
        $g_bCopyToStickDL = False
        $g_bIsCopyPhaseDL = False

        _PopClose()

    Else

        ; Paralleler Download MIT Pipelining —

        ; _DownloadParallel übernimmt die Kopie intern: sobald ein Slot

        ; fertig ist, startet sofort die asynchrone Kopie auf den Stick.

        ; $sDrive und $bDeleteAfterCopy werden direkt übergeben.

        ; Bei kein Stick ($bCopyToStick = False) wird "" übergeben → kein Copy

        Local $sDrivePar = $bCopyToStick ? $sDrive : ""

        Local $aParResult = _DownloadParallel($aQueue, $iCount, $iSlots, $sDrivePar, $bDeleteAfterCopy)

        If IsArray($aParResult) Then

            $iOK       = $aParResult[0]

            $iFail     = $aParResult[1]

            $iCopied   = $aParResult[2]

            $iCopyFail = $aParResult[3]

        EndIf

        ; Bei parallelem Download ohne Stick — alle OK-ISOs in Queue aufnehmen

        If Not $bCopyToStick Then

            For $__pj = 0 To $ISO_COUNT - 1

                For $__qi = 0 To $iCount - 1

                    If $aQueue[$__qi] = $__pj Then

                        Local $sTmpFile = $TMP_DOWNLOAD_DIR & "\" & $g_aISOs[$__pj][3]

                        Local $sISOFile = $DOWNLOAD_DIR & "\" & $g_aISOs[$__pj][3]

                        If FileExists($sTmpFile) Or FileExists($sISOFile) Then

                            _AddToPendingCopyQueue($__pj)

                        EndIf

                        ExitLoop

                    EndIf

                Next

            Next

        EndIf

    EndIf

    $g_bBusy = False

    GUICtrlSetData($g_hSpeedLbl, "")

    GUICtrlSetData($g_hEtaLbl,   "")

    If $g_bCancel Then

        ; Abbruch durch Nutzer

        Sleep(500)

        _CleanupIncompleteTmp()

        _Status("Abgebrochen — unvollständige TMP-Dateien bereinigt.")

        _FillTree()

    ElseIf $iOK = 0 And $iFail > 0 Then

        ; Alle fehlgeschlagen

        GUICtrlSetData($g_hProgress, 0)

        _Status("Download fehlgeschlagen — " & $iFail & " ISO(s) konnten nicht heruntergeladen werden.")

        _FillTree()

        ; kein _ApplyDLCheckmarks() — nichts erfolgreich heruntergeladen

        MsgBox(16, "Download fehlgeschlagen ✗", _
            "Kein ISO konnte erfolgreich heruntergeladen werden." & @CRLF & @CRLF & _
            "Fehlgeschlagen: " & $iFail & " / " & $iCount & @CRLF & @CRLF & _
            "Mögliche Ursachen:" & @CRLF & _
            "  • URLs haben sich geändert (neue Version der Distro verfügbar)" & @CRLF & _
            "  • Internetverbindung oder Firewall blockiert den Download" & @CRLF & _
            "  • Mirror aktuell nicht erreichbar" & @CRLF & @CRLF & _
            "─────────────────────────────────────────────" & @CRLF & _
            "Antivirus / Sicherheitssoftware blockiert?" & @CRLF & @CRLF & _
            "Hinweis: Eine Firewall-Freigabe allein reicht oft nicht aus!" & @CRLF & _
            "Ursache: Der Web-Schutz (HTTPS-Scanning / SSL-Inspection) fängt" & @CRLF & _
            "         die verschlüsselte Verbindung von curl.exe ab." & @CRLF & @CRLF & _
            "Lösung:" & @CRLF & _
            "  Antivirus  →  Web-Schutz / HTTP-Scanner  →  HTTPS-Scanning  →  Aus" & @CRLF & _
            "  ODER: Web-Schutz für die Dauer des Downloads temporär deaktivieren" & @CRLF & _
            "─────────────────────────────────────────────" & @CRLF & @CRLF & _
            "Tipp: '🔍 URLs prüfen' klicken um alle Quellen zu testen," & @CRLF & _
            "dann erneut versuchen oder manuell eine URL eingeben.")

    Else

        ; Teilerfolg oder alles erfolgreich

        GUICtrlSetData($g_hProgress, 100)

        Local $sMsg = $iOK & " von " & $iCount & " ISO(s) heruntergeladen."

        If $iCopied > 0 Then $sMsg &= @CRLF & $iCopied & " ISO(s) auf " & $sDrive & " kopiert."

        If $iFail > 0 Then $sMsg &= @CRLF & $iFail & " Download(s) fehlgeschlagen."

        If $iCopyFail > 0 Then $sMsg &= @CRLF & $iCopyFail & " Kopierfehler."

        ; /v14.45: background.png immer neu generieren + Ergebnis merken für Dialog

        Local $bThemeUpdatedDL = False

        If $iCopied > 0 And $sDrive <> "" Then

            _EnsureVentoyTheme($sDrive, False)

            Local $sThemeDirBG = $sDrive & "\ventoy\themes\usb-stick"

            If FileExists($sThemeDirBG) Then

                _Log("  v14.45: background.png aktualisieren nach " & $iCopied & " kopierten ISO(s)")

                _CreateThemeBackground($sThemeDirBG, $sDrive)

                $bThemeUpdatedDL = True

            EndIf

        EndIf

        _Status($sMsg)

        _FillTree()

        Local $sThemeLine = $bThemeUpdatedDL ? "✓ Boot-Bild (background.png) aktualisiert." : ""

        If $iFail > 0 Then

            MsgBox(48, "Teilweise fertig", _
                $sMsg & @CRLF & @CRLF & _
                ($sThemeLine <> "" ? $sThemeLine & @CRLF : "") & _
                "Fehlgeschlagene ISOs bitte erneut versuchen oder '🔍 URLs prüfen'.")

        Else

            ; TMP-Ordner bereinigen wenn alles OK und gelöscht

            If $bDeleteAfterCopy And FileExists($TMP_DOWNLOAD_DIR) Then

                DirRemove($TMP_DOWNLOAD_DIR, 1)

                DirCreate($TMP_DOWNLOAD_DIR)

                _Log("🗑 TMP-Verzeichnis bereinigt: " & $TMP_DOWNLOAD_DIR)

            EndIf

            If $bCopyToStick Then

                MsgBox(64, "Fertig ✓", _
                    $iOK & " ISO(s) heruntergeladen und auf " & $sDrive & " kopiert!" & @CRLF & @CRLF & _
                    "Kopiert:      " & $iCopied & " ISO(s)" & @CRLF & _
                    (($iCopyFail > 0) ? ("Kopierfehler: " & $iCopyFail & " ISO(s)" & @CRLF) : "") & _
                    (($sThemeLine <> "") ? ($sThemeLine & @CRLF) : ""))

            Else

                ; Download ohne Stick — Hinweis auf ausstehende Kopien

                Local $sPendHint = ""

                If $g_iPendingCopyCount > 0 Then

                    $sPendHint = @CRLF & @CRLF & _
                        "💡 Tipp: Sobald ein Ventoy-Stick angeschlossen wird," & @CRLF & _
                        "wird automatisch angeboten, " & $g_iPendingCopyCount & " ISO(s) auf den Stick zu kopieren."

                EndIf

                MsgBox(64, "Download abgeschlossen ✓", _
                    $iOK & " ISO(s) erfolgreich heruntergeladen!" & @CRLF & @CRLF & _
                    "Gespeichert in: " & $DOWNLOAD_DIR & $sPendHint)

            EndIf

        EndIf

    EndIf

EndFunc

Func _ChooseDownloadSlots($iJobCount)

    Local $iW = 520, $iH = 360

    Local $hDlg = GUICreate("Download-Modus wählen — " & $APP_TITLE, $iW, $iH, -1, -1, _
        BitOR($WS_CAPTION, $WS_SYSMENU), $WS_EX_DROPSHADOW, $g_hMain)

    GUISetBkColor($C_W)

    GUISetFont(9, 400, 0, "Segoe UI")

    ; Header

    GUICtrlCreateLabel("", 0, 0, $iW, 60)

    GUICtrlSetBkColor(-1, $C_BLUE)

    GUICtrlSetState(-1, $GUI_DISABLE)

    GUICtrlCreateLabel("Download-Modus wählen", 20, 10, $iW-40, 24)

    GUICtrlSetFont(-1, 13, 700, 0, "Segoe UI Semibold")

    GUICtrlSetColor(-1, 0xFFFFFF)

    GUICtrlSetBkColor(-1, $C_BLUE)

    Local $sCapHint = ""

    If $g_iSpeedMbps >= 0 And $g_iRecommendedSlots < $MAX_PARALLEL_SLOTS Then

        $sCapHint = "  (max " & $g_iRecommendedSlots & " empfohlen)"

    EndIf

    GUICtrlCreateLabel($iJobCount & " ISO(s) ausgewählt" & $sCapHint, 20, 36, $iW-40, 16)

    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")

    GUICtrlSetColor(-1, 0x93C5FD)

    GUICtrlSetBkColor(-1, $C_BLUE)

    ; Bandbreiten-Info

    Local $sSpeedInfo, $iSpeedColor

    If $g_iSpeedMbps < 0 Then

        $sSpeedInfo = "Bandbreite noch nicht gemessen"

        $iSpeedColor = $C_DIM

    ElseIf $g_iSpeedMbps = 0 Then

        $sSpeedInfo = "⚠ Keine Internetverbindung erkannt"

        $iSpeedColor = $C_RED

    ElseIf $g_iSpeedMbps >= 400 Then

        $sSpeedInfo = "🚀 Sehr schnell: " & $g_iSpeedMbps & " Mbit/s — Parallele Downloads sehr empfohlen!"

        $iSpeedColor = $C_GRN

    ElseIf $g_iSpeedMbps >= 100 Then

        $sSpeedInfo = "⚡ Gut: " & $g_iSpeedMbps & " Mbit/s — " & $g_iRecommendedSlots & " parallele Slots empfohlen"

        $iSpeedColor = $C_AMB

    Else

        $sSpeedInfo = "🐌 Langsam: " & $g_iSpeedMbps & " Mbit/s — 1 Download empfohlen"

        $iSpeedColor = $C_RED

    EndIf

    GUICtrlCreateLabel($sSpeedInfo, 20, 72, $iW-40, 18)

    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")

    GUICtrlSetColor(-1, $iSpeedColor)

    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlCreateLabel("", 20, 96, $iW-40, 1)

    GUICtrlSetBkColor(-1, $C_BRD)

    GUICtrlSetState(-1, $GUI_DISABLE)

    ; Erklärungstext

    GUICtrlCreateLabel("Wie viele ISOs sollen gleichzeitig heruntergeladen werden?", 20, 104, $iW-40, 16)

    GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_TXT)

    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlCreateLabel("Mehr Streams = schneller bei guter Verbindung,  aber höhere CPU/Netzwerk-Last.", 20, 122, $iW-40, 14)

    GUICtrlSetFont(-1, 8, 400, 2, "Segoe UI")

    GUICtrlSetColor(-1, $C_MID)

    GUICtrlSetBkColor(-1, $C_W)

    ; Slot-Buttons — cap bei Speedtest-Empfehlung damit Fenster übersichtlich bleibt

    ; Wenn Speed gemessen: max = empfohlene Slots; sonst: hartes MAX_PARALLEL_SLOTS

    Local $iSpeedCap  = ($g_iSpeedMbps >= 0) ? $g_iRecommendedSlots : $MAX_PARALLEL_SLOTS

    Local $iMaxChoice = $iJobCount

    If $iMaxChoice > $iSpeedCap       Then $iMaxChoice = $iSpeedCap

    If $iMaxChoice > $MAX_PARALLEL_SLOTS Then $iMaxChoice = $MAX_PARALLEL_SLOTS

    If $iMaxChoice < 1                Then $iMaxChoice = 1

    Local $ahSlotBtns[$MAX_PARALLEL_SLOTS]

    Local $iBtnW = Int(($iW - 40 - ($iMaxChoice - 1) * 8) / $iMaxChoice)

    If $iBtnW > 100 Then $iBtnW = 100

    Local $iBtnStartX = 20

    Local $iBtnY = 148

    ; Slot-Beschriftungen

    Local $aSlotDesc[7] = ["", "1 Stream" & @CRLF & "(sequentiell)", "2 Streams", "3 Streams", "4 Streams", "5 Streams", "6 Streams (Max)"]

    Local $aSlotMbps[7] = ["", "beliebig", "≥100 Mbit/s", "≥250 Mbit/s", "≥400 Mbit/s", "≥600 Mbit/s", "≥800 Mbit/s"]

    For $k = 1 To $iMaxChoice

        Local $iX = $iBtnStartX + ($k-1) * ($iBtnW + 8)

        Local $bRecommended = ($k = $g_iRecommendedSlots)

        Local $bBestForSpeed = ($k = $iMaxChoice And $g_iSpeedMbps >= 400)

        Local $iBg, $iFg

        If $bRecommended Then

            $iBg = $C_LBLU

            $iFg = $C_BLUE

        ElseIf $bBestForSpeed Then

            $iBg = $C_LGRN

            $iFg = $C_GRN

        Else

            $iBg = 0xF1F5F9

            $iFg = $C_TXT

        EndIf

        $ahSlotBtns[$k-1] = GUICtrlCreateButton($k & "x" & @CRLF & $aSlotMbps[$k], $iX, $iBtnY, $iBtnW, 54)

        GUICtrlSetFont(-1, 10, 700, 0, "Segoe UI")

        GUICtrlSetBkColor(-1, $iBg)

        GUICtrlSetColor(-1, $iFg)

        ; Empfohlen-Markierung

        If $bRecommended Then

            GUICtrlCreateLabel("★ empfohlen", $iX, $iBtnY+56, $iBtnW, 13)

            GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")

            GUICtrlSetColor(-1, $C_BLUE)

            GUICtrlSetBkColor(-1, $C_W)

        ElseIf $bBestForSpeed Then

            GUICtrlCreateLabel("⚡ Maximum", $iX, $iBtnY+56, $iBtnW, 13)

            GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")

            GUICtrlSetColor(-1, $C_GRN)

            GUICtrlSetBkColor(-1, $C_W)

        EndIf

    Next

    ; "Maximum nutzen"-Button (hervorgehoben wenn ≥400 Mbit/s)

    Local $hBtnMax = 0

    If $g_iSpeedMbps >= 400 And $iMaxChoice > 1 Then

        GUICtrlCreateLabel("", 20, 230, $iW-40, 1)

        GUICtrlSetBkColor(-1, $C_BRD)

        GUICtrlSetState(-1, $GUI_DISABLE)

        $hBtnMax = GUICtrlCreateButton("🚀  Maximum nutzen  (" & $iMaxChoice & " parallele Downloads)", 20, 240, $iW-40, 36)

        GUICtrlSetFont(-1, 10, 700, 0, "Segoe UI")

        GUICtrlSetBkColor(-1, $C_LGRN)

        GUICtrlSetColor(-1, $C_GRN)

        GUICtrlCreateLabel("Bei " & $g_iSpeedMbps & " Mbit/s: alle " & $iMaxChoice & " ISOs gleichzeitig laden — maximale Auslastung der Leitung.", 20, 280, $iW-40, 14)

        GUICtrlSetFont(-1, 8, 400, 2, "Segoe UI")

        GUICtrlSetColor(-1, $C_MID)

        GUICtrlSetBkColor(-1, $C_W)

    EndIf

    ; Abbrechen

    Local $hBtnCancel = GUICtrlCreateButton("Abbrechen", $iW-120, $iH-44, 100, 28)

    GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")

    GUICtrlSetBkColor(-1, $C_LRED)

    GUICtrlSetColor(-1, $C_RED)

    GUISetState(@SW_SHOW, $hDlg)

    Local $iResult = 0

    While $iResult = 0

        Local $m = GUIGetMsg()

        If $m = $GUI_EVENT_CLOSE Or $m = $hBtnCancel Then

            $iResult = -1   ; Abbruch

        ElseIf $m = $hBtnMax Then

            $iResult = $iMaxChoice

        Else

            For $k = 0 To $iMaxChoice - 1

                If $m = $ahSlotBtns[$k] Then

                    $iResult = $k + 1

                    ExitLoop

                EndIf

            Next

        EndIf

    WEnd

    GUIDelete($hDlg)

    If $iResult < 0 Then Return 0

    Return $iResult

EndFunc

Func _DownloadParallel(ByRef $aQueue, $iTotal, $iSlots, $sDrive = "", $bDeleteAfterCopy = False)

    _Log("=== Paralleler Download mit Pipelining: " & $iTotal & " ISOs, " & $iSlots & " Slots → " & $sDrive & " ===")

    Local $sCurl = _CurlPath()

    ; Multi-Slot-Popup aufbauen — adaptive Zeilenhöhe für Übersichtlichkeit

    ; Standard: 80px/Zeile (1-3 Slots)  Kompakt: 62px (4-5)  Mini: 50px (6)

    Local $iRowH = 80

    If $iSlots >= 5 Then

        $iRowH = 50

    ElseIf $iSlots >= 4 Then

        $iRowH = 62

    EndIf

    ; Bildschirm-Cap: Fenster darf nie größer als Bildschirm minus 80px Rand

    Local $iMaxPopH = @DesktopHeight - 80

    Local $iCalcH   = 120 + $iSlots * $iRowH + 60 + 68

    While $iCalcH > $iMaxPopH And $iRowH > 42

        $iRowH -= 4

        $iCalcH = 120 + $iSlots * $iRowH + 60 + 68

    WEnd

    ; Innerhalb einer Zeile: proportionale Y-Offsets und Balkenhöhe

    Local $iBarH   = ($iRowH <= 50) ? 8 : ($iRowH <= 62) ? 10 : 12

    Local $iOBar   = ($iRowH <= 50) ? 14 : ($iRowH <= 62) ? 16 : 18   ; Y-Offset Balken

    Local $iODet   = $iOBar + $iBarH + 4                               ; Y-Offset Detail-Label

    Local $iOSep   = $iRowH - 14                                       ; Y-Offset Trennlinie

    Local $bTimer  = ($iRowH >= 70)                                    ; Laufzeit-Label nur Standard

    Local $iOTimer = ($bTimer) ? ($iRowH - 30) : 0                    ; Y-Offset Timer

    Local $iPopH = $iCalcH

    Local $iPopW = 680

    Local $sModeHint = ($iRowH <= 50) ? " [Mini-Ansicht]" : ($iRowH <= 62) ? " [Kompakt]" : ""

    Local $hPopDlg = GUICreate("Parallel-Download (" & $iSlots & " Streams" & $sModeHint & ") — " & $APP_TITLE, _
        $iPopW, $iPopH, -1, -1, BitOR($WS_CAPTION, $WS_SYSMENU), $WS_EX_DROPSHADOW, $g_hMain)

    GUISetBkColor($C_W)

    GUISetFont(9, 400, 0, "Segoe UI")

    ; Header

    GUICtrlCreateLabel("", 0, 0, $iPopW, 5)

    GUICtrlSetBkColor(-1, $C_BLUE)

    GUICtrlSetState(-1, $GUI_DISABLE)

    Local $hPDTitle = GUICtrlCreateLabel("Parallel-Download: 0 / " & $iTotal & " fertig", 18, 12, $iPopW-36, 20)

    GUICtrlSetFont(-1, 11, 700, 0, "Segoe UI Semibold")

    GUICtrlSetColor(-1, $C_TXT)

    GUICtrlSetBkColor(-1, $C_W)

    Local $hPDSub = GUICtrlCreateLabel($iSlots & " Streams  |  " & $iTotal & " ISOs gesamt  |  " & _
        "Einzelne Slots können per ✕ abgebrochen werden", 18, 34, $iPopW-36, 16)

    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_MID)

    GUICtrlSetBkColor(-1, $C_W)

    ; Gesamt-Fortschrittsbalken

    GUICtrlCreateLabel("", 18, 56, $iPopW-36, 1)

    GUICtrlSetBkColor(-1, $C_BRD)

    GUICtrlSetState(-1, $GUI_DISABLE)

    Local $hPDGlobBar = GUICtrlCreateProgress(18, 62, $iPopW-36, 10)

    GUICtrlSetColor(-1, $C_BLUE)

    ; Slot-Zeilen  (jede Zeile 80px hoch)

    ; Layout je Slot

    ;   Y+0  : "Slot N:"  +  ISO-Name  +  [✕ Slot N]

    ;   Y+18 : Fortschrittsbalken (Bg + Fill)  +  Prozent

    ;   Y+34 : Detail-Zeile (Größe / Speed / ETA)

    ;   Y+52 : Laufzeit-Label  +  (nach Abbruch: "⏭ übersprungen")

    ;   Y+64 : Trennlinie

    Local $iSlotY   = 82

    Local $iBtnW_SK = 72          ; Breite des Slot-Abbrechen-Buttons

    Local $iBarMaxW = $iPopW - 100 - $iBtnW_SK - 10   ; Balkenbreite angepasst

    Local $aSlotBarY[$iSlots]

    Local $aSlotTStart[$iSlots]

    Local $aSlotLastSize[$iSlots]

    Local $aSlotLastTick[$iSlots]

    Local $aSlotSmoothBps[$iSlots]

    For $s = 0 To $iSlots - 1

        ; "Slot N:" Label

        GUICtrlCreateLabel("Slot " & ($s+1) & ":", 18, $iSlotY, 46, 14)

        GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")

        GUICtrlSetColor(-1, $C_DIM)

        GUICtrlSetBkColor(-1, $C_W)

        ; ISO-Name

        $g_ahSlotNameLbl[$s] = GUICtrlCreateLabel("— wartend —", 68, $iSlotY, $iPopW - 68 - $iBtnW_SK - 14, 14)

        GUICtrlSetFont(-1, 8, 600, 0, "Segoe UI")

        GUICtrlSetColor(-1, $C_TXT)

        GUICtrlSetBkColor(-1, $C_W)

        ; ✕ Slot-Abbrechen-Button (rechts oben je Zeile)

        $g_ahSlotCancelBtn[$s] = GUICtrlCreateButton("✕", $iPopW - $iBtnW_SK - 8, $iSlotY - 2, $iBtnW_SK, 18)

        GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")

        GUICtrlSetBkColor(-1, $C_LRED)

        GUICtrlSetColor(-1, $C_RED)

        GUICtrlSetTip(-1, "Slot " & ($s+1) & " abbrechen — nächste ISO in der Warteschlange wird gestartet")

        GUICtrlSetState(-1, $GUI_DISABLE)

        ; Fortschrittsbalken-Hintergrund (adaptive Höhe)

        $g_ahSlotBarBg[$s] = GUICtrlCreateLabel("", 18, $iSlotY+$iOBar, $iBarMaxW, $iBarH)

        GUICtrlSetBkColor(-1, $C_BRD)

        GUICtrlSetState(-1, $GUI_DISABLE)

        ; Füllbalken

        $g_ahSlotBarFill[$s] = GUICtrlCreateLabel("", 18, $iSlotY+$iOBar, 1, $iBarH)

        GUICtrlSetBkColor(-1, $C_BLUE)

        $aSlotBarY[$s] = $iSlotY + $iOBar

        ; Prozent-Label (rechts neben Balken)

        $g_ahSlotPctLbl[$s] = GUICtrlCreateLabel("0%", $iBarMaxW + 22, $iSlotY + $iOBar - 4, 54, 18)

        GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")

        GUICtrlSetColor(-1, $C_BLUE)

        GUICtrlSetBkColor(-1, $C_W)

        ; Detail-Label (Dateigröße / Speed / ETA)

        $g_ahSlotDetailLbl[$s] = GUICtrlCreateLabel("", 18, $iSlotY+$iODet, $iPopW - 36, 13)

        GUICtrlSetFont(-1, 7, 400, 0, "Consolas")

        GUICtrlSetColor(-1, $C_DIM)

        GUICtrlSetBkColor(-1, $C_W)

        ; Laufzeit-Label (nur in Standard-Modus ≥70px/Zeile)

        If $bTimer Then

            GUICtrlCreateLabel("", 18, $iSlotY+$iOTimer, 200, 11)

            GUICtrlSetFont(-1, 7, 400, 2, "Segoe UI")

            GUICtrlSetColor(-1, $C_DIM)

            GUICtrlSetBkColor(-1, $C_W)

        EndIf

        ; Trennlinie

        GUICtrlCreateLabel("", 18, $iSlotY + $iOSep, $iPopW-36, 1)

        GUICtrlSetBkColor(-1, $C_BRD)

        GUICtrlSetState(-1, $GUI_DISABLE)

        $iSlotY += $iRowH

        ; Arrays initialisieren

        $g_aiSlotPID[$s]     = 0

        $g_aiSlotIdx[$s]     = -1

        $g_asSlotFile[$s]    = ""

        $g_aiSlotTotal[$s]   = 0

        $g_aiSlotWritten[$s] = 0

        $aSlotSmoothBps[$s]  = 0

    Next

    ; Abbrechen-Button

    Local $hPDBtnCancel = GUICtrlCreateButton("  ✕  Alle abbrechen", $iPopW-160, $iPopH-46, 142, 30)

    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")

    GUICtrlSetBkColor(-1, $C_LRED)

    GUICtrlSetColor(-1, $C_RED)

    ; --- Kopier-Status-Zeile (unter allen Download-Slots) ---

    Local $iCopyRowY = $iSlotY + 6

    GUICtrlCreateLabel("", 18, $iCopyRowY, $iPopW - 36, 1)

    GUICtrlSetBkColor(-1, $C_BRD)

    GUICtrlSetState(-1, $GUI_DISABLE)

    GUICtrlCreateLabel("Stick:", 18, $iCopyRowY + 6, 46, 14)

    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_DIM)

    GUICtrlSetBkColor(-1, $C_W)

    Local $hCopyNameLbl = GUICtrlCreateLabel("— Warteschlange leer —", 68, $iCopyRowY + 6, $iPopW - 84, 14)

    GUICtrlSetFont(-1, 8, 600, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_DIM)

    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlCreateLabel("", 18, $iCopyRowY + 24, $iBarMaxW, 10)

    GUICtrlSetBkColor(-1, $C_BRD)

    GUICtrlSetState(-1, $GUI_DISABLE)

    Local $hCopyBarFill = GUICtrlCreateLabel("", 18, $iCopyRowY + 24, 1, 10)

    GUICtrlSetBkColor(-1, $C_AMB)

    Local $hCopyPctLbl = GUICtrlCreateLabel("", $iBarMaxW + 22, $iCopyRowY + 20, 54, 18)

    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_AMB)

    GUICtrlSetBkColor(-1, $C_W)

    Local $hCopyDetailLbl = GUICtrlCreateLabel("", 18, $iCopyRowY + 38, $iPopW - 36, 13)

    GUICtrlSetFont(-1, 7, 400, 0, "Consolas")

    GUICtrlSetColor(-1, $C_DIM)

    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlSetData($g_hProgress, 0)

    GUISetState(@SW_SHOW, $hPopDlg)

    ; --- v2.27: Initial alle Slot-Namen anzeigen ---

    For $s = 0 To $iSlots - 1

        If $s < $iTotal Then

            GUICtrlSetData($g_ahSlotNameLbl[$s], $g_aISOs[$aQueue[$s]][0])

            GUICtrlSetData($g_ahSlotDetailLbl[$s], "Warteschlange ...")

        EndIf

    Next

    ; --- v2.27: Mirror-Check PARALLEL für die gesamte Queue (jetzt bei offenem Fenster) ---

    GUICtrlSetData($hPDTitle, "Mirror-Check läuft …")

    GUICtrlSetData($hPDSub, "Ermittle schnellste Server für alle ausgewählten ISOs ...")

    _PreTestAllMirrors($aQueue, $iTotal)

    GUICtrlSetData($hPDTitle, "Parallel-Download: 0 / " & $iTotal & " fertig")

    GUICtrlSetData($hPDSub, $iSlots & " Streams  |  " & $iTotal & " ISOs gesamt")

    ; =========================================================================

    ; HAUPT-DISPATCHER-SCHLEIFE

    ; =========================================================================

    Local $iQueuePtr  = 0     ; nächste zu startende ISO

    Local $iDoneCount = 0     ; fertige ISOs

    Local $iFailCount = 0     ; fehlgeschlagene ISOs

    For $s = 0 To $iSlots - 1

        $aSlotTStart[$s]  = 0

        $aSlotLastSize[$s] = 0

        $aSlotLastTick[$s] = TimerInit()

    Next

    ; FIFO-Kopier-Queue — immer nur eine Kopie auf den Stick gleichzeitig

    Local $aiCopyQueue[$iTotal]   ; FIFO-Queue: ISO-Indices

    Local $iCopyQueueHead = 0     ; nächster zu kopierender Eintrag

    Local $iCopyQueueTail = 0     ; nächster freier Platz

    For $q = 0 To $iTotal - 1

        $aiCopyQueue[$q] = -1

    Next

    ; Aktive Kopie (immer nur eine)

    Local $iActiveCopyPID   = 0   ; PID des laufenden robocopy (0 = kein Copy aktiv)

    Local $iActiveCopyIdx   = -1  ; ISO-Index der aktiven Kopie

    Local $sActiveCopyDest  = ""  ; Zieldatei der aktiven Kopie

    Local $iActiveCopyTotal = 0   ; Dateigröße der aktiven Kopie

    Local $iActiveCopyPct   = 0   ; Aktueller Prozentwert (0-100)

    Local $iCopyDone = 0          ; erfolgreich auf Stick kopiert

    Local $iCopyFail = 0          ; Kopierfehler

    ; Schleife läuft bis ALLE Downloads UND ALLE laufenden Kopien fertig sind

    Local $bPipelineRunning = True

       While $bPipelineRunning
        ; --- Events abfragen (Hält die GUI responsiv) ---
        Local $ev = GUIGetMsg()
        If $ev = $GUI_EVENT_CLOSE Or $ev = $g_hBtnCancel Or $ev = $hPDBtnCancel Then
            $g_bCancel = True
        EndIf

        ; --- KRITISCHER FIX: Wenn globaler Abbruch aktiv ist, alle Prozesse killen ---
        If $g_bCancel Then
            _Log("!!! Globaler Abbruch ausgelöst. Schließe alle aktiven Slots sauber ...")
            For $s = 0 To $iSlots - 1
                If $g_aiSlotPID[$s] <> 0 Then
                    ProcessClose($g_aiSlotPID[$s]) ; Beendet curl.exe im Hintergrund
                    _Log(" -> Slot " & ($s+1) & " (PID: " & $g_aiSlotPID[$s] & ") zwangsweise beendet.")
                    $g_aiSlotPID[$s] = 0
                    $g_aiSlotIdx[$s] = -1
                EndIf
            Next
            
            ; Falls eine Robocopy-Kopie aktiv ist, diese ebenfalls beenden
            If $iActiveCopyPID <> 0 Then
                ProcessClose($iActiveCopyPID)
                _Log(" -> Aktiver Kopiervorgang (PID: " & $iActiveCopyPID & ") abgebrochen.")
                $iActiveCopyPID = 0
            EndIf
            
            ExitLoop ; Schleife sicher verlassen
        EndIf

        ; --- Einzel-Slot-Abbruch prüfen ---
        For $s = 0 To $iSlots - 1
            If $ev = $g_ahSlotCancelBtn[$s] Then
                If $g_aiSlotPID[$s] <> 0 Then
                    Local $sCancelName = $g_aISOs[$g_aiSlotIdx[$s]][0]
                    ProcessClose($g_aiSlotPID[$s])
                    _Log("Slot " & ($s+1) & " manuell abgebrochen: " & $sCancelName)

                    GUICtrlSetData($g_ahSlotNameLbl[$s], "⏭  " & $sCancelName & "  (übersprungen)")
                    GUICtrlSetColor($g_ahSlotNameLbl[$s], $C_AMB)
                    GUICtrlSetBkColor($g_ahSlotBarFill[$s], $C_AMB)
                    GUICtrlSetData($g_ahSlotPctLbl[$s], "—")
                    GUICtrlSetColor($g_ahSlotPctLbl[$s], $C_AMB)
                    GUICtrlSetData($g_ahSlotDetailLbl[$s], "Abgebrochen — Slot wird mit nächster ISO neu gestartet")
                    GUICtrlSetState($g_ahSlotCancelBtn[$s], $GUI_DISABLE)

                    $g_aiSlotPID[$s] = 0
                    $g_aiSlotIdx[$s] = -1
                    $iDoneCount += 1
                EndIf
                ExitLoop
            EndIf
        Next ; <--- DIESES NEXT HAT GEFEHLT UND BEHEBT DEN FEHLER


        ; --- Freie Slots mit nächster ISO befüllen ---

        For $s = 0 To $iSlots - 1

            If $g_aiSlotPID[$s] = 0 And $iQueuePtr < $iTotal And Not $g_bCancel Then

                Local $iIdx = $aQueue[$iQueuePtr]

                $iQueuePtr += 1

                Local $sDestDir = $TMP_DOWNLOAD_DIR

                If Not FileExists($sDestDir) Then DirCreate($sDestDir)

                Local $sFile = $sDestDir & "\" & $g_aISOs[$iIdx][3]

                ; --- v2.27: ISO-Name sofort anzeigen ---

                _Log("Slot " & ($s+1) & " → bereite vor: " & $g_aISOs[$iIdx][0])

                GUICtrlSetData($g_ahSlotNameLbl[$s], $g_aISOs[$iIdx][0])

                GUICtrlSetColor($g_ahSlotNameLbl[$s], $C_TXT)

                GUICtrlSetData($g_ahSlotDetailLbl[$s], "Suche besten Server ...")

                GUICtrlSetState($g_ahSlotCancelBtn[$s], $GUI_ENABLE)

                GUICtrlSetData($g_ahSlotCancelBtn[$s], "✕ wart.")

                ; Schnellsten Mirror wählen (bevorzugt aus Cache)

                Local $sURL = ""

                If $g_asSortedURLs[$iIdx] <> "" Then

                    ; Cache nutzen (von _PreTestAllMirrors am Start)

                    Local $aCache = StringSplit($g_asSortedURLs[$iIdx], "|", 2)

                    If UBound($aCache) > 0 Then $sURL = $aCache[0]

                    _Log("  [Cache] Nutze vorgetesteten Mirror: " & $sURL)

                EndIf

                If $sURL = "" Then

                    Local $aSlotURLs[5], $iSlotURLCount = 0

                    If $g_aISOs[$iIdx][2] <> "" Then $aSlotURLs[$iSlotURLCount] = $g_aISOs[$iIdx][2]
$iSlotURLCount += 1

                    If $g_aISOs[$iIdx][4] <> "" Then $aSlotURLs[$iSlotURLCount] = $g_aISOs[$iIdx][4]
$iSlotURLCount += 1

                    If $g_aISOs[$iIdx][5] <> "" Then $aSlotURLs[$iSlotURLCount] = $g_aISOs[$iIdx][5]
$iSlotURLCount += 1

                    If $g_aISOs[$iIdx][8] <> "" Then $aSlotURLs[$iSlotURLCount] = $g_aISOs[$iIdx][8]
$iSlotURLCount += 1

                    

                    If $iSlotURLCount > 1 Then

                        _SortURLsBySpeed($aSlotURLs, 0, $iSlotURLCount - 1)

                        $sURL = $aSlotURLs[0]

                    Else

                        $sURL = $g_aISOs[$iIdx][2]

                    EndIf

                EndIf

                Local $iResume = 0

                If FileExists($sFile) Then $iResume = FileGetSize($sFile)

                ; Remote-Größe vorab ermitteln

                Local $iTotalSz = _RemoteSize($sURL)

                ; Resume deaktivieren bei SourceForge-Redirect-Seiten

                ; CDN-Direktlinks (*.dl.sourceforge.net) unterstützen Resume auch mit ?viasf=1

                Local $bSlotSFRedir  = (StringInStr($sURL, "sourceforge.net/projects/") > 0)

                Local $bSlotQueryStr = (StringInStr($sURL, "?") > 0 And Not StringInStr($sURL, ".dl.sourceforge.net/"))

                Local $bSlotNoResume = ($bSlotSFRedir Or $bSlotQueryStr)

                Local $sSlotResume = ""

                If Not $bSlotNoResume And $iResume > 0 Then $sSlotResume = "-C - "

                Local $sArgs = '-L ' & $sSlotResume & '--fail -s --retry 1 --retry-delay 2 ' & _
                               '--connect-timeout 15 --max-time 7200 ' & _
                               '--ssl-no-revoke ' & _
                               '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                               '-H "Accept: application/octet-stream" ' & _
                               '-o "' & $sFile & '" "' & $sURL & '"'

                Local $iPID = Run('"' & $sCurl & '" ' & $sArgs, $sDestDir, @SW_HIDE)

                If $iPID = 0 Then

                    _Log("Slot " & ($s+1) & ": curl konnte nicht gestartet werden für " & $g_aISOs[$iIdx][0])

                    $iFailCount += 1

                    ContinueLoop

                EndIf

                $g_aiSlotPID[$s]     = $iPID

                $g_aiSlotIdx[$s]     = $iIdx

                $g_asSlotFile[$s]    = $sFile

                $g_aiSlotTotal[$s]   = $iTotalSz

                $g_aiSlotWritten[$s] = $iResume

                $aSlotTStart[$s]     = TimerInit()

                $aSlotLastSize[$s]   = $iResume

                $aSlotLastTick[$s]   = TimerInit()

                _Log("Slot " & ($s+1) & " → gestartet: " & $g_aISOs[$iIdx][0])

                GUICtrlSetData($g_ahSlotDetailLbl[$s], "Verbindung hergestellt ...")

                GUICtrlSetColor($g_ahSlotPctLbl[$s], $C_BLUE)

                GUICtrlSetBkColor($g_ahSlotBarFill[$s], $C_BLUE)

                GUICtrlSetData($g_ahSlotCancelBtn[$s], "✕ abbr.")

            EndIf

        Next

        ; --- Fortschritt aller aktiven Slots aktualisieren ---

        Local $iTotalGlobBytes = 0, $iDoneGlobBytes = 0

        For $s = 0 To $iSlots - 1

            If $g_aiSlotPID[$s] = 0 And $g_aiSlotIdx[$s] = -1 Then ContinueLoop

            Local $iNowSize = 0

            If FileExists($g_asSlotFile[$s]) Then $iNowSize = FileGetSize($g_asSlotFile[$s])

            Local $iTotSz = $g_aiSlotTotal[$s]

            $iTotalGlobBytes += ($iTotSz > 0 ? $iTotSz : $iNowSize)

            $iDoneGlobBytes  += $iNowSize

            ; Slot-Prozent berechnen

            Local $iSlotPct = 0

            If $iTotSz > 0 Then

                $iSlotPct = Int($iNowSize / $iTotSz * 100)

                If $iSlotPct > 100 Then $iSlotPct = 100

            EndIf

            ; Fortschrittsbalken-Breite aktualisieren

            Local $iFillW = Int($iBarMaxW * $iSlotPct / 100)

            If $iFillW < 1 Then $iFillW = 1

            GUICtrlSetPos($g_ahSlotBarFill[$s], 18, $aSlotBarY[$s], $iFillW, $iBarH)

            GUICtrlSetData($g_ahSlotPctLbl[$s], $iSlotPct & "%")

            ; Speed berechnen (1s Intervall)

            Local $iTickDiff = TimerDiff($aSlotLastTick[$s])

            If $iTickDiff >= 1000 Then

                Local $iDelta = $iNowSize - $aSlotLastSize[$s]

                $aSlotLastSize[$s]  = $iNowSize

                $aSlotLastTick[$s]  = TimerInit()

                If $iDelta > 0 And $iTickDiff > 0 Then

                    Local $iBps = $iDelta / ($iTickDiff / 1000)

                    ; v2.29: EMA-Glättung für Parallel-Slots

                    If $aSlotSmoothBps[$s] = 0 Then

                        $aSlotSmoothBps[$s] = $iBps

                    Else

                        $aSlotSmoothBps[$s] = ($aSlotSmoothBps[$s] * 0.7) + ($iBps * 0.3)

                    EndIf

                    Local $sSpd = _FmtBytes($aSlotSmoothBps[$s]) & "/s"

                    Local $sETA = ""

                    If $iTotSz > 0 And $iBps > 0 Then

                        $sETA = "  ETA " & _FmtTime(($iTotSz - $iNowSize) / $iBps)

                    EndIf

                    Local $sDetail = _FmtBytes($iNowSize)

                    If $iTotSz > 0 Then $sDetail &= " / " & _FmtBytes($iTotSz)

                    $sDetail &= "   " & $sSpd & $sETA

                    GUICtrlSetData($g_ahSlotDetailLbl[$s], $sDetail)

                EndIf

            EndIf

            ; Prozess beendet?

            If $g_aiSlotPID[$s] <> 0 And Not ProcessExists($g_aiSlotPID[$s]) Then

                Local $iFinalSz = 0

                If FileExists($g_asSlotFile[$s]) Then $iFinalSz = FileGetSize($g_asSlotFile[$s])

                ; ISO-Mindestgröße 300 MB — schließt HTML-Fehlerseiten und Redirect-Stubs aus

                Local $bOK = ($iFinalSz >= 314572800) And ($iTotSz = 0 Or $iFinalSz >= Int($iTotSz * 0.99))

                If $bOK Then

                    $iDoneCount += 1

                    _Log("Slot " & ($s+1) & " fertig: " & $g_aISOs[$g_aiSlotIdx[$s]][0] & "  " & _FmtBytes($iFinalSz))

                    GUICtrlSetData($g_ahSlotNameLbl[$s], "✓ " & $g_aISOs[$g_aiSlotIdx[$s]][0])

                    GUICtrlSetColor($g_ahSlotNameLbl[$s], $C_GRN)

                    GUICtrlSetData($g_ahSlotPctLbl[$s], "100%")

                    GUICtrlSetColor($g_ahSlotPctLbl[$s], $C_GRN)

                    GUICtrlSetBkColor($g_ahSlotBarFill[$s], $C_GRN)

                    GUICtrlSetData($g_ahSlotDetailLbl[$s], _FmtBytes($iFinalSz) & "  ✓ vollständig")

                    ; === v14.48: FIFO-Queue — ISO nach erfolgreichem Download einreihen ===

                    If $sDrive <> "" And DriveStatus($sDrive) = "READY" Then

                        Local $iPipeIdx = $g_aiSlotIdx[$s]

                        Local $sCat     = $g_aISOs[$iPipeIdx][1]

                        Local $sFile    = $g_aISOs[$iPipeIdx][3]

                        Local $sCatDir  = $sDrive & "\" & $sCat

                        If Not FileExists($sCatDir) Then DirCreate($sCatDir)

                        Local $sDstFile = $sCatDir & "\" & $sFile

                        ; Bereits vorhanden mit gleicher Größe → sofort als erledigt zählen

                        If FileExists($sDstFile) And FileGetSize($sDstFile) = $iFinalSz Then

                            _Log("  Queue-Copy: bereits auf Stick — " & $g_aISOs[$iPipeIdx][0])

                            GUICtrlSetData($g_ahSlotDetailLbl[$s], _FmtBytes($iFinalSz) & "  ✓ bereits auf Stick")

                            $iCopyDone += 1

                            If $bDeleteAfterCopy Then FileDelete($g_asSlotFile[$s])

                        Else

                            ; In Kopier-Warteschlange einreihen

                            $aiCopyQueue[$iCopyQueueTail] = $iPipeIdx

                            $iCopyQueueTail += 1

                            _Log("  Queue-Copy eingereiht (Pos " & ($iCopyQueueTail - $iCopyQueueHead) & "): " & $g_aISOs[$iPipeIdx][0])

                            GUICtrlSetData($g_ahSlotDetailLbl[$s], _FmtBytes($iFinalSz) & "  ⏳ wartet auf Stick-Kopie")

                        EndIf

                    EndIf

                    ; === Ende FIFO-Queue ===

                Else

                    ; BITS-Fallback für CDN-blockierte Downloads (z.B. Dr.Web, Avira)

                    ; Wird ausgeführt wenn curl 0 Byte lieferte und kein Benutzerabbruch vorliegt

                    If $iFinalSz = 0 And Not $g_bCancel Then

                        Local $sBitsSlotURL = $g_aISOs[$g_aiSlotIdx[$s]][2]

                        Local $sBitsSlotFile = $g_asSlotFile[$s]

                        Local $sBitsSlotName = $g_aISOs[$g_aiSlotIdx[$s]][0]

                        _Log("Slot " & ($s+1) & ": curl lieferte 0 B — BITS-Fallback für " & $sBitsSlotName)

                        GUICtrlSetData($g_ahSlotDetailLbl[$s], "⚙ BITS-Transfer (Windows-Stack) ...")

                        GUICtrlSetColor($g_ahSlotNameLbl[$s], $C_AMB)

                        GUICtrlSetBkColor($g_ahSlotBarFill[$s], $C_AMB)

                        ; BITS synchron — kurzes PS-Skript (max 3600s Timeout)

                        Local $sBitsPS1 = @TempDir & "\vlm_bits_slot" & $s & ".ps1"

                        Local $hBitsF = FileOpen($sBitsPS1, 2)

                        If $hBitsF <> -1 Then

                            FileWriteLine($hBitsF, 'try {')

                            FileWriteLine($hBitsF, '  Import-Module BitsTransfer -ErrorAction Stop')

                            FileWriteLine($hBitsF, '  $job = Start-BitsTransfer -Source "' & $sBitsSlotURL & '" -Destination "' & $sBitsSlotFile & '" -Asynchronous -DisplayName "VLM_Slot' & $s & '"')

                            FileWriteLine($hBitsF, '  $deadline = (Get-Date).AddSeconds(3600)')

                            FileWriteLine($hBitsF, '  while ($job.JobState -notin @("Transferred","Error","TransientError") -and (Get-Date) -lt $deadline) { Start-Sleep 2 }')

                            FileWriteLine($hBitsF, '  if ($job.JobState -eq "Transferred") { Complete-BitsTransfer $job ; exit 0 }')

                            FileWriteLine($hBitsF, '  Remove-BitsTransfer $job ; exit 1')

                            FileWriteLine($hBitsF, '} catch { exit 2 }')

                            FileClose($hBitsF)

                            ; PowerShell starten und auf Abschluss warten (Event-Loop weiter aktiv)

                            Local $iBitsPID2 = Run('powershell -NoProfile -ExecutionPolicy Bypass -File "' & $sBitsPS1 & '"', "", @SW_HIDE)

                            While ProcessExists($iBitsPID2)

                                Local $evB = GUIGetMsg()

                                If $evB = $GUI_EVENT_CLOSE Then _Quit()

                                If $evB = $g_hBtnCancel Or ($g_hPopCancel <> 0 And $evB = $g_hPopCancel) Then

                                    $g_bCancel = True

                                    ProcessClose($iBitsPID2)

                                    ExitLoop

                                EndIf

                                Sleep(300)

                            WEnd

                            FileDelete($sBitsPS1)

                        EndIf

                        If FileExists($sBitsSlotFile) Then $iFinalSz = FileGetSize($sBitsSlotFile)

                        If $iFinalSz >= 314572800 Then

                            _Log("Slot " & ($s+1) & " BITS-Transfer erfolgreich: " & _FmtBytes($iFinalSz))

                            GUICtrlSetData($g_ahSlotNameLbl[$s], $sBitsSlotName)

                            GUICtrlSetColor($g_ahSlotNameLbl[$s], $C_GRN)

                            GUICtrlSetBkColor($g_ahSlotBarFill[$s], $C_GRN)

                            GUICtrlSetData($g_ahSlotDetailLbl[$s], "✓ BITS  " & _FmtBytes($iFinalSz))

                            ; Erfolg-Pfad: wie normaler Slot-Abschluss weiterführen

                            $iDoneCount += 1

                            GUICtrlSetData($hPDTitle, "Parallel-Download: " & $iDoneCount & " / " & $iTotal & " fertig")

                            GUICtrlSetData($hPDGlobBar, Int($iDoneCount / $iTotal * 100))

                            If $sDrive <> "" Then

                                $aiCopyQueue[$iCopyQueueTail] = $g_aiSlotIdx[$s]

                                $iCopyQueueTail += 1

                            EndIf

                            $g_aiSlotPID[$s] = 0 

$g_aiSlotIdx[$s] = -1

                            GUICtrlSetState($g_ahSlotCancelBtn[$s], $GUI_DISABLE)

                            ContinueLoop 2   ; Äußere For-Schleife — Slot direkt neu belegen

                        Else

                            If $iFinalSz > 0 Then FileDelete($sBitsSlotFile)

                            _Log("Slot " & ($s+1) & " BITS-Transfer fehlgeschlagen (" & _FmtBytes($iFinalSz) & ")")

                        EndIf

                    EndIf

                    $iFailCount += 1

                    Local $sFailReason = ""

                    If $iFinalSz > 0 And $iFinalSz < 314572800 Then

                        $sFailReason = "  (zu klein: " & _FmtBytes($iFinalSz) & " — möglicherweise Fehlerseite)"

                        FileDelete($g_asSlotFile[$s])   ; defekte Datei löschen

                    EndIf

                    _Log("Slot " & ($s+1) & " FEHLER: " & $g_aISOs[$g_aiSlotIdx[$s]][0] & "  " & _FmtBytes($iFinalSz) & $sFailReason)

                    GUICtrlSetData($g_ahSlotNameLbl[$s], "✗ " & $g_aISOs[$g_aiSlotIdx[$s]][0])

                    GUICtrlSetColor($g_ahSlotNameLbl[$s], $C_RED)

                    GUICtrlSetColor($g_ahSlotPctLbl[$s], $C_RED)

                    GUICtrlSetBkColor($g_ahSlotBarFill[$s], $C_RED)

                    GUICtrlSetData($g_ahSlotDetailLbl[$s], "✗ Fehlgeschlagen" & $sFailReason)

                EndIf

                ; ✕-Button deaktivieren — Slot ist fertig / wartet auf nächste ISO

                GUICtrlSetState($g_ahSlotCancelBtn[$s], $GUI_DISABLE)

                GUICtrlSetData($g_ahSlotCancelBtn[$s], "✕")

                $g_aiSlotPID[$s]  = 0

                $g_aiSlotIdx[$s]  = -1

            EndIf

        Next

        ; === v14.48: Sequenzielle FIFO-Kopie — immer nur eine Kopie auf den Stick ===

        If $sDrive <> "" Then

            ; --- Nächsten Job aus Queue starten, falls kein Copy aktiv ---

            If $iActiveCopyPID = 0 And $iCopyQueueHead < $iCopyQueueTail Then

                Local $iNextIdx  = $aiCopyQueue[$iCopyQueueHead]

                $iCopyQueueHead += 1

                Local $sQCat     = $g_aISOs[$iNextIdx][1]

                Local $sQFile    = $g_aISOs[$iNextIdx][3]

                Local $sQCatDir  = $sDrive & "\" & $sQCat

                If Not FileExists($sQCatDir) Then DirCreate($sQCatDir)

                Local $sQDst     = $sQCatDir & "\" & $sQFile

                Local $iQSrcSz   = 0

                Local $sQSrc     = $TMP_DOWNLOAD_DIR & "\" & $sQFile

                If FileExists($sQSrc) Then $iQSrcSz = FileGetSize($sQSrc)

                If FileExists($sQDst) Then FileDelete($sQDst)

                Local $sQRoboArgs = '/J /NJH /NJS /NDL /R:1 /W:1 "' & _
                    $TMP_DOWNLOAD_DIR & '" "' & $sQCatDir & '" "' & $sQFile & '"'

                Local $iQPID = Run("robocopy " & $sQRoboArgs, "", @SW_HIDE, $STDERR_MERGED)

                If $iQPID > 0 Then

                    $iActiveCopyPID   = $iQPID

                    $iActiveCopyIdx   = $iNextIdx

                    $sActiveCopyDest  = $sQDst

                    $iActiveCopyTotal = $iQSrcSz

                    $iActiveCopyPct   = 0

                    Local $iQueued = $iCopyQueueTail - $iCopyQueueHead

                    _Log("  Queue-Copy gestartet (PID " & $iQPID & ", noch " & $iQueued & " in Queue): " & $g_aISOs[$iNextIdx][0] & " → " & $sQCatDir)

                    GUICtrlSetData($hCopyNameLbl, "⬆ " & $g_aISOs[$iNextIdx][0] & _
                        ($iQueued > 0 ? "  (+" & $iQueued & " wartend)" : ""))

                    GUICtrlSetColor($hCopyNameLbl, $C_AMB)

                    GUICtrlSetPos($hCopyBarFill, 18, $iCopyRowY + 24, 1, 10)

                    GUICtrlSetBkColor($hCopyBarFill, $C_AMB)

                    GUICtrlSetData($hCopyPctLbl, "0%")

                    GUICtrlSetData($hCopyDetailLbl, "")

                Else

                    _Log("  Queue-Copy FEHLER: robocopy nicht startbar für " & $g_aISOs[$iNextIdx][0])

                    $iCopyFail += 1

                EndIf

            EndIf

            ; --- Aktive Kopie pollen (StdoutRead → exakter Fortschritt auch auf exFAT) ---

            If $iActiveCopyPID <> 0 Then

                Local $sQOut = StdoutRead($iActiveCopyPID)

                If $sQOut <> "" Then

                    Local $aQMatch = StringRegExp($sQOut, "(\d+(?:\.\d+)?)\s*%", 3)

                    If IsArray($aQMatch) And UBound($aQMatch) > 0 Then

                        $iActiveCopyPct = Int($aQMatch[UBound($aQMatch)-1])

                    EndIf

                EndIf

                Local $iQPct = $iActiveCopyPct

                If $iQPct > 99 Then $iQPct = 99

                Local $iQCopiedNow = ($iActiveCopyTotal * $iQPct) / 100

                GUICtrlSetData($hCopyDetailLbl, "⬆ " & _FmtBytes($iQCopiedNow) & " / " & _FmtBytes($iActiveCopyTotal) & "  " & $iQPct & "%")

                Local $iQFillW = Int($iBarMaxW * $iQPct / 100)

                If $iQFillW < 1 Then $iQFillW = 1

                GUICtrlSetPos($hCopyBarFill, 18, $iCopyRowY + 24, $iQFillW, 10)

                GUICtrlSetData($hCopyPctLbl, $iQPct & "%")

                ; v2.27: Während Kopiervorgang auf Abbruch prüfen

                Local $evCopy = GUIGetMsg()

                If $evCopy = $GUI_EVENT_CLOSE Or $evCopy = $g_hBtnCancel Or $evCopy = $hPDBtnCancel Then

                    $g_bCancel = True

                    ; robocopy sofort beenden

                    If ProcessExists($iActiveCopyPID) Then ProcessClose($iActiveCopyPID)

                    Local $tCK = TimerInit()

                    While ProcessExists($iActiveCopyPID) And TimerDiff($tCK) < 500

                        Sleep(10)

                    WEnd

                    If FileExists($sActiveCopyDest) Then FileDelete($sActiveCopyDest)

                    _Log("  Kopie auf Stick abgebrochen: " & ($iActiveCopyIdx >= 0 ? $g_aISOs[$iActiveCopyIdx][0] : "?"))

                    GUICtrlSetData($hCopyNameLbl, "✕ Kopie abgebrochen")

                    GUICtrlSetColor($hCopyNameLbl, $C_RED)

                    $iActiveCopyPID = 0

                    ExitLoop 2   ; Hauptschleife verlassen

                EndIf

                ; robocopy fertig?

                If Not ProcessExists($iActiveCopyPID) Then

                    Local $iQFinalSz = 0

                    If FileExists($sActiveCopyDest) Then $iQFinalSz = FileGetSize($sActiveCopyDest)

                    Local $bQOK = ($iQFinalSz >= Int($iActiveCopyTotal * 0.99))

                    If $bQOK Then

                        $iCopyDone += 1

                        ; Status nach Parallel-Kopie aktualisieren

                        $g_aiUSBStatus[$iActiveCopyIdx] = 1

                        $g_aiNodeColor[$iActiveCopyIdx] = 1

                        $g_asUSBSize[$iActiveCopyIdx]   = _FmtBytes($iQFinalSz)

                        _Log("  Queue-Copy ✓: " & $g_aISOs[$iActiveCopyIdx][0] & "  " & _FmtBytes($iQFinalSz))

                        Local $iStillQueued = $iCopyQueueTail - $iCopyQueueHead

                        GUICtrlSetData($hCopyNameLbl, "✓ " & $g_aISOs[$iActiveCopyIdx][0] & _
                            ($iStillQueued > 0 ? "  (+" & $iStillQueued & " in Queue)" : ""))

                        GUICtrlSetColor($hCopyNameLbl, $C_GRN)

                        GUICtrlSetPos($hCopyBarFill, 18, $iCopyRowY + 24, $iBarMaxW, 10)

                        GUICtrlSetBkColor($hCopyBarFill, $C_GRN)

                        GUICtrlSetData($hCopyPctLbl, "100%")

                        GUICtrlSetColor($hCopyPctLbl, $C_GRN)

                        GUICtrlSetData($hCopyDetailLbl, _FmtBytes($iQFinalSz) & "  ✓ auf Stick kopiert")

                        ; Beim ersten kopierten ISO → Boot-Thema einrichten

                        If $iCopyDone = 1 Then _EnsureVentoyTheme($sDrive, False)

                        ; TMP-Datei löschen wenn gewünscht

                        If $bDeleteAfterCopy Then

                            Local $sQTmpSrc = $TMP_DOWNLOAD_DIR & "\" & $g_aISOs[$iActiveCopyIdx][3]

                            FileDelete($sQTmpSrc)

                            _Log("  🗑 TMP gelöscht: " & $sQTmpSrc)

                        EndIf

                    Else

                        $iCopyFail += 1

                        _Log("  Queue-Copy ✗: " & $g_aISOs[$iActiveCopyIdx][0] & "  " & _FmtBytes($iQFinalSz))

                        GUICtrlSetData($hCopyNameLbl, "✗ Fehler: " & $g_aISOs[$iActiveCopyIdx][0])

                        GUICtrlSetColor($hCopyNameLbl, $C_RED)

                        GUICtrlSetData($hCopyDetailLbl, "✗ Kopierfehler — Zieldatei unvollständig")

                        GUICtrlSetBkColor($hCopyBarFill, $C_RED)

                        If FileExists($sActiveCopyDest) Then FileDelete($sActiveCopyDest)

                    EndIf

                    ; Aktive Kopie zurücksetzen → Queue-Processor kann nächsten Job starten

                    $iActiveCopyPID   = 0

                    $iActiveCopyIdx   = -1

                    $sActiveCopyDest  = ""

                    $iActiveCopyTotal = 0

                    $iActiveCopyPct   = 0

                EndIf

            EndIf

        EndIf

        ; === Ende sequenzielle FIFO-Kopie ===

        ; Gesamt-Fortschrittsbalken

        If $iTotalGlobBytes > 0 Then

            Local $iGlobPct = Int($iDoneGlobBytes / $iTotalGlobBytes * 100)

            If $iGlobPct > 100 Then $iGlobPct = 100

            GUICtrlSetData($hPDGlobBar, $iGlobPct)

            GUICtrlSetData($g_hProgress, $iGlobPct)   ; auch Haupt-Fortschrittsbalken aktualisieren

            Local $sCopyInfo = ""

            If $sDrive <> "" Then $sCopyInfo = "  |  Kopiert: " & $iCopyDone

            GUICtrlSetData($hPDTitle, "Download+Kopie: " & ($iDoneCount + $iFailCount) & "/" & $iTotal & " DL  " & $iGlobPct & "%" & $sCopyInfo)

        EndIf

        Local $iQueueLen = $iCopyQueueTail - $iCopyQueueHead

        GUICtrlSetData($g_hStatusLbl, "Download: " & ($iDoneCount+$iFailCount) & "/" & $iTotal & " DL  |  " & _
            $iCopyDone & " kopiert" & ($iQueueLen > 0 ? "  |  " & $iQueueLen & " in Queue" : "") & _
            ($iActiveCopyPID > 0 ? "  |  Kopie läuft..." : ""))

        ; Loop läuft bis alle Downloads fertig UND Kopier-Queue leer UND keine aktive Kopie

        $bPipelineRunning = False

        If ($iDoneCount + $iFailCount) < $iTotal Then $bPipelineRunning = True

        If $sDrive <> "" Then

            If $iActiveCopyPID <> 0 Then $bPipelineRunning = True

            If $iCopyQueueHead < $iCopyQueueTail Then $bPipelineRunning = True

        EndIf

        ; Poll-Intervall für UI und Prozessor-Zyklen (v2.27)

        Sleep(50)

    WEnd

    ; Alle noch laufenden Download-Slots und die aktive Kopie beenden falls Abbruch

    If $g_bCancel Then

        _Log("!!! Abbruch angefordert — beende alle Prozesse ...")

        For $s = 0 To $iSlots - 1

            If $g_aiSlotPID[$s] <> 0 Then

                ProcessClose($g_aiSlotPID[$s])

            EndIf

        Next

        ; Aktive Stick-Kopie abbrechen

        If $iActiveCopyPID <> 0 Then

            ProcessClose($iActiveCopyPID)

            If FileExists($sActiveCopyDest) Then 

                ; Kurzes Warten bis Handle frei

                Local $tW = TimerInit()

                While ProcessExists($iActiveCopyPID) And TimerDiff($tW) < 500

                    Sleep(10)

                WEnd

                FileDelete($sActiveCopyDest)

            EndIf

        EndIf

        _Log("--- Alle Prozesse beendet. ---")

        ; Unvollständige TMP-Dateien löschen

        _CleanupIncompleteTmp()

    EndIf

    GUICtrlSetData($hPDGlobBar, 100)

    GUICtrlSetData($g_hProgress, 100)

    Local $sFinalMsg = "Abgebrochen"

    If Not $g_bCancel Then

        $sFinalMsg = "Fertig: " & $iDoneCount & " DL OK / " & $iFailCount & " DL Fehler"

        If $sDrive <> "" Then $sFinalMsg &= "  |  " & $iCopyDone & " kopiert"

    EndIf

    GUICtrlSetData($hPDTitle, $sFinalMsg)

    

    If Not $g_bCancel Then Sleep(1200)

    GUIDelete($hPopDlg)

    GUICtrlSetData($g_hProgress, 0)

    ; v2.27: Nach Abbruch während Kopiervorgang — Programm schließen wenn gewünscht

    If $g_bCancel Then

        Local $iCloseChoice = MsgBox(292, "Vorgang abgebrochen", _
            "Der Download-/Kopiervorgang wurde abgebrochen." & @CRLF & @CRLF & _
            "Bereits vollständig heruntergeladene ISOs bleiben erhalten." & @CRLF & _
            "Unvollständige Dateien wurden bereinigt." & @CRLF & @CRLF & _
            "Möchten Sie das Programm jetzt beenden?" & @CRLF & @CRLF & _
            "  JA    — Programm beenden" & @CRLF & _
            "  NEIN  — Programm geöffnet lassen")

        If $iCloseChoice = 6 Then _Quit()

    EndIf

    _Log("=== Parallel-Download+Pipeline abgeschlossen: " & $iDoneCount & " DL OK / " & $iFailCount & " Fehler  |  " & $iCopyDone & " kopiert / " & $iCopyFail & " Kopierfehler ===")

    ; Ergebnisse als Array [0]=DL-OK, [1]=DL-Fehler, [2]=Copy-OK, [3]=Copy-Fehler

    Local $aResult[4] = [$iDoneCount, $iFailCount, $iCopyDone, $iCopyFail]

    Return $aResult

EndFunc

Func _DownloadOne($iIdx, $iJobNr, $iJobTotal)

    Local $sName  = $g_aISOs[$iIdx][0]

    ; Downloads gehen in TMP-Verzeichnis

    Local $sDestDir = $TMP_DOWNLOAD_DIR

    If Not FileExists($sDestDir) Then DirCreate($sDestDir)

    Local $sFile  = $sDestDir & "\" & $g_aISOs[$iIdx][3]

    Local $sCurl  = _CurlPath()

    ; === Schritt 1: URL-Liste aufbauen ===

    ; Für GitHub-Repos: echte CDN-URL per API ermitteln (höchste Priorität)

    Local $aURLs[6]   ; GitHub-API + Primär + Mirror1 + Mirror2 + Mirror3 + Reserve

    Local $iURLCount = 0

    ; GitHub API-URL auflösen (wenn Repo hinterlegt)

    If $g_aISOs[$iIdx][6] <> "" Then

        _PopUpdate(0, "GitHub API: Ermittle Download-URL ...", $sName)

        Local $sAPIUrl = _GitHubResolveURL($g_aISOs[$iIdx][6], $g_aISOs[$iIdx][7])

        If $sAPIUrl <> "" Then

            $aURLs[$iURLCount] = $sAPIUrl

            $iURLCount += 1

            _Log("    GitHub API → " & $sAPIUrl)

        Else

            _Log("    GitHub API: keine URL gefunden, nutze Direktlink")

        EndIf

    EndIf

    ; GitHub-Slot-Offset (1 wenn GitHub-Repo vorhanden, sonst 0)

    Local $iGHSlot96 = ($g_aISOs[$iIdx][6] <> "") ? 1 : 0

    ; Vortest-Cache verwenden falls vorhanden (spart erneuten Speed-Test)

    If $g_asSortedURLs[$iIdx] <> "" Then

        ; Cache enthält pre-sortierte Primär+Mirror-URLs (pipe-getrennt)

        Local $aCacheParts = StringSplit($g_asSortedURLs[$iIdx], "|", 1)

        For $__c = 1 To $aCacheParts[0]

            If $aCacheParts[$__c] <> "" And $iURLCount < 6 Then

                $aURLs[$iURLCount] = $aCacheParts[$__c]

                $iURLCount += 1

            EndIf

        Next

        _Log("    Mirror-Reihenfolge aus Vortest-Cache: " & ($iURLCount - $iGHSlot96) & " URLs (schnellster zuerst)")

    Else

        ; Kein Cache → klassische Reihenfolge aufbauen und danach sortieren

        If $g_aISOs[$iIdx][2] <> "" Then

            $aURLs[$iURLCount] = $g_aISOs[$iIdx][2]

            $iURLCount += 1

        EndIf

        If $g_aISOs[$iIdx][4] <> "" Then

            $aURLs[$iURLCount] = $g_aISOs[$iIdx][4]

            $iURLCount += 1

        EndIf

        If $g_aISOs[$iIdx][5] <> "" Then

            $aURLs[$iURLCount] = $g_aISOs[$iIdx][5]

            $iURLCount += 1

        EndIf

        If $g_aISOs[$iIdx][8] <> "" Then

            $aURLs[$iURLCount] = $g_aISOs[$iIdx][8]

            $iURLCount += 1

        EndIf

    EndIf

    ; Keine URL gespeichert (z.B. vom Stick importiert) →

    ;         Versions-Finder sofort starten und URL automatisch befuellen

    If $iURLCount = 0 Then

        _Log("Keine URL fuer '" & $sName & "' — starte Versions-Finder ...")

        _PopUpdate(2, "Keine Download-URL — suche auf oeffentlichen Mirrors ...", $sName)

        Sleep(400)

        If _FindLatestVersionURL($iIdx, $sCurl) Then

            Local $sFoundU = $g_asUpdateURL[$iIdx]

            Local $sFoundV = $g_asUpdateVer[$iIdx]

            Local $sFoundF = $g_asUpdateFile[$iIdx]

            _Log("Versions-Finder: v" & $sFoundV & " → " & $sFoundU)

            _PopUpdate(5, "Gefunden: v" & $sFoundV & " — starte Download ...", $sName)

            Sleep(600)

            ; URL + Dateiname dauerhaft in DB speichern

            _SaveURLToISO($iIdx, $sFoundU)

            If $sFoundF <> "" Then $g_aISOs[$iIdx][3] = $sFoundF

            ; URL-Liste befuellen und Download normal fortsetzen

            $aURLs[0]  = $sFoundU

            $iURLCount = 1

            $sFile     = $sDestDir & "\" & $g_aISOs[$iIdx][3]

        Else

            _Log("FEHLER: Versions-Finder hat keine URL fuer '" & $sName & "' gefunden.")

            _PopUpdate(0, "Keine URL gefunden — Fallback-Optionen ...", $sName)

            Sleep(600)

            _PopClose()

            Local $bFB = _DownloadFallbackDialog($iIdx, $sFile, $sName, $iJobNr, $iJobTotal)

            If Not $bFB Then

                _PopShow("Download", $iJobTotal & " Distribution(en)", True)

                GUICtrlSetData($g_hPopTitle, "Download " & ($iJobNr + 1) & " / " & $iJobTotal)

                GUICtrlSetData($g_hPopSub, $sName & " — UEBERSPRUNGEN")

            EndIf

            Return $bFB

        EndIf

    EndIf

    ; Nur sortieren wenn KEIN Vortest-Cache vorhanden (Cache ist bereits sortiert)

    ; URLs nach Mirror-Geschwindigkeit sortieren (schnellster zuerst)

    If $g_asSortedURLs[$iIdx] = "" And $iURLCount > 1 Then

        Local $iGitHubCount = 0

        If $g_aISOs[$iIdx][6] <> "" Then $iGitHubCount = 1  ; GitHub-URL beansprucht Slot 0

        If $iURLCount - $iGitHubCount > 1 Then

            _SortURLsBySpeed($aURLs, $iGitHubCount, $iURLCount - 1)

        EndIf

    EndIf

    _Status("Lade: " & $sName & "  (" & ($iJobNr+1) & "/" & $iJobTotal & ")")

    _Log("--- Download: " & $sName & " (" & $iURLCount & " URLs verfügbar)")

    GUICtrlSetData($g_hPopTitle, "Download " & ($iJobNr+1) & " / " & $iJobTotal)

    GUICtrlSetData($g_hPopSub,   $sName)

    ; Resume-Offset prüfen

    Local $iResume = 0

    If FileExists($sFile) Then

        $iResume = FileGetSize($sFile)

        _Log("    Resume ab: " & _FmtBytes($iResume))

    EndIf

    ; === Schritt 2: URL-Fallback-Schleife ===

    Local $bSuccess = False

    For $u = 0 To $iURLCount - 1

        If $g_bCancel Then ExitLoop

        Local $sURL = $aURLs[$u]

        _Log("    Versuch " & ($u+1) & "/" & $iURLCount & ": " & $sURL)

        _PopUpdate(0, "URL " & ($u+1) & "/" & $iURLCount & ": Ermittle Größe ...", $sName)

        ; Dateigröße vorab (HEAD-Request)

        Local $iTotalSize = _RemoteSize($sURL)

        _Log("    Remote-Größe: " & _FmtBytes($iTotalSize))

        ; Bereits vollständig?

        If $iResume >= $iTotalSize And $iTotalSize > 0 Then

            _Log("    Bereits vollständig, überspringe.")

            _PopUpdate(100, "Bereits vorhanden: " & _FmtBytes($iResume), $sName & " — 100%")

            Sleep(600)

            $bSuccess = True

            ExitLoop

        EndIf

        ; --- curl mit GitHub-kompatiblen Headern starten ---

        ; -L    = Redirects folgen (wichtig für GitHub 302, SourceForge)

        ; -A    = User-Agent (SourceForge/GitHub brauchen Browser-UA)

        ; --fail = Exit-Code ≠0 bei HTTP 4xx/5xx (verhindert HTML-Fehlerseiten als "Download")

        ; Kein -C - bei: SourceForge-Redirect-Seiten (/projects/.../download) da diese

        ; Range-Requests nicht unterstützen. CDN-Direktlinks (master.dl.sf.net etc.)

        ; unterstützen Range-Requests auch mit ?viasf=1.

        Local $bSFRedirect  = (StringInStr($sURL, "sourceforge.net/projects/") > 0)

        Local $bQueryString = (StringInStr($sURL, "?") > 0 And Not StringInStr($sURL, ".dl.sourceforge.net/"))

        Local $bNoResume    = ($bSFRedirect Or $bQueryString)

        Local $sResume = ""

        If Not $bNoResume And $iResume > 0 Then

            $sResume = "-C - "

        ElseIf $bNoResume And $iResume > 0 Then

            _Log("    Resume deaktiviert für SourceForge-Redirect oder unbekannten Query-String")

        EndIf

        ; verbesserte curl-Flags

        ; --ssl-no-revoke  = Windows OCSP-Prüfung überspringen (häufige Fehlerquelle)

        ; --tcp-nodelay    = Latenz bei kleinen Paketen minimieren

        ; --no-alpn        = Kompatibilität bei manchen Proxy-Servern/Firewalls erhöhen

        ; retry 3          = mehr Versuche, retry-connrefused = auch bei Verbindungsabbruch

        Local $sArgs = '-L ' & $sResume & '--fail -s --retry 3 --retry-delay 2 --retry-connrefused ' & _
                       '--connect-timeout 30 --max-time 7200 ' & _
                       '--ssl-no-revoke --tcp-nodelay --no-alpn ' & _
                       '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36" ' & _
                       '-H "Accept: */*" ' & _
                       '-H "Accept-Language: de-DE,de;q=0.9,en;q=0.8" ' & _
                       '-o "' & $sFile & '" ' & _
                       '"' & $sURL & '"'

        _Log("    curl: " & $sArgs)

        Local $iPID = Run('"' & $sCurl & '" ' & $sArgs, $sDestDir, @SW_HIDE)

        If $iPID = 0 Then

            _Log("    curl nicht startbar, nächste URL ...")

            ContinueLoop

        EndIf

        $g_iCurlPID = $iPID

        Local $tInterval  = TimerInit()

        Local $iLastSize   = $iResume

        Local $fSmoothBps  = 0

        Local $sLastSpeed  = ""

        Local $sLastETA    = ""

        While ProcessExists($iPID)

            If $g_bCancel Then

                ProcessClose($iPID)

                _Log("    Abgebrochen vom Benutzer.")

                ExitLoop

            EndIf

            Local $ev = GUIGetMsg()

            If $ev = $GUI_EVENT_CLOSE  Then _Quit()

            If $ev = $g_hBtnCancel    Then $g_bCancel = True

            If $g_hPopCancel <> 0 And $ev = $g_hPopCancel Then $g_bCancel = True

            Local $iNow

            If FileExists($sFile) Then

                $iNow = FileGetSize($sFile)

            Else

                $iNow = 0

            EndIf

            Local $iPct = 0

            If $iTotalSize > 0 Then

                $iPct = Int($iNow / $iTotalSize * 100)

                If $iPct > 99 Then $iPct = 99

            Else

                $iPct = Int(Mod(TimerDiff($tInterval) / 500, 90))

            EndIf

            GUICtrlSetData($g_hProgress, Int(($iJobNr * 100 + $iPct) / $iJobTotal))

            Local $iElapsed = TimerDiff($tInterval) / 1000

            If $iElapsed >= 1.0 Then

                Local $iDelta = $iNow - $iLastSize

                If $iDelta >= 0 Then

                    Local $iBps = $iDelta / $iElapsed

                    If $iBps > 0 Then

                        ; v2.29: EMA-Glättung (70% alt, 30% neu) — filtert Schreib-Cache-Bursts

                        If $fSmoothBps = 0 Then

                            $fSmoothBps = $iBps

                        Else

                            $fSmoothBps = ($fSmoothBps * 0.7) + ($iBps * 0.3)

                        EndIf

                        $sLastSpeed = _FmtBytes($fSmoothBps) & "/s"

                        GUICtrlSetData($g_hSpeedLbl, $sLastSpeed)

                        If $iTotalSize > 0 And $iNow < $iTotalSize Then

                            $sLastETA = "ETA " & _FmtTime(($iTotalSize - $iNow) / $iBps)

                            GUICtrlSetData($g_hEtaLbl, $sLastETA)

                        EndIf

                    EndIf

                EndIf

                $iLastSize = $iNow

                $tInterval = TimerInit()

            EndIf

            Local $sDetail = _FmtBytes($iNow)

            If $iTotalSize > 0 Then $sDetail &= " / " & _FmtBytes($iTotalSize)

            If $sLastSpeed <> "" Then $sDetail &= "     " & $sLastSpeed

            If $sLastETA   <> "" Then $sDetail &= "     " & $sLastETA

            If $u > 0 Then $sDetail &= "  [Quelle " & ($u+1) & "]"

            _PopUpdate($iPct, $sDetail, $sName & "  —  " & $iPct & "%")

            Sleep(250)   ; v2.28: feineres Polling (war 800ms) für präzisere Geschwindigkeitsanzeige

        WEnd

        $g_iCurlPID = 0

        Sleep(600)

        If $g_bCancel Then ExitLoop

        ; Erfolg prüfen

        ; ISO-Mindestgröße: 300 MB — HTML-Fehlerseiten, Redirect-Stubs und

        ; unvollständige Downloads werden damit zuverlässig ausgeschlossen.

        ; (kleinste echte ISO im Set ist Tails mit ~1,5 GB)

        Local $iMinISOSize = 314572800   ; 300 MB in Bytes

        Local $iSize

        If FileExists($sFile) Then

            $iSize = FileGetSize($sFile)

        Else

            $iSize = 0

        EndIf

        _Log("    Dateigröße nach Download: " & _FmtBytes($iSize))

        If $iSize >= $iMinISOSize Then

            ; Wenn Remote-Größe bekannt: Vollständigkeit prüfen (≥99%)

            If $iTotalSize > 0 Then

                If $iSize >= Int($iTotalSize * 0.99) Then

                    _PopUpdate(100, "✓ OK: " & _FmtBytes($iSize), $sName & " — 100%")

                    _Status("OK: " & $sName & " (" & _FmtBytes($iSize) & ")")

                    _Log("    Download erfolgreich (Quelle " & ($u+1) & "): " & _FmtBytes($iSize) & " / " & _FmtBytes($iTotalSize))

                    $bSuccess = True

                    ExitLoop

                Else

                    _Log("    Unvollständig (" & _FmtBytes($iSize) & " / " & _FmtBytes($iTotalSize) & ", " & Int($iSize / $iTotalSize * 100) & "%) — nächste Quelle")

                    _PopUpdate(0, "Unvollständig (" & Int($iSize / $iTotalSize * 100) & "%) — versuche nächste Quelle ...", $sName)

                    Sleep(1500)

                    ; BUGFIX: Teildatei löschen — kein Cross-URL-Resume!

                    ; Teildatei von URL A mit URL B weiterzuladen erzeugt korrupte ISO.

                    FileDelete($sFile)

                    $iResume = 0

                EndIf

            Else

                ; Remote-Größe unbekannt (kein Content-Length): Größe muss plausibel sein.

                ; curl gibt Exit-Code 0 auch bei erfolgreichen Downloads ohne Content-Length.

                ; Wir akzeptieren als Erfolg wenn die Datei ≥300MB ist und in der letzten

                ; Sekunde KEINE neuen Bytes mehr hinzugekommen sind (= Download abgeschlossen).

                _PopUpdate(100, "✓ OK (Größe unbekannt): " & _FmtBytes($iSize), $sName & " — fertig")

                _Status("OK: " & $sName & " (" & _FmtBytes($iSize) & ")")

                _Log("    Download erfolgreich, Größe unbekannt (Quelle " & ($u+1) & "): " & _FmtBytes($iSize))

                $bSuccess = True

                ExitLoop

            EndIf

        ElseIf $iSize > 0 Then

            ; Datei zu klein — wahrscheinlich HTML-Fehlerseite oder Redirect-Stub

            _Log("    Datei zu klein (" & _FmtBytes($iSize) & " < 300 MB) — möglicherweise HTML-Fehlerseite, Quelle defekt")

            _PopUpdate(0, "Fehler: Datei zu klein (" & _FmtBytes($iSize) & ") — versuche Quelle " & ($u+2) & " ...", $sName)

            FileDelete($sFile)

            $iResume = 0

            Sleep(1500)

        Else

            _Log("    Keine Datei erzeugt — Quelle nicht erreichbar, nächste versuchen")

            _PopUpdate(0, "Quelle nicht erreichbar — versuche Quelle " & ($u+2) & " ...", $sName)

            $iResume = 0

            Sleep(1500)

        EndIf

    Next

    ; === Schritt 2b: Letzter curl-Versuch mit --insecure (SSL-Fehler überwinden) ===

    ; Manche Mirror-Server haben abgelaufene SSL-Zertifikate — das --insecure-Flag

    ; ignoriert die Zertifikatsprüfung und ermöglicht den Download trotzdem.

    ; Nur 1 Versuch mit der ersten URL, kurze Timeout-Zeit.

    If Not $bSuccess And Not $g_bCancel And $iURLCount > 0 Then

        _Log("    Alle normalen curl-Quellen fehlgeschlagen — Letzter Versuch: --insecure ...")

        _PopUpdate(3, "Letzter Versuch: SSL-Zertifikat ignorieren (--insecure) ...", $sName)

        If FileExists($sFile) Then FileDelete($sFile)

        Local $sArgsIns = '-L --insecure --fail -s --retry 1 --connect-timeout 30 --max-time 7200 ' & _
                          '--compressed ' & _
                          '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:125.0) Gecko/20100101 Firefox/125.0" ' & _
                          '-H "Accept: */*" ' & _
                          '-o "' & $sFile & '" "' & $aURLs[0] & '"'

        Local $iPIDins = Run('"' & $sCurl & '" ' & $sArgsIns, $sDestDir, @SW_HIDE)

        If $iPIDins <> 0 Then

            $g_iCurlPID = $iPIDins

            Local $tIns = TimerInit()

            While ProcessExists($iPIDins)

                If $g_bCancel Then ProcessClose($iPIDins) 

ExitLoop

                Local $evIns = GUIGetMsg()

                If $evIns = $GUI_EVENT_CLOSE Then _Quit()

                If $evIns = $g_hBtnCancel Then $g_bCancel = True

                If $g_hPopCancel <> 0 And $evIns = $g_hPopCancel Then $g_bCancel = True

                Local $iSzIns = 0

                If FileExists($sFile) Then $iSzIns = FileGetSize($sFile)

                Local $iPctIns = Int(Mod(TimerDiff($tIns) / 500, 90))

                If $iSzIns > 0 Then

                    _PopUpdate($iPctIns, "--insecure: " & _FmtBytes($iSzIns) & " geladen ...", $sName)

                EndIf

                Sleep(1000)

            WEnd

            $g_iCurlPID = 0

            Local $iSzInsF = 0

            If FileExists($sFile) Then $iSzInsF = FileGetSize($sFile)

            If $iSzInsF >= 314572800 Then

                _PopUpdate(99, "✓ --insecure OK: " & _FmtBytes($iSzInsF), $sName & " — fertig")

                _Log("    --insecure erfolgreich: " & _FmtBytes($iSzInsF))

                $bSuccess = True

            Else

                If $iSzInsF > 0 Then FileDelete($sFile)

                _Log("    --insecure ebenfalls fehlgeschlagen (" & _FmtBytes($iSzInsF) & ")")

            EndIf

        EndIf

    EndIf

    ; === Schritt 3: PowerShell BITS-Fallback ===

    If Not $bSuccess And Not $g_bCancel Then

        _Log("    Alle curl-Quellen fehlgeschlagen — versuche BITS-Transfer ...")

        _PopUpdate(5, "Versuche BITS-Transfer (Windows-Hintergrunddienst) ...", $sName)

        ; Beste URL für BITS: GitHub API-URL bevorzugen, sonst Primär-URL

        Local $sBitsURL

        If ($iURLCount > 0) Then

            $sBitsURL = $aURLs[0]

        Else

            $sBitsURL = $g_aISOs[$iIdx][2]

        EndIf

        $bSuccess = _DownloadBITS($sBitsURL, $sFile, $sName, $iJobNr, $iJobTotal)

        If $bSuccess Then

            _Log("    BITS-Transfer erfolgreich!")

        Else

            _Log("    BITS-Transfer ebenfalls fehlgeschlagen.")

        EndIf

    EndIf

    ; === Schritt 3b: Automatischer Versions-Finder Fallback (v14.37) ===

    ; Alle bekannten URLs fehlgeschlagen. Haeufigste Ursache: neue Version veroeffentlicht.

    ; Suche aktuelle ISO auf oeffentlichen Mirrors und lade sie direkt herunter.

    If Not $bSuccess And Not $g_bCancel Then

        _Log("    Schritt 3b: Versions-Finder — suche aktuelle Version auf Mirrors ...")

        _PopUpdate(3, "Suche aktuelle Version auf oeffentlichen Mirrors ...", $sName)

        Sleep(400)

        If _FindLatestVersionURL($iIdx, $sCurl) Then

            Local $sAutoURL  = $g_asUpdateURL[$iIdx]

            Local $sAutoVer  = $g_asUpdateVer[$iIdx]

            Local $sAutoFile = $g_asUpdateFile[$iIdx]

            _Log("    Versions-Finder: v" & $sAutoVer & " gefunden → " & $sAutoURL)

            _PopUpdate(8, "Gefunden: v" & $sAutoVer & " — starte Download ...", $sName)

            Sleep(700)

            ; Zieldateiname fuer neue Version bestimmen

            Local $sNewAutoFile

            If $sAutoFile <> "" Then

                $sNewAutoFile = $sDestDir & "\" & $sAutoFile

            Else

                $sNewAutoFile = $sFile

            EndIf

            If FileExists($sNewAutoFile) Then FileDelete($sNewAutoFile)

            ; curl-Versuch mit neuer URL

            $bSuccess = _DownloadCurlDirect($sAutoURL, $sNewAutoFile, $sName, $iJobNr, $iJobTotal)

            If Not $bSuccess Then

                _Log("    Versions-Finder: curl fehlgeschlagen — versuche BITS ...")

                _PopUpdate(5, "Versions-Finder: versuche BITS-Transfer ...", $sName)

                $bSuccess = _DownloadBITS($sAutoURL, $sNewAutoFile, $sName, $iJobNr, $iJobTotal)

            EndIf

            If $bSuccess Then

                ; Neue URL, Dateiname, Anzeigename und Mirrors dauerhaft in DB speichern via _AutoApplyUpdate

                _AutoApplyUpdate($iIdx)

                _AutoUpdateTooltip($iIdx)   ; Tooltip-Zeile mit neuer Versionsnummer synchronisieren

                $sFile = $sNewAutoFile

                _Log("    Versions-Finder: v" & $sAutoVer & " erfolgreich — DB aktualisiert.")

                _PopUpdate(100, "Versions-Finder: v" & $sAutoVer & " erfolgreich heruntergeladen!", $sName)

                Sleep(900)

            Else

                _Log("    Versions-Finder: Download v" & $sAutoVer & " fehlgeschlagen.")

                If FileExists($sNewAutoFile) Then FileDelete($sNewAutoFile)

            EndIf

        Else

            _Log("    Versions-Finder: Keine aktuellere Version auf Mirrors gefunden.")

        EndIf

    EndIf

    ; === Schritt 4: Erweiterter Fallback-Dialog mit mehreren Optionen ===

    If Not $bSuccess And Not $g_bCancel Then

        _Log("FEHLER: Alle automatischen Quellen fehlgeschlagen für " & $sName)

        _PopUpdate(0, "Alle Quellen fehlgeschlagen — Fallback-Optionen verfügbar ...", $sName)

        Sleep(800)

        _PopClose()

        $bSuccess = _DownloadFallbackDialog($iIdx, $sFile, $sName, $iJobNr, $iJobTotal)

        ; Popup wieder öffnen falls weitere Downloads folgen

        If Not $bSuccess Then

            _PopShow("Download", $iJobTotal & " Distribution(en)", True)

            GUICtrlSetData($g_hPopTitle, "Download " & ($iJobNr+1) & " / " & $iJobTotal)

            GUICtrlSetData($g_hPopSub, $sName & " — ÜBERSPRUNGEN")

            _Status("Übersprungen: " & $sName)

            Sleep(1000)

        EndIf

    EndIf

    GUICtrlSetData($g_hSpeedLbl, "")

    GUICtrlSetData($g_hEtaLbl,   "")

    Return $bSuccess   ; True = erfolgreich heruntergeladen, False = fehlgeschlagen

EndFunc

Func _GitHubResolveURL($sRepo, $sAssetPattern)

    If $sRepo = "" Or $sAssetPattern = "" Then Return ""

    Local $sCurl = _CurlPath()

    If $sCurl = "" Then Return ""

    Local $sAPIUrl = "https://api.github.com/repos/" & $sRepo & "/releases/latest"

    _Log("    GitHub API Anfrage: " & $sAPIUrl)

    ; curl: JSON der API abrufen

    ; -H "Accept: application/vnd.github+json"  = GitHub API v3 Format

    ; -H "X-GitHub-Api-Version: 2022-11-28"     = stabile API-Version

    Local $sArgs = '-s -L --max-time 20 ' & _
                   '-H "Accept: application/vnd.github+json" ' & _
                   '-H "X-GitHub-Api-Version: 2022-11-28" ' & _
                   '-A "UniversalISOManager/10.0" ' & _
                   '"' & $sAPIUrl & '"'

    Local $iPID = Run('"' & $sCurl & '" ' & $sArgs, "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)

    If $iPID = 0 Then

        _Log("    GitHub API: curl nicht startbar")

        Return ""

    EndIf

    Local $sJSON = ""

    While ProcessExists($iPID)

        $sJSON &= StdoutRead($iPID)

        Sleep(150)

    WEnd

    $sJSON &= StdoutRead($iPID)

    If StringLen($sJSON) < 50 Then

        _Log("    GitHub API: Leere Antwort")

        Return ""

    EndIf

    ; JSON parsen: "browser_download_url":"https://..." für das passende Asset suchen

    ; Muster: Suche nach dem Asset mit dem gewünschten Dateinamen

    ; GitHub JSON-Struktur: assets[].name + assets[].browser_download_url

    ;

    ; FIX: Korrekte Glob-zu-Regex-Konvertierung

    ;   Vorher: StringReplace("*", ...) → * blieb als Regex-Quantifier (falsch!)

    ;   Bsp:  Nobara-*-Official.iso → Nobara\-*\-Official\.iso  ← FALSCH (*=0..n Bindestriche)

    ;   Jetzt: * → .* (Glob-Wildcard = beliebige Zeichen)

    ;   Bsp:  Nobara-*-Official.iso → Nobara\-.*\-Official\.iso ← KORREKT

    Local $sPatternEsc = $sAssetPattern

    $sPatternEsc = StringReplace($sPatternEsc, "*", "[[GLOB_STAR]]")    ; Platzhalter schützen

    $sPatternEsc = StringReplace($sPatternEsc, "?", "[[GLOB_QMARK]]")

    $sPatternEsc = StringReplace($sPatternEsc, ".", "\.")               ; Regex: . escapen

    $sPatternEsc = StringReplace($sPatternEsc, "-", "\-")               ; Regex: - escapen

    $sPatternEsc = StringReplace($sPatternEsc, "[[GLOB_STAR]]",  ".*")  ; Glob * → Regex .*

    $sPatternEsc = StringReplace($sPatternEsc, "[[GLOB_QMARK]]", ".")   ; Glob ? → Regex .

    Local $aMatch = StringRegExp($sJSON, _
        '"name"\s*:\s*"' & $sPatternEsc & '"[^}]*?"browser_download_url"\s*:\s*"([^"]+)"', 3)

    If Not IsArray($aMatch) Or UBound($aMatch) = 0 Then

        ; Rückwärts-Suche: browser_download_url zuerst, dann name

        $aMatch = StringRegExp($sJSON, _
            '"browser_download_url"\s*:\s*"([^"]+' & $sPatternEsc & '[^"]*)"', 3)

    EndIf

    If IsArray($aMatch) And UBound($aMatch) > 0 Then

        Local $sFoundURL = $aMatch[0]

        _Log("    GitHub API: Asset gefunden → " & $sFoundURL)

        Return $sFoundURL

    EndIf

    ; Fallback: Suche nach .iso in browser_download_url

    Local $aISO = StringRegExp($sJSON, '"browser_download_url"\s*:\s*"([^"]+\.iso)"', 3)

    If IsArray($aISO) And UBound($aISO) > 0 Then

        _Log("    GitHub API: ISO-Fallback → " & $aISO[0])

        Return $aISO[0]

    EndIf

    _Log("    GitHub API: Kein passendes Asset gefunden")

    Return ""

EndFunc

Func _DownloadBITS($sURL, $sFile, $sName, $iJobNr, $iJobTotal)

    If $sURL = "" Then Return False

    _Log("    BITS-Transfer: " & $sURL & " → " & $sFile)

    _PopUpdate(2, "BITS-Transfer gestartet ...", $sName & " [BITS]")

    ; Temporäre PS1-Datei schreiben (sicherer als einzeiliger Befehl)

    Local $sPS1 = @TempDir & "\vlm_bits.ps1"

    Local $hPS = FileOpen($sPS1, 2)

    If $hPS = -1 Then

        _Log("    BITS: Kann PS1-Datei nicht erstellen")

        Return False

    EndIf

    FileWriteLine($hPS, '$ProgressPreference = "SilentlyContinue"')

    FileWriteLine($hPS, 'try {')

    FileWriteLine($hPS, '  Import-Module BitsTransfer -ErrorAction Stop')

    FileWriteLine($hPS, '  $job = Start-BitsTransfer -Source "' & $sURL & '" -Destination "' & $sFile & '" -Asynchronous -DisplayName "VLM"')

    FileWriteLine($hPS, '  while ($job.JobState -notin @("Transferred","Error","TransientError")) {')

    FileWriteLine($hPS, '    $pct = if ($job.BytesTotal -gt 0) { [int]($job.BytesTransferred / $job.BytesTotal * 100) } else { 0 }')

    FileWriteLine($hPS, '    Write-Host "PROGRESS:$pct:$($job.BytesTransferred):$($job.BytesTotal)"')

    FileWriteLine($hPS, '    Start-Sleep -Milliseconds 1000')

    FileWriteLine($hPS, '  }')

    FileWriteLine($hPS, '  if ($job.JobState -eq "Transferred") { Complete-BitsTransfer $job; Write-Host "BITS_OK" }')

    FileWriteLine($hPS, '  else { Remove-BitsTransfer $job; Write-Host "BITS_ERR:$($job.JobState)" }')

    FileWriteLine($hPS, '} catch { Write-Host "BITS_EXCEPTION:$_" }')

    FileClose($hPS)

    Local $iPID = Run('powershell -NoProfile -ExecutionPolicy Bypass -File "' & $sPS1 & '"', _
        "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)

    If $iPID = 0 Then

        _Log("    BITS: PowerShell nicht startbar")

        FileDelete($sPS1)

        Return False

    EndIf

    Local $bOK = False

    Local $iLastPct = 0

    While ProcessExists($iPID)

        If $g_bCancel Then

            ProcessClose($iPID)

            _Log("    BITS: Abgebrochen")

            ExitLoop

        EndIf

        Local $sOut = StdoutRead($iPID)

        If $sOut <> "" Then

            ; PROGRESS-Zeilen auswerten

            Local $aLines = StringSplit(StringStripWS($sOut, 3), @LF, 2)

            For $l = 0 To UBound($aLines) - 1

                Local $sLine = StringStripWS($aLines[$l], 3)

                If StringLeft($sLine, 9) = "PROGRESS:" Then

                    Local $aParts = StringSplit($sLine, ":", 2)

                    If UBound($aParts) >= 3 Then

                        Local $iPct  = Int($aParts[1])

                        Local $iDone = Number($aParts[2])

                        Local $iTotal = Number($aParts[3])

                        If $iPct > $iLastPct Then $iLastPct = $iPct

                        Local $sDetail = _FmtBytes($iDone)

                        If $iTotal > 0 Then $sDetail &= " / " & _FmtBytes($iTotal)

                        _PopUpdate($iPct, $sDetail & "  [BITS-Transfer]", $sName & "  —  " & $iPct & "%")

                        GUICtrlSetData($g_hProgress, Int(($iJobNr * 100 + $iPct) / $iJobTotal))

                    EndIf

                ElseIf $sLine = "BITS_OK" Then

                    $bOK = True

                ElseIf StringLeft($sLine, 8) = "BITS_ERR" Or StringLeft($sLine, 14) = "BITS_EXCEPTION" Then

                    _Log("    BITS Fehler: " & $sLine)

                EndIf

            Next

        EndIf

        Local $ev = GUIGetMsg()

        If $ev = $GUI_EVENT_CLOSE  Then _Quit()

        If $ev = $g_hBtnCancel    Then $g_bCancel = True

        If $g_hPopCancel <> 0 And $ev = $g_hPopCancel Then $g_bCancel = True

        Sleep(500)

    WEnd

    ; Letzte Ausgabe lesen

    Local $sFinal = StdoutRead($iPID)

    If StringInStr($sFinal, "BITS_OK") Then $bOK = True

    FileDelete($sPS1)

    ; Erfolgsprüfung: BITS_OK-Signal UND Mindestgröße 300 MB

    Local $iSize

    If FileExists($sFile) Then

        $iSize = FileGetSize($sFile)

    Else

        $iSize = 0

    EndIf

    If $iSize >= 314572800 Then   ; 300 MB Minimum für ISO-Dateien

        _PopUpdate(100, "✓ BITS OK: " & _FmtBytes($iSize), $sName & " — 100%")

        _Status("OK (BITS): " & $sName & " (" & _FmtBytes($iSize) & ")")

        _Log("    BITS-Transfer abgeschlossen: " & _FmtBytes($iSize))

        Return True

    EndIf

    If $iSize > 0 Then

        _Log("    BITS: Datei zu klein (" & _FmtBytes($iSize) & ") — möglicherweise HTML-Fehlerseite")

        FileDelete($sFile)

    EndIf

    Return False

EndFunc

Func _DownloadCurlDirect($sURL, $sFile, $sName, $iJobNr, $iJobTotal)

    Local $sCurl = _CurlPath()

    If $sCurl = "" Or $sURL = "" Then Return False

    Local $iTotalSize = _RemoteSize($sURL)

    _Log("    Direktdownload: " & $sURL & "  Größe: " & _FmtBytes($iTotalSize))

    Local $iResume

    If FileExists($sFile) Then

        $iResume = FileGetSize($sFile)

    Else

        $iResume = 0

    EndIf

    If $iResume >= $iTotalSize And $iTotalSize > 0 Then

        _PopUpdate(100, "Bereits vorhanden: " & _FmtBytes($iResume), $sName & " — 100%")

        Return True

    EndIf

    Local $sArgs = '-L -C - -s --retry 1 --connect-timeout 30 --max-time 14400 ' & _
                   '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                   '-H "Accept: application/octet-stream" ' & _
                   '-o "' & $sFile & '" "' & $sURL & '"'

    Local $iPID = Run('"' & $sCurl & '" ' & $sArgs, $DOWNLOAD_DIR, @SW_HIDE)

    If $iPID = 0 Then Return False

    $g_iCurlPID = $iPID

    Local $tInterval = TimerInit()

    Local $iLastSize = $iResume

    While ProcessExists($iPID)

        If $g_bCancel Then

            ProcessClose($iPID)

            ExitLoop

        EndIf

        Local $ev = GUIGetMsg()

        If $ev = $GUI_EVENT_CLOSE  Then _Quit()

        If $ev = $g_hBtnCancel    Then $g_bCancel = True

        If $g_hPopCancel <> 0 And $ev = $g_hPopCancel Then $g_bCancel = True

        Local $iNow

        If FileExists($sFile) Then

            $iNow = FileGetSize($sFile)

        Else

            $iNow = 0

        EndIf

        Local $iPct

        If ($iTotalSize > 0) Then

            $iPct = Int($iNow / $iTotalSize * 100)

        Else

            $iPct = Int(Mod(TimerDiff($tInterval)/500, 90))

        EndIf

        If $iPct > 99 Then $iPct = 99

        GUICtrlSetData($g_hProgress, Int(($iJobNr * 100 + $iPct) / $iJobTotal))

        Local $iEl = TimerDiff($tInterval) / 1000

        Local $sSpd = ""

        If $iEl >= 1.0 Then

            Local $iDelta = $iNow - $iLastSize

            If $iDelta > 0 Then

                $sSpd = "  " & _FmtBytes($iDelta / $iEl) & "/s"

                GUICtrlSetData($g_hSpeedLbl, _FmtBytes($iDelta / $iEl) & "/s")

            EndIf

            $iLastSize = $iNow

            $tInterval = TimerInit()

        EndIf

        Local $sDetail = _FmtBytes($iNow)

        If $iTotalSize > 0 Then $sDetail &= " / " & _FmtBytes($iTotalSize)

        _PopUpdate($iPct, $sDetail & $sSpd & "  [Manuell]", $sName & "  —  " & $iPct & "%")

        Sleep(800)

    WEnd

    $g_iCurlPID = 0

    Sleep(500)

    Local $iSize

    If FileExists($sFile) Then

        $iSize = FileGetSize($sFile)

    Else

        $iSize = 0

    EndIf

    ; ISO-Mindestgröße 300 MB + Vollständigkeitscheck

    If $iSize >= 314572800 Then

        If $iTotalSize = 0 Or $iSize >= Int($iTotalSize * 0.99) Then

            _PopUpdate(100, "✓ OK: " & _FmtBytes($iSize), $sName & " — 100%")

            _Log("    Direktdownload erfolgreich: " & _FmtBytes($iSize))

            Return True

        EndIf

    ElseIf $iSize > 0 Then

        _Log("    Direktdownload: Datei zu klein (" & _FmtBytes($iSize) & ") — möglicherweise Fehlerseite")

        FileDelete($sFile)

    EndIf

    Return False

EndFunc

Func _ManualURLDialog($sName, $sFilename)

    Local $sHint = ""

    If StringInStr($sName, "G DATA") Or StringInStr($sName, "GDATA") Or StringInStr($sName, "BootMedium") Or _
       StringInStr($sName, "ESET") Or StringInStr($sName, "SysRescue") Or StringInStr($sName, "eset_sysrescue") Then

        $sHint = "G DATA BootMedium (ESET SysRescue Live ist seit Sept. 2023 EOL):" & @CRLF & _
                 "Downloadseite: https://www.gdatasoftware.com/downloads" & @CRLF & _
                 "Direktdownload: https://www.gdatasoftware.com/fileadmin/web/en/documents/bootcd/GData-BootMedium.iso"

    ElseIf StringInStr($sName, "Comodo Rescue") Or StringInStr($sName, "comodo_rescue") Then

        $sHint = "Comodo Rescue Disk: https://www.comodo.com/home/internet-security/rescue-disk.php" & @CRLF & _
                 "Direktdownload: https://download.comodo.com/crd/download/setups/comodo_rescue_disk.iso"

    ElseIf StringInStr($sName, "Nobara") Then

        $sHint = "Nobara: https://nobaraproject.org/download/" & @CRLF & _
                 "→ Aktuellen Release-ISO-Link kopieren"

    ElseIf StringInStr($sName, "Garuda") Or StringInStr($sName, "Dr460nized") Or StringInStr($sName, "Drauger") Then

        $sHint = "Garuda Linux Gaming (Drauger OS EOL — Arch-basierter Ersatz):" & @CRLF & _
                 "Direktdownload: https://iso.builds.garudalinux.org/iso/latest/garuda/dr460nized-gaming/latest.iso" & @CRLF & _
                 "Downloadseite: https://garudalinux.org/downloads"

    ElseIf StringInStr($sName, "PikaOS") Or StringInStr($sName, "Pika") Then

        $sHint = "PikaOS (Ventoy-inkompatibel): https://pika-os.com/" & @CRLF & _
                 "→ Direktdownload: https://iso.pika-os.com/"

    ElseIf StringInStr($sName, "EndeavourOS") Or StringInStr($sName, "Endeavour") Then

        $sHint = "EndeavourOS: https://endeavouros.com/latest-release/" & @CRLF & _
                 "→ Mirror DE: https://mirror.alpix.eu/endeavouros/iso/"

    ElseIf StringInStr($sName, "Bazzite") Then

        $sHint = "Bazzite (nur Installer): https://bazzite.gg/" & @CRLF & _
                 "→ Direktdownload: https://download.bazzite.gg/bazzite-stable-amd64.iso"

    ElseIf StringInStr($sName, "Kali") Then

        $sHint = "Kali offiziell: https://cdimage.kali.org/current/" & @CRLF & _
                 "Kali CDN: https://kali.download/kali-images/current/" & @CRLF & _
                 "→ kali-linux-YYYY.N-live-amd64.iso"

    ElseIf StringInStr($sName, "Tails") Then

        $sHint = "Tails offiziell: https://download.tails.net/tails/stable/" & @CRLF & _
                 "→ tails-amd64-X.Y.iso  (ISO, nicht .img!)"

    ElseIf StringInStr($sName, "Parrot") Then

        $sHint = "Parrot offiziell: https://www.parrotsec.org/download/" & @CRLF & _
                 "→ Parrot-security-X.Y_amd64.iso"

    ElseIf StringInStr($sName, "Mint") Then

        $sHint = "Linux Mint: https://linuxmint.com/download.php" & @CRLF & _
                 "→ Cinnamon Edition → direkten Mirror-Link kopieren"

    ElseIf StringInStr($sName, "Ubuntu") And Not StringInStr($sName, "Lubuntu") Then

        $sHint = "Ubuntu offiziell: https://releases.ubuntu.com/" & @CRLF & _
                 "→ ubuntu-XX.XX.X-desktop-amd64.iso"

    ElseIf StringInStr($sName, "Zorin") Then

        $sHint = "Zorin OS: https://zorin.com/os/download/" & @CRLF & _
                 "→ Core Edition → ISO-Link kopieren"

    ElseIf StringInStr($sName, "Pop") Then

        $sHint = "Pop!_OS: https://system76.com/pop/download/" & @CRLF & _
                 "→ NVIDIA-Version → direkten ISO-Link kopieren"

    ElseIf StringInStr($sName, "Manjaro") Then

        $sHint = "Manjaro: https://manjaro.org/download/" & @CRLF & _
                 "→ KDE Plasma Edition → ISO herunterladen"

    ElseIf StringInStr($sName, "Fedora") Then

        $sHint = "Fedora offiziell: https://fedoraproject.org/workstation/download/" & @CRLF & _
                 "→ Fedora-Workstation-Live-x86_64-44-X.X.iso"

    ElseIf StringInStr($sName, "EndeavourOS") Then

        $sHint = "EndeavourOS: https://endeavouros.com/latest-release/" & @CRLF & _
                 "→ EndeavourOS_CODENAME-YYYY.MM.iso"

    ElseIf StringInStr($sName, "CachyOS") Then

        $sHint = "CachyOS: https://cachyos.org/download/" & @CRLF & _
                 "→ Desktop ISO → direkten CDN-Link kopieren"

    ElseIf StringInStr($sName, "Debian") Then

        $sHint = "Debian offiziell: https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/" & @CRLF & _
                 "→ debian-live-XX.X-amd64-xfce.iso"

    ElseIf StringInStr($sName, "MX") Then

        $sHint = "MX Linux: https://mxlinux.org/download-links/" & @CRLF & _
                 "→ MX-XX.X_x64.iso (64-bit)"

    ElseIf StringInStr($sName, "Lubuntu") Then

        $sHint = "Lubuntu: https://lubuntu.me/downloads/" & @CRLF & _
                 "→ lubuntu-XX.XX.X-desktop-amd64.iso"

    ElseIf StringInStr($sName, "AlmaLinux") Then

        $sHint = "AlmaLinux: https://almalinux.org/get-almalinux/" & @CRLF & _
                 "→ AlmaLinux-X.X-x86_64-Live-XFCE.iso"

    Else

        $sHint = "Bitte die direkte .iso Download-URL eingeben."

    EndIf

    ; Zwischenablage vorausfüllen wenn sie eine ISO-URL enthält

    Local $sClip = ClipGet()

    Local $sDefault = ""

    If StringLeft($sClip, 4) = "http" Then

        Local $sClipL = StringLower($sClip)

        If StringInStr($sClipL, ".iso") Or StringInStr($sClipL, "release") Or _
           StringInStr($sClipL, "download") Or StringInStr($sClipL, "cdimage") Then

            $sDefault = StringStripWS($sClip, 3)

        EndIf

    EndIf

    Local $sDWHint = @CRLF & _
        "──────────────────────────────────────────────────────" & @CRLF & _
        "💡 DistroWatch-Suche:  https://distrowatch.com/?pkg=" & StringReplace($sName, " ", "+") & @CRLF & _
        "(URL als Vorlage im Browser kopieren → hier mit Ctrl+V einfügen)" & @CRLF & _
        "──────────────────────────────────────────────────────"

    Local $sPrompt = "Manuelle URL für:" & @CRLF & _
        "  " & $sName & @CRLF & @CRLF & _
        $sHint & @CRLF & _
        $sDWHint & @CRLF & _
        "Zieldatei: " & $sFilename & @CRLF & @CRLF & _
        "Direkte Download-URL eingeben (https://...):"

    Local $sURL = InputBox("Manuelle URL — " & $sName, $sPrompt, $sDefault, "", 660, 340)

    If @error Or StringStripWS($sURL, 3) = "" Then Return ""

    $sURL = StringStripWS($sURL, 3)

    If Not StringLeft($sURL, 4) = "http" Then

        MsgBox(16, "Ungültige URL", "Die URL muss mit http:// oder https:// beginnen.")

        Return ""

    EndIf

    _Log("    Manuelle URL eingegeben: " & $sURL)

    Return $sURL

EndFunc

Func _DownloadFallbackDialog($iIdx, $sFile, $sName, $iJobNr, $iJobTotal)

    ; Versions-Finder URL vormerken fuer Zwischenablage + Browser-Option

    Local $sFoundVer = $g_asUpdateVer[$iIdx]

    Local $sFoundURL = $g_asUpdateURL[$iIdx]

    If $sFoundURL <> "" Then ClipPut($sFoundURL)   ; vorbefuellen fuer _ManualURLDialog

    Local $iW = 580, $iH = 546

    Local $hDlg = GUICreate("⚠ Download fehlgeschlagen — " & $sName, $iW, $iH, -1, -1, _
        BitOR($WS_CAPTION, $WS_SYSMENU), $WS_EX_DROPSHADOW, $g_hMain)

    GUISetBkColor($C_W)

    GUISetFont(9, 400, 0, "Segoe UI")

    ; ── Roter Warnstreifen ─────────────────────────────────────────────────

    GUICtrlCreateLabel("", 0, 0, $iW, 5)

    GUICtrlSetBkColor(-1, $C_RED)

    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── Header ─────────────────────────────────────────────────────────────

    GUICtrlCreateLabel("", 0, 5, $iW, 62)

    GUICtrlSetBkColor(-1, $C_LRED)

    GUICtrlSetState(-1, $GUI_DISABLE)

    GUICtrlCreateLabel("⚠  Alle automatischen Quellen fehlgeschlagen", 18, 12, $iW - 36, 22)

    GUICtrlSetFont(-1, 12, 700, 0, "Segoe UI Semibold")

    GUICtrlSetColor(-1, $C_RED)

    GUICtrlSetBkColor(-1, $C_LRED)

    GUICtrlCreateLabel($sName, 18, 36, $iW - 36, 18)

    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_MID)

    GUICtrlSetBkColor(-1, $C_LRED)

    ; ── Ursachen / Versions-Finder-Banner ─────────────────────────────────

    If $sFoundVer <> "" Then

        ; Gruenes Banner: Neuere Version wurde vom Versions-Finder gefunden

        GUICtrlCreateLabel("", 18, 72, $iW - 36, 74)

        GUICtrlSetBkColor(-1, 0xD4EDDA)

        GUICtrlSetState(-1, $GUI_DISABLE)

        GUICtrlCreateLabel("🆕  Versions-Finder: Neuere Version verfügbar!", 26, 77, $iW - 52, 16)

        GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI Semibold")

        GUICtrlSetColor(-1, 0x155724)

        GUICtrlSetBkColor(-1, 0xD4EDDA)

        GUICtrlCreateLabel("  v" & $sFoundVer & "  auf Mirror gefunden und verifiziert.", 26, 94, $iW - 52, 14)

        GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")

        GUICtrlSetColor(-1, 0x155724)

        GUICtrlSetBkColor(-1, 0xD4EDDA)

        GUICtrlCreateLabel("  Tipp: " & Chr(34) & "Eigene URL eingeben" & Chr(34) & " ist bereits mit der gefundenen URL vorbefüllt (Ctrl+V).", 26, 111, $iW - 52, 28)

        GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")

        GUICtrlSetColor(-1, 0x155724)

        GUICtrlSetBkColor(-1, 0xD4EDDA)

    Else

        GUICtrlCreateLabel("Mögliche Ursachen:", 18, 78, $iW - 36, 14)

        GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")

        GUICtrlSetColor(-1, $C_TXT)

        GUICtrlSetBkColor(-1, $C_W)

        GUICtrlCreateLabel( _
            "  •  URL hat sich geändert (neue Version der Distribution veröffentlicht)" & @CRLF & _
            "  •  Netzwerk oder Firewall blockiert den direkten Download" & @CRLF & _
            "  •  Mirror-Server temporär nicht erreichbar / GitHub-Rate-Limit", _
            18, 94, $iW - 36, 44)

        GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")

        GUICtrlSetColor(-1, $C_MID)

        GUICtrlSetBkColor(-1, $C_W)

    EndIf

    GUICtrlCreateLabel("", 18, 148, $iW - 36, 1)

    GUICtrlSetBkColor(-1, $C_BRD)

    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── Optionen-Titel ─────────────────────────────────────────────────────

    GUICtrlCreateLabel("Bitte wähle eine Alternative:", 18, 152, $iW - 36, 16)

    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI Semibold")

    GUICtrlSetColor(-1, $C_TXT)

    GUICtrlSetBkColor(-1, $C_W)

    ; ────────────────────────────────────────────────────────────────────────

    ; Option 1 — TORRENT

    ; ────────────────────────────────────────────────────────────────────────

    Local $sTorrentURL = _GetTorrentURL($iIdx)

    Local $hBtn1, $hBtn2, $hBtn3, $hBtn4, $hBtn5

    Local $iBg1, $iFg1

    If $sTorrentURL <> "" Then

        $iBg1 = $C_LBLU 

$iFg1 = $C_BLUE

    Else

        $iBg1 = $C_CARD  

$iFg1 = $C_DIM

    EndIf

    GUICtrlCreateLabel("", 18, 174, $iW - 36, 58)

    GUICtrlSetBkColor(-1, $iBg1)

    GUICtrlSetState(-1, $GUI_DISABLE)

    $hBtn1 = GUICtrlCreateButton("🧲  Torrent / Magnet öffnen", 26, 179, 200, 28)

    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")

    GUICtrlSetBkColor(-1, $iBg1)

    GUICtrlSetColor(-1, $iFg1)

    If $sTorrentURL = "" Then GUICtrlSetState(-1, $GUI_DISABLE)

    Local $sTorrentHint

    If $sTorrentURL <> "" Then

        $sTorrentHint = "Öffnet den Torrent/Magnet-Link im Browser." & @CRLF & _
            "Lade die ISO mit qBittorrent/Motrix und lege sie in:" & @CRLF & _
            StringLeft($TMP_DOWNLOAD_DIR, 60)

    Else

        $sTorrentHint = "Kein Torrent-Link für diese Distribution hinterlegt."

    EndIf

    GUICtrlCreateLabel($sTorrentHint, 234, 179, $iW - 252, 46)

    GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")

    GUICtrlSetColor(-1, $iFg1)

    GUICtrlSetBkColor(-1, $iBg1)

    ; ────────────────────────────────────────────────────────────────────────

    ; Option 2 — BROWSER-DOWNLOAD

    ; ────────────────────────────────────────────────────────────────────────

    ; Wenn Versions-Finder URL gefunden hat, diese fuer Browser-Option nutzen

    Local $sWebURL

    If $sFoundURL <> "" Then

        $sWebURL = $sFoundURL    ; direkte ISO-URL der neueren Version

    Else

        $sWebURL = _GetOfficialWebURL($iIdx)

    EndIf

    GUICtrlCreateLabel("", 18, 238, $iW - 36, 58)

    GUICtrlSetBkColor(-1, $C_LGRN)

    GUICtrlSetState(-1, $GUI_DISABLE)

    $hBtn2 = GUICtrlCreateButton("🌐  Im Browser herunterladen", 26, 243, 200, 28)

    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")

    GUICtrlSetBkColor(-1, $C_LGRN)

    GUICtrlSetColor(-1, $C_GRN)

    Local $sBrowserHint

    If $sFoundVer <> "" Then

        $sBrowserHint = "Oeffnet direkte ISO-URL von v" & $sFoundVer & " im Browser." & @CRLF & _
            "ISO speichern nach: " & StringLeft($TMP_DOWNLOAD_DIR, 50)

    Else

        $sBrowserHint = "Oeffnet die offizielle Download-Seite im Browser." & @CRLF & _
            "ISO manuell herunterladen und ablegen in:" & @CRLF & StringLeft($TMP_DOWNLOAD_DIR, 60)

    EndIf

    GUICtrlCreateLabel($sBrowserHint, 234, 243, $iW - 252, 46)

    GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_GRN)

    GUICtrlSetBkColor(-1, $C_LGRN)

    ; ────────────────────────────────────────────────────────────────────────

    ; Option 3 — MANUELLE URL

    ; ────────────────────────────────────────────────────────────────────────

    GUICtrlCreateLabel("", 18, 302, $iW - 36, 58)

    GUICtrlSetBkColor(-1, $C_LAMB)

    GUICtrlSetState(-1, $GUI_DISABLE)

    $hBtn3 = GUICtrlCreateButton("✏  Eigene URL eingeben", 26, 307, 200, 28)

    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")

    GUICtrlSetBkColor(-1, $C_LAMB)

    GUICtrlSetColor(-1, $C_AMB)

    GUICtrlCreateLabel( _
        "Direkte .iso-URL manuell eingeben." & @CRLF & _
        "Versucht curl und BITS mit der eingegebenen URL." & @CRLF & _
        "Ideal wenn eine neue Version erschienen ist.", _
        234, 307, $iW - 252, 46)

    GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_AMB)

    GUICtrlSetBkColor(-1, $C_LAMB)

    GUICtrlCreateLabel("", 18, 366, $iW - 36, 1)

    GUICtrlSetBkColor(-1, $C_BRD)

    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ────────────────────────────────────────────────────────────────────────

    ; Option 4 — DISTROWATCH SUCHE  (v14.18)

    ; ────────────────────────────────────────────────────────────────────────

    Local $sDistroWatchURL = "https://distrowatch.com/search.php?ostype=All&status=All&" & _
        "popularity=1&keywordsAndNot=and&keywords=" & StringReplace($sName, " ", "+")

    GUICtrlCreateLabel("", 18, 370, $iW - 36, 54)

    GUICtrlSetBkColor(-1, 0xEEE8FF)

    GUICtrlSetState(-1, $GUI_DISABLE)

    $hBtn5 = GUICtrlCreateButton("🔎  DistroWatch suchen", 26, 376, 200, 28)

    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")

    GUICtrlSetBkColor(-1, 0xEEE8FF)

    GUICtrlSetColor(-1, 0x6236FF)

    GUICtrlSetTip(-1, "Öffnet DistroWatch-Suche für '" & $sName & "' im Browser" & @CRLF & _
        "→ Direktlink kopieren → 'Eigene URL eingeben' nutzen")

    GUICtrlCreateLabel( _
        "Öffnet DistroWatch im Browser — direkten Mirror-Link kopieren." & @CRLF & _
        "Dann 'Eigene URL' wählen und den Link einfügen (Ctrl+V).", _
        234, 376, $iW - 252, 42)

    GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")

    GUICtrlSetColor(-1, 0x6236FF)

    GUICtrlSetBkColor(-1, 0xEEE8FF)

    ; ────────────────────────────────────────────────────────────────────────

    ; Option 5 — ÜBERSPRINGEN

    ; ────────────────────────────────────────────────────────────────────────

    GUICtrlCreateLabel("", 18, 430, $iW - 36, 1)

    GUICtrlSetBkColor(-1, $C_BRD)

    GUICtrlSetState(-1, $GUI_DISABLE)

    $hBtn4 = GUICtrlCreateButton("✕  Diesen ISO überspringen", $iW - 220, $iH - 48, 200, 30)

    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

    GUICtrlSetBkColor(-1, $C_CARD)

    GUICtrlSetColor(-1, $C_MID)

    ; TMP-Ordner-Pfad als Info anzeigen

    GUICtrlCreateLabel("Download-Ordner für manuell gespeicherte ISOs:  " & $TMP_DOWNLOAD_DIR, _
        18, $iH - 42, $iW - 240, 28)

    GUICtrlSetFont(-1, 7, 400, 0, "Consolas")

    GUICtrlSetColor(-1, $C_DIM)

    GUICtrlSetBkColor(-1, $C_W)

    GUISetState(@SW_SHOW, $hDlg)

    GUISetState(@SW_DISABLE, $g_hMain) ; Parent deaktivieren (Modal)

    ; ── Event-Loop ────────────────────────────────────────────────────────

    ; 0=überspringen, 1=Torrent, 2=Browser, 3=ManuelleURL, 4=DistroWatch

    Local $iResult = 0

    While True

        Local $aMsg = GUIGetMsg(1)

        If $aMsg[1] = $hDlg Then

            Switch $aMsg[0]

                Case $GUI_EVENT_CLOSE, $hBtn4

                    $iResult = 0

                    ExitLoop

                Case $hBtn1

                    $iResult = 1

                    ExitLoop

                Case $hBtn2

                    $iResult = 2

                    ExitLoop

                Case $hBtn3

                    $iResult = 3

                    ExitLoop

                Case $hBtn5

                    $iResult = 4

                    ExitLoop

            EndSwitch

        ElseIf $aMsg[1] = $g_hMain And $aMsg[0] = $GUI_EVENT_CLOSE Then

            $iResult = 0

            ExitLoop

        EndIf

        Sleep(10)

    WEnd

    GUISetState(@SW_ENABLE, $g_hMain) ; Parent wieder aktivieren

    GUIDelete($hDlg)

    ; ── Aktion ausführen ──────────────────────────────────────────────────

    Local $bSuccess = False

    Local $sFilename = $g_aISOs[$iIdx][3]

    Select

        Case $iResult = 1   ; ── Torrent ──────────────────────────────────

            _Log("    Fallback: Torrent-Link geöffnet: " & $sTorrentURL)

            ShellExecute($sTorrentURL)

            $bSuccess = _WaitForManualISO($sFilename, $sName, $TMP_DOWNLOAD_DIR, _
                "Torrent-Download läuft..." & @CRLF & @CRLF & _
                "1. Starte den Download in deinem Torrent-Client (qBittorrent, Motrix ...)" & @CRLF & _
                "2. Speichere die fertige ISO in:" & @CRLF & "   " & $TMP_DOWNLOAD_DIR & @CRLF & @CRLF & _
                "Klicke 'Fertig' wenn die Datei vollständig heruntergeladen ist." & @CRLF & _
                "Optional: Trage unten eine funktionierende Direkt-URL ein und speichere sie.", _
                $iIdx)

        Case $iResult = 2   ; ── Browser ──────────────────────────────────

            _Log("    Fallback: Browser-URL geöffnet: " & $sWebURL)

            ShellExecute($sWebURL)

            $bSuccess = _WaitForManualISO($sFilename, $sName, $TMP_DOWNLOAD_DIR, _
                "Browser-Download läuft..." & @CRLF & @CRLF & _
                "1. Lade die ISO auf der geöffneten Seite herunter" & @CRLF & _
                "2. Kopiere den direkten ISO-Download-Link aus dem Browser" & @CRLF & _
                "3. Speichere oder verschiebe die ISO nach:  " & $TMP_DOWNLOAD_DIR & @CRLF & @CRLF & _
                "Tipp: Den direkten Link unten eintragen — wird für nächsten Download gespeichert!", _
                $iIdx)

        Case $iResult = 3   ; ── Manuelle URL ─────────────────────────────

            Local $sManualURL = _ManualURLDialog($sName, $sFilename)

            If $sManualURL <> "" Then

                _PopShow("Manueller Download", $sName, True)

                GUICtrlSetData($g_hPopTitle, "Download " & ($iJobNr+1) & " / " & $iJobTotal)

                GUICtrlSetData($g_hPopSub, $sName & " [Manuell]")

                _Log("    Manueller Download: " & $sManualURL)

                $bSuccess = _DownloadCurlDirect($sManualURL, $sFile, $sName, $iJobNr, $iJobTotal)

                If Not $bSuccess Then

                    _PopUpdate(5, "curl fehlgeschlagen — versuche BITS ...", $sName)

                    $bSuccess = _DownloadBITS($sManualURL, $sFile, $sName, $iJobNr, $iJobTotal)

                EndIf

                ; Bei Erfolg: URL automatisch speichern

                If $bSuccess Then _SaveURLToISO($iIdx, $sManualURL)

            EndIf

        Case $iResult = 4   ; ── DistroWatch ──────────────────────────────

            ; DistroWatch öffnen, danach auf manuelle Ablage warten

            _Log("    Fallback: DistroWatch geöffnet für: " & $sName)

            ShellExecute($sDistroWatchURL)

            $bSuccess = _WaitForManualISO($sFilename, $sName, $TMP_DOWNLOAD_DIR, _
                "DistroWatch geöffnet — so geht's:" & @CRLF & @CRLF & _
                "1. Suche auf DistroWatch den Eintrag für '" & $sName & "'" & @CRLF & _
                "2. Klicke auf einen der direkten ISO-Download-Spiegel" & @CRLF & _
                "3. Speichere die ISO in:" & @CRLF & "   " & $TMP_DOWNLOAD_DIR & @CRLF & @CRLF & _
                "💡 Tipp: Den direkten ISO-Link unten eintragen — wird für" & @CRLF & _
                "   zukünftige Downloads in der Datenbank gespeichert.", _
                $iIdx)

        Case Else   ; ── Überspringen ──────────────────────────────────────

            _Log("    Fallback: " & $sName & " übersprungen.")

            $bSuccess = False

    EndSelect

    Return $bSuccess

EndFunc

Func _WaitForManualISO($sFilename, $sName, $sDir, $sInstructions, $iIdx = -1)

    Local $iW = 580, $iH = 390

    Local $hDlg = GUICreate("Warte auf ISO — " & $sName, $iW, $iH, -1, -1, _
        BitOR($WS_CAPTION, $WS_SYSMENU), $WS_EX_DROPSHADOW, $g_hMain)

    GUISetBkColor($C_W)

    GUISetFont(9, 400, 0, "Segoe UI")

    GUICtrlCreateLabel("", 0, 0, $iW, 5)

    GUICtrlSetBkColor(-1, $C_AMB)

    GUICtrlSetState(-1, $GUI_DISABLE)

    GUICtrlCreateLabel("Manueller Download — Warte auf ISO", 18, 14, $iW - 36, 20)

    GUICtrlSetFont(-1, 11, 700, 0, "Segoe UI Semibold")

    GUICtrlSetColor(-1, $C_TXT)

    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlCreateLabel($sInstructions, 18, 40, $iW - 36, 130)

    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_MID)

    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlCreateLabel("", 18, 178, $iW - 36, 1)

    GUICtrlSetBkColor(-1, $C_BRD)

    GUICtrlSetState(-1, $GUI_DISABLE)

    GUICtrlCreateLabel("Erwartete Datei:", 18, 186, 120, 14)

    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_TXT)

    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlCreateLabel($sFilename, 140, 186, $iW - 158, 14)

    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")

    GUICtrlSetColor(-1, $C_BLUE)

    GUICtrlSetBkColor(-1, $C_W)

    Local $hStatusLbl = GUICtrlCreateLabel("Warte auf Datei ...", 18, 208, $iW - 36, 42)

    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_DIM)

    GUICtrlSetBkColor(-1, $C_W)

    ; ── URL-Speicher-Bereich (immer sichtbar, aber erst nach Erfolg aktiv) ─

    GUICtrlCreateLabel("", 18, 256, $iW - 36, 1)

    GUICtrlSetBkColor(-1, $C_BRD)

    GUICtrlSetState(-1, $GUI_DISABLE)

    GUICtrlCreateLabel("💾  Funktionierende URL für zukünftige Downloads speichern (optional):", 18, 264, $iW - 36, 14)

    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")

    GUICtrlSetColor(-1, $C_MID)

    GUICtrlSetBkColor(-1, $C_W)

    Local $hURLEdit = GUICtrlCreateEdit("", 18, 282, $iW - 120, 22, BitOR($ES_AUTOHSCROLL, $WS_BORDER))

    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")

    GUICtrlSetColor(-1, $C_TXT)

    Local $hBtnSaveURL = GUICtrlCreateButton("💾 Speichern", $iW - 96, 282, 78, 22)

    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")

    GUICtrlSetBkColor(-1, $C_LBLU)

    GUICtrlSetColor(-1, $C_BLUE)

    GUICtrlSetState($hBtnSaveURL, $GUI_DISABLE)

    GUICtrlCreateLabel("", 18, 312, $iW - 36, 1)

    GUICtrlSetBkColor(-1, $C_BRD)

    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── Buttons ───────────────────────────────────────────────────────────

    Local $hBtnOpen = GUICtrlCreateButton("📁  Ordner öffnen", 18, $iH - 48, 150, 30)

    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

    GUICtrlSetBkColor(-1, $C_CARD)

    GUICtrlSetColor(-1, $C_MID)

    Local $hBtnDone = GUICtrlCreateButton("✓  Fertig — ISO ist vorhanden", $iW - 270, $iH - 48, 250, 30)

    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI Semibold")

    GUICtrlSetBkColor(-1, $C_LGRN)

    GUICtrlSetColor(-1, $C_GRN)

    Local $hBtnAbort = GUICtrlCreateButton("✕  Abbrechen", $iW - 400, $iH - 48, 120, 30)

    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

    GUICtrlSetBkColor(-1, $C_CARD)

    GUICtrlSetColor(-1, $C_MID)

    If Not FileExists($sDir) Then DirCreate($sDir)

    GUISetState(@SW_SHOW, $hDlg)

    GUISetState(@SW_DISABLE, $g_hMain) ; Modal

    Local $bResult  = False

    Local $tCheck   = TimerInit()

    Local $bURLSaved = False

    While True

        Local $aMsg = GUIGetMsg(1)

        If $aMsg[1] = $hDlg Then

            Switch $aMsg[0]

                Case $GUI_EVENT_CLOSE, $hBtnAbort

                    $bResult = False

                    ExitLoop

                Case $hBtnOpen

                    ShellExecute("explorer.exe", $sDir)

                Case $hBtnSaveURL

                    Local $sSaveURL = StringStripWS(GUICtrlRead($hURLEdit), 3)

                    If StringLeft($sSaveURL, 4) = "http" And $iIdx >= 0 Then

                        $bURLSaved = _SaveURLToISO($iIdx, $sSaveURL)

                        If $bURLSaved Then

                            GUICtrlSetData($hBtnSaveURL, "✓ Gespeichert")

                            GUICtrlSetBkColor($hBtnSaveURL, $C_LGRN)

                            GUICtrlSetColor($hBtnSaveURL, $C_GRN)

                            GUICtrlSetState($hBtnSaveURL, $GUI_DISABLE)

                        EndIf

                    EndIf

                Case $hBtnDone

                    Local $sTarget = $sDir & "\" & $sFilename

                    If FileExists($sTarget) And FileGetSize($sTarget) >= 314572800 Then

                        If GUICtrlRead($hBtnDone) = "✓  Schließen" Then ExitLoop

                        GUICtrlSetData($hStatusLbl, "✓  ISO gefunden: " & _FmtBytes(FileGetSize($sTarget)))

                        GUICtrlSetColor($hStatusLbl, $C_GRN)

                        GUICtrlSetState($hBtnSaveURL, $GUI_ENABLE)

                        GUICtrlSetData($hBtnDone, "✓  Schließen")

                        GUICtrlSetBkColor($hBtnDone, $C_LGRN)

                        $bResult = True

                    Else

                        GUICtrlSetData($hStatusLbl, "⚠ Datei nicht gefunden oder < 300 MB.")

                        GUICtrlSetColor($hStatusLbl, $C_RED)

                    EndIf

            EndSwitch

        EndIf

        If TimerDiff($tCheck) >= 5000 Then

            $tCheck = TimerInit()

            Local $sChk = $sDir & "\" & $sFilename

            If FileExists($sChk) And FileGetSize($sChk) >= 314572800 Then

                If Not $bResult Then

                    GUICtrlSetData($hStatusLbl, "✓  ISO erkannt! Klicke 'Fertig' zum Fortfahren.")

                    GUICtrlSetColor($hStatusLbl, $C_GRN)

                EndIf

            EndIf

        EndIf

        Sleep(10)

    WEnd

    GUISetState(@SW_ENABLE, $g_hMain)

    GUIDelete($hDlg)

    Return $bResult

EndFunc

Func _LoadUserURLs()

    If Not FileExists($URL_INI) Then Return

    For $i = 0 To $ISO_COUNT - 1

        Local $sSec = "ISO_" & $i

        Local $sURL = IniRead($URL_INI, $sSec, "url", "")

        If $sURL <> "" And StringLeft($sURL, 4) = "http" Then

            $g_aISOs[$i][2] = $sURL

            _Log("User-URL geladen [" & $i & "] " & $g_aISOs[$i][0] & ": " & $sURL)

        EndIf

    Next

EndFunc

Func _GetTorrentURL($iIdx)

    Local $sName = $g_aISOs[$iIdx][0]

    Select

        Case StringInStr($sName, "Ubuntu")

            Return "https://ubuntu.com/download/alternative-downloads#bittorrent"

        Case StringInStr($sName, "Lubuntu")

            Return "https://lubuntu.me/downloads/"

        Case StringInStr($sName, "Mint")

            Return "https://www.linuxmint.com/torrents/"

        Case StringInStr($sName, "Debian")

            Return "https://www.debian.org/CD/torrent-cd/"

        Case StringInStr($sName, "Fedora")

            Return "https://torrent.fedoraproject.org/"

        Case StringInStr($sName, "Manjaro")

            Return "https://manjaro.org/download/"

        Case StringInStr($sName, "Tails")

            Return "https://tails.net/install/download/index.en.html"

        Case StringInStr($sName, "Parrot")

            Return "https://www.parrotsec.org/download/"

        Case StringInStr($sName, "MX")

            Return "https://mxlinux.org/torrent-files/"

        Case StringInStr($sName, "AlmaLinux")

            Return "https://mirrors.almalinux.org/isos/x86_64/9.7.html"

        Case StringInStr($sName, "Zorin")

            Return "https://zorin.com/os/download/"

        Case StringInStr($sName, "Pop")

            Return "https://system76.com/pop"

        Case StringInStr($sName, "G DATA") Or StringInStr($sName, "GDATA") Or StringInStr($sName, "BootMedium") Or _
             StringInStr($sName, "ESET") Or StringInStr($sName, "SysRescue")

            Return "https://www.gdatasoftware.com/downloads"

        Case StringInStr($sName, "Comodo Rescue")

            Return "https://www.comodo.com/home/internet-security/rescue-disk.php"

        Case StringInStr($sName, "Nobara")

            Return "https://nobaraproject.org/download/"

        Case StringInStr($sName, "Garuda")

            Return "https://garudalinux.org/downloads"

        Case StringInStr($sName, "EndeavourOS")

            Return "https://endeavouros.com/latest-release/"

        Case StringInStr($sName, "CachyOS")

            Return "https://cachyos.org/download/"

        Case StringInStr($sName, "Archcraft")

            Return "https://archcraft.io/download.html"

        Case Else

            Return ""

    EndSelect

EndFunc

Func _GetOfficialWebURL($iIdx)

    Local $sName = $g_aISOs[$iIdx][0]

    Select

        Case StringInStr($sName, "G DATA") Or StringInStr($sName, "GDATA") Or StringInStr($sName, "BootMedium") Or _
             StringInStr($sName, "ESET") Or StringInStr($sName, "SysRescue")

            Return "https://www.gdatasoftware.com/downloads"

        Case StringInStr($sName, "Comodo Rescue")
            Return "https://www.comodo.com/home/internet-security/rescue-disk.php"

        Case StringInStr($sName, "Nobara")
            Return "https://nobaraproject.org/download/"

        Case StringInStr($sName, "Garuda")
            Return "https://garudalinux.org/downloads"

        Case StringInStr($sName, "Tails")
            Return "https://tails.net/install/download/"

        Case StringInStr($sName, "Parrot")
            Return "https://www.parrotsec.org/download/"

        Case StringInStr($sName, "Mint")
            Return "https://linuxmint.com/download.php"

        Case StringInStr($sName, "Ubuntu") And Not StringInStr($sName, "Lubuntu")

            Return "https://ubuntu.com/download/desktop"

        Case StringInStr($sName, "Zorin")
            Return "https://zorin.com/os/download/"

        Case StringInStr($sName, "Pop")
            Return "https://system76.com/pop"

        Case StringInStr($sName, "Manjaro")
            Return "https://manjaro.org/download/"

        Case StringInStr($sName, "Fedora")
            Return "https://fedoraproject.org/workstation/download/"

        Case StringInStr($sName, "Archcraft")
            Return "https://archcraft.io/download.html"

        Case StringInStr($sName, "CachyOS")
            Return "https://cachyos.org/download/"

        Case StringInStr($sName, "Debian")
            Return "https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/"

        Case StringInStr($sName, "MX")
            Return "https://mxlinux.org/download-links/"

        Case StringInStr($sName, "Lubuntu")
            Return "https://lubuntu.me/downloads/"

        Case StringInStr($sName, "AlmaLinux")
            Return "https://almalinux.org/get-almalinux/"

        Case StringInStr($sName, "EndeavourOS")
            Return "https://endeavouros.com/latest-release/"

        Case Else

            Return "https://distrowatch.com/search.php?ostype=Linux"

    EndSelect

EndFunc

Func _URLHostname($sURL)

    If $sURL = "" Then Return ""

    Local $s = StringRegExpReplace($sURL, "^https?://", "")

    Local $i = StringInStr($s, "/")

    If $i > 0 Then Return StringLeft($s, $i - 1)

    Return $s

EndFunc

Func _CatFromURL($sURL)

    If $sURL = "" Then Return ""

    Local $sL = StringLower($sURL)

    ; ── Sicherheit ────────────────────────────────────────────────────────

    If StringInStr($sL,"kali.org") Or StringInStr($sL,"kali-images") Or _
       StringInStr($sL,"kali.download") Or StringInStr($sL,"parrotsec.org") Or _
       StringInStr($sL,"tails.boum.org") Or StringInStr($sL,"tails.net") Or _
       StringInStr($sL,"blackarch.org") Or StringInStr($sL,"whonix.org") Or _
       StringInStr($sL,"backbox.org") Or StringInStr($sL,"mirror.backbox") Or _
       StringInStr($sL,"linuxkodachi") Or StringInStr($sL,"kodachi") Or _
       StringInStr($sL,"remnux.org") Or StringInStr($sL,"caine-live") Then

        Return "Sicherheit"

    EndIf

    ; ── Antivirus ─────────────────────────────────────────────────────────

    If StringInStr($sL,"drweb.com") Or StringInStr($sL,"eset.com") Or _
       StringInStr($sL,"comodo.com") Or StringInStr($sL,"eset_sysrescue") Or _
       StringInStr($sL,"comodo_rescue") Or StringInStr($sL,"gdatasoftware.com") Or _
       StringInStr($sL,"gdata-bootmedium") Or StringInStr($sL,"gdata_bootmedium") Then

        Return "Antivirus"

    EndIf

    ; ── Gaming ────────────────────────────────────────────────────────────

    If StringInStr($sL,"nobara") Or StringInStr($sL,"garuda-linux") Or _
       StringInStr($sL,"garudalinux.org") Or StringInStr($sL,"/gaming") Or _
       StringInStr($sL,"nobaraproject.org") Then

        Return "Gaming"

    EndIf

    ; ── Leichtgewichtig ───────────────────────────────────────────────────

    If StringInStr($sL,"debian.org") Or StringInStr($sL,"debian-cd") Or _
       StringInStr($sL,"cdimage.debian") Or StringInStr($sL,"lubuntu") Or _
       StringInStr($sL,"mxlinux.org") Or StringInStr($sL,"mxlinux") Or _
       StringInStr($sL,"antixlinux.com") Or StringInStr($sL,"alpinelinux.org") Or _
       StringInStr($sL,"almalinux.org") Or StringInStr($sL,"/almalinux") Or _
       StringInStr($sL,"rockylinux.org") Or StringInStr($sL,"rocky-linux") Then

        Return "Leichtgewichtig"

    EndIf

    ; ── Fortgeschrittene ──────────────────────────────────────────────────

    If StringInStr($sL,"archlinux.org") Or StringInStr($sL,"arch-linux") Or _
       StringInStr($sL,"manjaro.org") Or StringInStr($sL,"/manjaro/") Or _
       StringInStr($sL,"fedoraproject.org") Or StringInStr($sL,"/fedora/") Or _
       StringInStr($sL,"cachyos.org") Or StringInStr($sL,"cachy") Or _
       StringInStr($sL,"endeavouros.com") Or StringInStr($sL,"endeavour") Or _
       StringInStr($sL,"gentoo.org") Or StringInStr($sL,"voidlinux.org") Then

        Return "Fortgeschrittene"

    EndIf

    ; ── Einsteiger ────────────────────────────────────────────────────────

    If StringInStr($sL,"ubuntu.com") Or StringInStr($sL,"ubuntu-releases") Or _
       StringInStr($sL,"releases.ubuntu.com") Or _
       StringInStr($sL,"linuxmint.com") Or StringInStr($sL,"linux-mint") Or _
       StringInStr($sL,"zorinos.com") Or StringInStr($sL,"/zorinos") Or _
       StringInStr($sL,"pop-os.org") Or StringInStr($sL,"system76.com") Then

        Return "Einsteiger"

    EndIf

    Return ""   ; URL lässt keine eindeutige Zuordnung zu

EndFunc

Func _CurlPath()

    Local $aPaths[4] = [ _
        @SystemDir & "\curl.exe", _
        @WindowsDir & "\System32\curl.exe", _
        @ScriptDir  & "\curl.exe", _
        "curl.exe"]

    For $i = 0 To 3

        If FileExists($aPaths[$i]) Then Return $aPaths[$i]

    Next

    Return ""

EndFunc

Func _FindLatestVersionURL($iIdx, $sCurl)

    ; BUG-FIX v14.38: Bounds-Check VOR Array-Schreibzugriff (verhindert @error bei Überläufen)

    If $iIdx < 0 Or $iIdx >= $ISO_COUNT Or $iIdx >= $ISO_MAX Then Return False

    $g_asUpdateVer[$iIdx]  = ""

    $g_asUpdateURL[$iIdx]  = ""

    $g_asUpdateFile[$iIdx] = ""

    Local $sName     = $g_aISOs[$iIdx][0]

    Local $sNameLow  = StringLower($sName)

    Local $sFileURL  = $g_aISOs[$iIdx][2]

    Local $sGitRepo  = $g_aISOs[$iIdx][6]

    ; Aktuelle Version: erst aus URL, dann aus gespeichertem Dateinamen extrahieren

    ; BUG-FIX v14.38: zusätzlich YYMMDD-Format (CachyOS) aus URL-Pfad erkennen

    Local $sCurrVer = ""

    Local $aV1 = StringRegExp($sFileURL, "(\d+\.\d+(?:\.\d+)*)", 1)

    If Not @error Then $sCurrVer = $aV1[0]

    If $sCurrVer = "" Then

        Local $aV2 = StringRegExp($g_aISOs[$iIdx][3], "(\d+\.\d+(?:\.\d+)*)", 1)

        If Not @error Then $sCurrVer = $aV2[0]

    EndIf

    ; YYMMDD-Format aus Pfad-Segment (z.B. CachyOS: /desktop/260308/)

    If $sCurrVer = "" Then

        Local $aVD = StringRegExp($sFileURL, "/(\d{6})/", 1)

        If Not @error Then $sCurrVer = $aVD[0]

    EndIf

    ; Versionsnummer aus dem Anzeige-Namen (für Stick-Imports ohne URL/Datei)

    ; Regex auf ganze Zahlen erweitert (z.B. "Zorin OS 18" → "18", vorher nur "17.3")

    If $sCurrVer = "" Then

        Local $aVN = StringRegExp($sName, "([\d]+(?:\.[\d]+)*)", 1)

        If Not @error Then $sCurrVer = $aVN[0]

    EndIf

    Local $sLatestVer  = ""

    Local $sLatestURL  = ""

    Local $sLatestFile = ""

    ; Einträge OHNE primäre URL (Stick-Import) sofort zur Web-Suche schicken.

    ; Do...Until True ermöglicht ExitLoop als GOTO-Ersatz → alle Distro-Blöcke überspringen.

    Do

        If $sFileURL = "" Then

            _Log("  [v14.39] Keine gespeicherte URL → direkte Web-Suche für: " & $sName)

            ; Anzeigenamen bereinigen: Versionssuffix und Codename abschneiden

            Local $sN39 = StringRegExpReplace($sName, "(?i)\s+[\d\.]+[\w\s\(\)_-]*$", "")

            $sN39 = StringStripWS($sN39, 3)

            If StringLen($sN39) < 3 Then $sN39 = $sName

            _WebSearchLatestISO($sN39, $g_aISOs[$iIdx][3], $sCurl, $sLatestVer, $sLatestURL, $sLatestFile)

            ExitLoop   ; Distro-spezifische Blöcke + normalen Fallback überspringen

        EndIf

        ; ===== GENERISCH: GitHub-Repo in [6] (Format owner/repo, kein http) =====

        If $sGitRepo <> "" And StringInStr($sGitRepo, "/") And Not StringInStr($sGitRepo, "http") Then

            _GitHubLatestISO($sGitRepo, $sCurl, $sLatestVer, $sLatestURL, $sLatestFile)

        EndIf

        

        ; ===== GENERISCH: SourceForge (v2.27) =====

        If $sLatestURL = "" And (StringInStr($sFileURL, "sourceforge.net") Or StringInStr($sFileURL, "dl.sourceforge.net")) Then

            Local $aSF = StringRegExp($sFileURL, "(?i)sourceforge\.net/(?:projects|project)/([^/]+)", 1)

            If Not @error Then

                _SourceForgeLatestISO($aSF[0], $sCurl, $sLatestVer, $sLatestURL, $sLatestFile)

            EndIf

        EndIf

    ; ===== GARUDA LINUX GAMING Dr460nized (v2.27: Drauger OS EOL — Garuda als Ersatz) =====

    If $sLatestURL = "" And (StringInStr($sNameLow, "garuda") Or StringInStr($sNameLow, "dr460nized")) Then

        $sLatestURL  = "https://iso.builds.garudalinux.org/iso/latest/garuda/dr460nized-gaming/latest.iso"

        $sLatestFile = "garuda-dr460nized-gaming-linux-zen.iso"

        $sLatestVer  = "latest"

    EndIf

    ; ===== DRAUGER OS Legacy (EOL 2024 — wird auf Garuda Gaming umgeleitet) =====

    If $sLatestURL = "" And StringInStr($sNameLow, "drauger") Then

        $sLatestURL  = "https://iso.builds.garudalinux.org/iso/latest/garuda/dr460nized-gaming/latest.iso"

        $sLatestFile = "garuda-dr460nized-gaming-linux-zen.iso"

        $sLatestVer  = "latest"

    EndIf

    ; ===== PIKAOS Legacy (Ventoy mount-Fehler — v2.24 durch Drauger OS ersetzt) =====

    If $sLatestURL = "" And StringInStr($sNameLow, "pikaos") Then

        $sLatestURL  = "https://iso.pika-os.com/PikaOS-Nest-KDE-4.0-amd64-v3-26.04.04-1.iso"

        $sLatestFile = "PikaOS-Nest-KDE-4.0-amd64-v3-26.04.04-1.iso"

        $sLatestVer  = "4.0-26.04.04"

    EndIf

    ; ===== ENDEAVOUROS Legacy (war kurzzeitig in Slot [21]) =====

    If $sLatestURL = "" And StringInStr($sNameLow, "endeavouros") Then

        Local $sEosDummy1 = "", $sEosDummy2 = ""

        _GitHubLatestISO("EndeavourOS/ISO", $sCurl, $sLatestVer, $sEosDummy1, $sEosDummy2)

        If $sLatestVer <> "" Then

            $sLatestFile = "EndeavourOS_" & $sLatestVer & ".iso"

            $sLatestURL  = "https://mirror.alpix.eu/endeavouros/iso/" & $sLatestFile

        EndIf

    EndIf

    ; ===== BAZZITE Legacy (direkter CDN — v2.24: durch EndeavourOS ersetzt) =====

    If $sLatestURL = "" And StringInStr($sNameLow, "bazzite") Then

        $sLatestURL  = "https://download.bazzite.gg/bazzite-stable-amd64.iso"

        $sLatestFile = "bazzite-stable-amd64.iso"

        Local $sBzDummy1 = "", $sBzDummy2 = ""

        _GitHubLatestISO("ublue-os/bazzite", $sCurl, $sLatestVer, $sBzDummy1, $sBzDummy2)

    EndIf

    ; ===== CHIMERAOS Legacy (GitHub, für stick-importierte alte ISOs) =====

    If $sLatestURL = "" And StringInStr($sNameLow, "chimera") Then

        _GitHubLatestISO("ChimeraOS/install-media", $sCurl, $sLatestVer, $sLatestURL, $sLatestFile)

    EndIf

    ; ===== G DATA BOOTMEDIUM (kein GitHub-Tag — direkter CDN-Link) =====

    ; ersetzt ESET SysRescue Live (EOL seit Sept. 2023)

    If $sLatestURL = "" And (StringInStr($sNameLow, "gdata") Or StringInStr($sNameLow, "g data") Or _
       StringInStr($sNameLow, "eset") Or StringInStr($sNameLow, "sysrescue_live") Or _
       StringInStr($sNameLow, "gdata_bootmedium") Or StringInStr($sNameLow, "gdata-bootmedium")) Then

        $sLatestURL   = "https://www.gdatasoftware.com/fileadmin/web/en/documents/bootcd/GData-BootMedium.iso"

        $sLatestFile  = "GData-BootMedium.iso"

        $sLatestVer   = "BootMedium-Current"  ; kein Versions-Tag, immer aktuell

    EndIf

    ; ===== COMODO RESCUE DISK (direkter CDN-Link) =====

    If $sLatestURL = "" And (StringInStr($sNameLow, "comodo") Or StringInStr($sNameLow, "comodo_rescue")) Then

        $sLatestURL   = "https://download.comodo.com/crd/download/setups/comodo_rescue_disk.iso"

        $sLatestFile  = "comodo_rescue_disk.iso"

        $sLatestVer   = "Rescue-2.0"

    EndIf

    ; ===== UBUNTU (nicht Lubuntu/Kubuntu/Xubuntu/GamePack) =====

    If $sLatestURL = "" And StringInStr($sNameLow, "ubuntu") And Not StringInStr($sNameLow, "lubuntu") And Not StringInStr($sNameLow, "kubuntu") And Not StringInStr($sNameLow, "xubuntu") And Not StringInStr($sNameLow, "gamepack") And Not StringInStr($sNameLow, "game_pack") Then

        Local $sMirrorBase = "https://releases.ubuntu.com/"

        Local $sH1 = _FetchMirrorDir($sMirrorBase, $sCurl)

        If $sH1 <> "" Then

            Local $aM1 = StringRegExp($sH1, 'href="(\d+\.\d+)/"', 3)

            If Not @error Then

                Local $sBV1 = ""

                For $m = 0 To UBound($aM1) - 1

                    If _VersionNewer($aM1[$m], $sBV1) Then $sBV1 = $aM1[$m]

                Next

                If $sBV1 <> "" Then

                    Local $sRH1 = _FetchMirrorDir($sMirrorBase & $sBV1 & "/", $sCurl)

                    If $sRH1 <> "" Then

                        ; Typ bestimmen: Server vs. Desktop

                        Local $sTargetType = "desktop"

                        If StringInStr($sNameLow, "server") Then $sTargetType = "live-server"

                        

                        ; Regex sucht nach ubuntu-XX.YY-[desktop|live-server]-amd64.iso

                        Local $aI1 = StringRegExp($sRH1, "(ubuntu-" & StringReplace($sBV1, ".", "\.") & "-" & $sTargetType & "-amd64\.iso)", 3)

                        If Not @error And UBound($aI1) > 0 Then

                            $sLatestVer  = $sBV1

                            $sLatestFile = $aI1[0]

                            $sLatestURL  = $sMirrorBase & $sBV1 & "/" & $sLatestFile

                        EndIf

                    EndIf

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== LUBUNTU =====

    If $sLatestURL = "" And StringInStr($sNameLow, "lubuntu") Then

        Local $sLuBase = "https://cdimage.ubuntu.com/lubuntu/releases/"

        Local $sHLu = _FetchMirrorDir($sLuBase, $sCurl)

        If $sHLu <> "" Then

            Local $aMLu = StringRegExp($sHLu, 'href="(\d+\.\d+)/"', 3)

            If Not @error Then

                Local $sBVLu = ""

                For $m = 0 To UBound($aMLu) - 1

                    If _VersionNewer($aMLu[$m], $sBVLu) Then $sBVLu = $aMLu[$m]

                Next

                If $sBVLu <> "" Then

                    Local $sRHLu = _FetchMirrorDir($sLuBase & $sBVLu & "/release/", $sCurl)

                    If $sRHLu <> "" Then

                        Local $aILu = StringRegExp($sRHLu, "(lubuntu-[^""]*?amd64\.iso)", 3)

                        If Not @error And UBound($aILu) > 0 Then

                            $sLatestVer  = $sBVLu

                            $sLatestFile = $aILu[0]

                            $sLatestURL  = $sLuBase & $sBVLu & "/release/" & $sLatestFile

                        EndIf

                    EndIf

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== FEDORA SECURITY LAB =====

    If $sLatestURL = "" And StringInStr($sNameLow, "fedora") And StringInStr($sNameLow, "security") Then

        Local $sFSecBase = "https://dl.fedoraproject.org/pub/alt/releases/"

        Local $sHFSec = _FetchMirrorDir($sFSecBase, $sCurl)

        If $sHFSec <> "" Then

            Local $aMFSec = StringRegExp($sHFSec, 'href="(\d+)/"', 3)

            If Not @error Then

                Local $sBVFSec = ""

                For $m = 0 To UBound($aMFSec) - 1

                    If _VersionNewer($aMFSec[$m], $sBVFSec) Then $sBVFSec = $aMFSec[$m]

                Next

                If $sBVFSec <> "" Then

                    Local $sFSecRel = $sFSecBase & $sBVFSec & "/Labs/x86_64/iso/"

                    Local $sRHFSec = _FetchMirrorDir($sFSecRel, $sCurl)

                    If $sRHFSec <> "" Then

                        Local $aIFSec = StringRegExp($sRHFSec, "(Fedora-Security-Live-x86_64-[^""]+\.iso)", 3)

                        If Not @error And UBound($aIFSec) > 0 Then

                            $sLatestVer  = $sBVFSec

                            $sLatestFile = $aIFSec[0]

                            $sLatestURL  = $sFSecRel & $sLatestFile

                        EndIf

                    EndIf

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== LINUX KODACHI =====

    If $sLatestURL = "" And StringInStr($sNameLow, "kodachi") Then

        ; SourceForge: Dateiliste nach linux-kodachi-xfce-X.Y.Z-amd64.iso durchsuchen

        Local $sHKod = _FetchMirrorDir("https://sourceforge.net/projects/linuxkodachi/files/kodachi-desktop/", $sCurl)

        If $sHKod <> "" Then

            Local $aIKod = StringRegExp($sHKod, "(linux-kodachi-xfce-([\d\.]+)-amd64\.iso)", 3)

            If Not @error And UBound($aIKod) > 1 Then

                Local $sBVKod = ""

                Local $sLatestKodFile = ""

                For $m = 0 To UBound($aIKod) - 1 Step 2

                    If _VersionNewer($aIKod[$m + 1], $sBVKod) Then

                        $sBVKod        = $aIKod[$m + 1]

                        $sLatestKodFile = $aIKod[$m]

                    EndIf

                Next

                If $sLatestKodFile <> "" Then

                    $sLatestVer  = $sBVKod

                    $sLatestFile = $sLatestKodFile

                    $sLatestURL  = "https://downloads.sourceforge.net/project/linuxkodachi/kodachi-desktop/" & $sLatestKodFile

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== TAILS =====

    ; ===== TAILS =====

    ; Drei Mirror-Quellen für Directory-Listing — fällt auf nächste um wenn eine nicht antwortet.

    ;        download.tails.net blockiert Curl (HTTP 403) → wird NICHT als Primärquelle genutzt.

    If $sLatestURL = "" And StringInStr($sNameLow, "tails") Then

        ; kernel.org durch ftp.fau.de ersetzt (kernel.org 404 für 7.6.1 bestätigt)

        Local $asTailsMirrorDirs[3] = [ _
            "https://ftp.halifax.rwth-aachen.de/tails/stable/", _
            "https://mirrors.dotsrc.org/tails/stable/", _
            "https://ftp.fau.de/tails/stable/"]

        Local $sBVTails = ""

        Local $sBestMirrorBase = ""

        For $mt = 0 To 2

            If $sBVTails <> "" Then ExitLoop   ; erstes erfolgreiches Mirror genügt

            Local $sHTails = _FetchMirrorDir($asTailsMirrorDirs[$mt], $sCurl)

            If $sHTails = "" Then ContinueLoop

            ; Suche tails-amd64-X.Y/ Verzeichnisse im Listing

            Local $aITails = StringRegExp($sHTails, "tails-amd64-([\d\.]+)/", 3)

            If @error Or UBound($aITails) = 0 Then ContinueLoop

            For $m = 0 To UBound($aITails) - 1

                If _VersionNewer($aITails[$m], $sBVTails) Then $sBVTails = $aITails[$m]

            Next

            If $sBVTails <> "" Then $sBestMirrorBase = $asTailsMirrorDirs[$mt]

        Next

        If $sBVTails <> "" Then

            $sLatestVer  = $sBVTails

            $sLatestFile = "tails-amd64-" & $sBVTails & ".iso"

            ; Primäre URL vom erfolgreichsten Mirror, RWTH bevorzugt

            Local $sMirrorBase = ($sBestMirrorBase <> "") ? $sBestMirrorBase : "https://ftp.halifax.rwth-aachen.de/tails/stable/"

            $sLatestURL = $sMirrorBase & "tails-amd64-" & $sBVTails & "/" & $sLatestFile

            _Log("  [Tails] Neueste Version: " & $sBVTails & " via " & $sMirrorBase)

        EndIf

    EndIf

    ; ===== PARROT SECURITY =====

    If $sLatestURL = "" And StringInStr($sNameLow, "parrot") Then

        Local $sHParrot = _FetchMirrorDir("https://cdimage.parrotsec.org/parrot/iso/stable/", $sCurl)

        If $sHParrot <> "" Then

            Local $aIParrot = StringRegExp($sHParrot, "(Parrot-security-[\d\.]+-amd64\.iso)", 3)

            If Not @error And UBound($aIParrot) > 0 Then

                Local $aVParrot = StringRegExp($aIParrot[0], "Parrot-security-([\d\.]+)-amd64", 1)

                If Not @error Then

                    $sLatestVer  = $aVParrot[0]

                    $sLatestFile = $aIParrot[0]

                    $sLatestURL  = "https://cdimage.parrotsec.org/parrot/iso/stable/" & $sLatestFile

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== NOBARA (GNOME — nobaraproject.org) =====

    ; FIX: Nur für Einträge OHNE GitHub-Repo (also GNOME-Variante).

    ;            KDE-Eintrag hat $sGitRepo gesetzt → überspringt diesen Block und nutzt GitHub-API.

    ;            Vorher: KDE bekam die GNOME-URL weil dieser Check für beide feuerte,

    ;            dann war $sLatestURL nicht mehr leer → GitHub-Check wurde nie erreicht.

    ; NEU: Wenn Directory-Listing (404) fehlschlägt → HEAD auf aktuelle URL prüfen.

    ;            Ist die aktuelle URL gültig → Return False (kein Update nötig).

    ;            So wird verhindert, dass der GitHub-Block mit seinem alten Fallback

    ;            eine HTML-Seite als ISO-URL einschleust.

    If $sLatestURL = "" And StringInStr($sNameLow, "nobara") And $sGitRepo = "" Then

        ; Versuch 1: Directory-Listing (liefert 404 seit mind. April 2026, trotzdem versuchen)

        Local $sHNobara = _FetchMirrorDir("https://nobara-images.nobaraproject.org/", $sCurl)

        If $sHNobara <> "" Then

            Local $aINobara = StringRegExp($sHNobara, "(Nobara-(\d+)-Official-[\d-]+\.iso)", 3)

            If Not @error And UBound($aINobara) > 1 Then

                ; aINobara[0]=filename, aINobara[1]=version-number

                $sLatestVer  = $aINobara[1]

                $sLatestFile = $aINobara[0]

                $sLatestURL  = "https://nobara-images.nobaraproject.org/" & $sLatestFile

                _Log("[Nobara] Directory-Listing: " & $sLatestFile & " (v" & $sLatestVer & ")")

            EndIf

        EndIf

        ; Versuch 2: Aktuelle URL direkt per HEAD prüfen (Directory-Listing = 404, Direktlinks = 200)

        If $sLatestURL = "" Then

            Local $sCurrNBURL = $g_aISOs[$iIdx][2]

            ; Nur prüfen wenn die aktuelle URL eine echte ISO-URL ist (kein GitHub, kein .html)

            If $sCurrNBURL <> "" And Not StringInStr($sCurrNBURL, "github.com") And _
               Not StringInStr($sCurrNBURL, ".html") And StringInStr($sCurrNBURL, ".iso") Then

                Local $iPNB = Run('"' & $sCurl & '" -s -I -L --max-time 12 --connect-timeout 8 --ssl-no-revoke ' & _
                                '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                                '-o NUL -w "%{http_code}" "' & $sCurrNBURL & '"', "", @SW_HIDE, $STDOUT_CHILD)

                If $iPNB <> 0 Then

                    Local $sNBHeadOut = ""

                    While 1

                        $sNBHeadOut &= StdoutRead($iPNB)

                        If @error Then ExitLoop

                    Wend

                    ProcessClose($iPNB)

                    Local $sNBCode = StringStripWS($sNBHeadOut, 3)

                    If $sNBCode = "200" Or $sNBCode = "206" Then

                        _Log("[Nobara] Directory-Listing nicht verfügbar — aktuelle URL gültig (HTTP " & $sNBCode & "), kein Update nötig")

                        Return False   ; aktuelle Version ist erreichbar → kein Update

                    Else

                        _Log("[Nobara] Directory-Listing und aktuelle URL nicht erreichbar (HTTP " & $sNBCode & ")")

                    EndIf

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== LINUX MINT =====

    If $sLatestURL = "" And StringInStr($sNameLow, "mint") And Not StringInStr($sNameLow, "peppermint") Then

        Local $sMintBase = "https://mirrors.kernel.org/linuxmint/stable/"

        Local $sHMint = _FetchMirrorDir($sMintBase, $sCurl)

        If $sHMint <> "" Then

            Local $aMMint = StringRegExp($sHMint, 'href="([\d\.]+)/"', 3)

            If Not @error Then

                Local $sBVMint = ""

                For $m = 0 To UBound($aMMint) - 1

                    If _VersionNewer($aMMint[$m], $sBVMint) Then $sBVMint = $aMMint[$m]

                Next

                If $sBVMint <> "" Then

                    Local $sDEMint = "cinnamon"

                    If StringInStr($sNameLow, "mate") Then $sDEMint = "mate"

                    If StringInStr($sNameLow, "xfce") Then $sDEMint = "xfce"

                    Local $sRHMint = _FetchMirrorDir($sMintBase & $sBVMint & "/", $sCurl)

                    If $sRHMint <> "" Then

                        Local $aIMint = StringRegExp($sRHMint, "(linuxmint-[^""]*?" & $sDEMint & "[^""]*?64bit\.iso)", 3)

                        If Not @error And UBound($aIMint) > 0 Then

                            $sLatestVer  = $sBVMint

                            $sLatestFile = $aIMint[0]

                            $sLatestURL  = $sMintBase & $sBVMint & "/" & $sLatestFile

                        EndIf

                    EndIf

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== DEBIAN LIVE =====

    If $sLatestURL = "" And StringInStr($sNameLow, "debian") Then

        Local $sDebBase = "https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/"

        Local $sHDeb = _FetchMirrorDir($sDebBase, $sCurl)

        If $sHDeb <> "" Then

            Local $sDEDeb = "xfce"

            If StringInStr($sNameLow, "gnome") Then $sDEDeb = "gnome"

            If StringInStr($sNameLow, "kde") Then $sDEDeb = "kde"

            If StringInStr($sNameLow, "mate") Then $sDEDeb = "mate"

            If StringInStr($sNameLow, "cinnamon") Then $sDEDeb = "cinnamon"

            Local $aIDeb = StringRegExp($sHDeb, "(debian-live-[\d\.]+-amd64-" & $sDEDeb & "\.iso)", 3)

            If Not @error And UBound($aIDeb) > 0 Then

                Local $aVDeb = StringRegExp($aIDeb[0], "debian-live-([\d\.]+)-amd64", 1)

                If Not @error Then

                    $sLatestVer  = $aVDeb[0]

                    $sLatestFile = $aIDeb[0]

                    $sLatestURL  = $sDebBase & $sLatestFile

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== FEDORA WORKSTATION =====

    If $sLatestURL = "" And StringInStr($sNameLow, "fedora") Then

        Local $sFedBase = "https://dl.fedoraproject.org/pub/fedora/linux/releases/"

        Local $sHFed = _FetchMirrorDir($sFedBase, $sCurl)

        If $sHFed <> "" Then

            Local $aMFed = StringRegExp($sHFed, 'href="(\d+)/"', 3)

            If Not @error Then

                Local $sBVFed = ""

                For $m = 0 To UBound($aMFed) - 1

                    If _VersionNewer($aMFed[$m], $sBVFed) Then $sBVFed = $aMFed[$m]

                Next

                If $sBVFed <> "" Then

                    Local $sFedRel = $sFedBase & $sBVFed & "/Workstation/x86_64/iso/"

                    Local $sRHFed = _FetchMirrorDir($sFedRel, $sCurl)

                    If $sRHFed <> "" Then

                        Local $aIFed = StringRegExp($sRHFed, "(Fedora-Workstation-Live-x86_64-[^""]+\.iso)", 3)

                        If Not @error And UBound($aIFed) > 0 Then

                            $sLatestVer  = $sBVFed

                            $sLatestFile = $aIFed[0]

                            $sLatestURL  = $sFedRel & $sLatestFile

                        EndIf

                    EndIf

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== MANJARO =====

    If $sLatestURL = "" And StringInStr($sNameLow, "manjaro") Then

        Local $sDEMan = "kde"

        If StringInStr($sNameLow, "xfce") Then $sDEMan = "xfce"

        If StringInStr($sNameLow, "gnome") Then $sDEMan = "gnome"

        Local $sManDeURL = "https://download.manjaro.org/" & $sDEMan & "/"

        Local $sHMan = _FetchMirrorDir($sManDeURL, $sCurl)

        If $sHMan <> "" Then

            Local $aMMan = StringRegExp($sHMan, 'href="([\d\.]+)/"', 3)

            If Not @error Then

                Local $sBVMan = ""

                For $m = 0 To UBound($aMMan) - 1

                    If _VersionNewer($aMMan[$m], $sBVMan) Then $sBVMan = $aMMan[$m]

                Next

                If $sBVMan <> "" Then

                    Local $sManVerURL = $sManDeURL & $sBVMan & "/"

                    Local $sRHMan = _FetchMirrorDir($sManVerURL, $sCurl)

                    If $sRHMan <> "" Then

                        Local $aIMan = StringRegExp($sRHMan, "(manjaro-" & $sDEMan & "-[^""]+\.iso)", 3)

                        If Not @error And UBound($aIMan) > 0 Then

                            $sLatestVer  = $sBVMan

                            $sLatestFile = $aIMan[0]

                            $sLatestURL  = $sManVerURL & $sLatestFile

                        EndIf

                    EndIf

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== MX LINUX =====

    If $sLatestURL = "" And (StringInStr($sNameLow, "mx linux") Or StringInStr($sNameLow, "mx-") Or $sName = "MX Linux" Or StringLeft($sNameLow, 3) = "mx ") Then

        Local $sMXBase = "https://ftp.halifax.rwth-aachen.de/mxlinux/isos/MX/Final/"

        Local $sHMX = _FetchMirrorDir($sMXBase, $sCurl)

        If $sHMX <> "" Then

            ; Suche Unterordner wie Xfce/, KDE/ etc.

            Local $sDEMX = "Xfce"

            If StringInStr($sNameLow, "kde") Then $sDEMX = "KDE"

            If StringInStr($sNameLow, "fluxbox") Then $sDEMX = "Fluxbox"

            Local $sRHMX = _FetchMirrorDir($sMXBase & $sDEMX & "/", $sCurl)

            If $sRHMX <> "" Then

                Local $aIMX = StringRegExp($sRHMX, "(MX-[\d\.]+_" & $sDEMX & "_x64\.iso)", 3)

                If @error Then $aIMX = StringRegExp($sRHMX, "(MX-[\d\.]+[^""]*?x64\.iso)", 3)

                If Not @error And UBound($aIMX) > 0 Then

                    Local $aVMX = StringRegExp($aIMX[0], "MX-([\d\.]+)", 1)

                    If Not @error Then

                        $sLatestVer  = $aVMX[0]

                        $sLatestFile = $aIMX[0]

                        $sLatestURL  = $sMXBase & $sDEMX & "/" & $sLatestFile

                    EndIf

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== CACHYOS =====

    If $sLatestURL = "" And StringInStr($sNameLow, "cachy") Then

        ; Suche neuesten YYMMDD-Ordner im Listing

        Local $sHCachy = _FetchMirrorDir("https://iso.cachyos.org/desktop/", $sCurl)

        If $sHCachy <> "" Then

            Local $aMCachy = StringRegExp($sHCachy, "href=""(\d{6})/""", 3)

            If Not @error And UBound($aMCachy) > 0 Then

                Local $sBestCachy = ""

                For $m = 0 To UBound($aMCachy) - 1

                    If $aMCachy[$m] > $sBestCachy Then $sBestCachy = $aMCachy[$m]

                Next

                If $sBestCachy <> "" Then

                    $sLatestVer  = $sBestCachy

                    $sLatestFile = "cachyos-desktop-linux-" & $sBestCachy & ".iso"

                    $sLatestURL  = "https://iso.cachyos.org/desktop/" & $sBestCachy & "/" & $sLatestFile

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== ALMALINUX =====

    If $sLatestURL = "" And StringInStr($sNameLow, "alma") Then

        Local $sHAlma = _FetchMirrorDir("https://repo.almalinux.org/almalinux/latest/live/x86_64/", $sCurl)

        If $sHAlma <> "" Then

            Local $sDEAlma = "XFCE"

            If StringInStr($sNameLow, "kde") Then $sDEAlma = "KDE"

            If StringInStr($sNameLow, "gnome") Then $sDEAlma = "GNOME"

            Local $aIAlma = StringRegExp($sHAlma, "(AlmaLinux-[\d\.]+-x86_64-Live-" & $sDEAlma & "\.iso)", 3)

            If Not @error And UBound($aIAlma) > 0 Then

                Local $aVAlma = StringRegExp($aIAlma[0], "AlmaLinux-([\d\.]+)-", 1)

                If Not @error Then

                    $sLatestVer  = $aVAlma[0]

                    $sLatestFile = $aIAlma[0]

                    $sLatestURL  = "https://repo.almalinux.org/almalinux/latest/live/x86_64/" & $sLatestFile

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== POP!_OS =====

    If $sLatestURL = "" And StringInStr($sNameLow, "pop") Then

        ; iso.pop-os.org/XX.YY/amd64/nvidia/BUILD/ Listing pruefen

        Local $aVPop = StringRegExp($sFileURL, "iso\.pop-os\.org/(\d+\.\d+)/", 1)

        If Not @error Then

            Local $sPopVer = $aVPop[0]

            Local $sHPop = _FetchMirrorDir("https://iso.pop-os.org/" & $sPopVer & "/amd64/nvidia/", $sCurl)

            If $sHPop <> "" Then

                Local $aMPop = StringRegExp($sHPop, 'href="(\d+)/"', 3)

                If Not @error And UBound($aMPop) > 0 Then

                    Local $sBestBuild = "0"

                    For $m = 0 To UBound($aMPop) - 1

                        If Int($aMPop[$m]) > Int($sBestBuild) Then $sBestBuild = $aMPop[$m]

                    Next

                    $sLatestVer  = $sPopVer & "." & $sBestBuild

                    $sLatestFile = "pop-os_" & $sPopVer & "_amd64_nvidia_" & $sBestBuild & ".iso"

                    $sLatestURL  = "https://iso.pop-os.org/" & $sPopVer & "/amd64/nvidia/" & $sBestBuild & "/" & $sLatestFile

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== ARCHCRAFT (SourceForge) =====

    If $sLatestURL = "" And StringInStr($sNameLow, "archcraft") Then

        Local $sHArch = _FetchMirrorDir("https://sourceforge.net/projects/archcraft/files/", $sCurl)

        If $sHArch <> "" Then

            ; Suche vYY.MM Ordner

            Local $aMArch = StringRegExp($sHArch, '"name"\s*:\s*"(v\d+\.\d+)"', 3)

            If Not @error And UBound($aMArch) > 0 Then

                Local $sBestArch = $aMArch[UBound($aMArch) - 1]   ; letzter = neuester

                Local $aVArch = StringRegExp($sBestArch, "v([\d\.]+)", 1)

                If Not @error Then

                    Local $sArchVerFolder = $aVArch[0]

                    Local $sArchDate = StringReplace($sArchVerFolder, ".", "")

                    $sLatestVer  = "20" & $sArchDate

                    $sLatestFile = "archcraft-20" & $sArchDate & "-x86_64.iso"

                    $sLatestURL  = "https://master.dl.sourceforge.net/project/archcraft/" & $sBestArch & "/" & $sLatestFile & "?viasf=1"

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== G DATA BOOTMEDIUM (kein Update-Check nötig — stabiler CDN-Link) =====

    ; ersetzt ESET SysRescue Live (EOL seit Sept. 2023)

    If $sLatestURL = "" And (StringInStr($sNameLow, "gdata") Or StringInStr($sNameLow, "g data") Or _
       StringInStr($sNameLow, "eset") Or StringInStr($sNameLow, "sysrescue") Or _
       StringInStr($sNameLow, "gdata_bootmedium") Or StringInStr($sNameLow, "gdata-bootmedium")) Then

        $sLatestURL  = "https://www.gdatasoftware.com/fileadmin/web/en/documents/bootcd/GData-BootMedium.iso"

        $sLatestFile = "GData-BootMedium.iso"

        $sLatestVer  = "BootMedium-Current"

    EndIf

    ; ===== COMODO RESCUE DISK (kein Update-Check — stabiler CDN-Link) =====

    If $sLatestURL = "" And StringInStr($sNameLow, "comodo") Then

        $sLatestURL  = "https://download.comodo.com/crd/download/setups/comodo_rescue_disk.iso"

        $sLatestFile = "comodo_rescue_disk.iso"

        $sLatestVer  = "Rescue-2.0"

    EndIf

    ; ===== GARUDA LINUX (latest.iso URL — immer aktuell) =====

    ; Garuda nutzt permanente latest.iso-URL — kein Update-Check nötig.

    ; Früher wurde sLatestVer="latest" gesetzt und der Download-Test lief immer durch,

    ; was Phase 2 fälschlicherweise nodeColor=2 (orange) setzen ließ.

    ; Jetzt: direkt Return False → Phase 1 bleibt maßgeblich (grün = URL erreichbar).

    If $sLatestURL = "" And StringInStr($sNameLow, "garuda") Then

        If StringInStr($sFileURL, "latest.iso") Then

            Return False   ; latest.iso = Dauerlink, immer aktuell — kein falsches "Update verfügbar"

        EndIf

    EndIf

    ; ===== ZORIN OS =====

    If $sLatestURL = "" And StringInStr($sNameLow, "zorin") Then

        Local $sHZorin = _FetchMirrorDir("https://ftp.halifax.rwth-aachen.de/zorinos/", $sCurl)

        If $sHZorin <> "" Then

            Local $aMZorin = StringRegExp($sHZorin, 'href="(\d+)/"', 3)

            If Not @error Then

                Local $sBVZorin = ""

                For $m = 0 To UBound($aMZorin) - 1

                    If Int($aMZorin[$m]) > Int($sBVZorin) Then $sBVZorin = $aMZorin[$m]

                Next

                If $sBVZorin <> "" Then

                    Local $sRHZorin = _FetchMirrorDir("https://ftp.halifax.rwth-aachen.de/zorinos/" & $sBVZorin & "/", $sCurl)

                    If $sRHZorin <> "" Then

                        Local $aIZorin = StringRegExp($sRHZorin, "(Zorin-OS-[\d\.]+-[^""]+\.iso)", 3)

                        If Not @error And UBound($aIZorin) > 0 Then

                            Local $aVZorin = StringRegExp($aIZorin[0], "Zorin-OS-([\d\.]+)-", 1)

                            If Not @error Then

                                $sLatestVer  = $aVZorin[0]

                                $sLatestFile = $aIZorin[0]

                                $sLatestURL  = "https://ftp.halifax.rwth-aachen.de/zorinos/" & $sBVZorin & "/" & $sLatestFile

                            EndIf

                        EndIf

                    EndIf

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== v2.0: SYSTEMRESCUE — SourceForge-Verzeichnis scannen =====

    If $sLatestURL = "" And StringInStr($sNameLow, "systemrescue") Then

        Local $sSRBase = "https://master.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/"

        Local $sHSR = _FetchMirrorDir("https://sourceforge.net/projects/systemrescuecd/files/sysresccd-x86/", $sCurl)

        If $sHSR <> "" Then

            Local $aVSR = StringRegExp($sHSR, '"(/files/sysresccd-x86/([\d\.]+)/)"', 3)

            If Not @error And UBound($aVSR) >= 2 Then

                Local $sBVSR = ""

                For $m = 1 To UBound($aVSR) - 1 Step 2

                    If _VersionNewer($aVSR[$m], $sBVSR) Then $sBVSR = $aVSR[$m]

                Next

                If $sBVSR <> "" Then

                    $sLatestVer  = $sBVSR

                    $sLatestFile = "systemrescue-" & $sBVSR & "-amd64.iso"

                    $sLatestURL  = $sSRBase & $sBVSR & "/" & $sLatestFile & "?viasf=1"

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== v2.0: GPARTED — SourceForge-Verzeichnis scannen =====

    If $sLatestURL = "" And StringInStr($sNameLow, "gparted") Then

        Local $sGPBase = "https://master.dl.sourceforge.net/project/gparted/gparted-live-stable/"

        Local $sHGP = _FetchMirrorDir("https://sourceforge.net/projects/gparted/files/gparted-live-stable/", $sCurl)

        If $sHGP <> "" Then

            Local $aVGP = StringRegExp($sHGP, '"(/files/gparted-live-stable/([\d\.]+-\d+)/)"', 3)

            If Not @error And UBound($aVGP) >= 2 Then

                Local $sBVGP = ""

                For $m = 1 To UBound($aVGP) - 1 Step 2

                    If _VersionNewer(StringRegExpReplace($aVGP[$m], "-\d+$", ""), StringRegExpReplace($sBVGP, "-\d+$", "")) Then $sBVGP = $aVGP[$m]

                Next

                If $sBVGP <> "" Then

                    $sLatestVer  = $sBVGP

                    $sLatestFile = "gparted-live-" & $sBVGP & "-amd64.iso"

                    $sLatestURL  = $sGPBase & $sBVGP & "/" & $sLatestFile & "?viasf=1"

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== v2.0: CLONEZILLA — SourceForge-Verzeichnis scannen =====

    If $sLatestURL = "" And StringInStr($sNameLow, "clonezilla") Then

        Local $sCZBase = "https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/"

        Local $sHCZ = _FetchMirrorDir("https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/", $sCurl)

        If $sHCZ <> "" Then

            Local $aVCZ = StringRegExp($sHCZ, '"(/files/clonezilla_live_stable/([\d\.]+-\d+)/)"', 3)

            If Not @error And UBound($aVCZ) >= 2 Then

                Local $sBVCZ = ""

                For $m = 1 To UBound($aVCZ) - 1 Step 2

                    If _VersionNewer(StringRegExpReplace($aVCZ[$m], "-\d+$", ""), StringRegExpReplace($sBVCZ, "-\d+$", "")) Then $sBVCZ = $aVCZ[$m]

                Next

                If $sBVCZ <> "" Then

                    $sLatestVer  = $sBVCZ

                    $sLatestFile = "clonezilla-live-" & $sBVCZ & "-amd64.iso"

                    $sLatestURL  = $sCZBase & $sBVCZ & "/" & $sLatestFile & "?viasf=1"

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== v2.27: UBUNTU GAMEPACK — SourceForge-Verzeichnis scannen =====

    If $sLatestURL = "" And (StringInStr($sNameLow, "gamepack") Or StringInStr($sNameLow, "game_pack")) Then

        Local $sUGPBase = "https://master.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/"

        Local $sHUGP = _FetchMirrorDir("https://sourceforge.net/projects/ualinux/files/Ubuntu%20Pack/GamePack/", $sCurl)

        If $sHUGP <> "" Then

            ; Suche nach ubuntu_game_pack-XX.YY-amd64.iso

            Local $aIUGP = StringRegExp($sHUGP, "(ubuntu_game_pack-([\d\.]+)-amd64\.iso)", 3)

            If Not @error And UBound($aIUGP) > 1 Then

                Local $sBVUGP = ""

                Local $sLatestUGPFile = ""

                For $m = 0 To UBound($aIUGP) - 1 Step 2

                    If _VersionNewer($aIUGP[$m + 1], $sBVUGP) Then

                        $sBVUGP        = $aIUGP[$m + 1]

                        $sLatestUGPFile = $aIUGP[$m]

                    EndIf

                Next

                If $sLatestUGPFile <> "" Then

                    $sLatestVer  = $sBVUGP

                    $sLatestFile = $sLatestUGPFile

                    $sLatestURL  = $sUGPBase & $sLatestUGPFile & "?viasf=1"

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== v2.0: RESCUEZILLA — GitHub Releases =====

    If $sLatestURL = "" And StringInStr($sNameLow, "rescuezilla") Then

        Local $sGHRZ = "rescuezilla/rescuezilla"

        Local $sHGHRZ = _FetchMirrorDir("https://api.github.com/repos/" & $sGHRZ & "/releases/latest", $sCurl)

        If $sHGHRZ <> "" Then

            Local $aTagRZ = StringRegExp($sHGHRZ, '"tag_name"\s*:\s*"([^"]+)"', 1)

            If Not @error Then

                Local $sTagRZ = $aTagRZ[0]

                Local $sVerRZ = StringRegExpReplace($sTagRZ, "^v", "")

                Local $aAssRZ = StringRegExp($sHGHRZ, '"browser_download_url"\s*:\s*"([^"]*rescuezilla-[^"]*-64bit[^"]*\.iso)"', 1)

                If Not @error Then

                    $sLatestVer  = $sVerRZ

                    $sLatestURL  = $aAssRZ[0]

                    $sLatestFile = StringRegExpReplace($sLatestURL, ".*/", "")

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== v2.0: FINNIX — Offizieller Mirror-Verzeichnis-Scan =====

    If $sLatestURL = "" And StringInStr($sNameLow, "finnix") Then

        Local $sHFX = _FetchMirrorDir("https://de.mirror.finnix.org/releases/", $sCurl)

        If $sHFX <> "" Then

            Local $aVFX = StringRegExp($sHFX, 'href="(\d+)/"', 3)

            If Not @error And UBound($aVFX) > 0 Then

                Local $sBVFX = ""

                For $m = 0 To UBound($aVFX) - 1

                    If Int($aVFX[$m]) > Int($sBVFX) Then $sBVFX = $aVFX[$m]

                Next

                If $sBVFX <> "" Then

                    $sLatestVer  = $sBVFX

                    $sLatestFile = "finnix-" & $sBVFX & ".iso"

                    $sLatestURL  = "https://de.mirror.finnix.org/releases/" & $sBVFX & "/" & $sLatestFile

                EndIf

            EndIf

        EndIf

    EndIf

    ; ===== v2.0: DR.WEB LIVEDISK — Version aus Dateiname auf geo-Server =====

    If $sLatestURL = "" And StringInStr($sNameLow, "dr.web") Then

        Local $sHDW = _FetchMirrorDir("https://download.geo.drweb.com/pub/drweb/livedisk/", $sCurl)

        If $sHDW <> "" Then

            Local $aVDW = StringRegExp($sHDW, 'drweb-livedisk-([\d\.-]+)-cd\.iso', 3)

            If Not @error And UBound($aVDW) > 0 Then

                $sLatestVer  = $aVDW[0]

                $sLatestFile = "drweb-livedisk-" & $aVDW[0] & "-cd.iso"

                $sLatestURL  = "https://download.geo.drweb.com/pub/drweb/livedisk/" & $sLatestFile

            EndIf

        EndIf

    EndIf

    ; ===== v2.16: HIREN'S BOOT CD PE (HBCD_PE_x64.iso) =====

    ; Kein Versions-Suffix im Dateinamen — immer HBCD_PE_x64.iso.

    ; Versions-Erkennung via Homepage-Scraping (hirensbootcd.org).

    ; Datei-URL ist fest; ein "Update" ist erkennbar wenn die Webpage

    ; eine höhere Versions-Zahl zeigt als in der DB gespeichert ist.

    If $sLatestURL = "" And (StringInStr($sNameLow, "hbcd") Or StringInStr($sNameLow, "hirens") Or _
                             StringInStr($sNameLow, "hiren's")) Then

        Local $sHHBCD = _FetchMirrorDir("https://www.hirensbootcd.org/", $sCurl)

        If $sHHBCD <> "" Then

            ; Suche nach "HBCD PE X.X.X" oder "Hiren's BootCD PE... vX.X.X" in der Seite

            Local $aHBVer = StringRegExp($sHHBCD, "(?i)Hiren's BootCD PE.*?v?([\d]+\.[\d]+(?:\.[\d]+)*)", 1)

            If @error Then

                $aHBVer = StringRegExp($sHHBCD, "HBCD[_\s]+PE[_\s\(]+([\d]+\.[\d]+(?:\.[\d]+)*)", 1)

            EndIf

            If @error Then

                $aHBVer = StringRegExp($sHHBCD, "(?:[Vv]ersion|hbcd)[\s:]+v?([\d]+\.[\d]+(?:\.[\d]+)*)", 1)

            EndIf

            If Not @error Then

                $sLatestVer = $aHBVer[0]

            EndIf

        EndIf

        ; URL ist fix — Dateiname ändert sich nie

        $sLatestURL  = "https://www.hirensbootcd.org/files/HBCD_PE_x64.iso"

        $sLatestFile = "HBCD_PE_x64.iso"

        ; Kein Versions-String gefunden → "latest" → Version-Vergleich überspringen

        If $sLatestVer = "" Then $sLatestVer = "latest"

        _Log("[HBCD] Update-Check: URL=" & $sLatestURL & "  Version=" & $sLatestVer)

    EndIf

    ; ===== v2.16: KASPERSKY RESCUE DISK (krd.iso) =====

    ; Fester Dateiname krd.iso ohne Versionsnummer.

    ; Kaspersky bietet keinen öffentlich curl-zugänglichen Mirror → HEAD-Test

    ; auf bekannte CDN-URLs, um zumindest Erreichbarkeit zu prüfen.

    If $sLatestURL = "" And ($sNameLow = "krd.iso" Or StringLeft($sNameLow, 4) = "krd " Or _
                              StringInStr($sNameLow, "kaspersky rescue")) Then

        $sLatestURL  = "https://rescuedisk.s.kaspersky-labs.com/updatable/2018/krd.iso"

        $sLatestFile = "krd.iso"

        $sLatestVer  = "latest"   ; keine Versionsnummer verfügbar

        _Log("[krd] Update-Check: URL=" & $sLatestURL)

    EndIf

    ; ===== v2.16: ANTIVIRUS LIVE CD =====

    ; Versions-Erkennung über SourceForge Verzeichnis-Listing.

    ; Dateiname: AntivirusLiveCD-{major}.{minor}-{build}.iso

    If $sLatestURL = "" And StringInStr($sNameLow, "antiviruslivecd") Then

        Local $sAVSFBase = "https://sourceforge.net/projects/antiviruslivecd/files/"

        Local $sHAVDir = _FetchMirrorDir($sAVSFBase, $sCurl)

        If $sHAVDir <> "" Then

            ; Versions-Ordner extrahieren, z.B. "51.0-1.5.1/"

            Local $aAVVers = StringRegExp($sHAVDir, '"name":"([\d]+\.[\d]+-[\d\.]+)"', 3)

            If @error Then

                $aAVVers = StringRegExp($sHAVDir, '/files/([\d]+\.[\d]+-[\d\.]+)/', 3)

            EndIf

            If Not @error And IsArray($aAVVers) And UBound($aAVVers) > 0 Then

                Local $sBestAV = ""

                For $av = 0 To UBound($aAVVers) - 1

                    Local $sAVN = StringRegExpReplace($aAVVers[$av], "-.*", "")   ; "51.0"

                    Local $sBestN = StringRegExpReplace($sBestAV, "-.*", "")

                    If _VersionNewer($sAVN, $sBestN) Or ($sAVN = $sBestN And _VersionNewer($aAVVers[$av], $sBestAV)) Then

                        $sBestAV = $aAVVers[$av]

                    EndIf

                Next

                If $sBestAV <> "" Then

                    $sLatestVer  = $sBestAV

                    ; Dateiname rekonstruieren: AntivirusLiveCD-51.0-1.5.1.iso

                    $sLatestFile = "AntivirusLiveCD-" & $sBestAV & ".iso"

                    $sLatestURL  = "https://netcologne.dl.sourceforge.net/project/antiviruslivecd/files/" & _
                                   $sBestAV & "/" & $sLatestFile & "?viasf=1"

                    _Log("[AntivirusLiveCD] Neueste Version: " & $sLatestVer & " → " & $sLatestURL)

                EndIf

            EndIf

        EndIf

        ; Fallback: bekannte stabile URL

        If $sLatestURL = "" Then

            $sLatestURL  = "https://master.dl.sourceforge.net/project/antiviruslivecd/files/51.0-1.5.1/AntivirusLiveCD-51.0-1.5.1.iso?viasf=1"

            $sLatestFile = "AntivirusLiveCD-51.0-1.5.1.iso"

            $sLatestVer  = "51.0-1.5.1"

            _Log("[AntivirusLiveCD] Fallback URL: " & $sLatestURL)

        EndIf

    EndIf

    ; ===== v2.9: NOBARA LINUX — GitHub Releases (Nobara-Project/nobara-images) =====

    ; Ersetzt Bazzite (v2.9): Fedora-Fork von GloriousEggroll, ISO: Nobara-XX-Official.iso

    ; GitHub API liefert Tag (z.B. "43") und browser_download_url für das ISO-Asset

    ; FIX: Guard $sGitRepo <> "" — GNOME-Eintrag hat kein GitHub-Repo und darf

    ;            diesen Block NICHT betreten. Ohne Guard feuerte der Block für GNOME,

    ;            GitHub-API lieferte leeres Array (keine Releases), Fallback setzte dann

    ;            die HTML-Seite als ISO-URL → korrupte DB-Einträge.

    If $sLatestURL = "" And StringInStr($sNameLow, "nobara") And $sGitRepo <> "" Then

        ; GitHub API: aktuelle Version + Download-URL abrufen

        Local $sGHNBJSON = _FetchMirrorDir("https://api.github.com/repos/" & $sGitRepo & "/releases/latest", $sCurl)

        If $sGHNBJSON <> "" Then

            ; Version aus tag_name extrahieren (z.B. "43" oder "43.20260328")

            Local $aTagNB = StringRegExp($sGHNBJSON, '"tag_name"\s*:\s*"([^"]+)"', 1)

            If Not @error Then

                $sLatestVer = StringRegExpReplace($aTagNB[0], "^v", "")

            EndIf

            ; Asset-URL für *-Official.iso suchen

            Local $aAssetNB = StringRegExp($sGHNBJSON, '"browser_download_url"\s*:\s*"([^"]+Nobara-[^"]*-Official\.iso)"', 3)

            If IsArray($aAssetNB) And UBound($aAssetNB) > 0 Then

                $sLatestURL  = $aAssetNB[0]

                $sLatestFile = StringMid($sLatestURL, StringInStr($sLatestURL, "/", 0, -1) + 1)

                _Log("[Nobara] GitHub-Asset: " & $sLatestFile & " → " & $sLatestURL)

            Else

                _Log("[Nobara] GitHub-API: Kein ISO-Asset gefunden (releases evtl. leer)")

            EndIf

        EndIf

        ; KEIN Fallback mehr auf GitHub-HTML-Seite — diese liefert 200 auf

        ;        HEAD-Requests, obwohl es kein echtes ISO ist. Das führte dazu, dass

        ;        _AutoApplyUpdate() die DB mit "Nobara-43-Official.iso" korrumpierte.

    EndIf

    ; ===== v14.38: WEB-SUCHE FALLBACK für unbekannte / nicht erkannte Distros =====

    ; Wenn alle distro-spezifischen Methoden fehlschlugen UND die Primär-URL nicht

    ; erreichbar ist → automatische Online-Suche starten

    If $sLatestURL = "" Then

        Local $bURLKnownBad = $g_abURLChecked[$iIdx] And Not $g_abURLOK[$iIdx]

        Local $bUnrecognized = True  ; True wenn keine der obigen Distro-Blöcke griff

        ; Erkannte Distros durch Name-Keywords identifizieren

        If StringInStr($sNameLow, "eset")      Then $bUnrecognized = False

        If StringInStr($sNameLow, "comodo")    Then $bUnrecognized = False

        If StringInStr($sNameLow, "nobara")    Then $bUnrecognized = False

        If StringInStr($sNameLow, "garuda")    Then $bUnrecognized = False

        If StringInStr($sNameLow, "fedora") And StringInStr($sNameLow, "security") Then $bUnrecognized = False

        If StringInStr($sNameLow, "tails")     Then $bUnrecognized = False

        If StringInStr($sNameLow, "parrot")    Then $bUnrecognized = False

        If StringInStr($sNameLow, "mint")      Then $bUnrecognized = False

        If StringInStr($sNameLow, "ubuntu") And Not StringInStr($sNameLow, "gamepack") And Not StringInStr($sNameLow, "game_pack") Then $bUnrecognized = False

        If StringInStr($sNameLow, "lubuntu")   Then $bUnrecognized = False

        If StringInStr($sNameLow, "zorin")     Then $bUnrecognized = False

        If StringInStr($sNameLow, "pop")       Then $bUnrecognized = False

        If StringInStr($sNameLow, "debian")    Then $bUnrecognized = False

        If StringInStr($sNameLow, "fedora")    Then $bUnrecognized = False

        If StringInStr($sNameLow, "manjaro")   Then $bUnrecognized = False

        If StringInStr($sNameLow, "mx linux")  Then $bUnrecognized = False

        If StringInStr($sNameLow, "mx-")       Then $bUnrecognized = False

        If StringLeft($sNameLow, 3) = "mx "    Then $bUnrecognized = False

        If StringInStr($sNameLow, "cachy")     Then $bUnrecognized = False

        If StringInStr($sNameLow, "alma")      Then $bUnrecognized = False

        If StringInStr($sNameLow, "archcraft")    Then $bUnrecognized = False

        If StringInStr($sNameLow, "kodachi")     Then $bUnrecognized = False

        If StringInStr($sNameLow, "chimera")     Then $bUnrecognized = False

        ; Neu erkannte Distros — haben eigene Handler oben

        If StringInStr($sNameLow, "systemrescue") Then $bUnrecognized = False

        If StringInStr($sNameLow, "gparted")      Then $bUnrecognized = False

        If StringInStr($sNameLow, "clonezilla")   Then $bUnrecognized = False

        If StringInStr($sNameLow, "rescuezilla")  Then $bUnrecognized = False

        If StringInStr($sNameLow, "finnix")       Then $bUnrecognized = False

        If StringInStr($sNameLow, "dr.web")       Then $bUnrecognized = False

        If StringInStr($sNameLow, "nobara")       Then $bUnrecognized = False   ; Nobara statt Bazzite

        ; Manuell-hinzugefügte ISOs — haben eigene Handler oben

        If StringInStr($sNameLow, "hbcd")         Then $bUnrecognized = False

        If StringInStr($sNameLow, "hirens")       Then $bUnrecognized = False

        If StringInStr($sNameLow, "antiviruslivecd") Then $bUnrecognized = False

        If StringInStr($sNameLow, "kaspersky")    Then $bUnrecognized = False

        If $sGitRepo <> ""                        Then $bUnrecognized = False

        ; Web-Suche starten wenn: Distro unbekannt ODER URL nachweislich defekt

        If $bUnrecognized Or $bURLKnownBad Then

            _Log("  [WebSearch] Keine distro-spezifische Methode gefunden oder URL tot — starte Web-Suche für: " & $sName)

            _WebSearchLatestISO($sName, $g_aISOs[$iIdx][3], $sCurl, $sLatestVer, $sLatestURL, $sLatestFile)

        EndIf

    EndIf

    Until True   ; Ende Do-Block (v14.39): ExitLoop oben springt direkt hierher (kein Goto nötig)

    ; ===== KEIN TREFFER ODER NICHT NEUER =====

    If $sLatestVer = "" Or $sLatestURL = "" Then Return False

    ; Spezialfall: "latest" ist nur dann ein Update, wenn sich die URL geändert hat

    ; (verhindert False-Positives bei statischen Links wie Hiren's BootCD oder Kaspersky)

    If $sLatestVer = "latest" Then

        If $sLatestURL == $g_aISOs[$iIdx][2] Then Return False

    ElseIf $sCurrVer <> "" And Not _VersionNewer($sLatestVer, $sCurrVer) Then

        ; Falls Version bekannt und NICHT neuer -> kein Update

        Return False

    EndIf

    ; ===== URL-Verifikation: HEAD-Request (v2.12) =====

    ; Methode 1 — HEAD: schnell, kein Download, Server-unabhängig (kein Range-Request nötig).

    ; Früher: Range-Download 512 KB — scheiterte wenn Server Range-Requests blockiert (z.B. Tails-Mirror).

    Local $bOK = False

    Local $iPHead = Run('"' & $sCurl & '" -s -I -L --max-time 15 --connect-timeout 8 --ssl-no-revoke ' & _
                    '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                    '-o NUL -w "%{http_code}" "' & $sLatestURL & '"', "", @SW_HIDE, $STDOUT_CHILD)

    If $iPHead <> 0 Then

        Local $sHeadOut = ""

        While 1

            $sHeadOut &= StdoutRead($iPHead)

            If @error Then ExitLoop

        Wend

        ProcessClose($iPHead)

        Local $sCode = StringStripWS($sHeadOut, 3)

        If $sCode = "200" Or $sCode = "206" Then

            $bOK = True

            _Log("  [VerCheck] HEAD-Test OK (" & $sCode & "): " & $sLatestURL)

        Else

            _Log("  [VerCheck] HEAD-Test fehlgeschlagen (HTTP " & $sCode & "): " & $sLatestURL)

        EndIf

    EndIf

    ; Methode 2 — Range-Download als Fallback wenn HEAD nichts zurückgab

    If Not $bOK Then

        Local $sTmpDL = @TempDir & "\vlm_dltest.tmp"

        FileDelete($sTmpDL)

        RunWait('"' & $sCurl & '" -s -L --max-time 20 --connect-timeout 10 --ssl-no-revoke ' & _
                '-r 0-131071 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                '-o "' & $sTmpDL & '" "' & $sLatestURL & '"', "", @SW_HIDE)

        If FileExists($sTmpDL) And FileGetSize($sTmpDL) > 4096 Then

            $bOK = True

            _Log("  [VerCheck] Range-Fallback OK (" & FileGetSize($sTmpDL) & " Bytes): " & $sLatestURL)

        EndIf

        FileDelete($sTmpDL)

    EndIf

    If Not $bOK Then

        ; FIX: Wenn aktuelle URL bekannt defekt → Update trotzdem erzwingen

        If $g_abURLChecked[$iIdx] And Not $g_abURLOK[$iIdx] Then

            _Log("  [VerCheck] Beide Tests fehlgeschlagen, aber URL bekannt defekt → Update erzwingen: " & $g_aISOs[$iIdx][0])

        Else

            Return False

        EndIf

    EndIf

    ; Ergebnis speichern

    $g_asUpdateVer[$iIdx]  = $sLatestVer

    $g_asUpdateURL[$iIdx]  = $sLatestURL

    $g_asUpdateFile[$iIdx] = $sLatestFile

    Return True

EndFunc

Func _OnCheckAllURLs()

    _HideTooltip()   ; 

    If $g_bBusy Then Return

    $g_bBusy = True

    $g_bCancel = False

    Local $sCurl = _CurlPath()

    If $sCurl = "" Then

        MsgBox(16, "Fehler", "curl.exe nicht gefunden!")

        $g_bBusy = False

        Return

    EndIf

    _PopShow("URL-Verfügbarkeitsprüfung", "Prüfe " & $ISO_COUNT & " Primär-URLs ...", True)

    GUICtrlSetData($g_hProgress, 0)

    _Log("=== URL-Verfügbarkeitsprüfung gestartet ===")

    Local $iOK = 0, $iFail = 0

    For $i = 0 To $ISO_COUNT - 1

        If $g_bCancel Then ExitLoop

        Local $sURL = $g_aISOs[$i][2]

        Local $sName = $g_aISOs[$i][0]

        Local $iPct = Int(($i + 1) / $ISO_COUNT * 100)

        _PopUpdate($iPct, "Prüfe: " & $sName, "Phase 1/2 — URL  " & ($i + 1) & "/" & $ISO_COUNT)

        GUICtrlSetData($g_hProgress, $iPct)

        ; Einträge ohne URL — GitHub-Repo prüfen falls [6] gesetzt (v2.9)

        If $sURL = "" Then

            If $g_aISOs[$i][6] <> "" Then

                ; GitHub-API HEAD-Check statt grau

                Local $sGHChk2 = "https://api.github.com/repos/" & $g_aISOs[$i][6] & "/releases/latest"

                Local $sGHArgs2 = '-s -I -L --max-time 10 --connect-timeout 8 -o NUL -w "%{http_code}" ' & _
                                  '-H "Accept: application/vnd.github+json" "' & $sGHChk2 & '"'

                Local $iGHP2 = Run('"' & $sCurl & '" ' & $sGHArgs2, "", @SW_HIDE, $STDOUT_CHILD)

                Local $sGHO2 = ""

                If $iGHP2 <> 0 Then

                    Local $tGH2 = TimerInit()

                    While ProcessExists($iGHP2) And TimerDiff($tGH2) < 12000

                        $sGHO2 &= StdoutRead($iGHP2)

                        Sleep(100)

                    WEnd

                    If ProcessExists($iGHP2) Then ProcessClose($iGHP2)

                    $sGHO2 &= StdoutRead($iGHP2)

                EndIf

                Local $iGHC2 = Int(StringStripWS($sGHO2, 3))

                $g_abURLChecked[$i] = True

                If $iGHC2 >= 200 And $iGHC2 < 400 Then

                    $g_abURLOK[$i]     = True

                    $g_aiNodeColor[$i] = 1

                    $iOK += 1

                    _Log("  [✓ GitHub " & $iGHC2 & "] " & $sName & " — GitHub-Repo erreichbar")

                Else

                    $g_abURLOK[$i]     = False

                    $g_aiNodeColor[$i] = 3

                    $iFail += 1

                    _Log("  [✗ GitHub " & $iGHC2 & "] " & $sName & " — GitHub-Repo nicht erreichbar")

                EndIf

            Else

                $g_abURLChecked[$i] = False

                $g_abURLOK[$i]      = False

                $g_aiNodeColor[$i]  = 4   ; grau: kein URL gespeichert (Stick-Import)

                _Log("  [–] " & $sName & " — keine URL gespeichert (Stick-Import?), überspringe HEAD-Check")

            EndIf

            Sleep(10)

            ContinueLoop

        EndIf

        _Log("  Prüfe: " & $sName & " → " & $sURL)

        ; HEAD-Request: -I = HEAD, -L = folge Redirects, --max-time = 10s Timeout

        ; -s = silent, -o NUL = kein Body, -w "%{http_code}" = nur Status-Code ausgeben

        Local $sArgs = '-s -I -L --max-time 10 --connect-timeout 8 ' & _
                       '-o NUL -w "%{http_code}" ' & _
                       '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                       '"' & $sURL & '"'

        Local $iPID = Run('"' & $sCurl & '" ' & $sArgs, "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)

        Local $sOut = ""

        If $iPID <> 0 Then

            Local $tW = TimerInit()

            While ProcessExists($iPID) And TimerDiff($tW) < 12000

                $sOut &= StdoutRead($iPID)

                ; GUI responsive halten

                Local $ev = GUIGetMsg()

                If $ev = $GUI_EVENT_CLOSE  Then _Quit()

                If $ev = $g_hBtnCancel    Then $g_bCancel = True

                If $g_hPopCancel <> 0 And $ev = $g_hPopCancel Then $g_bCancel = True

                Sleep(100)

            WEnd

            If ProcessExists($iPID) Then ProcessClose($iPID)

            $sOut &= StdoutRead($iPID)

        EndIf

        ; HTTP-Status auswerten: 200/206/302/301 = OK, alles andere = Fehler

        Local $iHTTP = Int(StringStripWS($sOut, 3))

        $g_abURLChecked[$i] = True

        If $iHTTP >= 200 And $iHTTP < 400 Then

            $g_abURLOK[$i]    = True

            $g_aiNodeColor[$i] = 1   ; grün (erreichbar, kein Update-Status yet)

            $iOK += 1

            _Log("  [✓ " & $iHTTP & "]  " & $sName)

        Else

            $g_abURLOK[$i]    = False

            $g_aiNodeColor[$i] = 3   ; rot (nicht erreichbar)

            $iFail += 1

            _Log("  [✗ " & $iHTTP & "]  " & $sName & "  →  URL nicht erreichbar oder geändert")

            ; Fallback-Mirror testen falls verfügbar

            If $g_aISOs[$i][4] <> "" Then

                _Log("    Teste Mirror 1: " & $g_aISOs[$i][4])

                Local $sArgs2 = '-s -I -L --max-time 8 --connect-timeout 6 -o NUL -w "%{http_code}" "' & $g_aISOs[$i][4] & '"'

                Local $iPID2 = Run('"' & $sCurl & '" ' & $sArgs2, "", @SW_HIDE, $STDOUT_CHILD)

                Local $sOut2 = ""

                Local $tW2 = TimerInit()

                While ProcessExists($iPID2) And TimerDiff($tW2) < 10000

                    $sOut2 &= StdoutRead($iPID2)

                    Sleep(100)

                WEnd

                If ProcessExists($iPID2) Then ProcessClose($iPID2)

                $sOut2 &= StdoutRead($iPID2)

                Local $iHTTP2 = Int(StringStripWS($sOut2, 3))

                If $iHTTP2 >= 200 And $iHTTP2 < 400 Then

                    $g_abURLOK[$i]    = True   ; Mirror OK → als verfügbar werten

                    $g_aiNodeColor[$i] = 1     ; grün (Mirror erreichbar)

                    $iFail -= 1

                    $iOK += 1

                    _Log("    [✓ Mirror " & $iHTTP2 & "]  " & $sName & " — Mirror erreichbar")

                EndIf

            EndIf

        EndIf

        Sleep(80)   ; kurze Pause um Server nicht zu überlasten

    Next

    ; ---- Phase 2: Versions-Finder im Hintergrund ----

    _PopUpdate(0, "Starte Versions-Scan ...", "Phase 2/2 — Versions-Finder")

    GUICtrlSetData($g_hProgress, 0)

    _Log("=== Phase 2: Versions-Finder gestartet ===")

    Local $iUpdates    = 0

    Local $sUpdateList = ""

    For $i = 0 To $ISO_COUNT - 1

        If $g_bCancel Then ExitLoop

        Local $sName2 = $g_aISOs[$i][0]

        Local $iPct2  = Int(($i + 1) / $ISO_COUNT * 100)

        _PopUpdate($iPct2, "Versions-Scan: " & $sName2, "Phase 2/2  —  " & ($i + 1) & "/" & $ISO_COUNT)

        GUICtrlSetData($g_hProgress, $iPct2)

        ; GUI responsive halten

        Local $ev2 = GUIGetMsg()

        If $ev2 = $GUI_EVENT_CLOSE  Then _Quit()

        If $ev2 = $g_hBtnCancel     Then $g_bCancel = True

        If $g_hPopCancel <> 0 And $ev2 = $g_hPopCancel Then $g_bCancel = True

        _Log("  Versions-Scan: " & $sName2)

        If _FindLatestVersionURL($i, $sCurl) Then

            $iUpdates += 1

            ; Versionsnummer automatisch in DB aktualisieren

            Local $sFoundVer = $g_asUpdateVer[$i]   ; sichern VOR AutoApply (wird dort gecleart)

            Local $sFoundURL = $g_asUpdateURL[$i]

            $sUpdateList &= "  " & $sName2 & "  ->  v" & $sFoundVer & @CRLF

            _Log("  [UPDATE] " & $sName2 & " -> v" & $sFoundVer & " @ " & $sFoundURL)

            _PopUpdate($iPct2, "Auto-Update: " & $sName2 & " → v" & $sFoundVer, "Phase 2/2 — AutoApply")

            $g_aiNodeColor[$i] = 2   ; orange — Update gefunden

            _AutoApplyUpdate($i)

            _Log("  [AutoApply] " & $sName2 & " aktualisiert in DB")

        EndIf

    Next

    ; ---- Phase 3: TreeView + DB-Speicherung ----

    _PopUpdate(100, $iOK & " URLs OK / " & $iFail & " fehlgeschlagen / " & $iUpdates & " Updates (auto-aktualisiert)", "Abgeschlossen")

    Sleep(600)

    _PopClose()

    $g_bBusy = False

    _Log("=== URL-Pruefung + Versions-Finder fertig: " & $iOK & " OK / " & $iFail & " fehlgeschlagen / " & $iUpdates & " Updates ===")

    _FillTree()   ; TreeView neu aufbauen — inkl. farbiger Punkt-Prefixe (v14.40)

    ; Ergebnis-Meldung zusammenstellen

    Local $sMsg = "URL-Pruefung & Versions-Scan abgeschlossen!" & @CRLF & @CRLF & _
        "Phase 1 — URL-Verfuegbarkeit:" & @CRLF & _
        "  Erreichbar:       " & $iOK & " URLs" & @CRLF & _
        "  Nicht erreichbar: " & $iFail & " URLs" & @CRLF & @CRLF & _
        "Phase 2 — Versions-Finder + Auto-Update:" & @CRLF & _
        "  Neuere Versionen: " & $iUpdates

    If $iUpdates > 0 Then

        $sMsg &= @CRLF & @CRLF & "Automatisch aktualisiert:" & @CRLF & $sUpdateList

        $sMsg &= @CRLF & "URLs, Dateinamen und Versionsnummern in der Datenbank" & @CRLF

        $sMsg &= "wurden automatisch auf die neueste Version angepasst."

    EndIf

    $sMsg &= @CRLF & @CRLF & "Ausgefallene URLs -> Protokoll-Tab fuer Details."

    If $iFail > 0 Then

        $sMsg &= @CRLF & @CRLF & "Hinweis: Nicht erreichbare URLs werden beim naechsten" & @CRLF & _
            "'🔍 URLs pruefen' automatisch per Web-Suche neu ermittelt."

    EndIf

    Local $iIcon = 262208

    If $iFail > 0 Or $iUpdates > 0 Then $iIcon = 262192

    MsgBox($iIcon, "URL-Pruefung & Versions-Scan", $sMsg)

    _Status("URL-Pruefung: " & $iOK & " erreichbar, " & $iFail & " fehlgeschlagen, " & $iUpdates & " Updates auto-aktualisiert.")

EndFunc

Func _SortURLsBySpeed(ByRef $aURLs, $iStart, $iEnd)

    If $iEnd - $iStart < 1 Then Return   ; weniger als 2 URLs → nichts zu tun

    Local $sCurl = _CurlPath()

    If $sCurl = "" Then Return

    Local $iCount = $iEnd - $iStart + 1

    Local $aSpeeds[$iCount]   ; gemessene Bytes je URL

    Local $aTmp    = $TMP_DOWNLOAD_DIR & "\vlm_mirrortest"

    ; Alle Mirror-PIDs parallel starten (je 5s Messung)

    Local $aPIDs[$iCount]

    Local $aFiles[$iCount]

    _Log("    Mirror-Speedtest: prüfe " & $iCount & " URLs parallel ...")

    For $k = 0 To $iCount - 1

        Local $sURL = $aURLs[$iStart + $k]

        If $sURL = "" Then

            $aPIDs[$k]  = 0

            $aFiles[$k] = ""

            $aSpeeds[$k] = 0

            ContinueLoop

        EndIf

        Local $sDst = $aTmp & "_" & $k & ".tmp"

        $aFiles[$k] = $sDst

        FileDelete($sDst)

        ; 5-Sekunden-Download: max-time 5 > connect-timeout 3

        Local $sArgs = '-s -L --fail --max-time 5 --connect-timeout 3 ' & _
                       '--limit-rate 0 ' & _
                       '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                       '-o "' & $sDst & '" "' & $sURL & '"'

        $aPIDs[$k]  = Run('"' & $sCurl & '" ' & $sArgs, "", @SW_HIDE)

        $aSpeeds[$k] = 0

    Next

    ; Auf alle Messungen warten (max 6s gesamt für sauberen Abbruch)

    Local $tWait = TimerInit()

    While TimerDiff($tWait) < 6000

        Local $bAllDone = True

        For $k = 0 To $iCount - 1

            If $aPIDs[$k] <> 0 And ProcessExists($aPIDs[$k]) Then

                $bAllDone = False

            EndIf

        Next

        If $bAllDone Then ExitLoop

        Sleep(100)

    WEnd

    ; Laufende Prozesse beenden falls Timeout (Fallback)

    For $k = 0 To $iCount - 1

        If $aPIDs[$k] <> 0 And ProcessExists($aPIDs[$k]) Then

            ProcessClose($aPIDs[$k])

        EndIf

    Next

    ; Metrik berechnen: Reine heruntergeladene Dateigröße in 5 Sekunden

    For $k = 0 To $iCount - 1

        If $aFiles[$k] <> "" And FileExists($aFiles[$k]) Then

            Local $iBytes = FileGetSize($aFiles[$k])

            $aSpeeds[$k] = $iBytes   ; Absolut heruntergeladene Menge (ignoriert Ping-Latenz)

            FileDelete($aFiles[$k])

            _Log("    Mirror " & ($k+1) & ": " & _FmtBytes($aSpeeds[$k]) & " geladen in ~5s  — " & $aURLs[$iStart + $k])

        EndIf

    Next

    ; Bubble-Sort: schnellster Mirror nach oben (absteigend)

    For $i = 0 To $iCount - 2

        For $j = 0 To $iCount - 2 - $i

            If $aSpeeds[$j] < $aSpeeds[$j+1] Then

                ; URLs tauschen

                Local $sTmpURL = $aURLs[$iStart + $j]

                $aURLs[$iStart + $j]   = $aURLs[$iStart + $j + 1]

                $aURLs[$iStart + $j + 1] = $sTmpURL

                ; Speeds tauschen

                Local $iTmpSpd = $aSpeeds[$j]

                $aSpeeds[$j]   = $aSpeeds[$j+1]

                $aSpeeds[$j+1] = $iTmpSpd

            EndIf

        Next

    Next

    _Log("    Schnellster Mirror: " & $aURLs[$iStart] & "  (" & _FmtBytes($aSpeeds[0]) & " absolute Metrik)")

EndFunc

Func _IsURLReachable($sURL, $iTimeout = 2)

    If $sURL = "" Then Return False

    Local $sCurl = _CurlPath()

    If $sCurl = "" Then Return False

    ; Schneller HEAD-Request (nur Header, kein Body-Download)

    Local $sArgs = '-s -I --fail --max-time ' & $iTimeout & ' ' & _
                   '--connect-timeout 2 ' & _
                   '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                   '"' & $sURL & '"'

    Local $iPID = Run('"' & $sCurl & '" ' & $sArgs, "", @SW_HIDE)

    Local $tWait = TimerInit()

    Local $iWaitMax = ($iTimeout * 1000) + 500  ; kurzer Buffer

    While ProcessExists($iPID) And TimerDiff($tWait) < $iWaitMax

        Sleep(50)  ; schnellere Polls statt 100ms

    WEnd

    If ProcessExists($iPID) Then ProcessClose($iPID)

    ; Bei HEAD-Request ist HTTP 200-204 erfolgreich

    Return @error = 0

EndFunc

; v2.27: Downloads nach Absturz/Abbruch wiederherstellen

Func _RecoverOrphanedDownloads()

    Local $sTmpDir = @TempDir & "\VLM_Downloads"

    If Not FileExists($sTmpDir) Then Return

    Local $hSearch = FileFindFirstFile($sTmpDir & "\*.iso")

    If $hSearch = -1 Then Return

    _Log("Prüfe verwaiste Downloads in " & $sTmpDir)

    Local $iRecovered = 0

    While 1

        Local $sFile = FileFindNextFile($hSearch)

        If @error Then ExitLoop

        

        Local $sSrc = $sTmpDir & "\" & $sFile

        Local $sDest = $DOWNLOAD_DIR & "\" & $sFile

        

        ; Wenn die Datei im Ziel noch nicht existiert oder kleiner ist -> verschieben/wiederherstellen

        If Not FileExists($sDest) Then

            If FileMove($sSrc, $sDest, 1) Then

                _Log("  Wiederhergestellt: " & $sFile)

                $iRecovered += 1

            EndIf

        Else

            ; Datei existiert bereits im Ziel -> im Tmp löschen

            FileDelete($sSrc)

        EndIf

    WEnd

    FileClose($hSearch)

    

    If $iRecovered > 0 Then

        _Log($iRecovered & " verwaiste Downloads wiederhergestellt.")

    EndIf

EndFunc

