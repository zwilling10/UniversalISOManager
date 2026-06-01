; ==========================================
; Module: VLM_USB.au3
; Part of UniversalISOManager
; ==========================================

#include-once

Func _FillDrives()
    GUICtrlSetData($g_hDriveCombo, "")
    Local $aDrives = DriveGetDrive("REMOVABLE")
    If Not IsArray($aDrives) Or $aDrives[0] = 0 Then
        GUICtrlSetData($g_hDriveCombo, "-- Kein USB-Laufwerk --", "-- Kein USB-Laufwerk --")
        Return
    EndIf
    For $i = 1 To $aDrives[0]
        Local $d = StringUpper($aDrives[$i])
        Local $sGB = Round(DriveSpaceTotal($d) / 1024, 1)
        Local $sEntry = $d & "  " & DriveGetLabel($d) & "  (" & $sGB & " GB)"
        GUICtrlSetData($g_hDriveCombo, $sEntry, $sEntry)
    Next
EndFunc

Func _DriveList()
    Local $aDrives = DriveGetDrive("REMOVABLE")
    If Not IsArray($aDrives) Then Return ""
    Local $s = ""
    For $i = 1 To $aDrives[0]
        $s &= StringUpper($aDrives[$i]) & ";"
    Next
    Return $s
EndFunc

Func _DriveListNew($sOld, $sNew)
    Local $a = StringSplit($sNew, ";", 2)
    For $i = 0 To UBound($a) - 1
        If $a[$i] <> "" And Not StringInStr($sOld, $a[$i]) Then Return $a[$i]
    Next
    Return ""
EndFunc

Func _StartupVentoyDetect()
    Local $aDrives = DriveGetDrive("REMOVABLE")
    If Not IsArray($aDrives) Or $aDrives[0] = 0 Then
        _Status("Kein USB-Laufwerk erkannt. Führe lokalen Scan aus...")
        _Log("Startup: Kein Stick gefunden. Starte lokalen Scan & Versionsprüfung.")
        ; v2.27: Automatisch lokalen Scan triggern
        $g_bAutoScanPending = True 
        ; Versions-Check sofort erzwingen (Web-Update)
        _StartAutoVersionCheck()
        Return
    EndIf

    ; Alle WechseldatentrÃ¤ger auf Ventoy prÃ¼fen
    Local $sFoundDrives = ""
    Local $iFound = 0
    For $i = 1 To $aDrives[0]
        Local $dV = StringUpper($aDrives[$i])
        If _IsVentoyInstalled($dV) Then
            $sFoundDrives &= $dV & ";"
            $iFound += 1
        Else
            ; NEU: Falls kein Ventoy, Setup-Angebot triggern
            _OnUSBIn($dV)
        EndIf
    Next

    If $iFound = 0 Then
        _Status("Kein Ventoy-Stick erkannt. Bitte Stick einstecken und â†» klicken.")
        Return
    EndIf

    ; Erstes gefundenes Laufwerk vorauswÃ¤hlen
    Local $sVentoyDrive = StringLeft($sFoundDrives, 2)

    If $iFound > 1 Then
        ; Mehrere Ventoy-Sticks: Auswahl per InputBox
        Local $aOpts = StringSplit(StringTrimRight($sFoundDrives, 1), ";", 2)
        Local $sListTxt = ""
        For $k = 0 To UBound($aOpts) - 1
            If $aOpts[$k] = "" Then ContinueLoop
            $sListTxt &= "  " & $aOpts[$k] & "  " & DriveGetLabel($aOpts[$k]) & _
                         "  (" & Round(DriveSpaceTotal($aOpts[$k]) / 1024, 1) & " GB)" & @CRLF
        Next
        Local $sChoice = InputBox("Mehrere Ventoy-Sticks", _
            $iFound & " Ventoy-Sticks erkannt:" & @CRLF & @CRLF & _
            $sListTxt & @CRLF & "Laufwerk eingeben (z.B. E:):", $sVentoyDrive, "", 400, 280)
        If @error Or StringStripWS($sChoice, 3) = "" Then Return
        $sVentoyDrive = StringUpper(StringLeft(StringStripWS($sChoice, 3), 2))
        If StringRight($sVentoyDrive, 1) <> ":" Then $sVentoyDrive &= ":"
    EndIf

    ; FIX: Combo komplett neu aufbauen und Ventoy-Stick auswÃ¤hlen.
    ; GUICtrlSetData($combo, "", $default) lÃ¶scht in AutoIt alle EintrÃ¤ge â€”
    ; daher alle Laufwerke neu eintragen und dabei den Ventoy-Eintrag selektieren.
    Local $sGBV  = Round(DriveSpaceTotal($sVentoyDrive) / 1024, 1)
    Local $sLblV = DriveGetLabel($sVentoyDrive)
    Local $sEntryV = StringUpper($sVentoyDrive) & "  " & $sLblV & "  (" & $sGBV & " GB)"
    GUICtrlSetData($g_hDriveCombo, "")   ; Combo leeren
    Local $aDrivesRB = DriveGetDrive("REMOVABLE")
    If IsArray($aDrivesRB) And $aDrivesRB[0] > 0 Then
        For $rb = 1 To $aDrivesRB[0]
            Local $dRB      = StringUpper($aDrivesRB[$rb])
            Local $sGBRB    = Round(DriveSpaceTotal($dRB) / 1024, 1)
            Local $sEntryRB = $dRB & "  " & DriveGetLabel($dRB) & "  (" & $sGBRB & " GB)"
            If StringLeft($dRB, 2) = StringLeft($sVentoyDrive, 2) Then
                GUICtrlSetData($g_hDriveCombo, $sEntryRB, $sEntryRB)  ; hinzufÃ¼gen + auswÃ¤hlen
            Else
                GUICtrlSetData($g_hDriveCombo, $sEntryRB)              ; nur hinzufÃ¼gen
            EndIf
        Next
    EndIf

    _Log("=== v14.41 Startup: Ventoy-Stick erkannt: " & $sVentoyDrive & " [" & $sLblV & "] ===")
    _Status("âœ“ Ventoy-Stick: " & $sVentoyDrive & " [" & $sLblV & "] â€” Hintergrund-Scan lÃ¤uft ...")

    ; Hintergrund-Scan vormerken â€” lÃ¤uft im nÃ¤chsten GUIGetMsg-Durchlauf
    ; v2.27: Scan nach Neu-Installation Ã¼berspringen (Stick ist leer)
    $g_sAutoScanDrive   = $sVentoyDrive
    If Not $g_bIsPostInstall Then
        $g_bAutoScanPending = True
    Else
        _Log("  Startup: Scan Ã¼bersprungen da Post-Install (frischer Stick).")
    EndIf
EndFunc

Func _AutoStickScan()
    If $g_bBusy Then Return
    $g_bBusy   = True
    $g_bCancel = False

    Local $sCurl = _CurlPath()
    If $sCurl = "" Then
        $g_bBusy = False
        _Status("AutoScan: curl.exe nicht gefunden!")
        Return
    EndIf

    _Log("=== AutoStickScan gestartet (Stick: " & $g_sAutoScanDrive & ") ===")
    $g_sLastScannedDrive = $g_sAutoScanDrive
    _PopShow("Stick-Analyse", "Scanne Stick " & $g_sAutoScanDrive & " nach ISOs ...", True)
    GUICtrlSetData($g_hProgress, 0)

    If $g_sAutoScanDrive <> "" Then
        _AutoOrganizeRootISOs($g_sAutoScanDrive)
        _EnsureVentoyTheme($g_sAutoScanDrive, False)
    EndIf

    ; â”€â”€ Phase 0: USB-Stick scannen â€” ISOs auf Stick erkennen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    For $x = 0 To $ISO_COUNT - 1
        $g_aiUSBStatus[$x] = 3 ; Default: nicht auf Stick
        $g_asUSBSize[$x]   = ""
    Next

    Local $aUnknownISOs[0][3]
    Local $iUnknownCount = 0

    If $g_sAutoScanDrive <> "" Then
        Local $aRec = _FileListToArrayRec($g_sAutoScanDrive, "*.iso", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
        If Not @error And IsArray($aRec) And $aRec[0] > 0 Then
            _Log("  " & $aRec[0] & " ISOs gefunden. FÃ¼hre Matching durch...")
            For $j = 1 To $aRec[0]
                If $g_bCancel Then ExitLoop
                Local $sFP = $aRec[$j]
                Local $sISO = StringMid($sFP, StringInStr($sFP, "\", 0, -1) + 1)
                Local $iSz = FileGetSize($sFP)
                Local $bMatch = False

                ; Pass 1: Exakt
                For $i = 0 To $ISO_COUNT - 1
                    If StringLower($sISO) = StringLower($g_aISOs[$i][3]) Then
                        $g_aiUSBStatus[$i] = 1
                        $g_asUSBSize[$i] = _FmtBytes($iSz)
                        $bMatch = True
                        ExitLoop
                    EndIf
                Next

                ; Pass 2: Fuzzy
                If Not $bMatch Then
                    For $i = 0 To $ISO_COUNT - 1
                        Local $sBase = _ISOBaseName($g_aISOs[$i][3])
                        If $sBase <> "" And StringInStr(StringLower($sISO), $sBase) Then
                            $g_aiUSBStatus[$i] = 1
                            $g_asUSBSize[$i] = _FmtBytes($iSz)
                            $bMatch = True
                            ExitLoop
                        EndIf
                    Next
                EndIf
                If Not $bMatch Then
                    $iUnknownCount += 1
                    ReDim $aUnknownISOs[$iUnknownCount][3]
                    $aUnknownISOs[$iUnknownCount - 1][0] = $sISO
                    $aUnknownISOs[$iUnknownCount - 1][1] = _FmtBytes($iSz)
                    $aUnknownISOs[$iUnknownCount - 1][2] = $sFP
                EndIf
                
                _PopUpdate(($j / $aRec[0]) * 100, "Verarbeite " & $sISO, "Stick-Scan (" & $j & "/" & $aRec[0] & ")")
            Next
        EndIf

        If $iUnknownCount > 0 Then
            _PopClose()
            _ImportUnknownISOsToDB($aUnknownISOs, $iUnknownCount, $g_sAutoScanDrive)
            _PopShow("Stick-Analyse", "SchlieÃŸe Scan ab...", True)
        EndIf
    EndIf

    _PopUpdate(100, "Fertig!", "TreeView wird aktualisiert")
    Sleep(300)
    _PopClose()
    $g_bBusy = False

    _Log("=== AutoStickScan fertig (Schnell-Scan) ===")
    _FillTree()
    If $g_sAutoScanDrive <> "" And DriveStatus($g_sAutoScanDrive) = "READY" Then
        _EnsureVentoyTheme($g_sAutoScanDrive, False, True)
    EndIf
    _Status("✓ Stick-Analyse abgeschlossen (Schnell-Modus).")
    _OnCleanupBrokenDownloads(True)
EndFunc

Func _GetSelectedDrive()
    Local $s = GUICtrlRead($g_hDriveCombo)
    If $s = "" Or StringLeft($s, 2) = "--" Then Return ""
    Return StringLeft($s, 2)   ; z.B. "E:"
EndFunc

Func _OnUSBIn($sDrive)
    _HideTooltip()   ; 
    ; FIX: Ventoy-Erkennung VOR Format-Dialog prÃ¼fen
    ; Vorher: Dialog wurde IMMER gezeigt, auch wenn Ventoy schon installiert war
    If _IsVentoyInstalled($sDrive) Then
        _Log("=== USB eingesteckt: Ventoy bereits vorhanden auf " & $sDrive & " [" & DriveGetLabel($sDrive) & "] â€” kein Setup nÃ¶tig ===")
        _Status("âœ“ Ventoy-Stick erkannt: " & $sDrive & " [" & DriveGetLabel($sDrive) & "] â€” Hintergrund-Scan lÃ¤uft ...")
        ; Combo-Box hat $sDrive bereits via _FillDrives() bekommen â€” nur Scan anstoÃŸen
        $g_sAutoScanDrive   = $sDrive
        $g_bAutoScanPending = True
        ; Ausstehende Kopien (Download ohne Stick) anbieten
        ; Wird nach dem Scan in der Main-Loop aufgerufen (_CheckPendingCopies)
        ; â†’ $g_bPendingCopyOffered zurÃ¼cksetzen damit nach frischem Scan erneut angeboten wird
        If $g_iPendingCopyCount > 0 Then $g_bPendingCopyOffered = False
        Return
    EndIf

    ; Ventoy nicht vorhanden: Setup-Dialog anbieten
    ; MsgBox MUSS vor _PopShow aufgerufen werden (kein Popup offen)
    Local $ret = MsgBox(308, "USB-Stick erkannt: " & $sDrive, _
        "Neuer USB-Stick auf " & $sDrive & " gefunden!" & @CRLF & @CRLF & _
        "Automatisch einrichten?" & @CRLF & _
        "   1.  Formatierung  (ExFAT)" & @CRLF & _
        "   2.  Ventoy installieren" & @CRLF & @CRLF & _
        "!  Alle vorhandenen Daten werden gelÃ¶scht  !")
    If $ret <> 6 Then Return

    ; --- v2.26: Setup benÃ¶tigt Admin â€” Automatischer Neustart ---
    If Not IsAdmin() Then
        _Log("Setup angefordert fÃ¼r " & $sDrive & " (Admin-Rechte fehlen) â†’ Neustart geplant")
        IniWrite($SETTINGS_INI, "App", "PendingSetupDrive", $sDrive)
        IniWrite($SETTINGS_INI, "App", "WasElevated", "0")
        _RestartAsAdmin()
        Return
    EndIf

    _FullSetup($sDrive)
EndFunc

Func _OnFormat()
    _HideTooltip()   ; 
    If Not $g_bFormatRequested Then Return  ; Schutz: nur bei echtem Button-Klick
    Local $sDrive = _GetSelectedDrive()
    If $sDrive = "" Then
        MsgBox(48, "Hinweis", "Bitte zuerst ein Laufwerk auswÃ¤hlen!")
        Return
    EndIf
    If MsgBox(308, "Formatieren", _
        "Laufwerk " & $sDrive & " wird als ExFAT formatiert." & @CRLF & _
        "Alle Daten werden gelÃ¶scht!") <> 6 Then Return

    ; --- v2.26: diskpart benÃ¶tigt Admin â€” On-Demand Elevation ---
    If Not IsAdmin() Then
        Local $iFmtAsk = MsgBox(308, "Administratorrechte erforderlich", _
            "Das Formatieren von " & $sDrive & " erfordert Administratorrechte." & @CRLF & @CRLF & _
            "â–¶  Die App wird jetzt als Administrator neu gestartet." & @CRLF & _
            "â–¶  Nach dem Formatieren kehrt sie automatisch ohne" & @CRLF & _
            "    Administratorrechte zurÃ¼ck." & @CRLF & @CRLF & _
            "Fortfahren?")
        If $iFmtAsk = 6 Then
            ; FIX v2.27: Laufwerk als Pending-Aktion speichern BEVOR Elevation
            IniWrite($SETTINGS_INI, "App", "PendingFormatDrive", $sDrive)
            IniWrite($SETTINGS_INI, "App", "WasElevated", "0")
            _RestartAsAdmin()
        EndIf
        Return
    EndIf

    $g_bBusy = True
    _PopShow("Formatierung", $sDrive & "  wird als ExFAT formatiert ...", False)
    Local $bOK = _DoFormat($sDrive)
    If $bOK Then
        _PopUpdate(100, "Abgeschlossen.", "Formatierung OK")
        Sleep(800)
    EndIf
    _PopClose()
    $g_bBusy = False
    If $bOK Then
        _Status("OK: " & $sDrive & " = ExFAT")
    Else
        _Status("FEHLER: Formatierung fehlgeschlagen!")
    EndIf
    If Not $bOK Then MsgBox(16, "Fehler", "Formatierung fehlgeschlagen!" & @CRLF & _
        "PrÃ¼fe: Programm als Administrator? Laufwerk in Benutzung?")
EndFunc

Func _OnVentoy()
    _HideTooltip()   ; 
    Local $sDrive = _GetSelectedDrive()
    If $sDrive = "" Then
        MsgBox(48, "Hinweis", "Bitte zuerst ein Laufwerk auswÃ¤hlen!")
        Return
    EndIf
    If DriveStatus($sDrive) <> "READY" Then
        MsgBox(16, "Fehler", "Laufwerk " & $sDrive & " ist nicht bereit.")
        Return
    EndIf
    If DriveSpaceTotal($sDrive) < 2000 Then
        MsgBox(16, "Fehler", "Laufwerk " & $sDrive & " ist zu klein (mind. 2 GB erforderlich).")
        Return
    EndIf

    ; --- v2.26: Ventoy2Disk + diskpart benÃ¶tigen Admin â€” On-Demand Elevation ---
    If Not IsAdmin() Then
        Local $iAsk = MsgBox(308, "Administratorrechte erforderlich", _
            "Die Ventoy-Installation auf " & $sDrive & " erfordert Administratorrechte." & @CRLF & @CRLF & _
            "â–¶  Die App wird jetzt als Administrator neu gestartet." & @CRLF & _
            "â–¶  Nach der Installation kehrt sie automatisch ohne" & @CRLF & _
            "    Administratorrechte zurÃ¼ck." & @CRLF & @CRLF & _
            "Fortfahren?")
        If $iAsk = 6 Then
            ; FIX v2.27: Laufwerk als Pending-Aktion speichern BEVOR Elevation
            IniWrite($SETTINGS_INI, "App", "PendingVentoyDrive", $sDrive)
            IniWrite($SETTINGS_INI, "App", "WasElevated", "0")
            _RestartAsAdmin()
        EndIf
        Return
    EndIf

    If MsgBox(308, "Ventoy installieren", _
        "Ventoy wird auf " & $sDrive & " INSTALLIERT!" & @CRLF & _
        "Alle Daten auf " & $sDrive & " werden GELOESCHT!" & @CRLF & @CRLF & _
        "Ventoy wird automatisch von GitHub heruntergeladen." & @CRLF & @CRLF & _
        "Fortfahren?") <> 6 Then Return

    $g_bBusy   = True
    $g_bCancel = False
    _PopShow("Ventoy Installation", "Starte automatische Installation ...", True)
    _DoVentoyAutoInstall($sDrive, False)
    ; _DoVentoyAutoInstall schliesst das Popup SELBST â€” kein _PopClose() hier!
    $g_bBusy = False
EndFunc

Func _FullSetup($sDrive)
    $g_bBusy   = True
    $g_bCancel = False
    _PopShow("USB-Stick einrichten", $sDrive & " wird vollstaendig konfiguriert ...", True)

    ; Schritt 1: Formatieren
    _PopUpdate(0, "Starte Formatierung ...", "Schritt 1/2 - ExFAT Formatierung")
    Local $bFmt = _DoFormat($sDrive)
    If Not $bFmt Then
        _PopClose()
        $g_bBusy = False
        MsgBox(16, "Fehler", "Formatierung fehlgeschlagen!" & @CRLF & _
            "Laeuft das Programm als Administrator?")
        Return
    EndIf

    ; Schritt 2: Ventoy â€” Popup ist noch offen, _DoVentoyAutoInstall schliesst es
    _DoVentoyAutoInstall($sDrive, False)
    $g_bBusy = False
EndFunc

Func _IsVentoyInstalled($sDrive)
    ; Methode 1: Label enthaelt "ventoy" (VTOYCLI setzt Label)
    Local $sLabel = DriveGetLabel($sDrive)
    If StringInStr($sLabel, "ventoy", 2) Then
        _Log("Ventoy erkannt via Label: '" & $sLabel & "'")
        Return True
    EndIf

    ; Methode 2: Bekannte Ventoy-Ordner/-Dateien auf Partition 1
    If FileExists($sDrive & "\ventoy\")        Then Return True
    If FileExists($sDrive & "\EFI\BOOT\")      Then Return True
    If FileExists($sDrive & "\VTOYEFI\")       Then Return True
    If FileExists($sDrive & "\ventoy.disk.img") Then Return True

    ; Methode 3: VTOYCLI Metadaten-Datei (neuere Versionen)
    If FileExists($sDrive & "\.ventoy")        Then Return True

    ; Methode 4: ventoy.json (aeltere Versionen)
    If FileExists($sDrive & "\ventoy.json")    Then Return True

    _Log("Ventoy nicht erkannt auf " & $sDrive & " (Label='" & $sLabel & "')")
    Return False
EndFunc

Func _DoFormat($sDrive)
    Local $sLetter = StringLeft($sDrive, 1)  ; "E" aus "E:"
    _Log("Formatiere: " & $sDrive)
    _Status("Formatiere " & $sDrive & " ...")

    ; diskpart-Script schreiben
    Local $sScript = @TempDir & "\vlm_fmt.txt"
    Local $h = FileOpen($sScript, 2)
    If $h = -1 Then
        _Log("FEHLER: Kann diskpart-Script nicht erstellen!")
        Return False
    EndIf
    FileWriteLine($h, "select volume " & $sLetter)
    FileWriteLine($h, "format fs=exfat label=VENTOY quick override")
    FileClose($h)

    _PopUpdate(10, "diskpart /s wird ausgefuehrt ...", "Schritt 1/2 - Formatierung " & $sDrive)
    _Log("diskpart /s " & $sScript)

    ; v2.25-Technik: Run() + eigene Schleife -> kein sichtbares Fenster, UI bleibt reaktiv
    Local $iPID = Run('diskpart /s "' & $sScript & '"', "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)

    If $iPID = 0 Then
        _Log("FEHLER: diskpart nicht startbar (Admin-Rechte fehlen?)")
        FileDelete($sScript)
        Return False
    EndIf

    Local $iStep = 15, $sOut = ""
    While ProcessExists($iPID)
        $sOut &= StdoutRead($iPID)
        $sOut &= StderrRead($iPID)
        If $iStep < 88 Then $iStep += 5
        _PopUpdate($iStep, "diskpart laeuft ...", "Schritt 1/2 - Formatierung " & $sDrive)
        Sleep(400)
    WEnd
    $sOut &= StdoutRead($iPID)
    $sOut &= StderrRead($iPID)
    FileDelete($sScript)

    _Log("diskpart Output: " & StringStripWS(StringReplace($sOut, @CRLF, " "), 3))

    Sleep(1200)
    Local $sFS = DriveGetFileSystem($sDrive)
    Local $bOK = ($sFS = "exFAT") Or StringInStr($sOut, "Prozent") Or _
                 StringInStr($sOut, "percent") Or StringInStr($sOut, "complete") Or _
                 StringInStr($sOut, "erfolgreich")

    _Log("Dateisystem nach Format: '" & $sFS & "'  bOK=" & $bOK)
    _PopUpdate(45, "Dateisystem: " & $sFS, "Schritt 1/2 - Formatierung " & ($bOK ? "OK" : "Pruefen!"))
    Sleep(500)
    Return True
EndFunc

Func _DoVentoyAutoInstall($sDrive, $bUpdateMode = False)
    Local $sCurl = _CurlPath()

    ; === Schritt 1: Internet-Check ===
    _PopUpdate(5, "Prüfe Internetverbindung ...", "Schritt 1/4 — Netzwerk")
    _Log("Ping 8.8.8.8 ...")
    Local $iPing = Ping("8.8.8.8", 3000)
    If Not $iPing Then $iPing = Ping("1.1.1.1", 3000)
    If Not $iPing Then
        If MsgBox(52, "Warnung", _
            "Keine Internetverbindung erkannt." & @CRLF & _
            "Download wird wahrscheinlich fehlschlagen." & @CRLF & @CRLF & _
            "Trotzdem fortfahren?") <> 6 Then
            _PopClose()
            Return
        EndIf
    EndIf

    ; === Schritt 2: Ventoy herunterladen (3 Fallback-Methoden) ===
    _PopUpdate(10, "Lade Ventoy von GitHub ...", "Schritt 2/4 — Download")
    _Log("Ventoy Download nach: " & $VENTOY_ZIP)
    If FileExists($VENTOY_TMP_DIR) Then DirRemove($VENTOY_TMP_DIR, 1)
    DirCreate($VENTOY_TMP_DIR)

    Local $bVentoyOK = False

    ; --- Methode 1: GitHub API mit PowerShell ---
    _PopUpdate(12, "Methode 1/3: GitHub API ...", "Schritt 2/4 — Download")
    _Log("Download Methode 1: GitHub API (PowerShell)")
    Local $sPS1 = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "' & _
        '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ' & _
        'try { ' & _
        '  $rel = Invoke-RestMethod -Uri \"https://api.github.com/repos/ventoy/Ventoy/releases/latest\" -UserAgent \"Mozilla/5.0\"; ' & _
        '  $asset = $rel.assets | Where-Object { $_.name -like \"*windows.zip\" } | Select-Object -First 1; ' & _
        '  if (-not $asset) { exit 2 }; ' & _
        '  Invoke-WebRequest -Uri $asset.browser_download_url -OutFile \"' & $VENTOY_ZIP & '\" -UserAgent \"Mozilla/5.0\" -UseBasicParsing ' & _
        '} catch { exit 1 }"'
    Local $iExit1 = RunWait($sPS1, "", @SW_HIDE)
    If $iExit1 = 0 And FileExists($VENTOY_ZIP) And FileGetSize($VENTOY_ZIP) > 1000000 Then
        $bVentoyOK = True
        _Log("Download Methode 1 erfolgreich (" & _FmtBytes(FileGetSize($VENTOY_ZIP)) & ")")
    Else
        _Log("Download Methode 1 fehlgeschlagen (ExitCode=" & $iExit1 & ")")
    EndIf

    ; --- Methode 2: curl direkt (SourceForge Mirror) ---
    If Not $bVentoyOK And $sCurl <> "" Then
        _PopUpdate(16, "Methode 2/3: SourceForge Mirror ...", "Schritt 2/4 — Download")
        _Log("Download Methode 2: SourceForge via curl")
        Local $iExit2 = RunWait('"' & $sCurl & '" -L -s --max-time 120 ' & _
            '-o "' & $VENTOY_ZIP & '" ' & _
            '"https://sourceforge.net/projects/ventoy/files/latest/download"', _
            $VENTOY_TMP_DIR, @SW_HIDE)
        If $iExit2 = 0 And FileExists($VENTOY_ZIP) And FileGetSize($VENTOY_ZIP) > 1000000 Then
            $bVentoyOK = True
            _Log("Download Methode 2 erfolgreich (" & _FmtBytes(FileGetSize($VENTOY_ZIP)) & ")")
        Else
            _Log("Download Methode 2 fehlgeschlagen (ExitCode=" & $iExit2 & ")")
        EndIf
    EndIf

    ; --- Methode 3: BITS Transfer (PowerShell) ---
    If Not $bVentoyOK Then
        _PopUpdate(20, "Methode 3/3: BITS Transfer ...", "Schritt 2/4 — Download")
        _Log("Download Methode 3: BITS Transfer (PowerShell)")
        Local $sBITS = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "' & _
            '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ' & _
            'try { ' & _
            '  $rel = Invoke-RestMethod -Uri \"https://api.github.com/repos/ventoy/Ventoy/releases/latest\" -UserAgent \"Mozilla/5.0\"; ' & _
            '  $asset = $rel.assets | Where-Object { $_.name -like \"*windows.zip\" } | Select-Object -First 1; ' & _
            '  if ($asset) { Start-BitsTransfer -Source $asset.browser_download_url -Destination \"' & $VENTOY_ZIP & '\" } ' & _
            '} catch { exit 1 }"'
        Local $iExit3 = RunWait($sBITS, "", @SW_HIDE)
        If $iExit3 = 0 And FileExists($VENTOY_ZIP) And FileGetSize($VENTOY_ZIP) > 1000000 Then
            $bVentoyOK = True
            _Log("Download Methode 3 erfolgreich (" & _FmtBytes(FileGetSize($VENTOY_ZIP)) & ")")
        Else
            _Log("Download Methode 3 fehlgeschlagen (ExitCode=" & $iExit3 & ")")
        EndIf
    EndIf

    If Not $bVentoyOK Then
        _PopUpdate(0, "Alle 3 Download-Methoden fehlgeschlagen.", "Schritt 2/4 — FEHLER")
        _Log("FEHLER: Ventoy konnte nicht heruntergeladen werden!")
        _PopClose()
        MsgBox(16, "Download-Fehler", _
            "Ventoy konnte nicht heruntergeladen werden:" & @CRLF & @CRLF & _
            "1. GitHub API (PowerShell) — Fehlgeschlagen" & @CRLF & _
            "2. SourceForge Mirror (curl) — Fehlgeschlagen" & @CRLF & _
            "3. BITS Transfer (PowerShell) — Fehlgeschlagen" & @CRLF & @CRLF & _
            "─────────────────────────────────────────────" & @CRLF & _
            "Antivirus / Sicherheitssoftware blockiert den Download?" & @CRLF & @CRLF & _
            "Hinweis: Eine Firewall-Freigabe allein reicht oft nicht aus!" & @CRLF & _
            "Ursache: Der Web-Schutz (HTTPS-Scanning / SSL-Inspection) fängt" & @CRLF & _
            "         die verschlüsselte Verbindung von curl.exe ab." & @CRLF & @CRLF & _
            "Lösung:" & @CRLF & _
            "  Antivirus  →  Web-Schutz / HTTP-Scanner  →  HTTPS-Scanning  →  Aus" & @CRLF & _
            "  ODER: Web-Schutz für die Dauer des Downloads temporär deaktivieren" & @CRLF & _
            "─────────────────────────────────────────────")
        Return
    EndIf

    ; --- Entpacken ---
    _PopUpdate(25, "Entpacke Ventoy ...", "Schritt 2/4 — Entpacken")
    _Log("Entpacke: " & $VENTOY_ZIP & " -> " & $VENTOY_TMP_DIR)
    Local $sPSUnzip = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "' & _
        'Expand-Archive -Path \"' & $VENTOY_ZIP & '\" -DestinationPath \"' & $VENTOY_TMP_DIR & '\" -Force"'
    RunWait($sPSUnzip, "", @SW_HIDE)
    Sleep(500) 

    ; --- Ventoy2Disk.exe finden ---
    Local $aFiles = _FileListToArrayRec($VENTOY_TMP_DIR, "Ventoy2Disk.exe", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
    If @error Or $aFiles[0] < 1 Then
        _PopUpdate(0, "Fehler: Ventoy2Disk.exe nicht gefunden!", "Schritt 2/4 — FEHLER")
        _Log("FEHLER: Ventoy2Disk.exe nicht im Archiv gefunden!")
        _PopClose()
        MsgBox(16, "Fehler", "Ventoy2Disk.exe wurde im Download nicht gefunden." & @CRLF & _
            "Das Archiv ist möglicherweise beschädigt.")
        Return
    EndIf
    Local $sVentoyExe = $aFiles[1]
    Local $sWorkDir = StringLeft($sVentoyExe, StringInStr($sVentoyExe, "\", 0, -1))
    _Log("Ventoy2Disk.exe: " & $sVentoyExe)
    _PopUpdate(30, "Ventoy heruntergeladen und entpackt.", "Schritt 2/4 — OK")

    ; === Schritt 3: Ventoy auf USB installieren ===
    Local $sAction
    If $bUpdateMode Then
        $sAction = "Aktualisiere"
    Else
        $sAction = "Installiere"
    EndIf
    Local $sFlag
    If $bUpdateMode Then
        $sFlag = " VTOYCLI /U"
    Else
        $sFlag = " VTOYCLI /I"
    EndIf
    _PopUpdate(35, $sAction & " Ventoy auf " & $sDrive & " ...", "Schritt 3/4 — Installation")
    _Log($sAction & " Ventoy auf " & $sDrive & " mit Flag: " & $sFlag)

    Local $sArgs = $sFlag & ' /Drive:' & $sDrive & ' /FS:exFAT /YES'
    Local $iResult = RunWait('"' & $sVentoyExe & '"' & $sArgs, $sWorkDir, @SW_HIDE)
    _Log("Ventoy2Disk ExitCode: " & $iResult)

    If $iResult <> 0 Then
        _PopUpdate(0, "Installation fehlgeschlagen (Code: " & $iResult & ")", "Schritt 3/4 — FEHLER")
        _PopClose()
        MsgBox(16, "Fehler", _
            "Ventoy-Installation fehlgeschlagen!" & @CRLF & _
            "Exit-Code: " & $iResult & @CRLF & @CRLF & _
            "Mögliche Ursachen:" & @CRLF & _
            "• USB-Stick wird von anderem Programm verwendet" & @CRLF & _
            "• Schreibschutz aktiv" & @CRLF & _
            "• Administrator-Rechte fehlen")
        Return
    EndIf
    _PopUpdate(50, "Ventoy installiert. Warte auf Laufwerk ...", "Schritt 3/4 — OK")

    ; === Schritt 4: Warten bis Laufwerk gemountet ===
    _PopUpdate(55, "Warte auf Laufwerk-Bereitschaft ...", "Schritt 4/4 — Mount")
    Local $iRetry = 0
    While DriveStatus($sDrive) <> "READY" And $iRetry < 30
        Sleep(1000)
        $iRetry += 1
        _PopUpdate(55 + Int($iRetry / 2), "Mount-Versuch " & $iRetry & "/30 ...", "Schritt 4/4 — Warten")
    WEnd

    If DriveStatus($sDrive) <> "READY" Then
        _PopClose()
        MsgBox(48, "Warnung", _
            "Laufwerk " & $sDrive & " wird nach der Installation nicht erkannt." & @CRLF & _
            "Bitte den USB-Stick kurz ab- und wieder anstecken.")
        Return
    EndIf

    ; === Aufräumen ===
    DirRemove($VENTOY_TMP_DIR, 1)

    ; === Fertig: Ventoy ===
    _PopUpdate(90, "✓ Ventoy installiert — richte Boot-Thema ein ...", "Schritt 4/4 — Theme")
    _Log("Ventoy Installation abgeschlossen. Laufwerk: " & $sDrive)

    ; Boot-Thema automatisch einrichten (im laufenden Popup sichtbar)
    _EnsureVentoyTheme($sDrive, True)

    _PopUpdate(100, "[OK] Ventoy + Boot-Thema erfolgreich eingerichtet!", "Fertig")
    _Status("Fertig: " & $sDrive & " mit Ventoy bereit.")
    Sleep(800)

    _PopClose()
    MsgBox(64, "Erfolg ✓", _
        "Ventoy-Stick erfolgreich erstellt!" & @CRLF & @CRLF & _
        "Laufwerk: " & $sDrive & @CRLF & _
        "Modus: ExFAT" & @CRLF & @CRLF & _
        "✓ Boot-Thema (USB-Stick Design) eingerichtet." & @CRLF & _
        "  Beim Booten sind die Kategorien als Ordner-Menü sichtbar." & @CRLF & @CRLF & _
        "ISO-Dateien einfach auf den Stick kopieren." & @CRLF & @CRLF & _
        "ℹ  Die App wird jetzt ohne Administratorrechte neu gestartet.")

    ; v2.26: Admin-Flag löschen → nächste Instanz startet normal ohne Rechte
    IniDelete($SETTINGS_INI, "App", "WasElevated")
    ; v2.27: Post-Install Flag setzen für Skip Intro & Scan
    IniWrite($SETTINGS_INI, "App", "PostInstall", "1")
    _Log("  Installation beendet. Warte auf System (Handle-Release)...")
    Sleep(1500) 
    _RestartAsUser()
EndFunc

Func _AddToPendingCopyQueue($iIdx)
    ; PrÃ¼fen ob ISO bereits in der Queue ist (kein Duplikat)
    For $__qi = 0 To $g_iPendingCopyCount - 1
        If $g_aiPendingCopyQueue[$__qi] = $iIdx Then Return   ; bereits vorhanden
    Next
    If $g_iPendingCopyCount >= $ISO_MAX Then Return   ; Schutz gegen Ãœberlauf
    $g_aiPendingCopyQueue[$g_iPendingCopyCount] = $iIdx
    $g_iPendingCopyCount += 1
    $g_bPendingCopyOffered = False   ; neuer Eintrag â†’ Angebot zurÃ¼cksetzen
    _Log("  PendingCopy: ISO #" & $iIdx & " (" & $g_aISOs[$iIdx][0] & ") in Queue aufgenommen (" & $g_iPendingCopyCount & " gesamt)")
EndFunc

Func _ClearPendingCopyQueue()
    $g_iPendingCopyCount  = 0
    $g_bPendingCopyOffered = False
    _Log("  PendingCopy: Queue geleert.")
EndFunc

Func _CheckPendingCopies($sDrive)
    _HideTooltip()   ; 
    If $g_iPendingCopyCount = 0 Then Return
    If $sDrive = "" Then Return
    If $g_bBusy Then Return

    ; Schritt 1: Welche ISOs liegen lokal vor?
    ; Spalten: [0]=ISO-Index  [1]=lokaler Pfad  [2]=Ziel auf Stick  [3]=1 wenn bereits auf Stick
    Local $aRealQueue[$g_iPendingCopyCount][4]
    Local $iRealCount = 0
    Local $iAlreadyOn = 0
    Local $sListNew   = ""
    Local $sListExist = ""

    For $i = 0 To $g_iPendingCopyCount - 1
        Local $iIdx      = $g_aiPendingCopyQueue[$i]
        Local $sFilename = $g_aISOs[$iIdx][3]
        Local $sCat      = $g_aISOs[$iIdx][1]

        ; Lokale Quelldatei suchen (TMP zuerst, dann finaler Download-Ordner)
        Local $sLocalPath = ""
        If FileExists($TMP_DOWNLOAD_DIR & "\" & $sFilename) Then
            $sLocalPath = $TMP_DOWNLOAD_DIR & "\" & $sFilename
        ElseIf FileExists($DOWNLOAD_DIR & "\" & $sFilename) Then
            $sLocalPath = $DOWNLOAD_DIR & "\" & $sFilename
        EndIf
        If $sLocalPath = "" Then ContinueLoop   ; lokal nicht mehr vorhanden

        Local $sStickDest = $sDrive & "\" & $sCat & "\" & $sFilename
        Local $bOnStick   = FileExists($sStickDest)

        $aRealQueue[$iRealCount][0] = $iIdx
        $aRealQueue[$iRealCount][1] = $sLocalPath
        $aRealQueue[$iRealCount][2] = $sStickDest
        $aRealQueue[$iRealCount][3] = $bOnStick
        $iRealCount += 1

        If $bOnStick Then
            $iAlreadyOn += 1
            $sListExist &= "  [!] " & $g_aISOs[$iIdx][0] & " (bereits auf Stick)" & @CRLF
        Else
            $sListNew &= "  [+] " & $g_aISOs[$iIdx][0] & @CRLF
        EndIf
    Next

    If $iRealCount = 0 Then
        _ClearPendingCopyQueue()
        Return
    EndIf

    If $g_bPendingCopyOffered Then Return
    $g_bPendingCopyOffered = True

    _Log("  PendingCopy: Stick " & $sDrive & ", " & $iRealCount & " ISO(s) bereit (" & $iAlreadyOn & " bereits vorhanden)")

    ; Schritt 2: Haupt-Dialog
    Local $sBody = "Es wurden " & $iRealCount & " ISO(s) ohne Stick heruntergeladen." & @CRLF & @CRLF
    If $sListNew   <> "" Then $sBody &= "Neu auf Stick kopieren:" & @CRLF & $sListNew
    If $sListExist <> "" Then $sBody &= @CRLF & "Bereits auf Stick vorhanden:" & @CRLF & $sListExist
    $sBody &= @CRLF & _
        "  JA      - Auf " & $sDrive & " kopieren + lokal loeschen" & @CRLF & _
        "  NEIN    - Spaeter (Angebot beim naechsten Scan erneut)" & @CRLF & _
        "  ABBRUCH - Queue leeren (kein Kopieren)"

    Local $iChoice = MsgBox(292, "ISOs auf Stick kopieren?", $sBody)
    Select
        Case $iChoice = 7   ; NEIN
            $g_bPendingCopyOffered = False
            _Log("  PendingCopy: Nutzer spaeter.")
            Return
        Case $iChoice <> 6  ; ABBRUCH oder X
            _ClearPendingCopyQueue()
            _Log("  PendingCopy: Queue geleert.")
            Return
    EndSelect

    ; Schritt 3: Strategie fuer bereits vorhandene ISOs
    Local $iOverwriteMode = 0   ; 1=ueberschreiben  2=ueberspringen+lokal loeschen  3=ueberspringen+behalten
    If $iAlreadyOn > 0 Then
        Local $sExistMsg = "Folgende ISO(s) sind bereits auf " & $sDrive & ":" & @CRLF & @CRLF & _
            $sListExist & @CRLF & _
            "Was soll passieren?" & @CRLF & @CRLF & _
            "  JA      - Ueberschreiben (neue Kopie, lokal loeschen)" & @CRLF & _
            "  NEIN    - Ueberspringen + lokale Datei loeschen" & @CRLF & _
            "  ABBRUCH - Ueberspringen + lokale Datei behalten"
        Local $iEC = MsgBox(291, "ISO bereits vorhanden", $sExistMsg)
        Select
            Case $iEC = 6  ; JA
                $iOverwriteMode = 1
            Case $iEC = 7  ; NEIN
                $iOverwriteMode = 2
            Case Else       ; ABBRUCH
                $iOverwriteMode = 3
        EndSelect
    EndIf

    ; Schritt 4: Kopierschleife
    $g_bBusy   = True
    $g_bCancel = False
    _PopShow("Kopiere auf Stick", $iRealCount & " ISO(s) -> " & $sDrive, True)
    Local $iCopied  = 0
    Local $iFailed  = 0
    Local $iSkipped = 0
    Local $iDeleted = 0

    For $i = 0 To $iRealCount - 1
        If $g_bCancel Then ExitLoop

        Local $iIdx2      = $aRealQueue[$i][0]
        Local $sLocalSrc  = $aRealQueue[$i][1]
        Local $sStickFile = $aRealQueue[$i][2]
        Local $bExistsOn  = $aRealQueue[$i][3]

        If $bExistsOn Then
            Select
                Case $iOverwriteMode = 1   ; Ueberschreiben
                    _PopUpdate(0, "Ueberschreibe: " & $g_aISOs[$iIdx2][0], ($i+1) & " / " & $iRealCount)
                    FileDelete($sStickFile)
                    If _CopyOneISOToStick($iIdx2, $sDrive, True) Then
                        $iCopied += 1
                        $iDeleted += 1
                    Else
                        $iFailed += 1
                    EndIf
                Case $iOverwriteMode = 2   ; Ueberspringen + lokal loeschen
                    FileDelete($sLocalSrc)
                    $iSkipped += 1
                    $iDeleted += 1
                    _Log("  PendingCopy: Skip+Delete: " & $g_aISOs[$iIdx2][0])
                Case Else                  ; Ueberspringen + behalten
                    $iSkipped += 1
                    _Log("  PendingCopy: Skip+Keep: " & $g_aISOs[$iIdx2][0])
            EndSelect
        Else
            ; Neu â€” kopieren und lokal loeschen
            _PopUpdate(0, "Kopiere: " & $g_aISOs[$iIdx2][0], ($i+1) & " / " & $iRealCount)
            If _CopyOneISOToStick($iIdx2, $sDrive, True) Then
                $iCopied += 1
                $iDeleted += 1
            Else
                $iFailed += 1
            EndIf
        EndIf
    Next
    
    ; v2.27: Theme erst NACH Abschluss aller KopierVorgaenge aktualisieren
    If $iCopied > 0 Then _EnsureVentoyTheme($sDrive, False)

    _PopClose()
    $g_bBusy = False
    _ClearPendingCopyQueue()
    _FillTree()

    ; Schritt 5: Ergebnis
    Local $sResult = ""
    If $iCopied  > 0 Then $sResult &= "Kopiert:          " & $iCopied  & " ISO(s)" & @CRLF
    If $iSkipped > 0 Then $sResult &= "Uebersprungen:    " & $iSkipped & " ISO(s)" & @CRLF
    If $iDeleted > 0 Then $sResult &= "Lokal geloescht:  " & $iDeleted & " ISO(s)" & @CRLF
    If $iFailed  > 0 Then $sResult &= "Kopierfehler:     " & $iFailed  & " ISO(s)" & @CRLF

    _Status($iCopied & " kopiert, " & $iSkipped & " uebersprungen, " & $iDeleted & " lokal geloescht.")
    If $iFailed = 0 Then
        MsgBox(64, "Abgeschlossen", $sResult)
    Else
        MsgBox(48, "Teilweise fertig", $sResult & @CRLF & "Fehlgeschlagene ISOs erneut versuchen.")
    EndIf
EndFunc

Func _OnCopyToUSB()
    _HideTooltip()   ; 
    If $g_bBusy Then Return

    ; === Laufwerk prÃ¼fen ===
    Local $sDrive = _GetSelectedDrive()
    If $sDrive = "" Then
        MsgBox(48, "Hinweis", "Bitte zuerst ein USB-Laufwerk in der Combo-Box auswÃ¤hlen!")
        Return
    EndIf
    If DriveStatus($sDrive) <> "READY" Then
        MsgBox(16, "Fehler", "Laufwerk " & $sDrive & " ist nicht erreichbar." & @CRLF & _
            "Bitte Stick prÃ¼fen und Laufwerks-Liste aktualisieren.")
        Return
    EndIf

    ; === ISOs ermitteln: angekreuzt ODER vorhanden (alle heruntergeladenen) ===
    Local $hTV = GUICtrlGetHandle($g_hTreeView)
    Local $aQueue[$ISO_COUNT]
    Local $iCount = 0

    ; Erst angekreuzte prÃ¼fen
    For $i = 0 To $ISO_COUNT - 1
        If $g_ahNodes[$i] <> 0 Then
            If _GUICtrlTreeView_GetChecked($hTV, $g_ahNodes[$i]) Then
                Local $sF = $DOWNLOAD_DIR & "\" & $g_aISOs[$i][3]
                Local $sFtmp = $TMP_DOWNLOAD_DIR & "\" & $g_aISOs[$i][3]   ; 
                ; TMP bevorzugen, dann normaler Ordner
                If FileExists($sFtmp) And FileGetSize($sFtmp) > 1048576 Then
                    $aQueue[$iCount] = $i
                    $iCount += 1
                ElseIf FileExists($sF) And FileGetSize($sF) > 1048576 Then
                    $aQueue[$iCount] = $i
                    $iCount += 1
                EndIf
            EndIf
        EndIf
    Next

    If $iCount = 0 Then
        ; Keine angekreuzten â†’ alle vorhandenen anbieten
        Local $iAvail = 0
        For $i = 0 To $ISO_COUNT - 1
            If FileExists($DOWNLOAD_DIR & "\" & $g_aISOs[$i][3]) Then $iAvail += 1
        Next
        If $iAvail = 0 Then
            MsgBox(48, "Hinweis", "Es wurden noch keine ISOs heruntergeladen." & @CRLF & _
                "Bitte zuerst ISOs ankreuzen und 'â¬‡ Herunterladen' klicken.")
            Return
        EndIf
        If MsgBox(308, "Alle vorhandenen ISOs kopieren?", _
            "Keine ISOs angekreuzt." & @CRLF & @CRLF & _
            "Sollen alle " & $iAvail & " bereits heruntergeladenen ISOs" & @CRLF & _
            "auf " & $sDrive & " kopiert werden?") <> 6 Then Return
        For $i = 0 To $ISO_COUNT - 1
            If FileExists($DOWNLOAD_DIR & "\" & $g_aISOs[$i][3]) And _
               FileGetSize($DOWNLOAD_DIR & "\" & $g_aISOs[$i][3]) > 1048576 Then
                $aQueue[$iCount] = $i
                $iCount += 1
            EndIf
        Next
    EndIf

    If $iCount = 0 Then
        MsgBox(48, "Hinweis", "Keine heruntergeladenen ISOs fÃ¼r die Auswahl gefunden.")
        Return
    EndIf

    ; === Ventoy-PrÃ¼fung ===
    If Not _IsVentoyInstalled($sDrive) Then
        If MsgBox(308, "Ventoy nicht erkannt", _
            "Auf " & $sDrive & " wurde kein Ventoy erkannt." & @CRLF & @CRLF & _
            "Label: '" & DriveGetLabel($sDrive) & "'" & @CRLF & @CRLF & _
            "Trotzdem kopieren? (ISOs werden in das Stammverzeichnis kopiert)" & @CRLF & _
            "Tipp: Zuerst 'Ventoy installieren' klicken.") <> 6 Then Return
    EndIf

    ; === Speicherplatz prÃ¼fen ===
    Local $iFreeUSB  = DriveSpaceFree($sDrive) * 1048576
    Local $iTotalISO = 0
    For $j = 0 To $iCount - 1
        Local $sF2 = $DOWNLOAD_DIR & "\" & $g_aISOs[$aQueue[$j]][3]
        If FileExists($sF2) Then $iTotalISO += FileGetSize($sF2)
    Next
    If $iTotalISO > $iFreeUSB Then
        If MsgBox(308, "Wenig Speicher", _
            "BenÃ¶tigt: " & _FmtBytes($iTotalISO) & @CRLF & _
            "Frei auf " & $sDrive & ": " & _FmtBytes($iFreeUSB) & @CRLF & @CRLF & _
            "Trotzdem kopieren?") <> 6 Then Return
    EndIf

    ; === Kopieren starten ===
    _CopyISOsToUSB($aQueue, $iCount, $sDrive)
EndFunc

Func _OnCopyAllTmpToUSB()
    If $g_bBusy Then Return

    ; === Laufwerk prÃ¼fen ===
    Local $sDrive = _GetSelectedDrive()
    If $sDrive = "" Then
        MsgBox(48, "Hinweis", "Bitte zuerst ein USB-Laufwerk in der Combo-Box auswÃ¤hlen!")
        Return
    EndIf
    If DriveStatus($sDrive) <> "READY" Then
        MsgBox(16, "Fehler", "Laufwerk " & $sDrive & " ist nicht erreichbar.")
        Return
    EndIf

    ; === TMP-Verzeichnis auf ISOs scannen ===
    If Not FileExists($TMP_DOWNLOAD_DIR) Then
        MsgBox(48, "Hinweis", "TMP-Verzeichnis nicht gefunden:" & @CRLF & $TMP_DOWNLOAD_DIR & @CRLF & @CRLF & _
            "Bitte zuerst ISOs herunterladen.")
        Return
    EndIf

    Local $hSearch = FileFindFirstFile($TMP_DOWNLOAD_DIR & "\*.iso")
    Local $aFoundISOs[0]
    Local $iFoundCount = 0
    If $hSearch <> -1 Then
        While True
            Local $sF = FileFindNextFile($hSearch)
            If @error Then ExitLoop
            Local $sFullPath = $TMP_DOWNLOAD_DIR & "\" & $sF
            If FileGetSize($sFullPath) > 1048576 Then
                ReDim $aFoundISOs[$iFoundCount + 1]
                $aFoundISOs[$iFoundCount] = $sF
                $iFoundCount += 1
            EndIf
        WEnd
        FileClose($hSearch)
    EndIf

    If $iFoundCount = 0 Then
        MsgBox(48, "Hinweis", "Keine ISO-Dateien im TMP-Verzeichnis gefunden:" & @CRLF & _
            $TMP_DOWNLOAD_DIR & @CRLF & @CRLF & _
            "Bitte zuerst ISOs mit 'â¬‡ Herunterladen' laden.")
        Return
    EndIf

    ; Liste der gefundenen ISOs anzeigen
    Local $sList = ""
    Local $iTotalTMPSize = 0
    For $k = 0 To $iFoundCount - 1
        Local $iSz = FileGetSize($TMP_DOWNLOAD_DIR & "\" & $aFoundISOs[$k])
        $iTotalTMPSize += $iSz
        $sList &= "  â€¢ " & $aFoundISOs[$k] & "  (" & _FmtBytes($iSz) & ")" & @CRLF
    Next

    ; Ventoy-PrÃ¼fung
    If Not _IsVentoyInstalled($sDrive) Then
        If MsgBox(308, "Ventoy nicht erkannt", _
            "Auf " & $sDrive & " wurde kein Ventoy erkannt." & @CRLF & @CRLF & _
            "Trotzdem kopieren? (ISOs ins Stammverzeichnis)") <> 6 Then Return
    EndIf

    ; Speicherplatz prÃ¼fen
    Local $iFreeUSB = DriveSpaceFree($sDrive) * 1048576
    If $iTotalTMPSize > $iFreeUSB Then
        If MsgBox(308, "Wenig Speicher", _
            "BenÃ¶tigt: " & _FmtBytes($iTotalTMPSize) & @CRLF & _
            "Frei auf " & $sDrive & ": " & _FmtBytes($iFreeUSB) & @CRLF & @CRLF & _
            "Trotzdem versuchen?") <> 6 Then Return
    EndIf

    ; BestÃ¤tigung + LÃ¶sch-Abfrage
    Local $iChoice = MsgBox(291, "Alle TMP-ISOs auf Stick kopieren?", _
        $iFoundCount & " ISO(s) aus TMP auf " & $sDrive & " kopieren:" & @CRLF & @CRLF & _
        $sList & @CRLF & _
        "Gesamt: " & _FmtBytes($iTotalTMPSize) & @CRLF & @CRLF & _
        "  JA      â€” Kopieren + TMP-Dateien danach lÃ¶schen" & @CRLF & _
        "  NEIN    â€” Kopieren + TMP-Dateien behalten" & @CRLF & _
        "  ABBRUCH â€” Nicht kopieren")
    If $iChoice = 2 Then Return   ; Abbruch
    Local $bDeleteTMP = ($iChoice = 6)

    ; === Kopiervorgang ===
    $g_bBusy   = True
    $g_bCancel = False
    _PopShow("Alle TMP-ISOs â†’ Stick", $iFoundCount & " ISO(s) â†’ " & $sDrive, True)
    GUICtrlSetData($g_hProgress, 0)
    _Log("=== Kopiere alle TMP-ISOs auf " & $sDrive & " ===")
    _Log("TMP-Verzeichnis: " & $TMP_DOWNLOAD_DIR)

    Local $iCopied = 0, $iFailed = 0, $iDeleted = 0
    Local $iGlobalDone = 0

    For $k = 0 To $iFoundCount - 1
        If $g_bCancel Then ExitLoop

        Local $sSrc  = $TMP_DOWNLOAD_DIR & "\" & $aFoundISOs[$k]
        ; Kategorie fÃ¼r diese ISO ermitteln und Unterordner anlegen
        Local $sCatName = ""
        For $iCatLookup = 0 To $ISO_COUNT - 1
            If StringLower($g_aISOs[$iCatLookup][3]) = StringLower($aFoundISOs[$k]) Then
                $sCatName = $g_aISOs[$iCatLookup][1]
                ExitLoop
            EndIf
        Next
        Local $sDestBase = $sDrive
        If $sCatName <> "" Then
            $sDestBase = $sDrive & "\" & $sCatName
            If Not FileExists($sDestBase) Then DirCreate($sDestBase)
        EndIf
        Local $sDest = $sDestBase & "\" & $aFoundISOs[$k]
        Local $iFileSize = FileGetSize($sSrc)

        _Log("Kopiere: " & $aFoundISOs[$k] & "  (" & _FmtBytes($iFileSize) & ")")
        _Log("  Von:  " & $sSrc)
        _Log("  Nach: " & $sDest)
        _Status("Kopiere " & ($k+1) & "/" & $iFoundCount & ": " & $aFoundISOs[$k])

        ; Bereits vorhanden mit gleicher GrÃ¶ÃŸe?
        If FileExists($sDest) And FileGetSize($sDest) = $iFileSize Then
            _Log("  Bereits vorhanden (gleiche GrÃ¶ÃŸe) â€” Ã¼bersprungen")
            _PopUpdate(Int(($iGlobalDone + $iFileSize) / $iTotalTMPSize * 100), _
                "âœ“ Bereits vorhanden: " & $aFoundISOs[$k], "ISO " & ($k+1) & "/" & $iFoundCount)
            $iGlobalDone += $iFileSize
            $iCopied += 1
            If $bDeleteTMP Then
                FileDelete($sSrc)
                If Not FileExists($sSrc) Then $iDeleted += 1
            EndIf
            ContinueLoop
        EndIf

        ; ================================================================
        ;  robocopy /J â€” Unbuffered I/O fÃ¼r maximale Stick-Geschwindigkeit
        ;  /J        = unbuffered I/O (umgeht Windows Cache â†’ volle USB-BW)
        ;  /NDL      = kein Dir-Listing (ohne /NFL â†’ % bleibt im Stdout)
        ;  /NJH /NJS = kein Job-Header/Summary
        ;  /R:1 /W:1 = max. 1 Wiederholung, 1 s Wartezeit
        ;  Fortschritt: robocopy % per StdoutRead lesen
        ; ================================================================
        Local $sTRoboArgs = '/J /NJH /NJS /NDL /R:1 /W:1 "' & _
            $TMP_DOWNLOAD_DIR & '" "' & $sDestBase & '" "' & $aFoundISOs[$k] & '"'
        Local $iTCPID     = Run("robocopy " & $sTRoboArgs, "", @SW_HIDE, $STDERR_MERGED)
        Local $tStart     = TimerInit()
        Local $tSpeedTick = TimerInit()
        Local $iSpeedBase = 0, $sLastSpeed = "", $sLastETA = ""

        If $iTCPID = 0 Then
            ; Fallback: chunk-basierte Kopie mit 16 MB-BlÃ¶cken
            _Log("  FEHLER: robocopy nicht startbar â€” Fallback 16 MB-Chunk-Kopie")
            Local $iChunkSize = 16 * 1024 * 1024
            Local $hSrc = FileOpen($sSrc,  16)
            Local $hDst = FileOpen($sDest, 18)
            If $hSrc = -1 Or $hDst = -1 Then
                If $hSrc <> -1 Then FileClose($hSrc)
                If $hDst <> -1 Then FileClose($hDst)
                $iFailed += 1
                ContinueLoop
            EndIf
            Local $iWritten = 0
            While $iWritten < $iFileSize And Not $g_bCancel
                Local $oChunk = FileRead($hSrc, $iChunkSize)
                If @error Or BinaryLen($oChunk) = 0 Then ExitLoop
                FileWrite($hDst, $oChunk)
                $iWritten += BinaryLen($oChunk)
                Local $iFilePct = Int($iWritten / $iFileSize * 100)
                If $iFilePct > 99 Then $iFilePct = 99
                Local $iGlobPct = Int(($iGlobalDone + $iWritten) / $iTotalTMPSize * 100)
                If $iGlobPct > 99 Then $iGlobPct = 99
                If TimerDiff($tSpeedTick) >= 1000 Then
                    Local $iDelta = $iWritten - $iSpeedBase
                    Local $iBps   = $iDelta / (TimerDiff($tSpeedTick) / 1000)
                    $iSpeedBase = $iWritten 
$tSpeedTick = TimerInit()
                    If $iBps > 0 Then
                        $sLastSpeed = _FmtBytes($iBps) & "/s"
                        $sLastETA   = "  ETA " & _FmtTime(($iFileSize - $iWritten) / $iBps)
                    EndIf
                EndIf
                Local $sDetail = _FmtBytes($iWritten) & " / " & _FmtBytes($iFileSize)
                If $sLastSpeed <> "" Then $sDetail &= "     " & $sLastSpeed & $sLastETA
                _PopUpdate($iGlobPct, $sDetail, "ISO " & ($k+1) & "/" & $iFoundCount & ": " & $aFoundISOs[$k] & "  " & $iFilePct & "%")
                GUICtrlSetData($g_hProgress, $iGlobPct)
                GUICtrlSetData($g_hSpeedLbl, $sLastSpeed)
                Local $ev = GUIGetMsg()
                If $ev = $GUI_EVENT_CLOSE Then _Quit()
                If $ev = $g_hBtnCancel    Then $g_bCancel = True
                If $g_hPopCancel <> 0 And $ev = $g_hPopCancel Then $g_bCancel = True
            WEnd
            FileClose($hSrc)
            FileClose($hDst)
            If $g_bCancel Then
                FileDelete($sDest)
                _Log("  Abgebrochen â€” Zieldatei gelÃ¶scht.")
                ExitLoop
            EndIf
        Else
            ; robocopy /J lÃ¤uft â€” Fortschritt per StdoutRead + % Regex
            Local $iNowSize = 0, $iFilePct = 0
            While ProcessExists($iTCPID) And Not $g_bCancel
                Local $sTOut = StdoutRead($iTCPID)
                If $sTOut <> "" Then
                    Local $aTMatch = StringRegExp($sTOut, "(\d+(?:\.\d+)?)\s*%", 3)
                    If IsArray($aTMatch) And UBound($aTMatch) > 0 Then
                        $iFilePct = Int($aTMatch[UBound($aTMatch)-1])
                    EndIf
                EndIf
                If $iFilePct > 99 Then $iFilePct = 99
                $iNowSize = ($iFileSize * $iFilePct) / 100
                Local $iGlobPct = Int(($iGlobalDone + $iNowSize) / $iTotalTMPSize * 100)
                If $iGlobPct > 99 Then $iGlobPct = 99
                If TimerDiff($tSpeedTick) >= 1000 Then
                    Local $iDelta = $iNowSize - $iSpeedBase
                    Local $iBps   = $iDelta / (TimerDiff($tSpeedTick) / 1000)
                    $iSpeedBase = $iNowSize 
$tSpeedTick = TimerInit()
                    If $iBps > 0 Then
                        $sLastSpeed = _FmtBytes($iBps) & "/s"
                        $sLastETA   = "  ETA " & _FmtTime(($iFileSize - $iNowSize) / $iBps)
                    EndIf
                EndIf
                Local $sDetail = "â†’ Stick: " & _FmtBytes($iNowSize) & " / " & _FmtBytes($iFileSize)
                If $sLastSpeed <> "" Then $sDetail &= "     " & $sLastSpeed & $sLastETA
                _PopUpdate($iGlobPct, $sDetail, "ISO " & ($k+1) & "/" & $iFoundCount & ": " & $aFoundISOs[$k] & "  " & $iFilePct & "%")
                GUICtrlSetData($g_hProgress, $iGlobPct)
                GUICtrlSetData($g_hSpeedLbl, $sLastSpeed)
                Local $ev = GUIGetMsg()
                If $ev = $GUI_EVENT_CLOSE Then _Quit()
                If $ev = $g_hBtnCancel    Then $g_bCancel = True
                If $g_hPopCancel <> 0 And $ev = $g_hPopCancel Then $g_bCancel = True
                Sleep(400)
            WEnd
            If $g_bCancel Then
                If ProcessExists($iTCPID) Then
                    ProcessClose($iTCPID)
                    Sleep(500)
                EndIf
                FileDelete($sDest)
                _Log("  Abgebrochen â€” Zieldatei gelÃ¶scht.")
                ExitLoop
            EndIf
        EndIf

        ; ErfolgsprÃ¼fung
        Local $iFinalSize
        If FileExists($sDest) Then
            $iFinalSize = FileGetSize($sDest)
        Else
            $iFinalSize = 0
        EndIf

        If $iFinalSize >= Int($iFileSize * 0.995) Then
            $iCopied += 1
            $iGlobalDone += $iFileSize
            Local $iElapsed = TimerDiff($tStart) / 1000
            Local $sAvgSpd = ""
            If $iElapsed > 0 Then $sAvgSpd = "  Ã˜ " & _FmtBytes($iFileSize / $iElapsed) & "/s"
            _Log("  âœ“ OK: " & $aFoundISOs[$k] & "  " & _FmtBytes($iFinalSize) & $sAvgSpd)

            If $bDeleteTMP Then
                FileDelete($sSrc)
                If Not FileExists($sSrc) Then
                    $iDeleted += 1
                    _Log("  ðŸ—‘ TMP-Datei gelÃ¶scht: " & $sSrc)
                EndIf
            EndIf

            Local $iDonePct = Int($iGlobalDone / $iTotalTMPSize * 100)
            _PopUpdate($iDonePct, "âœ“ " & $aFoundISOs[$k] & "  " & _FmtBytes($iFinalSize) & $sAvgSpd, _
                "ISO " & ($k+1) & "/" & $iFoundCount & " â€” fertig")
            Sleep(300)
        Else
            $iFailed += 1
            _Log("  âœ— FEHLER: " & $aFoundISOs[$k] & " â€” " & _FmtBytes($iFinalSize) & "/" & _FmtBytes($iFileSize))
            Sleep(1000)
        EndIf
    Next

    GUICtrlSetData($g_hSpeedLbl, "")
    GUICtrlSetData($g_hEtaLbl, "")
    _PopUpdate(100, $iCopied & " kopiert" & ($iFailed > 0 ? ", " & $iFailed & " Fehler" : ""), "Fertig")
    Sleep(600)
    _PopClose()
    $g_bBusy = False
    _FillTree()

    Local $sResult = $iCopied & " von " & $iFoundCount & " TMP-ISO(s) auf " & $sDrive & " kopiert."
    If $bDeleteTMP Then $sResult &= @CRLF & $iDeleted & " TMP-Dateien gelÃ¶scht."
    If $iFailed > 0 Then $sResult &= @CRLF & $iFailed & " Fehler (Protokoll-Tab)."
    _Status($sResult)
    _Log($sResult)
    _Log("=== TMP â†’ Stick abgeschlossen ===")

    ; /v14.45: background.png aktualisieren + Ergebnis merken
    Local $bThemeUpdatedT = False
    If $iCopied > 0 Then
        _EnsureVentoyTheme($sDrive, False)
        Local $sThemeDirT = $sDrive & "\ventoy\themes\usb-stick"
        If FileExists($sThemeDirT) Then
            _Log("  v14.45: background.png aktualisieren nach _OnCopyAllTmpToUSB (" & $iCopied & " kopiert)")
            _CreateThemeBackground($sThemeDirT, $sDrive)
            $bThemeUpdatedT = True
        EndIf
    EndIf

    Local $sThemeLineT = $bThemeUpdatedT ? "âœ“ Boot-Bild (background.png) aktualisiert." : ""

    If $iFailed = 0 Then
        ; â€” TMP-Verzeichnis nach erfolgreicher Kopie komplett leeren
        If FileExists($TMP_DOWNLOAD_DIR) Then
            DirRemove($TMP_DOWNLOAD_DIR, 1)
            DirCreate($TMP_DOWNLOAD_DIR)
            $sResult &= @CRLF & "TMP-Ordner bereinigt."
            _Log("ðŸ—‘ TMP-Verzeichnis nach Kopie geleert: " & $TMP_DOWNLOAD_DIR)
        EndIf
        MsgBox(64, "Fertig âœ“", _
            $sResult & @CRLF & _
            ($sThemeLineT <> "" ? $sThemeLineT : ""))
    Else
        MsgBox(48, "Teilweise fertig", _
            $sResult & @CRLF & _
            ($sThemeLineT <> "" ? $sThemeLineT : ""))
    EndIf
EndFunc

Func _EnsureVentoyTheme($sDrive, $bUsePopup = False, $bForceRebuild = False)
    ; --- Basis-Checks mit Logging ---
    If $sDrive = "" Then
        _Log("  Boot-Thema: kein Laufwerk übergeben — übersprungen.")
        Return
    EndIf
    If DriveStatus($sDrive) <> "READY" Then
        _Log("  Boot-Thema: Laufwerk " & $sDrive & " nicht bereit (" & DriveStatus($sDrive) & ") — übersprungen.")
        Return
    EndIf

    ; ventoy-Ordner anlegen wenn er fehlt (z.B. bei frisch formatiertem Stick ohne Ventoy-App-Installation)
    Local $sVentoyDir = $sDrive & "\ventoy"
    If Not FileExists($sVentoyDir) Then
        _Log("  Boot-Thema: " & $sVentoyDir & " fehlt — lege an.")
        DirCreate($sVentoyDir)
        If @error Or Not FileExists($sVentoyDir) Then
            _Log("  Boot-Thema FEHLER: ventoy-Ordner konnte nicht erstellt werden: " & $sVentoyDir)
            Return
        EndIf
    EndIf

    Local $sThemeDir = $sDrive & "\ventoy\themes\usb-stick"
    Local $sThemeTxt = $sThemeDir & "\theme.txt"

    ; Version prüfen — Theme nur überspringen wenn aktuelle Version bereits installiert
    ; Ältere Versionen (v2.3, v2.4, ..., v2.18) werden automatisch auf v2.19 aktualisiert
    If FileExists($sThemeTxt) Then
        Local $hThemeCheck = FileOpen($sThemeTxt, 0)
        Local $sThemeContent = ""
        If $hThemeCheck <> -1 Then
            $sThemeContent = FileRead($hThemeCheck, 200)   ; nur Anfang lesen für Versions-Check
            FileClose($hThemeCheck)
        EndIf
        If StringInStr($sThemeContent, "v2.19") Then
            _Log("  Boot-Thema v2.19 bereits aktuell — übersprungen.")
            ; ventoy.json trotzdem immer aktualisieren (Kategorie-Navigation)
            _UpdateVentoyJson($sDrive)
            If $bForceRebuild Then
                _Log("  Boot-Thema: Erzwinge Hintergrundbild-Regenerierung (Datenbank/Freispeicher aktualisiert)")
                _CreateThemeBackground($sThemeDir, $sDrive)
            EndIf
            Return
        EndIf
        _Log("  Boot-Thema veraltet (kein v2.19-Tag) — wird auf v2.19 aktualisiert.")
    EndIf

    _Log("=== Boot-Thema automatisch installieren auf " & $sDrive & " ===")
    If $bUsePopup Then _PopUpdate(0, "ðŸŽ¨  Boot-Thema wird eingerichtet ...", "USB-Stick Design")

    ; --- Ordner Schritt fÃ¼r Schritt anlegen ---
    ; Schritt 1: ventoy\themes
    Local $sThemesDir = $sDrive & "\ventoy\themes"
    If Not FileExists($sThemesDir) Then
        DirCreate($sThemesDir)
        If @error Or Not FileExists($sThemesDir) Then
            _Log("  Boot-Thema FEHLER: Ordner konnte nicht erstellt werden: " & $sThemesDir & "  (@error=" & @error & ")")
            Return
        EndIf
        _Log("  Ordner erstellt: " & $sThemesDir)
    EndIf

    ; Schritt 2: ventoy\themes\usb-stick
    If Not FileExists($sThemeDir) Then
        DirCreate($sThemeDir)
        If @error Or Not FileExists($sThemeDir) Then
            _Log("  Boot-Thema FEHLER: Ordner konnte nicht erstellt werden: " & $sThemeDir & "  (@error=" & @error & ")")
            Return
        EndIf
        _Log("  Ordner erstellt: " & $sThemeDir)
    EndIf

    ; --- Dateien schreiben ---
    _WriteVentoyThemeTxt($sThemeDir)
    _CreateThemeBackground($sThemeDir, $sDrive)   ; Redesign â€” flat BG, opake Panels, Akzentstreifen, weiÃŸ/blau
    _UpdateVentoyJson($sDrive)

    ; Ergebnis prÃ¼fen
    If FileExists($sThemeTxt) Then
        _Log("  [OK] Boot-Thema installiert: " & $sThemeDir)
        _Status("[OK] Boot-Thema eingerichtet - beim Booten sind Ordner-Kategorien sichtbar")
    Else
        _Log("  Boot-Thema WARNUNG: theme.txt wurde nicht gefunden nach Schreiben: " & $sThemeTxt)
    EndIf
EndFunc

Func _WriteVentoyThemeTxt($sDir)
    Local $sTheme = '# =============================================================' & @LF
    $sTheme &= '# Universal ISO Manager USB-Stick Boot-Theme v2.25' & @LF
    $sTheme &= '# Nur ASCII + sichere Unifont-Groessen (10/12/14/16/18)' & @LF
    $sTheme &= '# =============================================================' & @LF & @LF
    
    $sTheme &= '# --- Hintergrund & Basis-Schrift ---' & @LF
    $sTheme &= 'desktop-image: "background.png"' & @LF
    $sTheme &= 'desktop-color: "#0D1B2A"' & @LF
    $sTheme &= 'title-text: ""' & @LF
    $sTheme &= 'terminal-font: "Unifont Regular 16"' & @LF
    $sTheme &= 'terminal-left: "0"' & @LF
    $sTheme &= 'terminal-top: "0"' & @LF
    $sTheme &= 'terminal-width: "100%"' & @LF
    $sTheme &= 'terminal-height: "100%"' & @LF & @LF
    
    $sTheme &= '# --- Haupttitel ---' & @LF
    $sTheme &= '+ label {' & @LF
    $sTheme &= '  top = 2%' & @LF
    $sTheme &= '  left = 0%' & @LF
    $sTheme &= '  width = 100%' & @LF
    $sTheme &= '  height = 48' & @LF
    $sTheme &= '  align = "center"' & @LF
    $sTheme &= '  text = "UNIVERSAL  LINUX  MANAGER"' & @LF
    $sTheme &= '  font = "Unifont Regular 18"' & @LF
    $sTheme &= '  color = "#FFFFFF"' & @LF
    $sTheme &= '}' & @LF & @LF
    
    $sTheme &= '# --- Anweisung ---' & @LF
    $sTheme &= '+ label {' & @LF
    $sTheme &= '  top = 9%' & @LF
    $sTheme &= '  left = 0%' & @LF
    $sTheme &= '  width = 100%' & @LF
    $sTheme &= '  height = 28' & @LF
    $sTheme &= '  align = "center"' & @LF
    $sTheme &= '  text = "Kategorie waehlen  >>  ENTER  >>  Distribution waehlen  >>  ENTER zum Booten"' & @LF
    $sTheme &= '  font = "Unifont Regular 16"' & @LF
    $sTheme &= '  color = "#2196F3"' & @LF
    $sTheme &= '}' & @LF & @LF
    
    $sTheme &= '# --- Haupt-Boot-Menu ---' & @LF
    $sTheme &= '+ boot_menu {' & @LF
    $sTheme &= '  left = 15%' & @LF
    $sTheme &= '  top = 22%' & @LF
    $sTheme &= '  width = 70%' & @LF
    $sTheme &= '  height = 65%' & @LF
    $sTheme &= '  item_font = "Unifont Regular 16"' & @LF
    $sTheme &= '  item_color = "#C8D4E0"' & @LF
    $sTheme &= '  selected_item_color = "#FFFFFF"' & @LF
    $sTheme &= '  item_height = 40' & @LF
    $sTheme &= '  item_padding = 14' & @LF
    $sTheme &= '  item_icon_space = 28' & @LF
    $sTheme &= '  item_spacing = 8' & @LF
    $sTheme &= '  menu_color_normal = "#8BA3BE"' & @LF
    $sTheme &= '  menu_color_highlight = "#F1C40F"' & @LF
    $sTheme &= '  scrollbar = true' & @LF
    $sTheme &= '  scrollbar_width = 8' & @LF
    $sTheme &= '}' & @LF & @LF
    
    $sTheme &= '# --- Fusszeile ---' & @LF
    $sTheme &= '+ label {' & @LF
    $sTheme &= '  top = 91%' & @LF
    $sTheme &= '  left = 0%' & @LF
    $sTheme &= '  width = 100%' & @LF
    $sTheme &= '  height = 22' & @LF
    $sTheme &= '  align = "center"' & @LF
    $sTheme &= '  text = "Auf/Ab: Auswahl     ENTER: Booten     Tab: Kategorie navigieren"' & @LF
    $sTheme &= '  font = "Unifont Regular 14"' & @LF
    $sTheme &= '  color = "#4A6FA5"' & @LF
    $sTheme &= '}' & @LF

    Local $hFile = FileOpen($sDir & "\theme.txt", 2)  ; 2 = Ã¼berschreiben
    If $hFile = -1 Then
        _Log("FEHLER: Konnte theme.txt nicht schreiben: " & $sDir)
        Return
    EndIf
    FileWrite($hFile, $sTheme)
    FileClose($hFile)
    _Log("  theme.txt geschrieben: " & $sDir & "\theme.txt")
EndFunc

Func _UpdateVentoyJson($sDrive)
    Local $sJsonPath = $sDrive & "\ventoy\ventoy.json"
    Local $sExisting = ""
    If FileExists($sJsonPath) Then
        Local $hR = FileOpen($sJsonPath, 0)
        If $hR <> -1 Then
            $sExisting = FileRead($hR)
            FileClose($hR)
        EndIf
    EndIf

    ; Theme-Block als JSON-String (nur gültige ventoy.json-Schlüssel: file + gfxmode)
    Local $sThemeBlock = _
        '    "theme": {' & @LF & _
        '        "file": "/ventoy/themes/usb-stick/theme.txt",' & @LF & _
        '        "gfxmode": "1920x1080,1280x720,auto"' & @LF & _
        '    }'

    ; Control-Block: einzelnes Objekt mit Schlüssel-Wert-Paaren (korrektes Ventoy-Format)
    Local $sFolderBlock = _
        '    "control": [' & @LF & _
        '        { "VTOY_MENU_TIMEOUT": "0" },' & @LF & _
        '        { "VTOY_SECONDARY_BOOT_MENU": "0" },' & @LF & _
        '        { "VTOY_DEFAULT_MENU_MODE": "1" },' & @LF & _
        '        { "VTOY_TREE_VIEW_MENU_STYLE": "1" },' & @LF & _
        '        { "VTOY_LOCALBOOT_MENU": "1" }' & @LF & _
        '    ]'

    ; --- v2.27: MemBoot-Block --- ISO-Pfaden sammeln (inkl. Kategorie-Ordner)
    Local $sMemBootBlock = ""
    Local $aMemBootFiles[0]
    Local $iMemBootCount = 0
    For $__mb = 0 To $ISO_COUNT - 1
        If $g_abMemBoot[$__mb] And $g_aISOs[$__mb][3] <> "" Then
            ReDim $aMemBootFiles[$iMemBootCount + 1]
            ; Ventoy-Pfad: /Kategorie/Dateiname.iso (Standard-Organisationsstruktur des Managers)
            Local $sCat = $g_aISOs[$__mb][1]
            If $sCat <> "" Then
                $aMemBootFiles[$iMemBootCount] = $sCat & "/" & $g_aISOs[$__mb][3]
            Else
                $aMemBootFiles[$iMemBootCount] = $g_aISOs[$__mb][3]
            EndIf
            $iMemBootCount += 1
        EndIf
    Next
    If $iMemBootCount > 0 Then
        $sMemBootBlock = '    "auto_memdisk": [' & @LF
        For $__mb = 0 To $iMemBootCount - 1
            Local $sFullVPath = "/" & StringReplace($aMemBootFiles[$__mb], "\", "/")
            Local $__mbComma = ($__mb < $iMemBootCount - 1) ? "," : ""
            $sMemBootBlock &= '        "' & $sFullVPath & '"' & $__mbComma & @LF
        Next
        $sMemBootBlock &= '    ]'
    EndIf

    ; Wenn bereits JSON vorhanden: Theme-Sektion ersetzen oder einfügen
    If $sExisting <> "" Then
        ; Bestehenden "theme"-Block entfernen (einfaches Regex-Replace)
        Local $sNew = StringRegExpReplace($sExisting, '(?s)"theme"\s*:\s*\{[^}]*\}\s*,?\s*', "")
        ; Bestehenden "control"-Block entfernen (unterstützt altes Array- und neues Objekt-Format)
        $sNew = StringRegExpReplace($sNew, '(?s)"control"\s*:\s*(?:\[[^\]]*\]|\{[^}]*\})\s*,?\s*', "")
        ; Bestehenden "auto_memdisk"-Block entfernen
        $sNew = StringRegExpReplace($sNew, '(?s)"auto_memdisk"\s*:\s*\[[^\]]*\]\s*,?\s*', "")
        ; Letzte } entfernen um neuen Inhalt einzufügen
        Local $iLast = StringInStr($sNew, "}", 0, -1)
        If $iLast > 0 Then
            Local $sHead = StringLeft($sNew, $iLast - 1)
            $sHead = StringStripWS($sHead, 2)
            ; Trailing-Komma sichern
            If StringRight($sHead, 1) <> "{" And StringRight($sHead, 1) <> "," Then
                $sHead &= ","
            EndIf
            If $sMemBootBlock <> "" Then
                $sNew = $sHead & @LF & $sThemeBlock & "," & @LF & $sFolderBlock & "," & @LF & $sMemBootBlock & @LF & "}"
            Else
                $sNew = $sHead & @LF & $sThemeBlock & "," & @LF & $sFolderBlock & @LF & "}"
            EndIf
        Else
            ; Fallback: komplett neu
            $sExisting = ""
        EndIf
        If $sExisting <> "" Then
            _WriteJsonFile($sJsonPath, $sNew)
            If $iMemBootCount > 0 Then
                _Log("  ventoy.json aktualisiert (Theme + MemBoot fÃ¼r " & $iMemBootCount & " ISO(s))")
            Else
                _Log("  ventoy.json aktualisiert (Theme-Sektion eingefÃ¼gt/ersetzt)")
            EndIf
            Return
        EndIf
    EndIf

    ; Neu erstellen
    Local $sJson
    If $sMemBootBlock <> "" Then
        $sJson = _
            "{" & @LF & _
            $sThemeBlock & "," & @LF & _
            $sFolderBlock & "," & @LF & _
            $sMemBootBlock & @LF & _
            "}" & @LF
    Else
        $sJson = _
            "{" & @LF & _
            $sThemeBlock & "," & @LF & _
            $sFolderBlock & @LF & _
            "}" & @LF
    EndIf
    _WriteJsonFile($sJsonPath, $sJson)
    If $iMemBootCount > 0 Then
        _Log("  ventoy.json neu erstellt: " & $sJsonPath & " (MemBoot: " & $iMemBootCount & " ISO(s))")
    Else
        _Log("  ventoy.json neu erstellt: " & $sJsonPath)
    EndIf
EndFunc

Func _AutoOrganizeRootISOs($sDrive)
    If $sDrive = "" Then Return False

    ; Alle ISOs im Root finden (nicht rekursiv fÃ¼r die Suche nach Kandidaten)
    Local $aRoot = _FileListToArray($sDrive, "*.iso", 1)
    If @error Or Not IsArray($aRoot) Or $aRoot[0] = 0 Then Return False

    Local $aToMove[$aRoot[0]][2] ; [0]=SourcePath, [1]=DestPath
    Local $iToMoveCount = 0

    _Log("  [AutoOrganize] PrÃ¼fe Hauptverzeichnis auf unorganisierte ISOs ...")

    For $i = 1 To $aRoot[0]
        Local $sFN = $aRoot[$i]
        Local $sFP = $sDrive & "\" & $sFN

        ; Kategorie bestimmen
        Local $sCat = ""
        ; 1. DB-Treffer suchen
        For $j = 0 To $ISO_COUNT - 1
            If StringLower($sFN) = StringLower($g_aISOs[$j][3]) Then
                $sCat = $g_aISOs[$j][1]
                ExitLoop
            EndIf
        Next
        ; 2. Falls nicht in DB (Fuzzy/Guess)
        If $sCat = "" Then $sCat = _GuessISOCategory($sFN)

        If $sCat <> "" Then
            Local $sDestFolder = $sDrive & "\" & $sCat
            Local $sDestPath   = $sDestFolder & "\" & $sFN

            If Not FileExists($sDestPath) Then
                $aToMove[$iToMoveCount][0] = $sFP
                $aToMove[$iToMoveCount][1] = $sDestPath
                $iToMoveCount += 1
                _Log("    [Root-ISO] Gefunden: " & $sFN & " -> Ziel: " & $sCat)
            EndIf
        EndIf
    Next

    If $iToMoveCount = 0 Then Return False

    ; Benutzer fragen
    Local $sMsg = "Es wurden " & $iToMoveCount & " ISO-Datei(en) direkt im Hauptverzeichnis von " & $sDrive & " gefunden." & @CRLF & @CRLF & _
                  "MÃ¶chtest du, dass der Manager diese automatisch in die passenden Kategorie-Ordner verschiebt?" & @CRLF & @CRLF
    Local $iMaxShow = $iToMoveCount > 8 ? 8 : $iToMoveCount
    For $m = 0 To $iMaxShow - 1
        Local $sFNm = StringMid($aToMove[$m][0], StringInStr($aToMove[$m][0], "\", 0, -1) + 1)
        Local $sDestCat = StringRegExpReplace($aToMove[$m][1], ".*\\([^\\]+)\\[^\\]+$", "$1")
        $sMsg &= "  â€¢ " & $sFNm & "  â†’  \" & $sDestCat & "\" & @CRLF
    Next
    If $iToMoveCount > 8 Then $sMsg &= "  ... und " & ($iToMoveCount - 8) & " weitere." & @CRLF

    If MsgBox(36, "Stick aufrÃ¤umen?", $sMsg) = 6 Then ; 6 = Yes
        _PopShow("Stick aufrÃ¤umen", "Verschiebe ISOs in Kategorien ...", False)
        Local $iSuccess = 0
        For $m = 0 To $iToMoveCount - 1
            Local $sSrc = $aToMove[$m][0]
            Local $sDst = $aToMove[$m][1]
            Local $sDstDir = StringLeft($sDst, StringInStr($sDst, "\", 0, -1))

            If Not FileExists($sDstDir) Then DirCreate($sDstDir)

            _Log("    Verschiebe: " & $sSrc & " -> " & $sDst)
            If FileMove($sSrc, $sDst, $FC_OVERWRITE + $FC_CREATEPATH) Then
                $iSuccess += 1
            EndIf
        Next
        _PopClose()
        If $iSuccess > 0 Then
            MsgBox(64, "Fertig", $iSuccess & " Datei(en) wurden erfolgreich verschoben.")
            Return True ; Re-Scan nÃ¶tig
        EndIf
    EndIf

    Return False
EndFunc

Func _ScanCheckWithWindow()
    Local $sCurl = _CurlPath()

    ; ── Fenster aufbauen ────────────────────────────────────────────────────
    Local $iW = 480, $iH = 360
    Local $hW = GUICreate("Scan-Check — Universal ISO Manager", $iW, $iH, -1, -1, _
        BitOR($WS_CAPTION, $WS_SYSMENU), $WS_EX_DROPSHADOW, $g_hMain)
    GUISetBkColor(0xFFFFFF, $hW)
    GUISetFont(9, 400, 0, "Segoe UI", $hW)

    ; Blauer Akzentstreifen
    GUICtrlCreateLabel("", 0, 0, $iW, 5)
    GUICtrlSetBkColor(-1, $C_BLUE)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; Icon-Box
    GUICtrlCreateLabel("", 18, 16, 46, 46)
    GUICtrlSetBkColor(-1, $C_LBLU)
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUICtrlCreateLabel("VL", 24, 25, 34, 26)
    GUICtrlSetFont(-1, 13, 800, 0, "Segoe UI Black")
    GUICtrlSetColor(-1, $C_BLUE)
    GUICtrlSetBkColor(-1, $C_LBLU)

    ; Titel + Untertitel
    GUICtrlCreateLabel("Scan-Check", 74, 14, $iW - 94, 22)
    GUICtrlSetFont(-1, 12, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    Local $hSub = GUICtrlCreateLabel("Schritt 1/2: Verbindung wird getestet ...", 74, 38, $iW - 94, 16)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    GUICtrlCreateLabel("", 18, 68, $iW - 36, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; Live-Geschwindigkeitszähler (groß, zentriert)
    Local $hSpeed = GUICtrlCreateLabel("-- Mbit/s", 0, 80, $iW, 52)
    GUICtrlSetFont(-1, 30, 800, 0, "Segoe UI Black")
    GUICtrlSetColor(-1, $C_BLUE)
    GUICtrlSetBkColor(-1, 0xFFFFFF)
    GUICtrlSetStyle(-1, $SS_CENTER)

    ; Fortschrittsbalken (zeigt Zeit-Fortschritt 0–6s)
    Local $iBarX = 18, $iBarY = 142, $iBarW = $iW - 36, $iBarH = 14
    GUICtrlCreateLabel("", $iBarX, $iBarY, $iBarW, $iBarH)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)
    Local $hFill = GUICtrlCreateLabel("", $iBarX, $iBarY, 2, $iBarH)
    GUICtrlSetBkColor(-1, $C_BLUE)

    ; Status-Text unterhalb der Bar
    Local $hStatus = GUICtrlCreateLabel("Lade Testdaten ...", 18, 162, $iW - 36, 16)
    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    GUICtrlCreateLabel("", 18, 184, $iW - 36, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; Info-Text
    Local $hInfo = GUICtrlCreateLabel( _
        "Misst die Downloadgeschwindigkeit zu deutschen Spiegelservern." & @LF & _
        "Ergebnis bestimmt die empfohlene Anzahl paralleler Downloads.", _
        18, 190, $iW - 36, 32)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    GUICtrlCreateLabel("", 18, 228, $iW - 36, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── Antivirus/Firewall-Hinweis ──────────────────────────────────────────
    ; Hintergrundbox (Bernstein)
    GUICtrlCreateLabel("", 18, 236, $iW - 36, 62)
    GUICtrlSetBkColor(-1, 0xFFF8E6)
    GUICtrlSetState(-1, $GUI_DISABLE)
    ; Linke Akzentlinie
    GUICtrlCreateLabel("", 18, 236, 3, 62)
    GUICtrlSetBkColor(-1, 0xE6A800)
    GUICtrlSetState(-1, $GUI_DISABLE)
    ; Titel-Zeile
    GUICtrlCreateLabel("⚠  Antivirus blockiert den Download?", 28, 241, $iW - 50, 14)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0xA06000)
    GUICtrlSetBkColor(-1, 0xFFF8E6)
    ; Erklärtext
    GUICtrlCreateLabel( _
        "Nicht die Firewall — das HTTPS-Scanning / SSL-Inspection ist das Problem." & @LF & _
        "Lösung:  Antivirus  →  Web-Schutz / HTTP-Scanner  →  HTTPS-Scanning  →  deaktivieren" & @LF & _
        "oder temporär den Web-Schutz für die Dauer des Downloads ausschalten.", _
        28, 257, $iW - 48, 38)
    GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0x7A4A00)
    GUICtrlSetBkColor(-1, 0xFFF8E6)

    GUICtrlCreateLabel("", 18, 304, $iW - 36, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; Ueberspringen-Button
    Local $hBtnSkip = GUICtrlCreateButton("  Ueberspringen", $iW - 148, 316, 130, 28)
    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetColor(-1, $C_MID)

    GUISetState(@SW_SHOW, $hW)

    ; ── Hilfsfunktion: eine Messung durchführen und Fenster animieren ────────
    Local $iBytes = 0, $iElapsed = 0
    Local $bSkipped = False

    For $iRunde = 1 To 2   ; Runde 1 = Primär, Runde 2 = Fallback
        Local $sURL = ""
        If $iRunde = 1 Then
            $sURL = "https://ftp.fau.de/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.3.0-amd64-xfce.iso"
            GUICtrlSetData($hSub, "Teste Primär-Mirror: ftp.fau.de ...")
        Else
            $sURL = "https://ftp.halifax.rwth-aachen.de/ubuntu-releases/24.04/ubuntu-24.04.4-desktop-amd64.iso"
            GUICtrlSetData($hSub, "Primär fehlgeschlagen — teste Fallback-Mirror ...")
            GUICtrlSetColor($hSpeed, $C_AMB)
        EndIf

        If $sCurl = "" Then
            $bSkipped = True
            ExitLoop
        EndIf

        FileDelete($g_sSpeedTestFile)
        Local $sArgs = '-s -L --max-time 6 --connect-timeout 8 ' & _
                       '--ssl-no-revoke ' & _
                       '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                       '-o "' & $g_sSpeedTestFile & '" "' & $sURL & '"'
        Local $iPID = Run('"' & $sCurl & '" ' & $sArgs, "", @SW_HIDE)
        If $iPID = 0 Then
            $bSkipped = True
            ExitLoop
        EndIf

        _Log("Speedtest Runde " & $iRunde & " gestartet (PID " & $iPID & "): " & $sURL)
        Local $tStart = TimerInit()
        Local $iMaxMs = 7500   ; etwas mehr als max-time für sicheres Beenden

        While ProcessExists($iPID)
            Local $iMs    = TimerDiff($tStart)
            Local $iPct   = Int($iMs / $iMaxMs * 100)
            If $iPct > 99 Then $iPct = 99

            ; Balken animieren
            Local $iFillW = Int(($iW - 36) * $iPct / 100)
            If $iFillW < 2 Then $iFillW = 2
            ControlMove($hW, "", GUICtrlGetHandle($hFill), 18, 142, $iFillW, 14)

            ; Live-Geschwindigkeitszähler (groß, zentriert)
            Local $iNow = 0
            If FileExists($g_sSpeedTestFile) Then $iNow = FileGetSize($g_sSpeedTestFile)
            Local $fSec = $iMs / 1000
            If $fSec > 0.3 And $iNow > 0 Then
                Local $fLive = ($iNow * 8) / ($fSec * 1000000)
                GUICtrlSetData($hSpeed, Int($fLive) & " Mbit/s")
                GUICtrlSetData($hStatus, _FmtBytes($iNow) & " empfangen  |  " & Round($fSec, 1) & "s  |  " & Round($fSec / 6 * 100, 0) & "% der Messzeit")
            Else
                GUICtrlSetData($hStatus, "Verbinde ...")
            EndIf

            ; Events
            Local $ev = GUIGetMsg()
            If $ev = $GUI_EVENT_CLOSE Then
                ProcessClose($iPID)
                GUIDelete($hW)
                _Quit()
            EndIf
            If $ev = $hBtnSkip Or $ev = $GUI_EVENT_CLOSE Then
                ProcessClose($iPID)
                $bSkipped = True
                ExitLoop 2
            EndIf

            Sleep(120)
        WEnd

        $iElapsed = TimerDiff($tStart) / 1000
        $iBytes   = 0
        If FileExists($g_sSpeedTestFile) Then $iBytes = FileGetSize($g_sSpeedTestFile)
        FileDelete($g_sSpeedTestFile)
        _Log("Speedtest Runde " & $iRunde & ": " & _FmtBytes($iBytes) & " in " & Round($iElapsed, 2) & "s")

        If $iBytes >= 10240 And $iElapsed >= 0.5 Then ExitLoop   ; Erfolg
    Next

    ; ── Ergebnis auswerten ──────────────────────────────────────────────────
    If $bSkipped Or $iBytes < 10240 Or $iElapsed < 0.5 Then
        ; Kein Ergebnis
        GUICtrlSetData($hSpeed,  "? Mbit/s")
        GUICtrlSetData($hSub,    "Messung fehlgeschlagen oder uebersprungen")
        GUICtrlSetColor($hSpeed, $C_AMB)
        GUICtrlSetData($hStatus, "Antivirus blockiert? → Web-Schutz / HTTP-Scanner → HTTPS-Scanning deaktivieren")
        ControlMove($hW, "", GUICtrlGetHandle($hFill), 18, 142, $iW - 36, 14)
        GUICtrlSetBkColor($hFill, $C_AMB)
        GUICtrlSetData($g_hSpeedTestStatus, "? Mbit/s  —  Messung uebersprungen")
        GUICtrlSetColor($g_hSpeedTestStatus, $C_AMB)
        $g_iSpeedMbps        = -1
        $g_iRecommendedSlots = 2
    Else
        ; Mbit/s berechnen
        Local $fMbps = ($iBytes * 8) / ($iElapsed * 1000000)
        $g_iSpeedMbps = Int($fMbps)
        If $g_iSpeedMbps < 1 Then $g_iSpeedMbps = 1

        ; Slot-Empfehlung
        Select
            Case $g_iSpeedMbps < 100
                $g_iRecommendedSlots = 1
            Case $g_iSpeedMbps < 250
                $g_iRecommendedSlots = 2
            Case $g_iSpeedMbps < 400
                $g_iRecommendedSlots = 3
            Case $g_iSpeedMbps < 600
                $g_iRecommendedSlots = 4
            Case $g_iSpeedMbps < 800
                $g_iRecommendedSlots = 5
            Case Else
                $g_iRecommendedSlots = $MAX_PARALLEL_SLOTS
        EndSelect

        _Log("Speedtest fertig: " & $g_iSpeedMbps & " Mbit/s  ->  " & $g_iRecommendedSlots & " Slots empfohlen")

        ; Farbe + Icon je nach Speed
        Local $sIcon, $iCol, $iFillCol
        If $g_iSpeedMbps >= 400 Then
            $sIcon = "Sehr gut!  —  " 
$iCol = $C_GRN
$iFillCol = $C_GRN
        ElseIf $g_iSpeedMbps >= 50 Then
            $sIcon = "Gut  —  "       
$iCol = $C_AMB
$iFillCol = $C_AMB
        Else
            $sIcon = "Langsam  —  "   
$iCol = $C_RED
$iFillCol = $C_RED
        EndIf

        ; Endwerte anzeigen
        GUICtrlSetData($hSpeed, $g_iSpeedMbps & " Mbit/s")
        GUICtrlSetColor($hSpeed, $iCol)
        GUICtrlSetData($hSub, $sIcon & $g_iRecommendedSlots & " parallele Downloads empfohlen")
        GUICtrlSetColor($hSub, $iCol)
        GUICtrlSetData($hStatus, _FmtBytes($iBytes) & " in " & Round($iElapsed, 1) & "s gemessen  |  " & $g_iRecommendedSlots & " parallele Slots optimal")
        ControlMove($hW, "", GUICtrlGetHandle($hFill), 18, 142, $iW - 36, 14)
        GUICtrlSetBkColor($hFill, $iFillCol)

        ; Header-Label aktualisieren
        GUICtrlSetData($g_hSpeedTestStatus, $g_iSpeedMbps & " Mbit/s  —  " & $g_iRecommendedSlots & " parallele Slots empfohlen")
        GUICtrlSetColor($g_hSpeedTestStatus, $iCol)

        If $g_iSpeedMbps >= 400 Then
            _Status("Sehr gute Verbindung: " & $g_iSpeedMbps & " Mbit/s — " & $g_iRecommendedSlots & " parallele Streams empfohlen!")
        EndIf
    EndIf

    ; Button auf "Schliessen" umstellen
    GUICtrlSetData($hBtnSkip, "  Schliessen")
    GUICtrlSetBkColor($hBtnSkip, $C_LGRN)
    GUICtrlSetColor($hBtnSkip, $C_GRN)

    ; 2,5s warten (oder sofort schliessen wenn Nutzer klickt)
    Local $tWait = TimerInit()
    While TimerDiff($tWait) < 2500
        Local $ev = GUIGetMsg()
        If $ev = $GUI_EVENT_CLOSE Then
            GUIDelete($hW)
            _Quit()
        EndIf
        If $ev = $hBtnSkip Then ExitLoop
        Sleep(80)
    WEnd

    GUIDelete($hW)
    
    ; Phase 2: Datenbank-Update & USB-Stick Check (Scan-Check v2.27)
    _OnUpdates()
EndFunc

; === v2.27 Background Speedtest ===

Func _StartBackgroundSpeedTest()
    ; v2.27: Check if speedtest was already done (save bandwidth info across restarts)
    If Not $g_bSkipIntro Then
        IniDelete($SETTINGS_INI, "App", "SpeedMbps")
        IniDelete($SETTINGS_INI, "App", "SpeedSlots")
    EndIf
    Local $sSavedMbps = IniRead($SETTINGS_INI, "App", "SpeedMbps", "")
    Local $sSavedSlots = IniRead($SETTINGS_INI, "App", "SpeedSlots", "")
    If $sSavedMbps <> "" And $sSavedSlots <> "" Then
        Local $iMbps = Int($sSavedMbps)
        Local $iCol = ($iMbps >= 400 ? $C_GRN : ($iMbps >= 50 ? $C_AMB : $C_RED))
        GUICtrlSetData($g_hSpeedTestStatus, $sSavedMbps & " Mbit/s  —  " & $sSavedSlots & " parallele Slots empfohlen")
        GUICtrlSetColor($g_hSpeedTestStatus, $iCol)
        Return
    EndIf
    
    GUICtrlSetData($g_hSpeedTestStatus, "Bandbreite wird gemessen...")

    Local $sCurl = _CurlPath()
    If $sCurl = "" Then
        GUICtrlSetData($g_hSpeedTestStatus, "")
        Return
    EndIf
    
    Local $sURL = "https://ftp.fau.de/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.4.0-amd64-xfce.iso"
    FileDelete($g_sSpeedTestFile)
    
    Local $sArgs = '-s -L --max-time 10 --connect-timeout 8 ' & _
                   '--ssl-no-revoke ' & _
                   '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                   '-o "' & $g_sSpeedTestFile & '" "' & $sURL & '"'
    
    $g_iBGSpeedPID = Run('"' & $sCurl & '" ' & $sArgs, "", @SW_HIDE)
    If $g_iBGSpeedPID = 0 Then
        GUICtrlSetData($g_hSpeedTestStatus, "")
        Return
    EndIf
    $g_tBGSpeedStart = TimerInit()
    _Log("Background Speedtest gestartet (PID " & $g_iBGSpeedPID & ")")
EndFunc

Func _CheckBackgroundSpeedTest()
    If $g_iBGSpeedPID = 0 Then Return
    
    If ProcessExists($g_iBGSpeedPID) Then
        ; Noch am Laufen, optional Live-Update in der Statusbar oder so
        Return
    EndIf
    
    ; Fertig!
    Local $iElapsed = TimerDiff($g_tBGSpeedStart) / 1000
    Local $iBytes = 0
    If FileExists($g_sSpeedTestFile) Then $iBytes = FileGetSize($g_sSpeedTestFile)
    FileDelete($g_sSpeedTestFile)
    
    If $iBytes > 10240 And $iElapsed >= 0.5 Then
        Local $fMbps = ($iBytes * 8) / ($iElapsed * 1000000)
        $g_iSpeedMbps = Int($fMbps)
        If $g_iSpeedMbps < 1 Then $g_iSpeedMbps = 1
        
        ; Slot-Empfehlung
        Select
            Case $g_iSpeedMbps < 100
                $g_iRecommendedSlots = 1
            Case $g_iSpeedMbps < 250
                $g_iRecommendedSlots = 2
            Case $g_iSpeedMbps < 400
                $g_iRecommendedSlots = 3
            Case $g_iSpeedMbps < 600
                $g_iRecommendedSlots = 4
            Case $g_iSpeedMbps < 800
                $g_iRecommendedSlots = 5
            Case Else
                $g_iRecommendedSlots = $MAX_PARALLEL_SLOTS
        EndSelect
        
        _Log("Background Speedtest fertig: " & $g_iSpeedMbps & " Mbit/s")
        
        ; v2.27: Save to INI to persist across restarts
        IniWrite($SETTINGS_INI, "App", "SpeedMbps", $g_iSpeedMbps)
        IniWrite($SETTINGS_INI, "App", "SpeedSlots", $g_iRecommendedSlots)
        
        ; UI Update
        Local $iCol = ($g_iSpeedMbps >= 400 ? $C_GRN : ($g_iSpeedMbps >= 50 ? $C_AMB : $C_RED))
        GUICtrlSetData($g_hSpeedTestStatus, $g_iSpeedMbps & " Mbit/s  —  " & $g_iRecommendedSlots & " parallele Slots empfohlen")
        GUICtrlSetColor($g_hSpeedTestStatus, $iCol)
    Else
        _Log("Background Speedtest fehlgeschlagen oder zu kurz.")
        GUICtrlSetData($g_hSpeedTestStatus, "") ; Label leeren wenn Test fehlschlägt
    EndIf
    
    $g_iBGSpeedPID = 0
EndFunc
