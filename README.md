# 🖥️ Universal ISO Manager v2.27

Ein Windows-GUI-Tool (AutoIt), das USB-Sticks mit dem **Ventoy-Bootmanager** einrichtet und Linux-ISO-Dateien automatisch herunterlädt, verwaltet und auf den Stick kopiert.

---

## ✨ Features

- 🔌 **Automatische USB-Erkennung** – Ventoy-Sticks werden sofort erkannt und gescannt
- ⬇️ **Parallele Downloads** – Bis zu 6 gleichzeitige Downloads, Speedtest-basiert
- 📦 **26+ vordefinierte ISOs** – Kali, Ubuntu, Debian, Fedora, Tails, SystemRescue, Clonezilla, GParted, WinPE u.v.m.
- 🔄 **Automatische Versionsprüfung** – Hintergrund-Check ohne UI-Blockade
- 🪞 **Mirror-Fallback-Kette** – Automatischer Wechsel bei Fehler, bis zu 3 Mirror + GitHub-Fallback
- 🎨 **Ventoy-Theme-Generator** – Erstellt ein individuelles Hintergrundbild (1920×1080) via PowerShell
- 🛡️ **Admin-Handling** – Neustart als Admin nur wenn nötig, danach automatisch zurück
- 📋 **Anwender- & Expertenmodus** – Vereinfachte oder vollständige Ansicht wählbar

---

## 🗂️ Module

| Modul | Beschreibung |
|---|---|
| `VentoyLinuxManager_v2_27.au3` | Programmstart, Event-Loop, Initialisierung |
| `VLM_GUI_v2_27.au3` | Benutzeroberfläche, TreeView, Farbcodierung |
| `VLM_DB_v2_27.au3` | ISO-Datenbank, Editor, Migration, Import |
| `VLM_Download_v2_27.au3` | Download-Engine, Mirror-Auswahl, Wiederherstellung |
| `VLM_USB_v2_27.au3` | USB-Verwaltung, Ventoy-Installation, Format |
| `VLM_Core_v2_27.au3` | Update-Checks, MemBoot, Tooltip-System, Logging |
| `VLM_Utils_v2_27.au3` | Hilfsfunktionen, Popup-System, Prozesssteuerung |

---

## 🎨 ISO-Status-Farbcodierung

| Farbe | Bedeutung |
|---|---|
| 🟢 Grün | Auf Stick & aktuell |
| 🟠 Orange | Veraltet oder Update verfügbar |
| 🔴 Rot | URL nicht erreichbar |
| ⬜ Grau | Nicht vorhanden / unbekannt |
| 🟦 Türkis | Vom Stick importiert (ohne URL) |

---

## 📁 Dateistruktur (Laufzeit)

```
UniversalISOManager/
├── vlm_settings.ini        # Einstellungen: Basisordner, Modus, Bandbreite
├── vlm_isos.ini            # ISO-Datenbank (Namen, URLs, Mirror, Beschreibungen)
├── vlm_user_urls.ini       # Vom Nutzer manuell eingetragene URLs
├── vlm_log.txt             # Protokoll aller Aktionen
├── ISOs/                   # Fertig heruntergeladene ISO-Dateien
│   └── .tmp/               # Laufende / unterbrochene Downloads
└── vlm_ventoy_setup/       # Temporärer Entpackordner für Ventoy-ZIP
```

---

## 🚀 Voraussetzungen

- Windows 10 / 11
- [AutoIt v3](https://www.autoitscript.com/) (zum Kompilieren)
- `curl.exe` im PATH oder im Programmordner
- Internetverbindung für Downloads & Versionsprüfung
- Administratorrechte für Format & Ventoy-Installation (werden automatisch angefragt)

---

## ⚙️ Installation & Start

1. Repository klonen oder ZIP herunterladen
2. `VentoyLinuxManager_v2_27.au3` mit AutoIt ausführen **oder** kompilierte `.exe` starten
3. Beim ersten Start: Basisordner wählen (z.B. `Dokumente\UniversalISOManager`)
4. Modus wählen: **Anwender** (einfach) oder **Experte** (alle Funktionen)

---

## 🛠️ ISO-Kategorien

- 🎮 Gaming
- 🔒 Sicherheit (Kali, Tails, …)
- 👶 Einsteiger (Ubuntu, Linux Mint, …)
- 🪶 Leichtgewicht (Puppy, AntiX, …)
- 🧠 Fortgeschrittene (Arch, Gentoo, …)
- 🆘 Rettung (SystemRescue, GParted, Clonezilla, …)
- 🦠 Antivirus (G DATA BootMedium, …)
- 🪟 WinPE

---

## 📄 Lizenz

Dieses Projekt steht unter der [MIT License](LICENSE).

---

## 🙏 Danksagungen

- [Ventoy](https://www.ventoy.net/) – Der Bootmanager im Hintergrund
- [AutoIt](https://www.autoitscript.com/) – Skriptsprache für Windows-GUIs
- [curl](https://curl.se/) – Download-Engine
