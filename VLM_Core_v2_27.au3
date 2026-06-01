; ==========================================
; Module: ULM_Core.au3
; Part of UniversalISOManager
; ==========================================

#include-once

Func _LoadMemBootSettings()
    ; Prüfen ob überhaupt [MemBoot]-Sektion existiert — wenn nicht: Defaults behalten
    Local $sSectionCheck = IniRead($SETTINGS_INI, "MemBoot", "saved", "0")
    If $sSectionCheck <> "1" Then
        _Log("[MemBoot] Keine gespeicherten Einstellungen → Hardcode-Defaults aktiv")
        Return
    EndIf
    ; Gespeicherte Werte laden (überschreiben Defaults)
    For $i = 0 To $ISO_MAX - 1
        Local $sVal = IniRead($SETTINGS_INI, "MemBoot", "mb_" & $i, "")
        If $sVal = "1" Then
            $g_abMemBoot[$i] = True
        ElseIf $sVal = "0" Then
            $g_abMemBoot[$i] = False
        EndIf
        ; Leerer String → kein Eintrag → Default bleibt
    Next
    _Log("[MemBoot] Einstellungen geladen aus " & $SETTINGS_INI)
EndFunc

Func _OnUpdates()
    _HideTooltip()   ; 
    If $g_bBusy Then Return
    $g_bBusy = True

    Local $sDrive = _GetSelectedDrive()

    _PopShow("Scan-Check — Datenbank & USB", "Prüfe lokale ISOs und USB-Stick ...", False)
    GUICtrlSetData($g_hProgress, 0)

    ; Root-ISOs in Kategorie-Unterordner migrieren (falls noch im Root)
    If $sDrive <> "" And DriveStatus($sDrive) = "READY" Then
        _PopUpdate(0, "Ordne ISOs in Kategorien ...", "v2.9 — Kategorie-Migration")
        Local $iMigOu = _MigrateRootISOsToCategories($sDrive)
        If $iMigOu > 0 Then _Status("[OK] " & $iMigOu & " ISO(s) in Kategorie-Ordner verschoben")
        _EnsureVentoyTheme($sDrive, False)
    EndIf

    ; USB-Status-Arrays zurücksetzen
    For $x = 0 To $ISO_COUNT - 1
        $g_aiUSBStatus[$x] = 0
        $g_asUSBSize[$x]   = ""
    Next
    $g_sLastScannedDrive = $sDrive

    ; -----------------------------------------------------------------------
    ; SCHRITT 1: Lokale ISOs prüfen (Download-Ordner)
    ; -----------------------------------------------------------------------
    Local $iLocalFound = 0, $iLocalMissing = 0
    _Log("=== Update-Check: Lokaler Download-Ordner ===")
    For $i = 0 To $ISO_COUNT - 1
        _PopUpdate(Int(($i+1)/$ISO_COUNT*100), "Lokal: " & $g_aISOs[$i][0], "Schritt 1/2 — " & ($i+1) & "/" & $ISO_COUNT)
        GUICtrlSetData($g_hProgress, Int(($i+1)/$ISO_COUNT*100))
        Local $sF = $DOWNLOAD_DIR & "\" & $g_aISOs[$i][3]
        If FileExists($sF) Then
            $iLocalFound += 1
            _Log("  [OK]   " & $g_aISOs[$i][0] & " (" & _FmtBytes(FileGetSize($sF)) & ")")
        Else
            $iLocalMissing += 1
            _Log("  [--]   Fehlt: " & $g_aISOs[$i][0])
        EndIf
        Sleep(60)
    Next
    _Log("Lokal: " & $iLocalFound & " vorhanden, " & $iLocalMissing & " fehlen.")

    ; -----------------------------------------------------------------------
    ; SCHRITT 2: USB-Stick scannen
    ; -----------------------------------------------------------------------
    Local $iStickFound = 0, $iStickOK = 0, $iStickOld = 0, $iStickUnknown = 0

    Local $abNeedsUpdate[$ISO_COUNT]
    For $x = 0 To $ISO_COUNT - 1
        $abNeedsUpdate[$x] = False
    Next

    Local $asOldFiles[0]   ; v2.28: Liste veralteter Dateien auf dem Stick sammeln

    ; Unbekannte ISOs sammeln für späteren Dialog
    ; Spalten: [0]=Dateiname  [1]=Größe formatiert  [2]=vollständiger Pfad
    Local $aUnknownISOs[0][3]
    Local $iUnknownCount = 0

    If $sDrive = "" Then
        _Log("=== Update-Check: USB-Stick ===  [kein Laufwerk gewählt – übersprungen]")
        _PopUpdate(100, "Kein USB-Stick gewählt — nur lokaler Scan.", "Fertig")
    Else
        _Log("=== Update-Check: USB-Stick  " & $sDrive & " ===")

        ; Vollständig rekursiver Scan des gesamten Sticks
        ; Findet ISOs in ALLEN Unterordnern — auch manuell angelegte
        Local $aStickISOs[0]   ; nur Dateinamen
        Local $aStickPaths[0]  ; vollständige Pfade
        Local $aRec = _FileListToArrayRec($sDrive, "*.iso", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
        If Not @error And IsArray($aRec) And $aRec[0] > 0 Then
            ReDim $aStickISOs[$aRec[0]]
            ReDim $aStickPaths[$aRec[0]]
            For $k = 1 To $aRec[0]
                Local $sFullPath = $aRec[$k]
                $aStickISOs[$k-1]  = StringMid($sFullPath, StringInStr($sFullPath, "\", 0, -1) + 1)
                $aStickPaths[$k-1] = $sFullPath
            Next
        EndIf
        $iStickFound = UBound($aStickISOs)
        _Log("  Gefunden: " & $iStickFound & " ISO(s) auf " & $sDrive & " (Root + Kategorie-Ordner)")

        ; Alle DB-Einträge zunächst auf "nicht auf Stick" setzen (Status 3)
        ; Wird weiter unten auf 1 oder 2 gesetzt wenn gefunden
        For $x = 0 To $ISO_COUNT - 1
            $g_aiUSBStatus[$x] = 3
        Next

        ; -----------------------------------------------------------------------
        ; Jede ISO auf dem Stick analysieren
        ; -----------------------------------------------------------------------
        For $j = 0 To $iStickFound - 1
            Local $sISO      = $aStickISOs[$j]
            ; vollständigen Pfad aus $aStickPaths nutzen (Root oder Unterordner)
            Local $sISOPath  = $aStickPaths[$j]
            Local $iStickSz  = FileGetSize($sISOPath)
            Local $bMatched  = False
            Local $bUpToDate = False

            _PopUpdate(50 + Int(($j+1)/($iStickFound + ($iStickFound = 0))*45), _
                "Analysiere: " & $sISO & "  (" & _FmtBytes($iStickSz) & ")", _
                "Schritt 2/2 — ISO " & ($j+1) & "/" & $iStickFound)
            GUICtrlSetData($g_hProgress, 50 + Int(($j+1)/($iStickFound + ($iStickFound = 0))*45))

            ; --- Exakter Dateinamen-Treffer → Größenvergleich ---
            For $i = 0 To $ISO_COUNT - 1
                If StringLower($sISO) = StringLower($g_aISOs[$i][3]) Then
                    $bMatched = True
                    ; Erwartete Größe: entweder lokal bekannt oder Remote-HEAD-Request
                    Local $iExpected = _GetExpectedSize($i, $iStickSz)

                    If $iExpected = 0 Then
                        ; Keine Referenzgröße verfügbar → nur Namensübereinstimmung = OK
                        $bUpToDate = True
                        $g_aiUSBStatus[$i] = 1
                        $g_asUSBSize[$i]   = _FmtBytes($iStickSz)
                        _Log("  [✓ aktuell]  " & $sISO & "  " & _FmtBytes($iStickSz) & "  (Größe unbekannt, Name OK)")
                    ElseIf _SizesMatch($iStickSz, $iExpected) Then
                        ; Name UND Größe stimmen → definitiv aktuell
                        $bUpToDate = True
                        $g_aiUSBStatus[$i] = 1
                        $g_asUSBSize[$i]   = _FmtBytes($iStickSz)
                        _Log("  [✓ aktuell]  " & $sISO & "  " & _FmtBytes($iStickSz) & " ≈ " & _FmtBytes($iExpected) & " (Größe OK)")
                    Else
                        ; Name gleich aber Größe weicht ab → beschädigt oder andere Build-Variante
                        ; Nur als veraltet markieren, wenn nicht bereits eine aktuelle Version gefunden wurde
                        If $g_aiUSBStatus[$i] <> 1 Then $g_aiUSBStatus[$i] = 2
                        $g_asUSBSize[$i]   = _FmtBytes($iStickSz)
                        _ArrayAdd($asOldFiles, $sISOPath)   ; zur Lösch-Liste hinzufügen
                        _Log("  [⚠ Größe abweichend]  " & $sISO & _
                             "  Stick: " & _FmtBytes($iStickSz) & _
                             "  Erwartet: " & _FmtBytes($iExpected) & _
                             "  →  zum Download vorgemerkt")
                    EndIf
                    ExitLoop
                EndIf
            Next

            ; --- Fuzzy-Treffer: anderer Dateiname, gleiche Distro (Prefix-Matching) ---
            If Not $bMatched Then
                For $i = 0 To $ISO_COUNT - 1
                    Local $sBase = _ISOBaseName($g_aISOs[$i][3])
                    If $sBase <> "" And StringInStr(StringLower($sISO), $sBase) Then
                        $bMatched = True
                        
                        ; Versionen vergleichen
                        Local $sStickVer = ""
                        Local $aMatches = StringRegExp($sISO, "(\d+(?:\.\d+)+)", 1)
                        If Not @error And IsArray($aMatches) Then $sStickVer = $aMatches[0]
                        
                        Local $sDBVer = ""
                        Local $aMatchesDB = StringRegExp($g_aISOs[$i][3], "(\d+(?:\.\d+)+)", 1)
                        If Not @error And IsArray($aMatchesDB) Then $sDBVer = $aMatchesDB[0]
                        
                        If $sStickVer <> "" And $sDBVer <> "" And _VersionNewer($sStickVer, $sDBVer) Then
                            ; Die Version auf dem Stick ist neuer! Datenbank aktualisieren
                            $g_asUpdateVer[$i]  = $sStickVer
                            $g_asUpdateFile[$i] = $sISO
                            Local $sOldURL = $g_aISOs[$i][2]
                            Local $sNewURL = $sOldURL
                            If StringInStr($sOldURL, $sDBVer) Then
                                $sNewURL = StringReplace($sOldURL, $sDBVer, $sStickVer, 0)
                            EndIf
                            $g_asUpdateURL[$i]  = $sNewURL
                            
                            _AutoApplyUpdate($i)
                            _AutoUpdateTooltip($i)
                            
                            $g_aiUSBStatus[$i] = 1
                            $g_asUSBSize[$i]   = _FmtBytes($iStickSz)
                            _Log("  [✓ Scan-Upgrade DB] " & $sISO & " ist neuer als DB (" & $sDBVer & ") -> DB auf v" & $sStickVer & " angehoben!")
                        ElseIf $sStickVer <> "" And $sDBVer <> "" And _VersionNewer($sDBVer, $sStickVer) Then
                            ; Version auf dem Stick ist älter -> veraltet
                            If $g_aiUSBStatus[$i] <> 1 Then $g_aiUSBStatus[$i] = 2
                            $g_asUSBSize[$i]   = _FmtBytes($iStickSz)
                            _ArrayAdd($asOldFiles, $sISOPath)   ; zur Lösch-Liste hinzufügen
                            _Log("  [⚠ veraltet]  " & $sISO & "  " & _FmtBytes($iStickSz) & _
                                 "  →  aktuell: " & $g_aISOs[$i][3] & "  [vorgemerkt]")
                        Else
                            ; Versionen gleich oder nicht ermittelbar → als aktuell werten
                            If $g_aiUSBStatus[$i] <> 1 Then $g_aiUSBStatus[$i] = 1
                            $g_asUSBSize[$i] = _FmtBytes($iStickSz)
                            _Log("  [✓ Fuzzy-Match OK]  " & $sISO & "  " & _FmtBytes($iStickSz) & _
                                 "  ≈ " & $g_aISOs[$i][3] & "  (gleiche/unbekannte Version)")
                        EndIf
                        ExitLoop
                    EndIf
                Next
            EndIf

            ; --- v14.26: Keyword-Matching anhand Anzeigenamen ---
            ; Extrahiert Schlüsselwörter aus $g_aISOs[$i][0] und sucht sie im Dateinamen
            If Not $bMatched Then
                Local $sISOLow = StringLower($sISO)
                For $i = 0 To $ISO_COUNT - 1
                    Local $sDisplayLow = StringLower($g_aISOs[$i][0])
                    ; Wörter aus dem Anzeigenamen extrahieren (mind. 4 Zeichen, keine Zahlen)
                    Local $aWords = StringRegExp($sDisplayLow, "[a-z]{4,}", 3)
                    If Not IsArray($aWords) Then ContinueLoop
                    Local $iMatchCount = 0
                    For $w = 0 To UBound($aWords) - 1
                        ; Generische Wörter überspringen
                        If $aWords[$w] = "linux" Or $aWords[$w] = "edition" Or _
                           $aWords[$w] = "version" Or $aWords[$w] = "release" Then ContinueLoop
                        If StringInStr($sISOLow, $aWords[$w]) Then $iMatchCount += 1
                    Next
                    If $iMatchCount >= 2 Then   ; mindestens 2 Schlüsselwörter müssen treffen
                        $bMatched = True
                        
                        ; Versionen vergleichen
                        Local $sStickVer = ""
                        Local $aMatches = StringRegExp($sISO, "(\d+(?:\.\d+)+)", 1)
                        If Not @error And IsArray($aMatches) Then $sStickVer = $aMatches[0]
                        
                        Local $sDBVer = ""
                        Local $aMatchesDB = StringRegExp($g_aISOs[$i][3], "(\d+(?:\.\d+)+)", 1)
                        If Not @error And IsArray($aMatchesDB) Then $sDBVer = $aMatchesDB[0]
                        
                        If $sStickVer <> "" And $sDBVer <> "" And _VersionNewer($sStickVer, $sDBVer) Then
                            ; Die Version auf dem Stick ist neuer! Datenbank aktualisieren
                            $g_asUpdateVer[$i]  = $sStickVer
                            $g_asUpdateFile[$i] = $sISO
                            Local $sOldURL = $g_aISOs[$i][2]
                            Local $sNewURL = $sOldURL
                            If StringInStr($sOldURL, $sDBVer) Then
                                $sNewURL = StringReplace($sOldURL, $sDBVer, $sStickVer, 0)
                            EndIf
                            $g_asUpdateURL[$i]  = $sNewURL
                            
                            _AutoApplyUpdate($i)
                            _AutoUpdateTooltip($i)
                            
                            $g_aiUSBStatus[$i] = 1
                            $g_asUSBSize[$i]   = _FmtBytes($iStickSz)
                            _Log("  [✓ Scan-Upgrade DB] " & $sISO & " ist neuer als DB (" & $sDBVer & ") -> DB auf v" & $sStickVer & " angehoben!")
                        ElseIf $sStickVer <> "" And $sDBVer <> "" And _VersionNewer($sDBVer, $sStickVer) Then
                            ; Version auf dem Stick ist älter -> veraltet
                            If $g_aiUSBStatus[$i] <> 1 Then $g_aiUSBStatus[$i] = 2
                            $g_asUSBSize[$i]   = _FmtBytes($iStickSz)
                            _ArrayAdd($asOldFiles, $sISOPath)   ; zur Lösch-Liste hinzufügen
                            _Log("  [⚠ Keyword-Match veraltet]  " & $sISO & "  →  " & $g_aISOs[$i][0] & "  [vorgemerkt]")
                        Else
                            ; Versionen gleich oder nicht ermittelbar → als aktuell werten
                            If $g_aiUSBStatus[$i] <> 1 Then $g_aiUSBStatus[$i] = 1
                            $g_asUSBSize[$i] = _FmtBytes($iStickSz)
                            _Log("  [✓ Keyword-Match OK]  " & $sISO & "  ≈  " & $g_aISOs[$i][0] & "  (gleiche/unbekannte Version)")
                        EndIf
                        ExitLoop
                    EndIf
                Next
            EndIf

            ; --- v14.26: Größen-Fallback — ISO per Dateigröße identifizieren ---
            ; Wenn der Name unbekannt ist, prüfe ob die Größe zu einer DB-ISO passt (±2%)
            If Not $bMatched And $iStickSz > 314572800 Then  ; > 300 MB
                For $i = 0 To $ISO_COUNT - 1
                    Local $iExpSz = _GetExpectedSize($i, $iStickSz)
                    If $iExpSz > 0 And _SizesMatch($iStickSz, $iExpSz) Then
                        $bMatched = True
                        $g_aiUSBStatus[$i] = 1
                        $g_asUSBSize[$i]   = _FmtBytes($iStickSz)
                        _Log("  [✓ Größen-Match]  " & $sISO & "  " & _FmtBytes($iStickSz) & _
                             "  ≈  " & $g_aISOs[$i][0] & "  (anderer Name, gleiche Größe)")
                        ExitLoop
                    EndIf
                Next
            EndIf

            If Not $bMatched Then
                $iStickUnknown += 1
                ReDim $aUnknownISOs[$iUnknownCount + 1][3]
                $aUnknownISOs[$iUnknownCount][0] = $sISO
                $aUnknownISOs[$iUnknownCount][1] = _FmtBytes($iStickSz)
                $aUnknownISOs[$iUnknownCount][2] = $sISOPath
                $iUnknownCount += 1
                _Log("  [?]  " & $sISO & "  " & _FmtBytes($iStickSz) & "  (nicht in Datenbank)")
            EndIf
        Next

        ; ISOs die gar nicht auf dem Stick gefunden wurden → Status bleibt 3
        For $i = 0 To $ISO_COUNT - 1
            If $g_aiUSBStatus[$i] = 3 Then
                _Log("  [✗ fehlt]  " & $g_aISOs[$i][0] & " — nicht auf Stick")
            EndIf
        Next

        ; v2.28 Fix: Zähler und Update-Flags auf Basis des finalen Status berechnen
        $iStickOK = 0
        $iStickOld = 0
        For $x = 0 To $ISO_COUNT - 1
            If $g_aiUSBStatus[$x] = 1 Then
                $iStickOK += 1
                $abNeedsUpdate[$x] = False
            ElseIf $g_aiUSBStatus[$x] = 2 Then
                $iStickOld += 1
                $abNeedsUpdate[$x] = True
            EndIf
        Next

        _Log("USB-Stick: " & $iStickOK & " aktuell, " & $iStickOld & " veraltet/abweichend, " & $iStickUnknown & " unbekannt.")

        If $iStickFound = 0 Then
            _Log("  Keine ISO-Dateien auf " & $sDrive & " gefunden.")
            ; Kein Stick-Inhalt → alle auf Status 3 lassen (nicht gefunden)
        EndIf

        ; Schritt 3 im Popup: Remote-Größen für abweichende ISOs nachholen
        ; (wird im Hintergrund bereits in _GetExpectedSize gemacht, Popup aktualisieren)
        _PopUpdate(97, _
            $iStickFound & " ISO(s) auf Stick: " & $iStickOK & " [OK] aktuell  /  " & $iStickOld & " [!] Update nötig  /  " & $iStickUnknown & " ?", _
            "Scan-Check abgeschlossen - aktualisiere Anzeige ...")
    EndIf

    Sleep(600)
    _PopClose()
    $g_bBusy = False

    ; Status-Zeile
    Local $sResult = "Lokal: " & $iLocalFound & "/" & $ISO_COUNT & "."
    If $sDrive <> "" Then
        $sResult &= "   Stick " & $sDrive & ": " & $iStickOK & " [OK] aktuell  " & $iStickOld & " [!] Update  " & $iStickUnknown & " ?"
    EndIf
    _Status($sResult)
    _FillTree()   ; Baum neu aufbauen — jetzt mit USB-Status-Labels

    ; Veraltete ISOs im TreeView markieren
    If $sDrive <> "" And $iStickOld > 0 Then
        _MarkOutdatedISOs($abNeedsUpdate)

        Local $sMsg = $iStickOld & " ISO(s) auf Stick " & $sDrive & " benötigen ein Update!" & @CRLF & @CRLF & _
            "Die betroffenen Distributionen wurden automatisch" & @CRLF & _
            "angekreuzt und sind bereit zum Herunterladen." & @CRLF & @CRLF & _
            "➜  Einfach  '⬇ Herunterladen'  klicken!" & @CRLF & @CRLF & _
            "Details im Protokoll-Tab."
        MsgBox(48, "⚠ Updates verfügbar", $sMsg)

        ; v2.28: Optionales Löschen veralteter ISOs anbieten
        If UBound($asOldFiles) > 0 Then
            Local $sDelList = ""
            For $k = 0 To UBound($asOldFiles) - 1
                $sDelList &= " • " & StringMid($asOldFiles[$k], StringInStr($asOldFiles[$k], "\", 0, -1) + 1) & @CRLF
            Next
            Local $iAnswer = MsgBox(36, "Veraltete ISOs löschen?", _
                "Sollen die folgenden veralteten ISO-Versionen vom Stick gelöscht werden," & @CRLF & _
                "um Platz für die neuen Versionen zu schaffen?" & @CRLF & @CRLF & $sDelList)
            If $iAnswer = 6 Then   ; Ja
                _Log("=== Lösche veraltete ISOs vom Stick ===")
                For $k = 0 To UBound($asOldFiles) - 1
                    Local $sCurPath = $asOldFiles[$k]
                    If FileDelete($sCurPath) Then
                        _Log("  [LÖSCHEN OK] " & $sCurPath)
                        
                        ; Finde die ISO in der DB, um den Status auf "Fehlt/Rot" (3) zu setzen
                        Local $sCurFile = StringMid($sCurPath, StringInStr($sCurPath, "\", 0, -1) + 1)
                        For $iIdx = 0 To $ISO_COUNT - 1
                            ; Prüfe auf Namensübereinstimmung oder ob es die veraltete Version dieser ISO war
                            If StringLower($sCurFile) = StringLower($g_aISOs[$iIdx][3]) Or _
                               StringInStr(StringLower($sCurFile), _ISOBaseName($g_aISOs[$iIdx][3])) Then
                                
                                $g_aiUSBStatus[$iIdx] = 3   ; Status: Nicht auf Stick (Rot)
                                $g_aiNodeColor[$iIdx] = 3   ; Farbe: Rot
                                _GUICtrlTreeView_SetChecked(GUICtrlGetHandle($g_hTreeView), $g_ahNodes[$iIdx], True)
                                $g_abNodeLast[$iIdx] = True
                            EndIf
                        Next
                    Else
                        _Log("  [FEHLER] Konnte nicht löschen: " & $sCurPath)
                    EndIf
                Next
                _Status("✓ Veraltete ISOs vom Stick gelöscht.")
                $iStickOld = 0
                _SyncCategoryCheckboxes() ; Checkboxen obenrum auch fixen
                _FillTree()   ; TreeView sofort aktualisieren um gelöschte ISOs anzuzeigen (v2.28)
                If $sDrive <> "" And DriveStatus($sDrive) = "READY" Then
                    _EnsureVentoyTheme($sDrive, False, True)   ; Ventoy Hintergrund aktualisieren (v2.28)
                EndIf
            EndIf
        EndIf
    ElseIf $sDrive <> "" And $iStickFound > 0 And $iStickOld = 0 And $iStickUnknown = 0 Then
        MsgBox(64, "[OK] Alles aktuell", _
            "Alle " & $iStickOK & " ISO(s) auf Stick " & $sDrive & @CRLF & _
            "sind aktuell und haben die erwartete Größe." & @CRLF & @CRLF & _
            "Kein Update erforderlich.")
    EndIf

    ; -----------------------------------------------------------------------
    ; Unbekannte ISOs — zuerst Import-Dialog, dann ggf. Ersatz-Dialog
    ; -----------------------------------------------------------------------
    If $sDrive <> "" And $iUnknownCount > 0 Then
        ; Schritt 1: In Datenbank importieren (Kategorie + Mirror-Suche)
        Local $iImported = _ImportUnknownISOsToDB($aUnknownISOs, $iUnknownCount, $sDrive)
        
        ; v2.28: Importierte ISOs aus der Unbekannt-Liste filtern, damit sie nicht doppelt im Ersatz-Dialog erscheinen
        If $iImported > 0 Then
            Local $aNewUnknown[UBound($aUnknownISOs)][3]
            Local $iNewCount = 0
            For $k = 0 To $iUnknownCount - 1
                Local $sFile = $aUnknownISOs[$k][0]
                Local $bIsNowKnown = False
                For $idx = 0 To $ISO_COUNT - 1
                    If StringLower($sFile) = StringLower($g_aISOs[$idx][3]) Then
                        $bIsNowKnown = True
                        ExitLoop
                    EndIf
                Next
                If Not $bIsNowKnown Then
                    $aNewUnknown[$iNewCount][0] = $aUnknownISOs[$k][0]
                    $aNewUnknown[$iNewCount][1] = $aUnknownISOs[$k][1]
                    $aNewUnknown[$iNewCount][2] = $aUnknownISOs[$k][2]
                    $iNewCount += 1
                EndIf
            Next
            ReDim $aNewUnknown[$iNewCount][3]
            $aUnknownISOs = $aNewUnknown
            $iUnknownCount = $iNewCount
        EndIf

        ; Schritt 2: Optional durch bekannte Distros ersetzen (alter Dialog)
        If $iUnknownCount > 0 Then
            _UnknownISODialog($aUnknownISOs, $iUnknownCount, $sDrive)
        EndIf
    EndIf

    ; v2.28: Endgültige Aktualisierung des Baum-Overviews und des Boot-Hintergrundbildes auf dem Stick
    _FillTree()
    If $sDrive <> "" And DriveStatus($sDrive) = "READY" Then
        _EnsureVentoyTheme($sDrive, False, True)
    EndIf
    _OnCleanupBrokenDownloads(True)
EndFunc

Func _OnHelp()
    Local $sTitle = "Hilfe & Erläuterungen — Universal ISO Manager"
    Local $sHelp = _
        "Hier finden Sie eine kurze Übersicht der wichtigsten Funktionen:" & @CRLF & @CRLF & _
        "🔄 UPDATE PRÜFEN" & @CRLF & _
        "Vergleicht die ISO-Dateien auf Ihrem USB-Stick mit der internen Datenbank." & @CRLF & _
        "Veraltete oder beschädigte ISOs werden markiert und können direkt" & @CRLF & _
        "durch die neueste Version ersetzt werden." & @CRLF & @CRLF & _
        "📁 DATENBANK" & @CRLF & _
        "Ermöglicht das Bearbeiten der ISO-Liste. Sie können Versionen anpassen," & @CRLF & _
        "eigene Distributionen hinzufügen oder nicht benötigte Einträge löschen." & @CRLF & @CRLF & _
        "🌐 URL CHECK" & @CRLF & _
        "Prüft alle hinterlegten Download-Links online auf Erreichbarkeit." & @CRLF & _
        "So sehen Sie sofort, ob ein Spiegelserver (Mirror) offline ist." & @CRLF & @CRLF & _
        "⬇ HERUNTERLADEN" & @CRLF & _
        "Lädt die ausgewählten (angekreuzten) ISOs herunter. Bei erkanntem" & @CRLF & _
        "Ventoy-Stick werden diese nach dem Download automatisch auf den Stick" & @CRLF & _
        "in den passenden Kategorie-Ordner kopiert." & @CRLF & @CRLF & _
        "🔎 ISO SUCHEN" & @CRLF & _
        "Durchsucht die Datenbank nach Namen oder Schlagworten. Hilfreich," & @CRLF & _
        "um schnell eine bestimmte Distribution in der langen Liste zu finden."
    
    MsgBox(64, $sTitle, $sHelp)
EndFunc

Func _GuessFriendlyName($sFilename)
    ; Bekannte Tools mit generischen oder komplexen Dateinamen → direkte Rückgabe
    Local $sLow = StringLower($sFilename)
    If StringInStr($sLow, "hbcd_pe") Or StringInStr($sLow, "hbcd-pe") Then
        Return "Hiren's Boot CD PE x64"
    EndIf
    If $sLow = "krd.iso" Or StringLeft($sLow, 4) = "krd." Then
        Return "Kaspersky Rescue Disk (krd)"
    EndIf
    If StringInStr($sLow, "antiviruslivecd") Then
        ; AntivirusLiveCD-51.0-1.5.1.iso → "AntivirusLiveCD 51.0 1.5.1"
        Local $aAVVer = StringRegExp($sFilename, "AntivirusLiveCD-([\d]+\.[\d]+-[\d\.]+)\.iso", 1)
        If Not @error Then Return "AntivirusLiveCD " & StringReplace($aAVVer[0], "-", " ")
        Return "AntivirusLiveCD"
    EndIf

    ; Generische Ableitung: Dateiendung entfernen, Trennzeichen → Leerzeichen
    Local $sBase = $sFilename
    If StringInStr($sBase, ".") Then
        $sBase = StringLeft($sBase, StringInStr($sBase, ".", 0, -1) - 1)
    EndIf
    $sBase = StringReplace($sBase, "-", " ")
    $sBase = StringReplace($sBase, "_", " ")
    While StringInStr($sBase, "  ")
        $sBase = StringReplace($sBase, "  ", " ")
    WEnd
    Return StringStripWS($sBase, 3)
EndFunc

Func _AddSFCands(ByRef $aCands, $sProj, $sFile)
    If StringLen($sProj) < 3 Then Return
    Local $sSF = "https://master.dl.sourceforge.net/project"
    ; Muster 1: Direkt im Root
    _ArrayAdd($aCands, $sSF & "/" & $sProj & "/" & $sFile & "?viasf=1")
    _ArrayAdd($aCands, "https://downloads.sourceforge.net/project/" & $sProj & "/" & $sFile)
    ; Muster 2: In "iso" Unterordner
    _ArrayAdd($aCands, $sSF & "/" & $sProj & "/iso/" & $sFile & "?viasf=1")
    ; Muster 3: In Versions-Ordner (falls Version im Name erkannt)
    Local $aV = StringRegExp($sFile, "(\d+\.\d+(?:\.\d+)*)", 1)
    If Not @error Then
        _ArrayAdd($aCands, $sSF & "/" & $sProj & "/" & $aV[0] & "/" & $sFile & "?viasf=1")
        _ArrayAdd($aCands, $sSF & "/" & $sProj & "/files/" & $aV[0] & "/" & $sFile & "?viasf=1")
        _ArrayAdd($aCands, $sSF & "/" & $sProj & "/files/Release%20" & $aV[0] & "/" & $sFile & "?viasf=1")
        _ArrayAdd($aCands, "https://downloads.sourceforge.net/project/" & $sProj & "/Release%20" & $aV[0] & "/" & $sFile)
    EndIf
EndFunc

Func _GetExpectedSize($iIdx, $iStickSize)
    ; Lokal vorhanden? → nehme lokale Größe als Referenz
    Local $sLocal = $DOWNLOAD_DIR & "\" & $g_aISOs[$iIdx][3]
    If FileExists($sLocal) And FileGetSize($sLocal) > 1048576 Then
        Return FileGetSize($sLocal)
    EndIf

    ; Kein lokaler Referenzwert → Remote-Größe per HEAD-Request holen
    ; Verwende Primär-URL (schnellster Mirror bevorzugt)
    Local $sURL = $g_aISOs[$iIdx][2]
    If $sURL = "" Then Return 0

    _Log("    Hole Remote-Größe für Größenvergleich: " & $g_aISOs[$iIdx][0])
    Local $iRemote = _RemoteSize($sURL)

    ; Falls Primär-URL keine Größe liefert (z.B. GitHub-Redirect) → Mirror 1 versuchen
    If $iRemote = 0 And $g_aISOs[$iIdx][4] <> "" Then
        $iRemote = _RemoteSize($g_aISOs[$iIdx][4])
    EndIf
    ; Mirror 2 als letzten HEAD-Fallback
    If $iRemote = 0 And $g_aISOs[$iIdx][5] <> "" Then
        $iRemote = _RemoteSize($g_aISOs[$iIdx][5])
    EndIf
    ; Mirror 3 als letzten HEAD-Fallback
    If $iRemote = 0 And $g_aISOs[$iIdx][8] <> "" Then
        $iRemote = _RemoteSize($g_aISOs[$iIdx][8])
    EndIf

    If $iRemote > 0 Then
        _Log("    Remote-Größe: " & _FmtBytes($iRemote))
    Else
        _Log("    Remote-Größe nicht ermittelbar — nur Namensvergleich")
    EndIf

    Return $iRemote
EndFunc

Func _SizesMatch($iActual, $iExpected)
    If $iExpected = 0 Then Return True   ; keine Referenz → als OK werten
    Local $iDiff = Abs($iActual - $iExpected)
    Local $fPct  = $iDiff / $iExpected
    Return ($fPct <= 0.02)   ; ≤ 2% Abweichung = OK
EndFunc

Func _HideTooltip()
    If $g_iLastTipNode <> -1 Then
        ToolTip("")
        $g_iLastTipNode = -1
    EndIf
EndFunc

Func _TooltipPoll()
    ; Checkbox-Zustand prüfen
    If Not $g_bShowInfo Then
        If $g_iLastTipNode <> -1 Then
            ToolTip("")
            $g_iLastTipNode = -1
        EndIf
        Return
    EndIf

    ; Fenster nicht im Vordergrund → Tooltip sofort ausblenden und abbrechen
    If Not WinActive($g_hMain) Then
        If $g_iLastTipNode <> -1 Then
            ToolTip("")
            $g_iLastTipNode = -1
        EndIf
        Return
    EndIf

    Local $hTV    = GUICtrlGetHandle($g_hTreeView)
    Local $aTVPos = WinGetPos($hTV)
    If Not IsArray($aTVPos) Then Return

    Local $aMouse = MouseGetPos()
    Local $iRelX  = $aMouse[0] - $aTVPos[0]
    Local $iRelY  = $aMouse[1] - $aTVPos[1]

    ; Maus außerhalb des TreeView → Tooltip ausblenden
    If $iRelX < 0 Or $iRelX > $aTVPos[2] Or $iRelY < 0 Or $iRelY > $aTVPos[3] Then
        If $g_iLastTipNode <> -1 Then
            ToolTip("")
            $g_iLastTipNode = -1
        EndIf
        Return
    EndIf

    ; Welcher TreeView-Node liegt unter der Maus?
    Local $tHitTest = _GUICtrlTreeView_HitTestEx($hTV, $iRelX, $iRelY)
    Local $hItem = DllStructGetData($tHitTest, "Item")
    Local $iFlags = DllStructGetData($tHitTest, "Flags")

    ; Prüfen, ob die Maus über dem eigentlichen Eintrag liegt (Icon, Label oder Checkbox)
    ; TVHT_ONITEM = TVHT_ONITEMICON (0x0002) | TVHT_ONITEMLABEL (0x0004) | TVHT_ONITEMSTATEICON (0x0040)
    ; Dadurch wird das Auslösen im leeren Raum rechts vom Text (TVHT_ONITEMRIGHT / 0x0020) verhindert.
    Local Const $TVHT_ONITEM = 0x0046
    If $hItem = 0 Or BitAND($iFlags, $TVHT_ONITEM) = 0 Then
        If $g_iLastTipNode <> -1 Then
            ToolTip("")
            $g_iLastTipNode = -1
        EndIf
        Return
    EndIf

    ; ISO-Index aus Node-Param lesen; Kategorie-Nodes haben Param < 0 oder >= ISO_COUNT
    Local $iParam = _GUICtrlTreeView_GetItemParam($hTV, $hItem)
    If $iParam < 0 Or $iParam >= $ISO_COUNT Then
        If $g_iLastTipNode <> -1 Then
            ToolTip("")
            $g_iLastTipNode = -1
        EndIf
        Return
    EndIf

    ; Gleicher Node → kein Flackern
    If $iParam = $g_iLastTipNode Then Return
    $g_iLastTipNode = $iParam

    ; Highlights-Text aus Spalte [9] in nativem Windows-Tooltip mit Titel anzeigen
    Local $sTip = $g_aISOs[$iParam][9]
    If $sTip = "" Then
        ToolTip("")
    Else
        ToolTip($sTip, $aMouse[0], $aMouse[1], $g_aISOs[$iParam][0], 1)
    EndIf
EndFunc

Func _RemoteSize($sURL)
    Local $sCurl = _CurlPath()
    If $sCurl = "" Or $sURL = "" Then Return 0

    ; v2.27: Schnelle HEAD-Anfrage — max. 8s Gesamtzeit (statt früher 47s)
    ; Kein Fallback-Kettenbetrieb mehr, der das Programm einfriert.
    Local $sArgs = '-sI -L --max-time 8 --connect-timeout 5 ' & _
                   '--ssl-no-revoke ' & _
                   '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                   '-H "Accept-Encoding: identity" ' & _
                   '"' & $sURL & '"'

    Local $iPID = Run('"' & $sCurl & '" ' & $sArgs, "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
    If $iPID = 0 Then Return 0

    Local $sOut = ""
    Local $tTimeout = TimerInit()
    While ProcessExists($iPID) And TimerDiff($tTimeout) < 9000
        $sOut &= StdoutRead($iPID)
        Sleep(50)
    WEnd
    If ProcessExists($iPID) Then
        ProcessClose($iPID)
        _Log("  _RemoteSize: Timeout (8s) für " & $sURL)
        Return 0
    EndIf
    $sOut &= StdoutRead($iPID)

    ; Letzten Content-Length-Wert nach Redirect-Kette nehmen
    Local $aM = StringRegExp($sOut, '(?i)content-length:\s*(\d+)', 3)
    If IsArray($aM) And UBound($aM) > 0 Then
        Return Number($aM[UBound($aM)-1])
    EndIf
    Return 0
EndFunc

Func _FmtBytes($n)
    If $n >= 1073741824 Then Return Round($n / 1073741824, 2) & " GB"
    If $n >= 1048576    Then Return Round($n / 1048576,    1) & " MB"
    If $n >= 1024       Then Return Round($n / 1024,       0) & " KB"
    Return $n & " B"
EndFunc

Func _FmtTime($iS)
    If $iS <= 0 Then Return ""
    If $iS > 3600 Then Return Int($iS/3600) & "h " & Int(Mod($iS,3600)/60) & "m"
    If $iS > 60   Then Return Int($iS/60)   & "m " & Int(Mod($iS,60))      & "s"
    Return Int($iS) & "s"
EndFunc

Func _Status($s)
    GUICtrlSetData($g_hStatusLbl, $s)
EndFunc

Func _Log($s)
    Local $sLine = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $s
    
    ; Log-Edit (nur wenn GUI bereits existiert)
    If $g_hLogEdit <> 0 Then
        Local $sCur = GUICtrlRead($g_hLogEdit)
        GUICtrlSetData($g_hLogEdit, $sCur & $sLine & @CRLF)
        _SendMessage(GUICtrlGetHandle($g_hLogEdit), $EM_LINESCROLL, 0, 99999)
    EndIf
    
    ; Log-Datei
    Local $hF = FileOpen($LOG_FILE, 1)
    If $hF <> -1 Then
        FileWriteLine($hF, $sLine)
        FileClose($hF)
    EndIf
EndFunc

Func _Resize()
    Local $a = WinGetClientSize($g_hMain)
    If Not IsArray($a) Then Return
    Local $iW = $a[0], $iH = $a[1]
    If $iW < 850 Then $iW = 850 ; Mindestbreite erhöht für modulares Design
    If $iH < 600 Then $iH = 600

    ; --- 1. HEADER (Fix: 60px) ---
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hHdrBg), 0, 0, $iW, 60)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hHdrAccent), 0, 0, 5, 60)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hBtnHelp), $iW - 62, 18, 50, 24)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hBtnModeToggle), $iW - 180, 18, 112, 24)

    ; --- 2. DRIVE PANEL (Fix: 80px ab Y=68) ---
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hDrivePanelBg), 8, 68, $iW - 16, 80)
    ; Status & Speedtest rechtsbündig im Panel
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hStatusLbl), $iW - 310, 85, 290, 18)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hSpeedTestStatus), $iW - 310, 105, 290, 14)

    ; --- 3. CONTENT TABS (Flexibel) ---
    Local $iTabH = $iH - 280
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hTab), 8, 156, $iW - 16, $iTabH)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hDistroLbl), 22, 186, 400, 15)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hChkShowInfo), $iW - 240, 184, 220, 18)
    
    ; TreeView & Log
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hTreeView), 18, 208, $iW - 36, $iTabH - 148)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hLogEdit),  18, 190, $iW - 36, $iTabH - 130)
    
    ; Progress (Anker am Tab-Boden)
    Local $iProgY = 156 + $iTabH - 35
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hProgress), 18, $iProgY + 15, $iW - 36, 12)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hSpeedLbl), 18, $iProgY - 3,  220, 15)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hEtaLbl),   248, $iProgY - 3,  240, 15)

    ; --- 4. ACTION BAR (Anker am Fenster-Boden) ---
    Local $iActionY = $iH - 110
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hActionPanelBg), 0, $iActionY, $iW, 110)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hActionBorder), 0, $iActionY, $iW, 1)
    
    ; Zeile 1
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hBtnDownload), 18,  $iActionY + 15, 250, 36)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hBtnUpdates),  276, $iActionY + 15, 210, 36)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hBtnCancel),   494, $iActionY + 15, 140, 36)
    
    ; Zeile 2
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hBtnCheckURLs), 18,  $iActionY + 60, 160, 28)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hBtnISOSearch), 186, $iActionY + 60, 150, 28)
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hBtnEditDB),    344, $iActionY + 60, 140, 28)
    
    ; Footer
    ControlMove($g_hMain, "", GUICtrlGetHandle($g_hFooterLbl), 500, $iActionY + 67, $iW - 518, 14)
EndFunc

Func _WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
    Local $hTV = GUICtrlGetHandle($g_hTreeView)
    If $wParam = $hTV Or $wParam = $g_hTreeView Then
        Local $tNMHDR = DllStructCreate("hwnd hwndFrom;uint_ptr idFrom;int code", $lParam)
        Local $iCode = DllStructGetData($tNMHDR, "code")

        ; NM_CUSTOMDRAW — @AutoItX64-abhängige Struct-Definition
        ; ─────────────────────────────────────────────────────────────────
        ; 32-Bit AutoIt: NMHDR=12B → dwDrawStage@12, lItemlParam@44, clrText@48
        ;   struct: byte[12];dword;byte[28];ptr;dword;dword
        ; 64-Bit AutoIt: NMHDR=24B → dwDrawStage@24, lItemlParam@72, clrText@80
        ;   struct: byte[24];dword;byte[44];uint_ptr;dword;dword
        ; Das frühere byte[24] war NUR auf 64-Bit korrekt → 32-Bit zeigte immer Schwarz.
        ; ─────────────────────────────────────────────────────────────────
        If $iCode = -12 Then   ; NM_CUSTOMDRAW
            Local $tNMTVCD
            If @AutoItX64 Then
                $tNMTVCD = DllStructCreate( _
                    "byte[24];dword dwDrawStage;byte[44];uint_ptr lItemlParam;dword clrText;dword clrTextBk", _
                    $lParam)
            Else
                $tNMTVCD = DllStructCreate( _
                    "byte[12];dword dwDrawStage;byte[28];ptr lItemlParam;dword clrText;dword clrTextBk", _
                    $lParam)
            EndIf
            Local $iStage = DllStructGetData($tNMTVCD, "dwDrawStage")
            If $iStage = 1 Then Return 0x20          ; CDDS_PREPAINT → CDRF_NOTIFYITEMDRAW
            If $iStage = 0x10001 Then                 ; CDDS_ITEMPREPAINT → Item einfärben
                Local $iNodeParam = DllStructGetData($tNMTVCD, "lItemlParam")
                If $iNodeParam >= 0 And $iNodeParam < $ISO_COUNT Then
                    Local $iCR
                    Switch $g_aiNodeColor[$iNodeParam]
                        Case 1   ; Grün — auf Stick aktuell / URL aktuell
                            $iCR = BitOR(BitShift(BitAND($C_GRN,0xFF0000),16),BitAND($C_GRN,0xFF00),BitShift(BitAND($C_GRN,0xFF),-16))
                        Case 2   ; Orange — USB veraltet / Update verfügbar
                            $iCR = BitOR(BitShift(BitAND($C_AMB,0xFF0000),16),BitAND($C_AMB,0xFF00),BitShift(BitAND($C_AMB,0xFF),-16))
                        Case 3   ; Rot — URL nicht erreichbar
                            $iCR = BitOR(BitShift(BitAND($C_RED,0xFF0000),16),BitAND($C_RED,0xFF00),BitShift(BitAND($C_RED,0xFF),-16))
                        Case 4   ; Grau — kein URL gespeichert
                            $iCR = BitOR(BitShift(BitAND($C_DIM,0xFF0000),16),BitAND($C_DIM,0xFF00),BitShift(BitAND($C_DIM,0xFF),-16))
                        Case 5   ; Teal — vom USB-Stick importiert (v2.23)
                            $iCR = BitOR(BitShift(BitAND($C_TEAL,0xFF0000),16),BitAND($C_TEAL,0xFF00),BitShift(BitAND($C_TEAL,0xFF),-16))
                        Case Else  ; Standard (0)
                            $iCR = BitOR(BitShift(BitAND($C_TXT,0xFF0000),16),BitAND($C_TXT,0xFF00),BitShift(BitAND($C_TXT,0xFF),-16))
                    EndSwitch
                    DllStructSetData($tNMTVCD, "clrText", $iCR)
                    Return 0x2   ; CDRF_NEWFONT
                EndIf
                Return 0
            EndIf
            Return 0
        EndIf

        ; Drag-and-Drop — TVN_BEGINDRAG (ANSI -150 oder Unicode -407)
        If $iCode = -150 Or $iCode = -407 Then
            ; Quell-Item anhand aktueller Mausposition bestimmen
            Local $aCurPos = MouseGetPos()
            Local $tPt = DllStructCreate("long X;long Y")
            DllStructSetData($tPt, "X", $aCurPos[0])
            DllStructSetData($tPt, "Y", $aCurPos[1])
            DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $hTV, "struct*", $tPt)
            Local $hHitItem = _GUICtrlTreeView_HitTest($hTV, _
                DllStructGetData($tPt, "X"), DllStructGetData($tPt, "Y"))
            If $hHitItem <> 0 Then
                Local $iParam = _GUICtrlTreeView_GetItemParam($hTV, $hHitItem)
                If $iParam >= 0 And $iParam < $ISO_COUNT Then
                    $g_bDragging = True
                    $g_iDragISO  = $iParam
                EndIf
            EndIf
            Return 0
        EndIf
        Return 0  ; alle TV-Notifications konsumieren — _SyncCategoryCheckboxes übernimmt
    EndIf
    Return $GUI_RUNDEFMSG
EndFunc

Func _WM_LBUTTONUP($hWnd, $iMsg, $wParam, $lParam)
    If Not $g_bDragging Then Return $GUI_RUNDEFMSG
    $g_bDragging = False
    Local $iSrcISO = $g_iDragISO
    $g_iDragISO = -1

    Local $hTV = GUICtrlGetHandle($g_hTreeView)
    Local $aCurPos = MouseGetPos()
    Local $tPt = DllStructCreate("long X;long Y")
    DllStructSetData($tPt, "X", $aCurPos[0])
    DllStructSetData($tPt, "Y", $aCurPos[1])
    DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $hTV, "struct*", $tPt)
    Local $hHitItem = _GUICtrlTreeView_HitTest($hTV, _
        DllStructGetData($tPt, "X"), DllStructGetData($tPt, "Y"))
    If $hHitItem = 0 Then Return $GUI_RUNDEFMSG

    ; Kategorie-Nodes direkt als Drop-Ziel prüfen — v2.17: 8 Kategorien
    Local $aCatNames[8] = ["Gaming","Sicherheit","Einsteiger","Fortgeschrittene","Leichtgewichtig","Rettung","Antivirus","WinPE"]
    For $iCat = 0 To 4
        If $hHitItem = $g_ahCatNodes[$iCat] Then
            ; Drop auf Kategorie-Header → ISO in diese Kategorie verschieben
            If $g_aISOs[$iSrcISO][1] <> $aCatNames[$iCat] Then
                _MoveISOToCategory($iSrcISO, $aCatNames[$iCat])
            EndIf
            Return $GUI_RUNDEFMSG
        EndIf
    Next

    ; Drop auf ISO-Node → Positionen tauschen
    Local $iTargetISO = _GUICtrlTreeView_GetItemParam($hTV, $hHitItem)
    If $iTargetISO < 0 Or $iTargetISO >= $ISO_COUNT Then Return $GUI_RUNDEFMSG
    If $iTargetISO = $iSrcISO Then Return $GUI_RUNDEFMSG

    _SwapISOs($iSrcISO, $iTargetISO)
    Return $GUI_RUNDEFMSG
EndFunc

Func _FetchMirrorDir($sURL, $sCurl)
    Local $sTmp = @TempDir & "\ulm_dirlist.html"
    FileDelete($sTmp)
    Local $sArgs = '-s -L --max-time 12 --connect-timeout 8 --ssl-no-revoke ' & _
                   '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                   '-o "' & $sTmp & '" "' & $sURL & '"'
    Local $iPID = Run('"' & $sCurl & '" ' & $sArgs, "", @SW_HIDE)
    If $iPID <> 0 Then
        Local $tFetch = TimerInit()
        While ProcessExists($iPID) And TimerDiff($tFetch) < 13000
            Local $evF = GUIGetMsg()
            If $evF = $GUI_EVENT_CLOSE Then
                ProcessClose($iPID)
                _Quit()
            EndIf
            If $evF = $g_hBtnCancel Or ($g_hPopCancel <> 0 And $evF = $g_hPopCancel) Then
                $g_bCancel = True
            EndIf
            If $g_bCancel Then
                ProcessClose($iPID)
                Return ""
            EndIf
            Sleep(50)
        WEnd
        If ProcessExists($iPID) Then ProcessClose($iPID)
    EndIf
    If Not FileExists($sTmp) Then Return ""
    Local $hF = FileOpen($sTmp, 0)
    If $hF = -1 Then Return ""
    Local $sHTML = FileRead($hF)
    FileClose($hF)
    FileDelete($sTmp)
    Return $sHTML
EndFunc

Func _VersionNewer($sNew, $sCurr)
    If $sNew = "" Then Return False
    If $sCurr = "" Then Return True   ; v2.28 Fix: Erlaubt Initial-Vergleich in Loops
    If $sNew = $sCurr Then Return False
    Local $aNew = StringSplit($sNew, ".")
    Local $aCur = StringSplit($sCurr, ".")
    Local $iMax = $aNew[0]
    If $aCur[0] > $iMax Then $iMax = $aCur[0]
    For $p = 1 To $iMax
        Local $iN = 0
        Local $iC = 0
        If $p <= $aNew[0] Then $iN = Int($aNew[$p])
        If $p <= $aCur[0] Then $iC = Int($aCur[$p])
        If $iN > $iC Then Return True
        If $iN < $iC Then Return False
    Next
    Return False
EndFunc

Func _AutoApplyUpdate($iIdx)
    If $iIdx < 0 Or $iIdx >= $ISO_COUNT Or $iIdx >= $ISO_MAX Then Return False
    If $g_asUpdateVer[$iIdx] = "" Or $g_asUpdateURL[$iIdx] = "" Then Return False

    Local $sNewVer  = $g_asUpdateVer[$iIdx]
    Local $sNewURL  = $g_asUpdateURL[$iIdx]
    Local $sNewFile = $g_asUpdateFile[$iIdx]
    Local $bChanged = False

    ; ── Primäre URL aktualisieren ─────────────────────────────────────────────
    If $g_aISOs[$iIdx][2] <> $sNewURL Then
        _Log("  [AutoUpdate] URL: " & $g_aISOs[$iIdx][2] & "  →  " & $sNewURL)
        $g_aISOs[$iIdx][2] = $sNewURL
        $bChanged = True
    EndIf

    ; ── Dateiname aktualisieren ───────────────────────────────────────────────
    If $sNewFile <> "" And $g_aISOs[$iIdx][3] <> $sNewFile Then
        _Log("  [AutoUpdate] Datei: " & $g_aISOs[$iIdx][3] & "  →  " & $sNewFile)
        $g_aISOs[$iIdx][3] = $sNewFile
        $bChanged = True
        ; Wenn Dateiname geändert → Stick-Status auf "veraltet" (alter Dateiname stimmt nicht mehr)
        If $g_aiUSBStatus[$iIdx] = 1 Then
            $g_aiUSBStatus[$iIdx] = 2
            _Log("  [AutoUpdate] USB-Status → veraltet (neuer Dateiname: " & $sNewFile & ")")
        EndIf
    EndIf

    ; ── Anzeigename aktualisieren (Versionsnummer ersetzen) ───────────────────
    ; Strategie: alle \d+\.\d+[\.\d]* Muster im Namen durch neue Version ersetzen
    Local $sOldName = $g_aISOs[$iIdx][0]
    Local $sNewName = $sOldName
    ; FIX: $sOldVer VOR dem "latest"-If deklarieren — sonst undeklarariert wenn
    ;            $sNewVer = "latest" (z.B. HBCD, krd) und Zeile 10566 "Variable not declared"
    Local $sOldVer = ""
    If $sNewVer <> "latest" Then
        ; Altes Versions-Pattern finden und ersetzen
        ; FIX: Regex erkennt jetzt auch reine Ganzzahlen (z.B. "41" in "Nobara Linux 41")
        ;            Vorher nur \d+\.\d+ → "41" wurde nicht erkannt → Version wurde angehängt statt ersetzt
        $sOldVer = ""
        Local $aOV = StringRegExp($sOldName, "([\d]+(?:\.[\d]+)*)", 1)
        If Not @error Then $sOldVer = $aOV[0]

        If $sOldVer <> "" And $sOldVer <> $sNewVer Then
            ; Versionsnummer ersetzen (StringReplace ist sicherer als Regex hier)
            $sNewName = StringReplace($sOldName, $sOldVer, $sNewVer, 1)
            If $sNewName <> $sOldName Then
                _Log("  [AutoUpdate] Name: '" & $sOldName & "'  →  '" & $sNewName & "'")
                $g_aISOs[$iIdx][0] = $sNewName
                $bChanged = True
            EndIf
        ElseIf $sOldVer = "" Then
            ; Keine Versionsnummer im Namen — Version anhängen, sofern noch nicht vorhanden
            ; Verhindert wiederholtes Anhängen (z.B. "Zorin OS 18 Core 18 18 18...")
            If Not StringRegExp($sOldName, "(^|[^0-9])" & $sNewVer & "([^0-9]|$)") Then
                $sNewName = $sOldName & " " & $sNewVer
                _Log("  [AutoUpdate] Name (Version ergänzt): '" & $sNewName & "'")
                $g_aISOs[$iIdx][0] = $sNewName
                $bChanged = True
            EndIf
        EndIf
    EndIf

    ; ── v2.12: Mirror-URLs [4] und [5] mitaktualisieren ──────────────────────
    ; Wenn sich die Versionsnummer im Primär-URL geändert hat, werden auch Mirror-URLs
    ; automatisch aktualisiert (sofern sie das gleiche Versionsformat enthalten).
    ; Verhindert, dass Tails-Mirror [4]/[5] auf alte 7.6-URL zeigen wenn Primary auf 7.7 wechselt.
    If $sOldVer <> "" And $sNewVer <> "" And $sOldVer <> $sNewVer Then
        For $__m = 4 To 5
            Local $sMirrorURL = $g_aISOs[$iIdx][$__m]
            If $sMirrorURL = "" Then ContinueLoop
            If Not StringInStr($sMirrorURL, $sOldVer) Then ContinueLoop
            Local $sNewMirrorURL = StringReplace($sMirrorURL, $sOldVer, $sNewVer, 0)
            If $sNewMirrorURL <> $sMirrorURL Then
                _Log("  [AutoUpdate] Mirror[" & $__m & "]: '" & $sMirrorURL & "'  →  '" & $sNewMirrorURL & "'")
                $g_aISOs[$iIdx][$__m] = $sNewMirrorURL
                $bChanged = True
            EndIf
        Next
    EndIf

    ; ── Update-Marker zurücksetzen ────────────────────────────────────────────
    $g_asUpdateVer[$iIdx]  = ""
    $g_asUpdateURL[$iIdx]  = ""
    $g_asUpdateFile[$iIdx] = ""

    ; ── Datenbank speichern ───────────────────────────────────────────────────
    If $bChanged Then
        _SaveIsoDB()
        _Log("  [AutoUpdate] DB gespeichert — " & $g_aISOs[$iIdx][0])
    EndIf
    Return $bChanged
EndFunc

; =============================================================================
; _OnCleanupBrokenDownloads
; Bereinigt abgebrochene/unvollständige Downloads lokal (TMP + Download-Ordner)
; und optional auch vom USB-Stick. Zeigt eine Abfrage vor dem Löschen.
; =============================================================================
Func _OnCleanupBrokenDownloads($bSilentIfNone = False)
    If $g_bBusy Then
        MsgBox(48, "Beschäftigt", "Bitte warte, bis der laufende Vorgang abgeschlossen ist.")
        Return
    EndIf

    _Log("=== Bereinigung: Suche nach abgebrochenen/unvollständigen Downloads ===")

    ; ------------------------------------------------------------------
    ; SCHRITT 1: TMP-Ordner scannen (laufende / abgebrochene Downloads)
    ; ------------------------------------------------------------------
    Local $aTmpBroken[0]        ; Pfade
    Local $aTmpBrokenSize[0]    ; Größen (formatiert)

    If FileExists($TMP_DOWNLOAD_DIR) Then
        Local $aTmp = _FileListToArray($TMP_DOWNLOAD_DIR, "*.iso", 1)
        If Not @error And IsArray($aTmp) Then
            For $f = 1 To $aTmp[0]
                Local $sPath = $TMP_DOWNLOAD_DIR & "\" & $aTmp[$f]
                Local $iSz   = FileGetSize($sPath)
                ; Unter 50 MB → definitiv unvollständig
                Local $bBroken = ($iSz < 52428800)
                If Not $bBroken Then
                    ; Größenvergleich mit Datenbank
                    For $i = 0 To $ISO_COUNT - 1
                        If StringLower($aTmp[$f]) = StringLower($g_aISOs[$i][3]) Then
                            Local $iExp = _GetExpectedSize($i, $iSz)
                            If $iExp > 0 And ($iSz / $iExp) < 0.95 Then
                                $bBroken = True
                            EndIf
                            ExitLoop
                        EndIf
                    Next
                EndIf
                If $bBroken Then
                    _ArrayAdd($aTmpBroken,     $sPath)
                    _ArrayAdd($aTmpBrokenSize, _FmtBytes($iSz))
                EndIf
            Next
        EndIf
    EndIf

    ; ------------------------------------------------------------------
    ; SCHRITT 2: Haupt-Download-Ordner scannen (sehr kleine / 0-Byte Dateien)
    ; ------------------------------------------------------------------
    Local $aLocalBroken[0]
    Local $aLocalBrokenSize[0]

    If FileExists($DOWNLOAD_DIR) Then
        Local $aLocal = _FileListToArray($DOWNLOAD_DIR, "*.iso", 1)
        If Not @error And IsArray($aLocal) Then
            For $f = 1 To $aLocal[0]
                Local $sPath = $DOWNLOAD_DIR & "\" & $aLocal[$f]
                Local $iSz   = FileGetSize($sPath)
                ; Unter 50 MB → unvollständiger Download
                If $iSz < 52428800 Then
                    _ArrayAdd($aLocalBroken,     $sPath)
                    _ArrayAdd($aLocalBrokenSize, _FmtBytes($iSz))
                EndIf
            Next
        EndIf
    EndIf

    ; ------------------------------------------------------------------
    ; SCHRITT 3: USB-Stick scannen (falls ausgewählt)
    ; ------------------------------------------------------------------
    Local $aStickBroken[0]
    Local $aStickBrokenSize[0]
    Local $sDrive = _GetSelectedDrive()

    If $sDrive <> "" And DriveStatus($sDrive) = "READY" Then
        Local $aStick = _FileListToArrayRec($sDrive, "*.iso", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
        If Not @error And IsArray($aStick) And $aStick[0] > 0 Then
            For $k = 1 To $aStick[0]
                Local $sPath = $aStick[$k]
                Local $iSz   = FileGetSize($sPath)
                Local $sName = StringMid($sPath, StringInStr($sPath, "\", 0, -1) + 1)
                Local $bBroken = ($iSz < 52428800)
                If Not $bBroken Then
                    For $i = 0 To $ISO_COUNT - 1
                        If StringLower($sName) = StringLower($g_aISOs[$i][3]) Then
                            Local $iExp = _GetExpectedSize($i, $iSz)
                            If $iExp > 0 And ($iSz / $iExp) < 0.90 Then
                                $bBroken = True
                            EndIf
                            ExitLoop
                        EndIf
                    Next
                EndIf
                If $bBroken Then
                    _ArrayAdd($aStickBroken,     $sPath)
                    _ArrayAdd($aStickBrokenSize, _FmtBytes($iSz))
                EndIf
            Next
        EndIf
    EndIf

    ; ------------------------------------------------------------------
    ; SCHRITT 4: Zusammenfassung — wenn nichts gefunden
    ; ------------------------------------------------------------------
    Local $iTotalFound = UBound($aTmpBroken) + UBound($aLocalBroken) + UBound($aStickBroken)
    If $iTotalFound = 0 Then
        If Not $bSilentIfNone Then
            MsgBox(64, "Bereinigung ✓", "Keine abgebrochenen oder unvollständigen ISO-Downloads gefunden." & @CRLF & @CRLF & _
                "Alle Dateien in TMP, Download-Ordner" & (($sDrive <> "") ? " und Stick " & $sDrive : "") & " sehen vollständig aus.")
        EndIf
        _Log("=== Bereinigung: Keine unvollständigen Downloads gefunden ===")
        Return
    EndIf

    ; ------------------------------------------------------------------
    ; SCHRITT 5: Abfrage-Dialog aufbauen
    ; ------------------------------------------------------------------
    Local $sMsg = "Folgende unvollständige oder abgebrochene Dateien wurden gefunden:" & @CRLF & @CRLF

    If UBound($aTmpBroken) > 0 Then
        $sMsg &= "📁 TMP-Ordner (" & UBound($aTmpBroken) & " Datei(en)):" & @CRLF
        For $k = 0 To UBound($aTmpBroken) - 1
            $sMsg &= "   • " & StringMid($aTmpBroken[$k], StringInStr($aTmpBroken[$k], "\", 0, -1) + 1) & "  (" & $aTmpBrokenSize[$k] & ")" & @CRLF
        Next
        $sMsg &= @CRLF
    EndIf

    If UBound($aLocalBroken) > 0 Then
        $sMsg &= "📁 Download-Ordner (" & UBound($aLocalBroken) & " Datei(en)):" & @CRLF
        For $k = 0 To UBound($aLocalBroken) - 1
            $sMsg &= "   • " & StringMid($aLocalBroken[$k], StringInStr($aLocalBroken[$k], "\", 0, -1) + 1) & "  (" & $aLocalBrokenSize[$k] & ")" & @CRLF
        Next
        $sMsg &= @CRLF
    EndIf

    If UBound($aStickBroken) > 0 Then
        $sMsg &= "💾 USB-Stick " & $sDrive & " (" & UBound($aStickBroken) & " Datei(en)):" & @CRLF
        For $k = 0 To UBound($aStickBroken) - 1
            $sMsg &= "   • " & StringMid($aStickBroken[$k], StringInStr($aStickBroken[$k], "\", 0, -1) + 1) & "  (" & $aStickBrokenSize[$k] & ")" & @CRLF
        Next
        $sMsg &= @CRLF
    EndIf

    $sMsg &= "Alle " & $iTotalFound & " Datei(en) jetzt löschen?"

    Local $iAnswer = MsgBox(292, "🗑 Abgebrochene Downloads bereinigen?", $sMsg)
    If $iAnswer <> 6 Then
        _Log("=== Bereinigung: Vom Benutzer abgebrochen ===")
        Return
    EndIf

    ; ------------------------------------------------------------------
    ; SCHRITT 6: Löschen
    ; ------------------------------------------------------------------
    Local $iDeleted = 0, $iFailed = 0

    For $k = 0 To UBound($aTmpBroken) - 1
        If FileDelete($aTmpBroken[$k]) Then
            $iDeleted += 1
            _Log("  [TMP gelöscht] " & $aTmpBroken[$k])
        Else
            $iFailed += 1
            _Log("  [FEHLER] Konnte nicht löschen: " & $aTmpBroken[$k])
        EndIf
    Next

    For $k = 0 To UBound($aLocalBroken) - 1
        If FileDelete($aLocalBroken[$k]) Then
            $iDeleted += 1
            _Log("  [Lokal gelöscht] " & $aLocalBroken[$k])
        Else
            $iFailed += 1
            _Log("  [FEHLER] Konnte nicht löschen: " & $aLocalBroken[$k])
        EndIf
    Next

    For $k = 0 To UBound($aStickBroken) - 1
        If FileDelete($aStickBroken[$k]) Then
            $iDeleted += 1
            _Log("  [Stick gelöscht] " & $aStickBroken[$k])
        Else
            $iFailed += 1
            _Log("  [FEHLER] Konnte nicht löschen: " & $aStickBroken[$k])
        EndIf
    Next

    _Log("=== Bereinigung abgeschlossen: " & $iDeleted & " gelöscht, " & $iFailed & " Fehler ===")

    ; Baumansicht aktualisieren
    _FillTree()
    _Status("🗑 Bereinigung: " & $iDeleted & " unvollständige ISO(s) gelöscht" & (($iFailed > 0) ? ", " & $iFailed & " Fehler." : "."))

    If $iFailed > 0 Then
        MsgBox(48, "Bereinigung abgeschlossen", $iDeleted & " Datei(en) gelöscht." & @CRLF & $iFailed & " Datei(en) konnten nicht gelöscht werden (evtl. noch in Verwendung).")
    Else
        MsgBox(64, "Bereinigung ✓", $iDeleted & " unvollständige Datei(en) erfolgreich gelöscht.")
    EndIf
EndFunc

Func _CleanupIncompleteTmp()
    If Not FileExists($TMP_DOWNLOAD_DIR) Then Return

    _Log("=== TMP-Cleanup: prüfe unvollständige Downloads ===")
    
    Local $aFiles = _FileListToArray($TMP_DOWNLOAD_DIR, "*.iso", 1)
    If @error Or Not IsArray($aFiles) Then
        _Log("    TMP leer oder kein Zugriff.")
        Return
    EndIf

    Local $iIncompleteCount = 0
    Local $sIncompleteList = ""
    Local $aIsIncomplete[$aFiles[0] + 1]
    
    For $f = 1 To $aFiles[0]
        Local $sPath = $TMP_DOWNLOAD_DIR & "\" & $aFiles[$f]
        Local $iSize = FileGetSize($sPath)
        Local $bIncomplete = False

        If $iSize < 52428800 Then
            $bIncomplete = True
        Else
            Local $iExpected = 0
            For $i = 0 To $ISO_COUNT - 1
                If StringLower($aFiles[$f]) = StringLower($g_aISOs[$i][3]) Then
                    If $g_aISOs[$i][2] <> "" Then
                        $iExpected = _RemoteSize($g_aISOs[$i][2])
                    Endif
                    If $iExpected = 0 And $g_aISOs[$i][4] <> "" Then
                        $iExpected = _RemoteSize($g_aISOs[$i][4])
                    EndIf
                    ExitLoop
                EndIf
            Next

            If $iExpected > 0 Then
                Local $fRatio = $iSize / $iExpected
                If $fRatio < 0.95 Then
                    $bIncomplete = True
                EndIf
            EndIf
        EndIf

        If $bIncomplete Then
            $aIsIncomplete[$f] = True
            $iIncompleteCount += 1
            $sIncompleteList &= "  • " & $aFiles[$f] & " (" & _FmtBytes($iSize) & ")" & @CRLF
        Else
            $aIsIncomplete[$f] = False
        EndIf
    Next

    If $iIncompleteCount = 0 Then
        _Log("    Keine unvollständigen Downloads gefunden.")
        Return
    EndIf

    ; Benutzer um Bestätigung fragen
    Local $iAsk = MsgBox(308, "Unvollständige Downloads bereinigen?", _
        "Es wurden " & $iIncompleteCount & " unvollständige Downloads im temporären Verzeichnis gefunden:" & @CRLF & @CRLF & _
        $sIncompleteList & @CRLF & _
        "Möchten Sie diese unvollständigen Dateien jetzt löschen, um Speicherplatz freizugeben?")
    
    If $iAsk <> 6 Then
        _Log("=== TMP-Cleanup: Vom Benutzer abgebrochen (Dateien behalten) ===")
        Return
    EndIf

    Local $iDeleted = 0
    For $f = 1 To $aFiles[0]
        If $aIsIncomplete[$f] Then
            Local $sPath = $TMP_DOWNLOAD_DIR & "\" & $aFiles[$f]
            FileDelete($sPath)
            If Not FileExists($sPath) Then
                $iDeleted += 1
                _Log("    🗑 Gelöscht: " & $aFiles[$f])
            EndIf
        EndIf
    Next

    _Log("=== TMP-Cleanup: " & $iDeleted & " unvollständige Downloads gelöscht ===")
    If $iDeleted > 0 Then
        _Status("🗑 TMP-Bereinigung: " & $iDeleted & " unvollständige ISO(s) gelöscht.")
        _FillTree()
    EndIf
EndFunc

Func _PreTestAllMirrors(ByRef $aQueue, $iCount)
    Local $sCurl = _CurlPath()
    If $sCurl = "" Then Return

    If Not FileExists($TMP_DOWNLOAD_DIR) Then DirCreate($TMP_DOWNLOAD_DIR)

    ; ── Aufbau der Test-Datenstruktur ─────────────────────────────────────
    ; Pro ISO: bis zu 4 testbare URLs (Primär + Mirror1-3); GitHub bleibt ausgenommen
    Local Const $MAX_URLS = 4
    Local $aTstURL[$iCount][$MAX_URLS]   ; URLs je Queue-Slot je Mirror
    Local $aTstPID[$iCount][$MAX_URLS]   ; curl-PIDs
    Local $aTstFile[$iCount][$MAX_URLS]  ; Temp-Dateien
    Local $aTstStart[$iCount][$MAX_URLS] ; TimerInit-Werte
    Local $aTstCount[$iCount]            ; Anzahl testbarer URLs je Slot
    Local $aGHSlot[$iCount]              ; 1 = GitHub-Slot vorhanden (wird nicht mit getestet)
    Local $iTotal = 0

    _Log("  [PreMirrorTest] Starte parallele Mirror-Prüfung für " & $iCount & " ISO(s) ...")

    For $q = 0 To $iCount - 1
        Local $iIdx  = $aQueue[$q]
        Local $iUC   = 0
        Local $bGH   = ($g_aISOs[$iIdx][6] <> "")   ; GitHub-Repo vorhanden?
        $aGHSlot[$q] = $bGH ? 1 : 0

        ; Primär-URL + Mirror1 + Mirror2 + Mirror3 in Test-Array
        If $g_aISOs[$iIdx][2] <> "" And $iUC < $MAX_URLS Then
            $aTstURL[$q][$iUC] = $g_aISOs[$iIdx][2]
            $iUC += 1
        EndIf
        If $g_aISOs[$iIdx][4] <> "" And $iUC < $MAX_URLS Then
            $aTstURL[$q][$iUC] = $g_aISOs[$iIdx][4]
            $iUC += 1
        EndIf
        If $g_aISOs[$iIdx][5] <> "" And $iUC < $MAX_URLS Then
            $aTstURL[$q][$iUC] = $g_aISOs[$iIdx][5]
            $iUC += 1
        EndIf
        If $g_aISOs[$iIdx][8] <> "" And $iUC < $MAX_URLS Then
            $aTstURL[$q][$iUC] = $g_aISOs[$iIdx][8]
            $iUC += 1
        EndIf

        $aTstCount[$q] = $iUC

        ; curl-Prozesse parallel starten (2s Chunk-Download pro Mirror)
        For $u = 0 To $iUC - 1
            Local $sURL = $aTstURL[$q][$u]
            Local $sDst = $TMP_DOWNLOAD_DIR & "\ulm_pre_" & $q & "_" & $u & ".tmp"
            $aTstFile[$q][$u]  = $sDst
            $aTstPID[$q][$u]   = 0
            $aTstStart[$q][$u] = 0
            FileDelete($sDst)

            Local $sArgs = '-s -L --fail --max-time 2 --connect-timeout 4 ' & _
                           '--limit-rate 0 ' & _
                           '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                           '-o "' & $sDst & '" "' & $sURL & '"'
            $aTstPID[$q][$u]   = Run('"' & $sCurl & '" ' & $sArgs, "", @SW_HIDE)
            $aTstStart[$q][$u] = TimerInit()
            $iTotal += 1
        Next
    Next

    If $iTotal = 0 Then Return

    ; ── Auf alle Prozesse warten (max 5s gesamt) ──────────────────────────
    Local $tGlobal = TimerInit()
    While TimerDiff($tGlobal) < 5500
        Local $bAllDone = True
        For $q = 0 To $iCount - 1
            For $u = 0 To $aTstCount[$q] - 1
                If $aTstPID[$q][$u] <> 0 And ProcessExists($aTstPID[$q][$u]) Then
                    $bAllDone = False
                    ExitLoop 2
                EndIf
            Next
        Next
        If $bAllDone Then ExitLoop
        Sleep(150)
    WEnd

    ; Laufende Prozesse nach Timeout beenden
    For $q = 0 To $iCount - 1
        For $u = 0 To $aTstCount[$q] - 1
            If $aTstPID[$q][$u] <> 0 And ProcessExists($aTstPID[$q][$u]) Then
                ProcessClose($aTstPID[$q][$u])
            EndIf
        Next
    Next

    ; ── Geschwindigkeiten messen, URLs sortieren, Cache befüllen ──────────
    For $q = 0 To $iCount - 1
        Local $iIdx   = $aQueue[$q]
        Local $iUC    = $aTstCount[$q]
        If $iUC = 0 Then ContinueLoop

        Local $aSpeeds[$iUC]
        For $u = 0 To $iUC - 1
            $aSpeeds[$u] = 0
            Local $sDst2 = $aTstFile[$q][$u]
            If $sDst2 <> "" And FileExists($sDst2) Then
                Local $iBytes  = FileGetSize($sDst2)
                Local $iElMs   = TimerDiff($aTstStart[$q][$u])
                If $iElMs > 100 And $iBytes > 0 Then
                    $aSpeeds[$u] = Int($iBytes / ($iElMs / 1000))
                EndIf
                FileDelete($sDst2)
                _Log("    [Pre] ISO#" & $iIdx & " URL" & $u & ": " & _FmtBytes($aSpeeds[$u]) & "/s  ← " & $aTstURL[$q][$u])
            EndIf
        Next

        ; Bubble-Sort: schnellster Mirror nach Index 0 (absteigend)
        If $iUC > 1 Then
            For $i = 0 To $iUC - 2
                For $j = 0 To $iUC - 2 - $i
                    If $aSpeeds[$j] < $aSpeeds[$j+1] Then
                        Local $sTmpU2 = $aTstURL[$q][$j]
                        $aTstURL[$q][$j]   = $aTstURL[$q][$j+1]
                        $aTstURL[$q][$j+1] = $sTmpU2
                        Local $iTmpS2 = $aSpeeds[$j]
                        $aSpeeds[$j]   = $aSpeeds[$j+1]
                        $aSpeeds[$j+1] = $iTmpS2
                    EndIf
                Next
            Next
        EndIf

        ; Sortierte URLs als pipe-getrennten String in den Cache schreiben
        Local $sPipe = ""
        For $u = 0 To $iUC - 1
            If $aTstURL[$q][$u] <> "" Then $sPipe &= $aTstURL[$q][$u] & "|"
        Next
        $g_asSortedURLs[$iIdx] = $sPipe

        If $aSpeeds[0] > 0 Then
            _Log("    [Pre] ISO#" & $iIdx & " schnellster Mirror: " & $aTstURL[$q][0] & " (" & _FmtBytes($aSpeeds[0]) & "/s)")
        Else
            _Log("    [Pre] ISO#" & $iIdx & " — kein Mirror reagierte (Fallback: Primär-URL)")
        EndIf
    Next

    _Log("  [PreMirrorTest] Abgeschlossen in " & Int(TimerDiff($tGlobal)) & " ms")
EndFunc

Func _SearchAndDisplay($sQuery, $hEdit, $hCountLbl, $hDlg)
    $g_iSearchHitCount = 0
    Local $sOut = ""
    Local $sQLow = StringLower($sQuery)

    For $i = 0 To $ISO_COUNT - 1
        Local $sName    = $g_aISOs[$i][0]
        Local $sCat     = $g_aISOs[$i][1]
        Local $sTip     = $g_aISOs[$i][9]
        Local $sURLPri  = $g_aISOs[$i][2]
        Local $sURLM1   = $g_aISOs[$i][4]
        Local $sURLM2   = $g_aISOs[$i][5]
        Local $sURLM3   = $g_aISOs[$i][8]

        ; Treffer-Prüfung (Name, Kategorie, Highlights/Tooltip)
        Local $bHit = False
        If $sQuery = "" Then
            $bHit = True
        ElseIf StringInStr(StringLower($sName), $sQLow) Then
            $bHit = True
        ElseIf StringInStr(StringLower($sCat), $sQLow) Then
            $bHit = True
        ElseIf StringInStr(StringLower($sTip), $sQLow) Then
            $bHit = True
        EndIf

        If Not $bHit Then ContinueLoop

        ; Treffer speichern
        $g_aiSearchHits[$g_iSearchHitCount] = $i
        $g_iSearchHitCount += 1

        ; --- Eintrag formatieren ---
        Local $sStatus = ""
        Local $sFileTmp = $TMP_DOWNLOAD_DIR & "\" & $g_aISOs[$i][3]
        Local $sFileLoc = $DOWNLOAD_DIR & "\" & $g_aISOs[$i][3]
        If FileExists($sFileTmp) And FileGetSize($sFileTmp) > 1048576 Then
            $sStatus = "[✓ TMP geladen  " & _FmtBytes(FileGetSize($sFileTmp)) & "]"
        ElseIf FileExists($sFileLoc) And FileGetSize($sFileLoc) > 1048576 Then
            $sStatus = "[✓ lokal vorhanden  " & _FmtBytes(FileGetSize($sFileLoc)) & "]"
        ElseIf $g_aiUSBStatus[$i] = 1 Then
            $sStatus = "[✓ auf USB-Stick]"
        Else
            $sStatus = "[nicht geladen]"
        EndIf

        $sOut &= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" & @CRLF
        $sOut &= "  #" & ($g_iSearchHitCount) & "  " & $sName & "   " & $sStatus & @CRLF
        $sOut &= "  Kategorie: " & $sCat & @CRLF
        $sOut &= @CRLF

        ; Highlights (erste 5 Zeilen aus Tooltip)
        Local $aLines = StringSplit($sTip, @LF, 2)
        Local $iMax = UBound($aLines)
        If $iMax > 6 Then $iMax = 6
        For $l = 1 To $iMax - 1   ; Zeile 0 = Name, ab 1 = Bullets
            $sOut &= "  " & $aLines[$l] & @CRLF
        Next
        $sOut &= @CRLF

        ; Download-Links
        Local $bHasURL = ($sURLPri <> "" Or $sURLM1 <> "" Or $sURLM2 <> "" Or $sURLM3 <> "" Or $g_aISOs[$i][6] <> "")
        If $bHasURL Then
            $sOut &= "  Download-URLs:" & @CRLF
            If $sURLPri <> "" Then $sOut &= "  [Primär]    " & $sURLPri & @CRLF
            If $sURLM1  <> "" Then $sOut &= "  [Mirror 1]  " & $sURLM1 & @CRLF
            If $sURLM2  <> "" Then $sOut &= "  [Mirror 2]  " & $sURLM2 & @CRLF
            If $sURLM3  <> "" Then $sOut &= "  [Mirror 3]  " & $sURLM3 & @CRLF
            If $g_aISOs[$i][6] <> "" Then
                $sOut &= "  [GitHub]     https://github.com/" & $g_aISOs[$i][6] & "/releases/latest" & @CRLF
            EndIf
        Else
            ; Keine URL gespeichert (z.B. vom Stick importiert)
            $sOut &= "  Download-URLs:  (keine gespeichert)" & @CRLF
            $sOut &= "  -> Beim Herunterladen wird automatisch nach einer aktuellen Version gesucht." & @CRLF
        EndIf
        $sOut &= @CRLF
    Next

    If $g_iSearchHitCount = 0 Then
        $sOut = @CRLF & "  Keine Ergebnisse für '" & $sQuery & "'" & @CRLF & @CRLF & _
                "  Tipps:" & @CRLF & _
                "  • Kategorie eingeben: Gaming, Sicherheit, Einsteiger, Fortgeschrittene, Leichtgewichtig" & @CRLF & _
                "  • Distro-Name: Kali, Ubuntu, Mint, Arch, Fedora, Manjaro ..." & @CRLF & _
                "  • Stichwort: NVIDIA, Gaming, Rolling, LTS, Privacy ..."
        GUICtrlSetData($hCountLbl, "  ✗ Kein Ergebnis für: '" & $sQuery & "'")
        GUICtrlSetColor($hCountLbl, $C_RED)
    Else
        GUICtrlSetData($hCountLbl, "  ✓ " & $g_iSearchHitCount & " Treffer  —  " & _
            "Klick auf 'Treffer herunterladen' kreuzt alle im Hauptfenster an")
        GUICtrlSetColor($hCountLbl, $C_GRN)
    EndIf

    GUICtrlSetData($hEdit, $sOut)
    ; Scroll zurück nach oben
    _SendMessage(GUICtrlGetHandle($hEdit), $EM_LINESCROLL, 0, -99999)
EndFunc

Func _WriteLogo($sPath)
    Local $sHex = _
        "424D361B000000000000360000002800000030000000300000000100180000000000001B0000C40E0000C40E00000000000000000000EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFEB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFEB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325FFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325FFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325FFFFFFFFFFFFFFFFFFFFFFFF" & _
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325EB6325" & _
        "EB6325EB6325"
    Local $hF = FileOpen($sPath, 18)   ; 2=schreiben + 16=binär
    If $hF = -1 Then Return False
    FileWrite($hF, Binary("0x" & $sHex))
    FileClose($hF)
    Return True
EndFunc

Func _Quit()
    If $g_bBusy Then
        If MsgBox(308, "Beenden", "Operation läuft noch. Trotzdem beenden?") <> 6 Then Return
        $g_bCancel = True
        If $g_iCurlPID Then ProcessClose($g_iCurlPID)
        If $g_iCurrentProcessPID Then ProcessClose($g_iCurrentProcessPID)
    EndIf
    _Log("Programm beendet.")
    Exit
EndFunc

Func _StartAutoVersionCheck()
    If $g_bAutoVersionCheck Then Return            ; bereits aktiv
    $g_bAutoVersionCheck    = True
    $g_iAutoVersionCheckIdx = 0
    $g_tAutoVersionStep     = TimerInit()
    _Log("=== Auto-Versionscheck gestartet (" & $ISO_COUNT & " Distros) ===")
EndFunc

Func _AutoVersionCheckStep()
    If Not $g_bAutoVersionCheck Then Return
    If TimerDiff($g_tAutoVersionStep) < 8000 Then Return   ; 8 s Pause zwischen den Schritten

    ; Alle Distros geprüft → Abschluss
    If $g_iAutoVersionCheckIdx >= $ISO_COUNT Then
        Local $sTodayDate = @YEAR & "/" & StringRight("0" & @MON, 2) & "/" & StringRight("0" & @MDAY, 2)
        IniWrite($SETTINGS_INI, "App", "LastVersionCheck", $sTodayDate)
        $g_bAutoVersionCheck    = False
        $g_iAutoVersionCheckIdx = 0
        $g_tAutoVersionPeriodic = TimerInit()   ; nächsten periodischen Check starten
        _FillTree()
        _Log("=== Auto-Versionscheck abgeschlossen — nächster Check in " & $AUTO_CHECK_INTERVAL_DAYS & " Tagen ===")
        Return
    EndIf

    Local $sCurl = _CurlPath()
    If $sCurl = "" Then
        $g_bAutoVersionCheck = False
        Return
    EndIf

    Local $iIdx = $g_iAutoVersionCheckIdx
    $g_iAutoVersionCheckIdx += 1
    $g_tAutoVersionStep = TimerInit()

    _Log("[AutoCheck " & $iIdx + 1 & "/" & $ISO_COUNT & "] Prüfe: " & $g_aISOs[$iIdx][0])
    _FindLatestVersionURL($iIdx, $sCurl)

    If $g_asUpdateVer[$iIdx] <> "" Then
        _Log("[AutoCheck] Neuer Stand gefunden: " & $g_aISOs[$iIdx][0] & " → v" & $g_asUpdateVer[$iIdx])
        _AutoApplyUpdate($iIdx)
        _AutoUpdateTooltip($iIdx)   ; Tooltip-Zeile mit neuer Versionsnummer synchronisieren
        _FillTree()                 ; v2.28: Aktualisiere TreeView sofort, um den neuen Stand anzuzeigen!
    EndIf
EndFunc

Func _BackgroundSearchStep()
    Local $sCurl = _CurlPath()
    If $sCurl = "" Or $ISO_COUNT = 0 Then Return

    $g_iBGUpdateIdx += 1
    If $g_iBGUpdateIdx >= $ISO_COUNT Then $g_iBGUpdateIdx = 0

    Local $iIdx = $g_iBGUpdateIdx
    Local $sOldURL = $g_aISOs[$iIdx][2]

    If _FindLatestVersionURL($iIdx, $sCurl) Then
        _AutoApplyUpdate($iIdx)
        _AutoUpdateTooltip($iIdx)
        
        ; Farbe korrigieren falls beim Import keine URL da war
        If $sOldURL = "" And $g_aISOs[$iIdx][2] <> "" Then
            If $g_aiUSBStatus[$iIdx] = 1 Then 
                $g_aiNodeColor[$iIdx] = 1
            Else
                $g_aiNodeColor[$iIdx] = 2
            EndIf
        ElseIf $g_aiUSBStatus[$iIdx] <> 1 Then
            $g_aiNodeColor[$iIdx] = 2   ; standard Update orange
        EndIf
        
        _FillTree()
        _Log("[BG-Search] Erfolgreich: Neues ISO für " & $g_aISOs[$iIdx][0] & " gefunden.")
    EndIf
EndFunc

Func _AutoUpdateTooltip($iIdx)
    Local $sTip  = $g_aISOs[$iIdx][9]
    Local $sName = $g_aISOs[$iIdx][0]
    If $sTip = "" Then Return

    Local $aLines = StringSplit($sTip, @LF, 1)
    If @error Or $aLines[0] < 1 Then Return

    ; Versionsnummer in erster Tooltip-Zeile suchen
    Local $aOldVer = StringRegExp($aLines[1], "([\d]+\.[\d]+(?:\.[\d]+)*)", 1)
    If @error Then Return    ; keine Version in erster Zeile — nichts zu tun

    ; Neue Versionsnummer aus dem (bereits aktualisierten) Anzeigenamen
    Local $aNewVer = StringRegExp($sName, "([\d]+\.[\d]+(?:\.[\d]+)*)", 1)
    If @error Then Return

    If $aOldVer[0] = $aNewVer[0] Then Return   ; identisch — kein Update nötig

    $aLines[1] = StringReplace($aLines[1], $aOldVer[0], $aNewVer[0], 1)

    Local $sNewTip = ""
    Local $k
    For $k = 1 To $aLines[0]
        $sNewTip &= $aLines[$k]
        If $k < $aLines[0] Then $sNewTip &= @LF
    Next
    $g_aISOs[$iIdx][9] = $sNewTip
    _Log("  [AutoCheck] Tooltip aktualisiert: v" & $aOldVer[0] & " → v" & $aNewVer[0])
EndFunc

Func _DaysSinceDate($sDate)
    If $sDate = "" Then Return 9999
    Local $aParts = StringSplit($sDate, "/", 2)
    If UBound($aParts) < 3 Then Return 9999
    Local $iOldJDN = _ULM_JDN(Int($aParts[0]), Int($aParts[1]), Int($aParts[2]))
    Local $iNowJDN = _ULM_JDN(@YEAR, @MON, @MDAY)
    Local $iDiff   = $iNowJDN - $iOldJDN
    Return ($iDiff >= 0 ? $iDiff : 0)
EndFunc

Func _ULM_JDN($y, $m, $d)
    Local $a = Int((14 - $m) / 12)
    Local $yy = $y + 4800 - $a
    Local $mm = $m + 12 * $a - 3
    Return $d + Int((153 * $mm + 2) / 5) + 365 * $yy + Int($yy / 4) - Int($yy / 100) + Int($yy / 400) - 32045
EndFunc

Func _WriteJsonFile($sPath, $sContent)
    Local $hF = FileOpen($sPath, 2 + 256)  ; 2=überschreiben, 256=UTF8-OHNE-BOM (Standard für ventoy.json)
    If $hF = -1 Then
        _Log("  FEHLER: Konnte ventoy.json nicht schreiben: " & $sPath)
        Return
    EndIf
    FileWrite($hF, $sContent)
    FileClose($hF)
EndFunc

