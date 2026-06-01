; Universal ISO Manager v2.27 — Automatisierter ISO-Downloader & USB-Stick-Verwalter
; Aktuelle Version: v2.27  -  Letzter Stand: 27. April 2026
; BEREINIGTE VERSION: Redundante Kommentare und nicht verwendeter Code entfernt.

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ListBoxConstants.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <TreeViewConstants.au3>
#include <GuiTreeView.au3>
#include <Array.au3>
#include <File.au3>
#include <String.au3>
#include <Misc.au3>
#include <GuiTab.au3>
#include <TabConstants.au3>
#include <EditConstants.au3>
#include <SendMessage.au3>
#include <AutoItConstants.au3>

; ===========================================================================
;  GLOBALE KONSTANTEN
; ===========================================================================
Global Const $APP_TITLE     = "Universal ISO Manager v2.27 (Expert Mode Support)"
Global $DOWNLOAD_DIR     = @ScriptDir & "\ISOs"
Global $TMP_DOWNLOAD_DIR = @TempDir   & "\VLM_Downloads"
Global $LOG_FILE         = @ScriptDir & "\vlm_log.txt"
Global Const $WS_EX_DROPSHADOW = 0x00020000

; ===========================================================================
;  ISO DATENBANK KONSTANTEN
; ===========================================================================
Global Const $ISO_MAX    = 64
Global $ISO_DB_INI  = @ScriptDir & "\vlm_isos.ini"
Global $URL_INI     = @ScriptDir & "\vlm_user_urls.ini"
Global Const $SETTINGS_INI = @ScriptDir & "\vlm_settings.ini"

; ===========================================================================
;  GLARY UTILITIES DESIGN SYSTEM — Farben (v14.94)
; ===========================================================================
Global Const $C_BG   = 0xF0F4F8    ; Glary Hauptflaeche
Global Const $C_W    = 0xFFFFFF    ; Reines Weiss
Global Const $C_CARD = 0xE4EBF2    ; Stahlblau-Grau
Global Const $C_HDR  = 0x122650    ; Glary Navy
Global Const $C_BLUE = 0x0075BE    ; Glary Corporate Blue
Global Const $C_LBLU = 0xD6ECFA    ; Hellblau-Tint
Global Const $C_RED  = 0xC0392B    ; Klares Rot
Global Const $C_LRED = 0xFDE8E8    ; Rot tint
Global Const $C_GRN  = 0x27AE60    ; Sauberes Gruen
Global Const $C_LGRN = 0xE8F8F0    ; Gruen tint
Global Const $C_AMB  = 0xE67E22    ; Orange
Global Const $C_LAMB = 0xFEF5E7    ; Orange tint
Global Const $C_TEAL = 0x1ABC9C    ; Türkis/Teal
Global Const $C_TXT  = 0x1A2B3C    ; Dunkles Navy
Global Const $C_MID  = 0x4A6785    ; Mittleres Blau-Grau
Global Const $C_DIM  = 0x8BA3BE    ; Gedaempftes Blau-Grau
Global Const $C_BRD  = 0xC5D5E5    ; Kühle Blau-Grau Linie

; ===========================================================================
;  GLOBALE VARIABLEN
; ===========================================================================
Global $g_hMain, $g_hTab
Global $g_hTabItemISO = 0, $g_hTabItemLog = 0, $g_hIsoTable = 0
Global $g_hDriveCombo, $g_hBtnRefresh, $g_hBtnFormat, $g_hBtnVentoy
Global $sCurl = ""
Global $g_bFormatRequested = False
Global $g_hTreeView, $g_hProgress, $g_hStatusLbl
Global $g_hBtnDownload, $g_hBtnUpdates, $g_hBtnCancel
Global $g_hLogEdit, $g_hSpeedLbl, $g_hEtaLbl

; Popup
Global $g_hPop = 0, $g_hPopTitle = 0, $g_hPopSub = 0
Global $g_hPopPct = 0, $g_hPopBar = 0, $g_hPopFill = 0
Global $g_hPopDetail = 0, $g_hPopCancel = 0

; URL-Check und TMP-Download
Global $g_hBtnCheckURLs, $g_hBtnEditDB
Global $g_abURLOK[$ISO_MAX], $g_abURLChecked[$ISO_MAX]
Global $g_asSortedURLs[$ISO_MAX], $g_asUpdateVer[$ISO_MAX]
Global $g_asUpdateURL[$ISO_MAX], $g_asUpdateFile[$ISO_MAX]
Global $g_bUseTmpDir = True

; Persistierung von Update- und Mirror-Status
Global $g_aiUpdateableISOs[$ISO_MAX], $g_iUpdateableCount = 0
Global $g_abISOHasUpdate[$ISO_MAX], $g_asLastMirrorStatus[$ISO_MAX]
Global $g_dLastUpdateCheckTime = 0

; TreeView Drag-and-Drop
Global $g_bDragging = False, $g_iDragISO = -1

; Background Update Search
Global $g_tBGUpdate = TimerInit(), $g_iBGUpdateIdx = 0

; ISO-Suche
Global $g_hBtnISOSearch, $g_aiSearchHits[$ISO_MAX], $g_iSearchHitCount = 0

; Parallele Downloads & Speedtest
Global Const $MAX_PARALLEL_SLOTS = 6
Global $g_iSpeedMbps = -1, $g_iRecommendedSlots = 1
Global $g_hSpeedTestStatus = 0
Global $g_sSpeedTestFile = @TempDir & "\vlm_speedtest.tmp"
Global $g_iBGSpeedPID = 0, $g_tBGSpeedStart = 0
Global $g_sLogoFile = @TempDir & "\vlm_logo.bmp"
Global $g_aiSlotPID[6], $g_aiSlotIdx[6], $g_asSlotFile[6]
Global $g_aiSlotTotal[6], $g_aiSlotWritten[6], $g_aiSlotMirrorIdx[6]

; ISO-Datenbank-Status
Global $ISO_COUNT = 26

; Popup-Slots
Global $g_ahSlotNameLbl[6], $g_ahSlotBarBg[6], $g_ahSlotBarFill[6]
Global $g_ahSlotPctLbl[6], $g_ahSlotDetailLbl[6], $g_ahSlotCancelBtn[6]

; Zustand
Global $g_bBusy = False, $g_bCancel = False, $g_iCurlPID = 0
Global $g_sLastDrives = "", $g_iUSBClock = 0
Global $g_iJobNrDL = -1
Global $g_iJobTotalDL = -1
Global $g_bCopyToStickDL = False
Global $g_bIsCopyPhaseDL = False
Global $VENTOY_TMP_DIR = @TempDir & "\VLM_Ventoy"
Global $VENTOY_ZIP     = $VENTOY_TMP_DIR & "\ventoy_latest.zip"
Global $g_iCurrentProcessPID = 0
Global $g_bExpertMode = False, $g_hBtnModeToggle, $g_hBtnHelp
Global $g_hChkSecureBoot, $g_bSecureBoot = True
Global $g_hHdrBg, $g_hHdrAccent, $g_hLogoPic, $g_hTitleLbl, $g_hSubTitleLbl
Global $g_hDrivePanelBg, $g_hDriveHdrLbl, $g_hActionPanelBg, $g_hActionBorder, $g_hFooterLbl

; ISO-Ordner Info Checkbox
Global $g_hChkShowInfo, $g_bShowInfo = True
Global $g_hDistroLbl

; ISO Daten
Global $g_aISOs[$ISO_MAX][10], $g_ahNodes[$ISO_MAX]
Global $g_ahCatNodes[8], $g_abCatLast[8], $g_abNodeLast[$ISO_MAX]
Global $g_aiUSBStatus[$ISO_MAX], $g_asUSBSize[$ISO_MAX]
Global $g_sLastScannedDrive = ""
Global $g_aiNodeColor[$ISO_MAX], $g_abImportedFromStick[$ISO_MAX]
Global $g_abMemBoot[$ISO_MAX]

; Startup Scan
Global $g_bAutoScanPending = False, $g_sAutoScanDrive = ""
Global $g_iLastTipNode = -1

; Automatischer Versions-Check
Global Const $AUTO_CHECK_INTERVAL_DAYS = 3
Global $g_bAutoVersionCheck = False, $g_iAutoVersionCheckIdx = 0
Global $g_tAutoVersionStep = 0, $g_tAutoVersionPeriodic = 0

; Pending Copies
Global $g_aiPendingCopyQueue[$ISO_MAX], $g_iPendingCopyCount = 0
Global $g_bPendingCopyOffered = False

; ===========================================================================
;  ELEVATION HELPER
; ===========================================================================
Func _RestartAsAdmin()
    Local $sArgs = (@Compiled ? "" : '"' & @ScriptFullPath & '" ') & "/AdminRestart"
    ShellExecute(@AutoItExe, $sArgs, "", "runas")
    Exit
EndFunc

Func _RestartAsUser()
    Local $sParams = (@Compiled ? "/NoAdmin" : '"' & @ScriptFullPath & '" /NoAdmin')
    ShellExecute(@AutoItExe, $sParams, "", "open")
    Sleep(800)
    Exit
EndFunc

; ===========================================================================
;  HAUPTPROGRAMM
; ===========================================================================

If $CmdLine[0] >= 1 And $CmdLine[1] = "/AdminRestart" Then
    IniWrite($SETTINGS_INI, "App", "WasElevated", "1")
EndIf

If IsAdmin() And IniRead($SETTINGS_INI, "App", "WasElevated", "0") = "0" Then
    If Not StringInStr($CmdLineRaw, "/NoAdmin") Then
        _RestartAsUser()
    EndIf
EndIf

; --- v2.27 Optimierung: Startup-Flags für schnelleren Start nach Admin/Setup ---
Global $g_bIsAdminRestart = ($CmdLine[0] >= 1 And $CmdLine[1] = "/AdminRestart")
Global $g_bIsPostInstall  = (IniRead($SETTINGS_INI, "App", "PostInstall", "0") = "1")
Global $g_bSkipIntro      = $g_bIsAdminRestart Or $g_bIsPostInstall

_FirstRunSetup()
If Not $g_bSkipIntro Then
    _ShowWelcome()
    _ShowModeSelection()
EndIf

_CreateGUI()
_Init()
_FillTree()
_FillDrives()
_PostInit()

Local $sPend = IniRead($SETTINGS_INI, "App", "PendingSetupDrive", "")
If $sPend <> "" And IsAdmin() Then
    IniDelete($SETTINGS_INI, "App", "PendingSetupDrive")
    _FullSetup($sPend)
EndIf

; FIX v2.27: Separate Pending-Aktionen nach Elevation abfangen
Local $sPendFmt = IniRead($SETTINGS_INI, "App", "PendingFormatDrive", "")
If $sPendFmt <> "" And IsAdmin() Then
    IniDelete($SETTINGS_INI, "App", "PendingFormatDrive")
    _PopShow("Formatierung", $sPendFmt & " wird als ExFAT formatiert ...", False)
    _DoFormat($sPendFmt)
    _PopClose()
EndIf

Local $sPendVty = IniRead($SETTINGS_INI, "App", "PendingVentoyDrive", "")
If $sPendVty <> "" And IsAdmin() Then
    IniDelete($SETTINGS_INI, "App", "PendingVentoyDrive")
    _PopShow("Ventoy Installation", "Starte automatische Installation ...", True)
    _DoVentoyAutoInstall($sPendVty, False)
EndIf

_Resize()
$g_sLastDrives = _DriveList()
$g_iUSBClock   = TimerInit()

; Nur scannen, wenn kein Admin-Restart für Setup aktiv ist
If Not $g_bIsAdminRestart Then 
    _RecoverOrphanedDownloads() ; v2.27: Downloads nach Absturz/Abbruch wiederherstellen
    _StartupVentoyDetect()
EndIf

; Nach dem ersten Start den PostInstall-Flag löschen
If $g_bIsPostInstall Then IniDelete($SETTINGS_INI, "App", "PostInstall")

$g_tAutoVersionPeriodic = TimerInit()

While 1
    Local $m = GUIGetMsg()
    Switch $m
        Case $GUI_EVENT_CLOSE
            _Quit()
        Case $GUI_EVENT_RESIZED
            _Resize()
        Case $g_hBtnRefresh
            _FillDrives()
        Case $g_hBtnVentoy
            _OnVentoy()
        Case $g_hBtnDownload
            _OnDownload()
        Case $g_hBtnUpdates
            _OnUpdates()
        Case $g_hBtnCancel
            $g_bCancel = True
        Case $g_hBtnCheckURLs
            _OnCheckAllURLs()
        Case $g_hBtnISOSearch
            _OnISOSearch()
        Case $g_hBtnEditDB
            _OnEditIsoDB()
        Case $g_hBtnModeToggle
            $g_bExpertMode = Not $g_bExpertMode
            IniWrite($SETTINGS_INI, "App", "ExpertMode", ($g_bExpertMode ? "1" : "0"))
            _UpdateUIMode()
        Case $g_hBtnHelp
            _OnHelp()
        Case $g_hChkShowInfo
            $g_bShowInfo = (GUICtrlRead($g_hChkShowInfo) = $GUI_CHECKED)
            _Log("Einstellung: Info-Fenster " & ($g_bShowInfo ? "aktiviert" : "deaktiviert"))
        Case $g_hChkSecureBoot
            $g_bSecureBoot = (GUICtrlRead($g_hChkSecureBoot) = $GUI_CHECKED)
            _Log("Einstellung: Secure Boot " & ($g_bSecureBoot ? "aktiviert" : "deaktiviert"))
            IniWrite($SETTINGS_INI, "App", "SecureBoot", ($g_bSecureBoot ? "1" : "0"))
    EndSwitch

    If TimerDiff($g_iUSBClock) > 2000 And Not $g_bBusy Then
        $g_iUSBClock = TimerInit()
        Local $sNow = _DriveList()
        If $sNow <> $g_sLastDrives Then
            Local $sNew = _DriveListNew($g_sLastDrives, $sNow)
            $g_sLastDrives = $sNow
            _FillDrives()
            If $sNew <> "" Then _OnUSBIn($sNew)
        EndIf
    EndIf

    If Not $g_bBusy Then 
        _SyncCategoryCheckboxes()
        _TooltipPoll()
    EndIf

    If Not $g_bAutoVersionCheck And Not $g_bBusy Then
        if TimerDiff($g_tAutoVersionPeriodic) > 86400000 Then
            $g_tAutoVersionPeriodic = TimerInit()
            Local $sLC = IniRead($SETTINGS_INI, "App", "LastVersionCheck", "")
            If $sLC = "" Or _DaysSinceDate($sLC) >= $AUTO_CHECK_INTERVAL_DAYS Then
                _StartAutoVersionCheck()
            EndIf
        EndIf
    EndIf

    If Not $g_bBusy Then 
        _AutoVersionCheckStep()
        _CheckBackgroundSpeedTest() ; v2.27 Background Speedtest Monitor
        If Not $g_bAutoVersionCheck And TimerDiff($g_tBGUpdate) > 120000 Then
            $g_tBGUpdate = TimerInit()
            _BackgroundSearchStep()
        EndIf
    EndIf

    If $g_bAutoScanPending And Not $g_bBusy Then
        $g_bAutoScanPending = False
        _OnUpdates() ; v2.27: Vollständiger Update-Check statt nur Stick-Scan
        If $g_iPendingCopyCount > 0 And $g_sAutoScanDrive <> "" Then
            _CheckPendingCopies($g_sAutoScanDrive)
        EndIf
    EndIf
WEnd

; === Module ===
#include "VLM_DB_v2_27.au3"
#include "VLM_GUI_v2_27.au3"
#include "VLM_USB_v2_27.au3"
#include "VLM_Download_v2_27.au3"
#include "VLM_Utils_v2_27.au3"
#include "VLM_Core_v2_27.au3"
