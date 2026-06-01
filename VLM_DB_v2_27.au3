; ==========================================
; Module: VLM_DB.au3
; Part of UniversalISOManager
; ==========================================

#include-once

Func _GetDefaultIsoDB()
    $ISO_COUNT = 26

; ============================================================================
; ISO-DATENBANK — 26 zuverlässige Distributionen incl. Editionen
; ============================================================================

; [0] Dr.Web LiveDisk 9.0.1
$g_aISOs[0][0] = "Dr.Web LiveDisk 9.0.1 (Antivirus)"
$g_aISOs[0][1] = "Antivirus"
$g_aISOs[0][2] = "https://download.geo.drweb.com/pub/drweb/livedisk/drweb-livedisk-900-cd.iso"
$g_aISOs[0][3] = "drweb-livedisk-900-cd.iso"
$g_aISOs[0][4] = "https://ftp.drweb.com/pub/drweb/livedisk/drweb-livedisk-900-cd.iso"
$g_aISOs[0][5] = "https://cdn-download.drweb.com/pub/drweb/livedisk/drweb-livedisk-900-cd.iso"
$g_aISOs[0][6] = ""
$g_aISOs[0][7] = ""
$g_aISOs[0][8] = "https://free.drweb.com/livedisk/"
$g_aISOs[0][9] = "🛡 Dr.Web LiveDisk 9.0.1 — Antivirus Live-System" & @LF & "✅ Bootet OHNE Installation (Debian-basiert)" & @LF & "• Erkennt und entfernt Malware, Viren, Trojaner" & @LF & "• Automatische Virensignatur-Updates" & @LF & "• Web: https://free.drweb.com/livedisk/" & @LF & "• Größe: ~840 MB"

; [1] SystemRescue 13.00
$g_aISOs[1][0] = "SystemRescue 13.00 (Rettung)"
$g_aISOs[1][1] = "Rettung"
$g_aISOs[1][2] = "https://master.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/13.00/systemrescue-13.00-amd64.iso?viasf=1"
$g_aISOs[1][3] = "systemrescue-13.00-amd64.iso"
$g_aISOs[1][4] = "https://netcologne.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/13.00/systemrescue-13.00-amd64.iso?viasf=1"
$g_aISOs[1][5] = "https://phoenixnap.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/13.00/systemrescue-13.00-amd64.iso?viasf=1"
$g_aISOs[1][6] = ""
$g_aISOs[1][7] = ""
$g_aISOs[1][8] = "https://www.system-rescue.org/Download/"
$g_aISOs[1][9] = "🛠 SystemRescue 13.00 — Rettungssystem" & @LF & "✅ Bootet OHNE Installation (Arch-basiert)" & @LF & "• GParted, TestDisk, PhotoRec, fsck, Partclone" & @LF & "• Web: https://www.system-rescue.org/" & @LF & "• Größe: ~1.23 GB"

; [2] GParted Live 1.8.1-2
$g_aISOs[2][0] = "GParted Live 1.8.1-2 (Partitionierung)"
$g_aISOs[2][1] = "Rettung"
$g_aISOs[2][2] = "https://master.dl.sourceforge.net/project/gparted/gparted-live-stable/1.8.1-2/gparted-live-1.8.1-2-amd64.iso?viasf=1"
$g_aISOs[2][3] = "gparted-live-1.8.1-2-amd64.iso"
$g_aISOs[2][4] = "https://netcologne.dl.sourceforge.net/project/gparted/gparted-live-stable/1.8.1-2/gparted-live-1.8.1-2-amd64.iso?viasf=1"
$g_aISOs[2][5] = "https://phoenixnap.dl.sourceforge.net/project/gparted/gparted-live-stable/1.8.1-2/gparted-live-1.8.1-2-amd64.iso?viasf=1"
$g_aISOs[2][6] = ""
$g_aISOs[2][7] = ""
$g_aISOs[2][8] = "https://gparted.org/download.php"
$g_aISOs[2][9] = "💽 GParted Live 1.8.1-2 — Partitionierung" & @LF & "✅ Bootet OHNE Installation (Grafisch)" & @LF & "• Partitionen erstellen, verschieben, vergrößern" & @LF & "• Web: https://gparted.org/" & @LF & "• Größe: ~617 MB"

; [3] Clonezilla 3.3.0-33
$g_aISOs[3][0] = "Clonezilla 3.3.0-33 (Backup & Klon)"
$g_aISOs[3][1] = "Rettung"
$g_aISOs[3][2] = "https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.3.0-33/clonezilla-live-3.3.0-33-amd64.iso?viasf=1"
$g_aISOs[3][3] = "clonezilla-live-3.3.0-33-amd64.iso"
$g_aISOs[3][4] = "https://netcologne.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.3.0-33/clonezilla-live-3.3.0-33-amd64.iso?viasf=1"
$g_aISOs[3][5] = "https://phoenixnap.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.3.0-33/clonezilla-live-3.3.0-33-amd64.iso?viasf=1"
$g_aISOs[3][6] = ""
$g_aISOs[3][7] = ""
$g_aISOs[3][8] = "https://clonezilla.org/downloads/"
$g_aISOs[3][9] = "💾 Clonezilla 3.3.0-33 — Backup & Systemklon" & @LF & "✅ Bootet OHNE Installation (Text-Menü)" & @LF & "• Disk-Klon und Image-Backup" & @LF & "• Web: https://clonezilla.org/" & @LF & "• Größe: ~476 MB"

; [4] Rescuezilla 2.6.1
$g_aISOs[4][0] = "Rescuezilla 2.6.1 (Grafisches Backup)"
$g_aISOs[4][1] = "Rettung"
$g_aISOs[4][2] = "https://github.com/rescuezilla/rescuezilla/releases/download/2.6.1/rescuezilla-2.6.1-64bit.oracular.iso"
$g_aISOs[4][3] = "rescuezilla-2.6.1-64bit.oracular.iso"
$g_aISOs[4][4] = "https://master.dl.sourceforge.net/project/rescuezilla/rescuezilla/2.6.1/rescuezilla-2.6.1-64bit.oracular.iso?viasf=1"
$g_aISOs[4][5] = "https://netcologne.dl.sourceforge.net/project/rescuezilla/rescuezilla/2.6.1/rescuezilla-2.6.1-64bit.oracular.iso?viasf=1"
$g_aISOs[4][6] = "rescuezilla/rescuezilla"
$g_aISOs[4][7] = "rescuezilla-*-64bit*.iso"
$g_aISOs[4][8] = "https://rescuezilla.com/download"
$g_aISOs[4][9] = "🖥 Rescuezilla 2.6.1 — Grafisches Backup-Tool" & @LF & "✅ Bootet OHNE Installation (Ubuntu Live-Desktop)" & @LF & "• Clonezilla-kompatibel mit GUI" & @LF & "• Web: https://rescuezilla.com/" & @LF & "• Größe: ~1.4 GB"

; [5] Finnix 251
$g_aISOs[5][0] = "Finnix 251 (Systemwartung)"
$g_aISOs[5][1] = "Rettung"
$g_aISOs[5][2] = "https://www.finnix.org/releases/251/finnix-251.iso"
$g_aISOs[5][3] = "finnix-251.iso"
$g_aISOs[5][4] = "https://de.mirror.finnix.org/releases/251/finnix-251.iso"
$g_aISOs[5][5] = "https://uk.mirror.finnix.org/releases/251/finnix-251.iso"
$g_aISOs[5][6] = ""
$g_aISOs[5][7] = ""
$g_aISOs[5][8] = "https://www.finnix.org/download"
$g_aISOs[5][9] = "🛠 Finnix 251 — Systemwartungs-Live-CD" & @LF & "✅ Bootet OHNE Installation (Debian Sid, Bash)" & @LF & "• Festplattenreparatur, Diagnose, Datenrettung" & @LF & "• Web: https://www.finnix.org/" & @LF & "• Größe: ~577 MB"

; [6] Debian 13.4.0 Trixie Live XFCE
$g_aISOs[6][0] = "Debian 13.4.0 Trixie Live XFCE"
$g_aISOs[6][1] = "Leichtgewichtig"
$g_aISOs[6][2] = "https://saimei.ftp.acc.umu.se/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.4.0-amd64-xfce.iso"
$g_aISOs[6][3] = "debian-live-13.4.0-amd64-xfce.iso"
$g_aISOs[6][4] = "https://ftp.halifax.rwth-aachen.de/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.4.0-amd64-xfce.iso"
$g_aISOs[6][5] = "https://ftp.fau.de/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.4.0-amd64-xfce.iso"
$g_aISOs[6][6] = ""
$g_aISOs[6][7] = ""
$g_aISOs[6][8] = "https://cdimage.debian.org/debian-cd/current-live/"
$g_aISOs[6][9] = "🖥 Debian 13.4.0 — Das stabilste Linux" & @LF & "✅ Bootet OHNE Installation (Live-Desktop)" & @LF & "• XFCE Desktop — läuft ab 512 MB RAM" & @LF & "• Web: https://www.debian.org/" & @LF & "• Größe: ~3.56 GB"

; [7] Ubuntu 26.04 LTS (Desktop)
$g_aISOs[7][0] = "Ubuntu 26.04 LTS (Desktop)"
$g_aISOs[7][1] = "Einsteiger"
$g_aISOs[7][2] = "https://mirror.xenyth.net/ubuntu-releases/26.04/ubuntu-26.04-desktop-amd64.iso"
$g_aISOs[7][3] = "ubuntu-26.04-desktop-amd64.iso"
$g_aISOs[7][4] = "https://releases.ubuntu.com/26.04/ubuntu-26.04-desktop-amd64.iso"
$g_aISOs[7][5] = "https://ftp.halifax.rwth-aachen.de/ubuntu-releases/26.04/ubuntu-26.04-desktop-amd64.iso"
$g_aISOs[7][6] = ""
$g_aISOs[7][7] = ""
$g_aISOs[7][8] = "https://ubuntu.com/download/desktop"
$g_aISOs[7][9] = "🖥 Ubuntu 26.04 LTS — Weltweite #1" & @LF & "✅ Bootet OHNE Installation (GNOME)" & @LF & "• 5 Jahre Support — sehr beliebt" & @LF & "• Web: https://ubuntu.com/" & @LF & "• Größe: ~4.1 GB"

; [8] Linux Mint 22.3 (Cinnamon)
$g_aISOs[8][0] = "Linux Mint 22.3 (Cinnamon)"
$g_aISOs[8][1] = "Einsteiger"
$g_aISOs[8][2] = "https://pub.linuxmint.io/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso"
$g_aISOs[8][3] = "linuxmint-22.3-cinnamon-64bit.iso"
$g_aISOs[8][4] = "https://mirrors.edge.kernel.org/linuxmint/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso"
$g_aISOs[8][5] = "https://ftp.gwdg.de/pub/linux/debian/mint/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso"
$g_aISOs[8][6] = ""
$g_aISOs[8][7] = ""
$g_aISOs[8][8] = "https://linuxmint.com/download.php"
$g_aISOs[8][9] = "🖥 Linux Mint 22.3 (Cinnamon) — Modern & Elegant" & @LF & "✅ Bootet OHNE Installation (Cinnamon)" & @LF & "• Cinnamon Desktop für modernen Look" & @LF & "• Web: https://linuxmint.com/" & @LF & "• Größe: ~3.3 GB"

; [9] Linux Mint 22.3 (MATE)
$g_aISOs[9][0] = "Linux Mint 22.3 (MATE)"
$g_aISOs[9][1] = "Leichtgewicht"
$g_aISOs[9][2] = "https://pub.linuxmint.io/stable/22.3/linuxmint-22.3-mate-64bit.iso"
$g_aISOs[9][3] = "linuxmint-22.3-mate-64bit.iso"
$g_aISOs[9][4] = "https://mirrors.edge.kernel.org/linuxmint/stable/22.3/linuxmint-22.3-mate-64bit.iso"
$g_aISOs[9][5] = "https://ftp.gwdg.de/pub/linux/debian/mint/stable/22.3/linuxmint-22.3-mate-64bit.iso"
$g_aISOs[9][6] = ""
$g_aISOs[9][7] = ""
$g_aISOs[9][8] = "https://linuxmint.com/download.php"
$g_aISOs[9][9] = "🖥 Linux Mint 22.3 (MATE) — Bestes für Windows-Umsteiger" & @LF & "✅ Bootet OHNE Installation (MATE)" & @LF & "• Klassische Taskleiste wie Windows" & @LF & "• Web: https://linuxmint.com/" & @LF & "• Größe: ~3.1 GB"

; [10] Linux Mint 22.3 (XFCE)
$g_aISOs[10][0] = "Linux Mint 22.3 (XFCE)"
$g_aISOs[10][1] = "Leichtgewicht"
$g_aISOs[10][2] = "https://pub.linuxmint.io/stable/22.3/linuxmint-22.3-xfce-64bit.iso"
$g_aISOs[10][3] = "linuxmint-22.3-xfce-64bit.iso"
$g_aISOs[10][4] = "https://mirrors.edge.kernel.org/linuxmint/stable/22.3/linuxmint-22.3-xfce-64bit.iso"
$g_aISOs[10][5] = "https://ftp.gwdg.de/pub/linux/debian/mint/stable/22.3/linuxmint-22.3-xfce-64bit.iso"
$g_aISOs[10][6] = ""
$g_aISOs[10][7] = ""
$g_aISOs[10][8] = "https://linuxmint.com/download.php"
$g_aISOs[10][9] = "🖥 Linux Mint 22.3 (XFCE) — Schlank & Schnell" & @LF & "✅ Bootet OHNE Installation (XFCE)" & @LF & "• Ideal für ältere Hardware" & @LF & "• Web: https://linuxmint.com/" & @LF & "• Größe: ~3.0 GB"

; [11] Fedora 44 Workstation
$g_aISOs[11][0] = "Fedora 44 Workstation"
$g_aISOs[11][1] = "Fortgeschrittene"
$g_aISOs[11][2] = "https://ftp.fau.de/fedora/linux/releases/44/Workstation/x86_64/iso/Fedora-Workstation-Live-44-1.7.x86_64.iso"
$g_aISOs[11][3] = "Fedora-Workstation-Live-44-1.7.x86_64.iso"
$g_aISOs[11][4] = "https://ftp.halifax.rwth-aachen.de/fedora/linux/releases/44/Workstation/x86_64/iso/Fedora-Workstation-Live-44-1.7.x86_64.iso"
$g_aISOs[11][5] = "https://mirrors.dotsrc.org/fedora/linux/releases/44/Workstation/x86_64/iso/Fedora-Workstation-Live-44-1.7.x86_64.iso"
$g_aISOs[11][6] = ""
$g_aISOs[11][7] = ""
$g_aISOs[11][8] = "https://fedoraproject.org/workstation/download/"
$g_aISOs[11][9] = "⚙ Fedora 44 — Modernste GNOME" & @LF & "✅ Bootet OHNE Installation (GNOME 48)" & @LF & "• Cutting Edge — neueste Technologien" & @LF & "• Web: https://fedoraproject.org/" & @LF & "• Größe: ~2.7 GB"

; [12] Lubuntu 24.04.4 LTS
$g_aISOs[12][0] = "Lubuntu 24.04.4 LTS"
$g_aISOs[12][1] = "Leichtgewicht"
$g_aISOs[12][2] = "https://cdimage.ubuntu.com/lubuntu/releases/noble/release/lubuntu-24.04.4-desktop-amd64.iso"
$g_aISOs[12][3] = "lubuntu-24.04.4-desktop-amd64.iso"
$g_aISOs[12][4] = "https://ftp.halifax.rwth-aachen.de/ubuntu-cdimage/lubuntu/releases/24.04/release/lubuntu-24.04.4-desktop-amd64.iso"
$g_aISOs[12][5] = "https://ftp.fau.de/ubuntu-cdimage/lubuntu/releases/24.04/release/lubuntu-24.04.4-desktop-amd64.iso"
$g_aISOs[12][6] = ""
$g_aISOs[12][7] = ""
$g_aISOs[12][8] = "https://lubuntu.me/downloads/"
$g_aISOs[12][9] = "🪶 Lubuntu 24.04.4 — Ubuntu ultraleicht" & @LF & "✅ Bootet OHNE Installation (LXQt)" & @LF & "• Läuft auf 512 MB RAM — ideal für alte PCs" & @LF & "• Web: https://lubuntu.me/" & @LF & "• Größe: ~3.22 GB"

; [13] Tails 7.7.1
$g_aISOs[13][0] = "Tails 7.7.1 (Anonym & Tor)"
$g_aISOs[13][1] = "Sicherheit"
$g_aISOs[13][2] = "https://ftp.halifax.rwth-aachen.de/tails/stable/tails-amd64-7.7.1/tails-amd64-7.7.1.iso"
$g_aISOs[13][3] = "tails-amd64-7.7.1.iso"
$g_aISOs[13][4] = "https://mirrors.dotsrc.org/tails/stable/tails-amd64-7.7.1/tails-amd64-7.7.1.iso"
$g_aISOs[13][5] = "https://ftp.fau.de/tails/stable/tails-amd64-7.7.1/tails-amd64-7.7.1.iso"
$g_aISOs[13][6] = ""
$g_aISOs[13][7] = ""
$g_aISOs[13][8] = "https://tails.net/install/download/"
$g_aISOs[13][9] = "🔒 Tails 7.7.1 — Maximum Privatsphäre" & @LF & "✔ Bootet OHNE Installation (RAM-only)" & @LF & "• Alle Verbindungen über Tor" & @LF & "• Web: https://tails.net/" & @LF & "• Größe: ~1.9 GB"

; [14] Parrot Security 7.1
$g_aISOs[14][0] = "Parrot Security 7.1"
$g_aISOs[14][1] = "Sicherheit"
$g_aISOs[14][2] = "https://deb.parrot.sh/parrot/iso/7.1/Parrot-security-7.1_amd64.iso"
$g_aISOs[14][3] = "Parrot-security-7.1_amd64.iso"
$g_aISOs[14][4] = "https://ftp.halifax.rwth-aachen.de/parrot/iso/7.1/Parrot-security-7.1_amd64.iso"
$g_aISOs[14][5] = "https://ftp.fau.de/parrot/iso/7.1/Parrot-security-7.1_amd64.iso"
$g_aISOs[14][6] = ""
$g_aISOs[14][7] = ""
$g_aISOs[14][8] = "https://www.parrotsec.org/download/"
$g_aISOs[14][9] = "🔒 Parrot Security 7.1 — Sicherheit & Tools" & @LF & "✅ Bootet OHNE Installation (MATE Desktop)" & @LF & "• Pen-Testing-Tools + alltagstauglich" & @LF & "• Web: https://www.parrotsec.org/" & @LF & "• Größe: ~3.4 GB"

; [15] Zorin OS 18 Core
$g_aISOs[15][0] = "Zorin OS 18 Core"
$g_aISOs[15][1] = "Einsteiger"
$g_aISOs[15][2] = "https://ftp.halifax.rwth-aachen.de/zorinos/18/Zorin-OS-18-Core-64-bit-r3.iso"
$g_aISOs[15][3] = "Zorin-OS-18-Core-64-bit-r3.iso"
$g_aISOs[15][4] = "https://mirrors.edge.kernel.org/zorinos-isos/18/Zorin-OS-18-Core-64-bit-r3.iso"
$g_aISOs[15][5] = "https://mirrors.dotsrc.org/zorinos/18/Zorin-OS-18-Core-64-bit-r3.iso"
$g_aISOs[15][6] = ""
$g_aISOs[15][7] = ""
$g_aISOs[15][8] = "https://zorin.com/os/download/"
$g_aISOs[15][9] = "🖥 Zorin OS 18 — Schönster Windows-Ersatz als Live-Desktop" & @LF & "✅ Bootet vollständig OHNE Installation (Live-Desktop)" & @LF & "• Windows-11-ähnliches Layout — sofort vertraut" & @LF & "• Windows-Apps via Wine/Bottles nutzbar" & @LF & "• Web: https://zorin.com/os/" & @LF & "• Größe: ~3.5 GB"

; [16] Pop!_OS 24.04 NVIDIA
$g_aISOs[16][0] = "Pop!_OS 24.04 LTS NVIDIA"
$g_aISOs[16][1] = "Einsteiger"
$g_aISOs[16][2] = "https://iso.pop-os.org/24.04/amd64/nvidia/9/pop-os_24.04_amd64_nvidia_9.iso"
$g_aISOs[16][3] = "pop-os_24.04_amd64_nvidia_9.iso"
$g_aISOs[16][4] = "https://mirrors.edge.kernel.org/pop-os/os/24.04/amd64/nvidia/pop-os_24.04_amd64_nvidia_9.iso"
$g_aISOs[16][5] = "https://ftp.fau.de/pop-os/24.04/amd64/nvidia/pop-os_24.04_amd64_nvidia_9.iso"
$g_aISOs[16][6] = ""
$g_aISOs[16][7] = ""
$g_aISOs[16][8] = "https://pop.system76.com/"
$g_aISOs[16][9] = "🖥 Pop!_OS 24.04 — NVIDIA-optimierter Live-Desktop" & @LF & "✅ Bootet vollständig OHNE Installation (COSMIC Desktop)" & @LF & "• NVIDIA-Treiber direkt im ISO enthalten" & @LF & "• Beliebt bei Entwicklern & Gamern" & @LF & "• Web: https://pop.system76.com/" & @LF & "• Größe: ~2.9 GB"

; [17] Manjaro 26.0.3 (KDE)
$g_aISOs[17][0] = "Manjaro 26.0.3 (KDE)"
$g_aISOs[17][1] = "Fortgeschrittene"
$g_aISOs[17][2] = "https://download.manjaro.org/kde/26.0.3/manjaro-kde-26.0.3-260228-linux618.iso"
$g_aISOs[17][3] = "manjaro-kde-26.0.3-260228-linux618.iso"
$g_aISOs[17][4] = "https://mirror.alpix.eu/manjaro/kde/26.0.3/manjaro-kde-26.0.3-260228-linux618.iso"
$g_aISOs[17][5] = "https://mirror.netcologne.de/manjaro/kde/26.0.3/manjaro-kde-26.0.3-260228-linux618.iso"
$g_aISOs[17][6] = ""
$g_aISOs[17][7] = ""
$g_aISOs[17][8] = "https://manjaro.org/download/"
$g_aISOs[17][9] = "⚙ Manjaro 26 KDE — Arch-Linux-Einstieg als Live-Desktop" & @LF & "✅ Bootet vollständig OHNE Installation (Live-Desktop)" & @LF & "• AUR — riesiges Software-Repository" & @LF & "• Rolling Release, KDE Plasma 6, Wayland" & @LF & "• Web: https://manjaro.org/" & @LF & "• Größe: ~5.3 GB"

; [18] Manjaro 26.0.3 (GNOME)
$g_aISOs[18][0] = "Manjaro 26.0.3 (GNOME)"
$g_aISOs[18][1] = "Fortgeschrittene"
$g_aISOs[18][2] = "https://download.manjaro.org/gnome/26.0.3/manjaro-gnome-26.0.3-260228-linux618.iso"
$g_aISOs[18][3] = "manjaro-gnome-26.0.3-260228-linux618.iso"
$g_aISOs[18][4] = "https://mirror.alpix.eu/manjaro/gnome/26.0.3/manjaro-gnome-26.0.3-260228-linux618.iso"
$g_aISOs[18][5] = "https://mirror.netcologne.de/manjaro/gnome/26.0.3/manjaro-gnome-26.0.3-260228-linux618.iso"
$g_aISOs[18][6] = ""
$g_aISOs[18][7] = ""
$g_aISOs[18][8] = "https://manjaro.org/download/"
$g_aISOs[18][9] = "⚙ Manjaro 26 GNOME — Arch-Linux mit GNOME" & @LF & "✅ Bootet vollständig OHNE Installation (GNOME)" & @LF & "• AUR — riesiges Software-Repository" & @LF & "• Web: https://manjaro.org/" & @LF & "• Größe: ~4.5 GB"

; [19] Manjaro 26.0.3 (XFCE)
$g_aISOs[19][0] = "Manjaro 26.0.3 (XFCE)"
$g_aISOs[19][1] = "Leichtgewicht"
$g_aISOs[19][2] = "https://download.manjaro.org/xfce/26.0.3/manjaro-xfce-26.0.3-260228-linux618.iso"
$g_aISOs[19][3] = "manjaro-xfce-26.0.3-260228-linux618.iso"
$g_aISOs[19][4] = "https://mirror.alpix.eu/manjaro/xfce/26.0.3/manjaro-xfce-26.0.3-260228-linux618.iso"
$g_aISOs[19][5] = "https://mirror.netcologne.de/manjaro/xfce/26.0.3/manjaro-xfce-26.0.3-260228-linux618.iso"
$g_aISOs[19][6] = ""
$g_aISOs[19][7] = ""
$g_aISOs[19][8] = "https://manjaro.org/download/"
$g_aISOs[19][9] = "⚙ Manjaro 26 XFCE — Arch-Linux mit XFCE" & @LF & "✅ Bootet vollständig OHNE Installation (XFCE)" & @LF & "• Extrem ressourcenschonend" & @LF & "• Web: https://manjaro.org/" & @LF & "• Größe: ~4.0 GB"

; [20] MX Linux 25.1 XFCE
$g_aISOs[20][0] = "MX Linux 25.1 XFCE"
$g_aISOs[20][1] = "Leichtgewichtig"
$g_aISOs[20][2] = "https://ftp.halifax.rwth-aachen.de/mxlinux/isos/MX/Final/Xfce/MX-25.1_Xfce_x64.iso"
$g_aISOs[20][3] = "MX-25.1_Xfce_x64.iso"
$g_aISOs[20][4] = "https://mirrors.dotsrc.org/mxlinux/isos/MX/Final/Xfce/MX-25.1_Xfce_x64.iso"
$g_aISOs[20][5] = "https://ftp.fau.de/mxlinux/isos/MX/Final/Xfce/MX-25.1_Xfce_x64.iso"
$g_aISOs[20][6] = ""
$g_aISOs[20][7] = ""
$g_aISOs[20][8] = "https://mxlinux.org/download-links/"
$g_aISOs[20][9] = "🪶 MX Linux 25.1 — #1 DistroWatch, sehr effizient" & @LF & "✅ Bootet vollständig OHNE Installation (XFCE)" & @LF & "• Debian-stabil + Antifreeze-Paketmanager" & @LF & "• Sehr schnell auch auf alter Hardware" & @LF & "• Web: https://mxlinux.org/" & @LF & "• Größe: ~2.6 GB"

; [21] Nobara Linux 41
$g_aISOs[21][0] = "Nobara Linux 41 (Gaming GNOME)"
$g_aISOs[21][1] = "Gaming"
$g_aISOs[21][2] = "https://nobara-images.nobaraproject.org/Nobara-41-Official-2024-12-31.iso"
$g_aISOs[21][3] = "Nobara-41-Official-2024-12-31.iso"
$g_aISOs[21][4] = ""
$g_aISOs[21][5] = ""
$g_aISOs[21][6] = ""
$g_aISOs[21][7] = ""
$g_aISOs[21][8] = "https://nobaraproject.org/download.html"
$g_aISOs[21][9] = "🎮 Nobara Linux 41 — Gaming-Distro von GloriousEggroll (ProtonGE)" & @LF & "✅ Bootet vollständig OHNE Installation (GNOME)" & @LF & "• ProtonGE, Steam, Lutris, OBS, MangoHud vorinstalliert" & @LF & "• Fedora-Basis mit Gaming-Patches direkt vom Proton-Entwickler" & @LF & "• Hervorragende AMD- und NVIDIA-Unterstützung" & @LF & "• Web: https://nobaraproject.org/" & @LF & "• Größe: ~4.5 GB"

; [22] Hiren's BootCD PE x64 v1.0.8
$g_aISOs[22][0] = "Hiren's BootCD PE x64 v1.0.8 (WinPE)"
$g_aISOs[22][1] = "WinPE"
$g_aISOs[22][2] = "https://www.hirensbootcd.org/files/HBCD_PE_x64.iso"
$g_aISOs[22][3] = "HBCD_PE_x64.iso"
$g_aISOs[22][4] = "https://www.hirensbootcd.org/files/HBCD_PE_x64.iso"
$g_aISOs[22][5] = "https://www.hirensbootcd.org/download/"
$g_aISOs[22][6] = ""
$g_aISOs[22][7] = ""
$g_aISOs[22][8] = "https://www.hirensbootcd.org/"
$g_aISOs[22][9] = "🪟 Hiren's BootCD PE — Windows-Rettungssystem" & @LF & "✅ Win10 PE x64 — Bootet vollständig im RAM" & @LF & "• Über 100 Diagnose-, Recovery- und Dateitools" & @LF & "• Netzwerk, Browser & Treiber-Support inklusive" & @LF & "• Web: https://www.hirensbootcd.org/" & @LF & "• Größe: ~3.06 GB"

; [23] CachyOS 2026.03
$g_aISOs[23][0] = "CachyOS 2026.03 (Gaming KDE Plasma)"
$g_aISOs[23][1] = "Gaming"
$g_aISOs[23][2] = "https://iso.cachyos.org/desktop/260308/cachyos-desktop-linux-260308.iso"
$g_aISOs[23][3] = "cachyos-desktop-linux-260308.iso"
$g_aISOs[23][4] = "https://cdn77.cachyos.org/ISO/desktop/260308/cachyos-desktop-linux-260308.iso"
$g_aISOs[23][5] = "https://mirror.cachyos.org/ISO/desktop/260308/cachyos-desktop-linux-260308.iso"
$g_aISOs[23][6] = "cachyos/cachyos-cachy-iso"
$g_aISOs[23][7] = "cachyos-desktop-linux-*.iso"
$g_aISOs[23][8] = "https://cachyos.org/download/"
$g_aISOs[23][9] = "🎮 CachyOS 2026.03 — Extremes Performance-Linux für Gaming" & @LF & "✅ Bootet OHNE Installation (KDE Plasma 6.6 Live-Desktop)" & @LF & "• x86-64-v3/v4 Optimierung + BORE/EEVDF Scheduler" & @LF & "• Steam, Lutris, MangoHud, GameMode vorinstalliert" & @LF & "• Web: https://cachyos.org/" & @LF & "• Größe: ~2.8 GB"

; [24] EndeavourOS Titan 2026.03
$g_aISOs[24][0] = "EndeavourOS Titan 2026.03 (Arch Live)"
$g_aISOs[24][1] = "Fortgeschrittene"
$g_aISOs[24][2] = "https://mirror.alpix.eu/endeavouros/iso/EndeavourOS_Titan-2026.03.06.iso"
$g_aISOs[24][3] = "EndeavourOS_Titan-2026.03.06.iso"
$g_aISOs[24][4] = "https://mirrors.gigenet.com/endeavouros/iso/EndeavourOS_Titan-2026.03.06.iso"
$g_aISOs[24][5] = "https://mirror.rznet.fr/endeavouros/iso/EndeavourOS_Titan-2026.03.06.iso"
$g_aISOs[24][6] = "EndeavourOS/ISO"
$g_aISOs[24][7] = "EndeavourOS_*.iso"
$g_aISOs[24][8] = "https://endeavouros.com/latest-release/"
$g_aISOs[24][9] = "🚀 EndeavourOS Titan — Arch Linux mit Live-Desktop" & @LF & "✅ Echter Live-Boot: schneller Start dank Arch-Basis (kein Ubuntu-Overhead)" & @LF & "• 20+ schnelle Mirror-Server weltweit (DE, FR, USA, ...)" & @LF & "• Rolling Release: immer aktuellste Pakete, AUR-Zugang" & @LF & "• Perfekt für Gaming: Steam, Proton, Lutris, MangoHud via AUR" & @LF & "• Web: https://endeavouros.com/" & @LF & "• Größe: ~3.5 GB"

; [25] Ubuntu GamePack 24.04
$g_aISOs[25][0] = "Ubuntu GamePack 24.04"
$g_aISOs[25][1] = "Gaming"
$g_aISOs[25][2] = "https://netcologne.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
$g_aISOs[25][3] = "ubuntu_game_pack-24.04-amd64.iso"
$g_aISOs[25][4] = "https://deac-ams.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
$g_aISOs[25][5] = "https://netix.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
$g_aISOs[25][6] = ""
$g_aISOs[25][7] = ""
$g_aISOs[25][8] = "https://master.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
$g_aISOs[25][9] = "🎮 Ubuntu GamePack 24.04" & @LF & "✅ Optimiert für Gaming auf Basis von Ubuntu" & @LF & "• Steam, Lutris, Proton, WINE bereits vorinstalliert" & @LF & "• ⚠ Nur SourceForge-Hosting — Download kann langsam sein" & @LF & "• Web: https://ualinux.com/" & @LF & "• Größe: ~5.2 GB"

EndFunc   ; _GetDefaultIsoDB

Func _LoadIsoDB()
    If FileExists($ISO_DB_INI) Then
        _LoadIsoDBFromINI()
        _Log("ISO-Datenbank aus INI geladen: " & $ISO_COUNT & " Einträge.")
        
        ; v2.27: Überspringe Migration wenn bereits auf aktuellem Stand
        If IniRead($ISO_DB_INI, "VLM_INTERNAL", "MigratedTo_v2_27", "0") = "1" Then 
            _Log("ISO-Datenbank: Migration übersprungen (v2.27 bereits aktiv).")
            Return
        EndIf

        Local $__bMigrated = False

        ; Schritt 1: veraltete/fehlerhafte Eintraege korrigieren
        For $__m = 0 To $ISO_COUNT - 1
            Local $__sN = $g_aISOs[$__m][0]
            Local $__sU = $g_aISOs[$__m][2]
            ; Fedora Security Lab (alle Versionen) und altes Kali → Kali Linux 2026.1
            If (StringInStr($__sN, "Fedora Security")) _
               Or (StringInStr($__sN, "Kali") And Not StringInStr($__sU, "kali-2026")) Then
                $g_aISOs[$__m][0] = "Kali Linux 2026.1 (Security Live)"
                $g_aISOs[$__m][1] = "Sicherheit"
                ; FAU als primary — cdimage.kali.org blockiert Curl (403)
                $g_aISOs[$__m][2] = "https://ftp.fau.de/kali/kali-2026.1/kali-linux-2026.1-live-amd64.iso"
                $g_aISOs[$__m][3] = "kali-linux-2026.1-live-amd64.iso"
                $g_aISOs[$__m][4] = "https://ftp.halifax.rwth-aachen.de/kali/kali-2026.1/kali-linux-2026.1-live-amd64.iso"
                $g_aISOs[$__m][5] = "https://mirrors.dotsrc.org/kali-images/kali-2026.1/kali-linux-2026.1-live-amd64.iso"
                $g_aISOs[$__m][6] = ""
                $g_aISOs[$__m][7] = ""
                $g_aISOs[$__m][8] = "https://cdimage.kali.org/kali-2026.1/kali-linux-2026.1-live-amd64.iso"
                $g_aISOs[$__m][9] = "Kali Linux 2026.1 — Industrie-Standard Pen-Testing" & @LF & _
                    "- 600+ Sicherheits-Tools, Live-Boot ohne Installation" & @LF & _
                    "- BackTrack-Modus, Kernel 6.18 (neu in 2026.1)" & @LF & _
                    "- Ventoy-kompatibel (offiziell unterstuetzt)" & @LF & _
                    "- Groesse: ~4,7 GB"
                $__bMigrated = True
                _Log("Migration: [" & $__m & "] " & $__sN & " -> Kali Linux 2026.1")
            EndIf
        Next

        ; openSUSE/ESET-Bereinigung — ALLE Vorkommen (KDE Live / DVD / Tumbleweed / veraltete ESET-Einträge)
        ; ESET SysRescue Live ist seit Sept. 2023 EOL — wird zu G DATA BootMedium migriert
        ; Rückwärts iterieren: Löschen verschiebt nur höhere Indizes → bereits verarbeitet
        Local $__bGData92 = False
        For $__e92 = 0 To $ISO_COUNT - 1
            If StringInStr($g_aISOs[$__e92][0], "G DATA") Or StringInStr($g_aISOs[$__e92][0], "GDATA") Or _
               StringInStr($g_aISOs[$__e92][3], "gdata_bootmedium") Or _
               StringInStr($g_aISOs[$__e92][0], "ESET") Or StringInStr($g_aISOs[$__e92][3], "eset_sysrescue") Then
                $__bGData92 = True
                ExitLoop
            EndIf
        Next
        For $__m92 = $ISO_COUNT - 1 To 0 Step -1
            Local $__sN92 = $g_aISOs[$__m92][0]
            Local $__sU92 = $g_aISOs[$__m92][2]
            If StringInStr($__sN92, "openSUSE") Or StringInStr($__sN92, "Tumbleweed") Or _
               StringInStr($__sU92, "opensuse.org") Or StringInStr($__sU92, "tumbleweed") Or _
               StringInStr($__sN92, "ESET") Or StringInStr($__sU92, "download.eset.com") Or _
               StringInStr($g_aISOs[$__m92][3], "eset_sysrescue") Then
                If Not $__bGData92 Then
                    ; Ersten Treffer → in G DATA BootMedium umwandeln (ESET SysRescue Live ist seit Sept. 2023 EOL)
                    $g_aISOs[$__m92][0] = "G DATA BootMedium (Antivirus)"
                    $g_aISOs[$__m92][1] = "Antivirus"
                    $g_aISOs[$__m92][2] = "https://www.gdatasoftware.com/fileadmin/web/en/documents/bootcd/GData-BootMedium.iso"
                    $g_aISOs[$__m92][3] = "GData-BootMedium.iso"
                    $g_aISOs[$__m92][4] = "https://www.gdatasoftware.com/fileadmin/web/de/documents/bootcd/GData-BootMedium.iso"
                    $g_aISOs[$__m92][5] = ""
                    $g_aISOs[$__m92][6] = ""
                    $g_aISOs[$__m92][7] = ""
                    $g_aISOs[$__m92][8] = "https://www.gdatasoftware.com/downloads"
                    $g_aISOs[$__m92][9] = "G DATA BootMedium — Bootfaehiges Antivirus-System (Gentoo-basiert, BSI-zertifiziert)"
                    $__bGData92 = True
                    $__bMigrated = True
                    _Log("Migration: [" & $__m92 & "] " & $__sN92 & " -> G DATA BootMedium (ESET EOL seit 09/2023)")
                Else
                    ; Weiterer openSUSE/Tumbleweed/ESET-Eintrag → aus Array löschen
                    For $__r92 = $__m92 To $ISO_COUNT - 2
                        For $__c92 = 0 To 9
                            $g_aISOs[$__r92][$__c92] = $g_aISOs[$__r92 + 1][$__c92]
                        Next
                    Next
                    For $__c92 = 0 To 9
                        $g_aISOs[$ISO_COUNT - 1][$__c92] = ""
                    Next
                    $ISO_COUNT -= 1
                    $__bMigrated = True
                    _Log("Migration: [" & $__m92 & "] " & $__sN92 & " aus DB entfernt (openSUSE/ESET EOL)")
                EndIf
            EndIf
        Next

        ; Schritt 2: Kodachi — add falls fehlend, URL-Fix falls vorhanden aber falsch
        Local $__bKodFound = False
        Local $__kodIdx = -1
        For $__k = 0 To $ISO_COUNT - 1
            If StringInStr($g_aISOs[$__k][0], "Kodachi") Then
                $__bKodFound = True
                $__kodIdx = $__k
                ExitLoop
            EndIf
        Next
        ; URL-Fix: vorhandener Eintrag mit langsamem Mirror oder falschem GitHub-Feld
        If $__bKodFound And $__kodIdx >= 0 Then
            Local $__kodU = $g_aISOs[$__kodIdx][2]
            If StringInStr($__kodU, "master.dl.sourceforge.net") Or Not StringInStr($__kodU, "sourceforge.net") Or $g_aISOs[$__kodIdx][6] <> "" Then
                $g_aISOs[$__kodIdx][2] = "https://netcologne.dl.sourceforge.net/project/linuxkodachi/kodachi-desktop/linux-kodachi-xfce-9.0.1-amd64.iso?viasf=1"
                $g_aISOs[$__kodIdx][3] = "linux-kodachi-xfce-9.0.1-amd64.iso"
                $g_aISOs[$__kodIdx][4] = "https://deac-ams.dl.sourceforge.net/project/linuxkodachi/kodachi-desktop/linux-kodachi-xfce-9.0.1-amd64.iso?viasf=1"
                $g_aISOs[$__kodIdx][5] = "https://netix.dl.sourceforge.net/project/linuxkodachi/kodachi-desktop/linux-kodachi-xfce-9.0.1-amd64.iso?viasf=1"
                $g_aISOs[$__kodIdx][6] = ""   ; kein GitHub
                $g_aISOs[$__kodIdx][7] = ""   ; kein GitHub-Tag
                $g_aISOs[$__kodIdx][8] = "https://master.dl.sourceforge.net/project/linuxkodachi/kodachi-desktop/linux-kodachi-xfce-9.0.1-amd64.iso?viasf=1"
                $__bMigrated = True
                _Log("Migration: Linux Kodachi Mirror auf schnelle EU-CDN optimiert")
            EndIf
        EndIf
        ; Auto-add falls komplett fehlend
        If Not $__bKodFound And $ISO_COUNT < $ISO_MAX Then
            Local $__ki = $ISO_COUNT
            $g_aISOs[$__ki][0] = "Linux Kodachi 9.0.1 (Privatsphaere)"
            $g_aISOs[$__ki][1] = "Sicherheit"
            $g_aISOs[$__ki][2] = "https://netcologne.dl.sourceforge.net/project/linuxkodachi/kodachi-desktop/linux-kodachi-xfce-9.0.1-amd64.iso?viasf=1"
            $g_aISOs[$__ki][3] = "linux-kodachi-xfce-9.0.1-amd64.iso"
            $g_aISOs[$__ki][4] = "https://deac-ams.dl.sourceforge.net/project/linuxkodachi/kodachi-desktop/linux-kodachi-xfce-9.0.1-amd64.iso?viasf=1"
            $g_aISOs[$__ki][5] = "https://netix.dl.sourceforge.net/project/linuxkodachi/kodachi-desktop/linux-kodachi-xfce-9.0.1-amd64.iso?viasf=1"
            $g_aISOs[$__ki][6] = ""   ; kein GitHub
            $g_aISOs[$__ki][7] = ""   ; kein GitHub-Tag
            $g_aISOs[$__ki][8] = "https://master.dl.sourceforge.net/project/linuxkodachi/kodachi-desktop/linux-kodachi-xfce-9.0.1-amd64.iso?viasf=1"
            $g_aISOs[$__ki][9] = "Linux Kodachi 9.0.1 — Privacy & Anonymitaet (XFCE)" & @LF & _
                "- Tor, I2P, VPN, DNSCrypt vorinstalliert" & @LF & _
                "- RAM-only Modus: hinterlaesst keine Spuren" & @LF & _
                "- XFCE Desktop, visuell ansprechend" & @LF & _
                "⚠ Nur SourceForge-Hosting — Download kann langsam sein" & @LF & _
                "- Basiert auf Debian 13 (Trixie)" & @LF & _
                "- Groesse: ~4,2 GB"
            $ISO_COUNT += 1
            $__bMigrated = True
            _Log("Migration: Linux Kodachi 9.0.1 hinzugefuegt (fehlte in INI)")
        EndIf

        ; Schritt 3a: v2.13 — Tails: 7.6 → 7.6.1 + kernel.org → ftp.fau.de
        ; Tails 7.6.1 erschienen am 09. April 2026; die alten 7.6-URLs liefern 404.
        ; kernel.org liefert ebenfalls 404 für 7.6.1 → wird durch ftp.fau.de ersetzt.
        For $__m = 0 To $ISO_COUNT - 1
            If Not StringInStr($g_aISOs[$__m][0], "Tails") Then ContinueLoop
            Local $bTailsMigrated = False
            ; Fall A: Noch auf download.tails.net → auf RWTH umstellen
            If StringInStr($g_aISOs[$__m][2], "download.tails.net") Then
                $g_aISOs[$__m][2] = "https://ftp.halifax.rwth-aachen.de/tails/stable/tails-amd64-7.6.1/tails-amd64-7.6.1.iso"
                $g_aISOs[$__m][3] = "tails-amd64-7.6.1.iso"
                $g_aISOs[$__m][4] = "https://mirrors.dotsrc.org/tails/stable/tails-amd64-7.6.1/tails-amd64-7.6.1.iso"
                $g_aISOs[$__m][5] = "https://ftp.fau.de/tails/stable/tails-amd64-7.6.1/tails-amd64-7.6.1.iso"
                $g_aISOs[$__m][0] = "Tails 7.6.1 (Anonym & Tor)"
                $bTailsMigrated = True
            EndIf
            ; Fall B: Auf veraltetem 7.6 (ohne .1) → auf 7.6.1 aktualisieren
            If StringInStr($g_aISOs[$__m][3], "tails-amd64-7.6.iso") Then
                $g_aISOs[$__m][2] = "https://ftp.halifax.rwth-aachen.de/tails/stable/tails-amd64-7.6.1/tails-amd64-7.6.1.iso"
                $g_aISOs[$__m][3] = "tails-amd64-7.6.1.iso"
                $g_aISOs[$__m][4] = "https://mirrors.dotsrc.org/tails/stable/tails-amd64-7.6.1/tails-amd64-7.6.1.iso"
                $g_aISOs[$__m][5] = "https://ftp.fau.de/tails/stable/tails-amd64-7.6.1/tails-amd64-7.6.1.iso"
                $g_aISOs[$__m][0] = "Tails 7.6.1 (Anonym & Tor)"
                $bTailsMigrated = True
            EndIf
            ; Fall C: kernel.org als Mirror → durch ftp.fau.de ersetzen (kernel.org 404)
            If StringInStr($g_aISOs[$__m][5], "mirrors.edge.kernel.org/tails") Then
                Local $sKVer = ""
                Local $aKV = StringRegExp($g_aISOs[$__m][3], "tails-amd64-([\d\.]+)\.iso", 1)
                If Not @error Then $sKVer = $aKV[0]
                If $sKVer = "" Then $sKVer = "7.6.1"
                $g_aISOs[$__m][5] = "https://ftp.fau.de/tails/stable/tails-amd64-" & $sKVer & "/tails-amd64-" & $sKVer & ".iso"
                $bTailsMigrated = True
            EndIf
            If $bTailsMigrated Then
                $__bMigrated = True
                _Log("Migration: Tails → 7.6.1 + ftp.fau.de als Mirror [5]")
            EndIf
            ExitLoop
        Next

        ; Schritt 3a2: v2.14 — Nobara GNOME: Korrupten "43"-Eintrag reparieren
        ; Ursache: _FindLatestVersionURL hatte einen fehlerhaften Fallback, der
        ;          "https://github.com/.../releases/latest" (HTML-Seite, kein ISO!)
        ;          als Primary-URL eingetragen hat. HEAD lieferte 200 auf HTML-Seite
        ;          → _AutoApplyUpdate feuerte → DB korrumpiert (Name "43", URL = HTML).
        ; Fix: Erkenne den kaputten Eintrag an der GitHub-HTML-URL oder am Namen "43",
        ;      stelle korrekte Werte für Nobara 41 wieder her.
        For $__m = 0 To $ISO_COUNT - 1
            If Not StringInStr($g_aISOs[$__m][0], "Nobara") Then ContinueLoop
            If StringInStr($g_aISOs[$__m][1], "Gaming") Then
                Local $bNobCorrupt = False
                ; Fall A: Primary-URL zeigt auf GitHub-HTML-Seite (kein ISO)
                If StringInStr($g_aISOs[$__m][2], "github.com") And Not StringInStr($g_aISOs[$__m][2], ".iso") Then
                    $bNobCorrupt = True
                EndIf
                ; Fall B: Dateiname ist "Nobara-43-Official.iso" (existiert nicht als echte ISO)
                If StringInStr($g_aISOs[$__m][3], "Nobara-43-Official.iso") Then
                    $bNobCorrupt = True
                EndIf
                ; Fall C: Name enthält "Nobara Linux 43" (falsche Auto-Update-Version)
                If StringRegExp($g_aISOs[$__m][0], "Nobara Linux 43") Then
                    $bNobCorrupt = True
                EndIf
                If $bNobCorrupt Then
                    $g_aISOs[$__m][0] = "Nobara Linux 41 (Gaming GNOME)"
                    $g_aISOs[$__m][2] = "https://nobara-images.nobaraproject.org/Nobara-41-Official-2024-12-31.iso"
                    $g_aISOs[$__m][3] = "Nobara-41-Official-2024-12-31.iso"
                    $g_aISOs[$__m][4] = ""
                    $g_aISOs[$__m][5] = ""
                    $g_aISOs[$__m][6] = ""   ; kein GitHub-Repo
                    $g_aISOs[$__m][7] = ""
                    $g_aISOs[$__m][8] = "https://nobaraproject.org/download.html"
                    $__bMigrated = True
                    _Log("Migration: Nobara GNOME — korrupten Eintrag (43/GitHub-HTML) auf 41/nobaraproject.org repariert")
                EndIf
            EndIf
            ExitLoop
        Next

        ; Schritt 3b: v14.80 — Kali URL-Fix (cdimage.kali.org → FAU als primary)
        For $__m = 0 To $ISO_COUNT - 1
            If Not StringInStr($g_aISOs[$__m][0], "Kali") Then ContinueLoop
            If StringInStr($g_aISOs[$__m][2], "cdimage.kali.org") Or _
               StringInStr($g_aISOs[$__m][2], "kali.download") Then
                $g_aISOs[$__m][2] = "https://ftp.fau.de/kali/kali-2026.1/kali-linux-2026.1-live-amd64.iso"
                $g_aISOs[$__m][4] = "https://ftp.halifax.rwth-aachen.de/kali/kali-2026.1/kali-linux-2026.1-live-amd64.iso"
                $g_aISOs[$__m][5] = "https://mirrors.dotsrc.org/kali-images/kali-2026.1/kali-linux-2026.1-live-amd64.iso"
                $g_aISOs[$__m][8] = "https://cdimage.kali.org/kali-2026.1/kali-linux-2026.1-live-amd64.iso"
                $__bMigrated = True
                _Log("Migration: Kali primary URL -> FAU (cdimage.kali.org blockiert Curl mit 403)")
            EndIf
            ExitLoop
        Next

        ; Schritt 3c: v2.27 — Korrektur für Ubuntu GamePack (wurde fälschlicherweise auf Desktop-ISO aktualisiert)
        ;             + Optimierung der Mirror-Reihenfolge (schnellste EU-CDN zuerst)
        For $__m = 0 To $ISO_COUNT - 1
            ; Fall 1: GamePack wurde irrtümlich auf ubuntu-desktop-ISO aktualisiert
            If $g_aISOs[$__m][1] = "Gaming" And (StringInStr($g_aISOs[$__m][2], "releases.ubuntu.com") Or StringInStr($g_aISOs[$__m][2], "ubuntu-26.04-desktop")) Then
                $g_aISOs[$__m][0] = "Ubuntu GamePack 24.04"
                $g_aISOs[$__m][1] = "Gaming"
                $g_aISOs[$__m][2] = "https://netcologne.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
                $g_aISOs[$__m][3] = "ubuntu_game_pack-24.04-amd64.iso"
                $g_aISOs[$__m][4] = "https://deac-ams.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
                $g_aISOs[$__m][5] = "https://netix.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
                $g_aISOs[$__m][6] = ""
                $g_aISOs[$__m][7] = ""
                $g_aISOs[$__m][8] = "https://master.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
                $g_aISOs[$__m][9] = "🎮 Ubuntu GamePack 24.04" & @LF & "✅ Optimiert für Gaming auf Basis von Ubuntu" & @LF & "• Steam, Lutris, Proton, WINE bereits vorinstalliert" & @LF & "• ⚠ Nur SourceForge-Hosting — Download kann langsam sein" & @LF & "• Web: https://ualinux.com/" & @LF & "• Größe: ~5.2 GB"
                $__bMigrated = True
                _Log("Migration: Korrupten Ubuntu GamePack-Eintrag (Desktop-ISO Mix-Up) repariert + EU-Mirror optimiert")
            EndIf
            ; Fall 2: GamePack-Eintrag existiert, aber hat langsamen master.dl als Primär-Mirror
            If StringInStr($g_aISOs[$__m][0], "GamePack") And StringInStr($g_aISOs[$__m][2], "master.dl.sourceforge.net") Then
                $g_aISOs[$__m][2] = "https://netcologne.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
                $g_aISOs[$__m][4] = "https://deac-ams.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
                $g_aISOs[$__m][5] = "https://netix.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
                $g_aISOs[$__m][8] = "https://master.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1"
                $__bMigrated = True
                _Log("Migration: Ubuntu GamePack Mirror-Reihenfolge auf schnelle EU-CDN optimiert")
            EndIf
        Next

        ; Schritt 3c: Veraltete Gaming-Distros (Drauger, Chimera, Garuda) restlos entfernen
        For $__m = $ISO_COUNT - 1 To 0 Step -1
            Local $__s3N = $g_aISOs[$__m][0]
            If StringInStr($__s3N, "chimera") Or StringInStr($__s3N, "ChimeraOS") Or _
               StringInStr($__s3N, "Bazzite") Or StringInStr($__s3N, "bazzite") Or _
               StringInStr($__s3N, "PikaOS") Or _
               StringInStr($__s3N, "Drauger") Or StringInStr($__s3N, "drauger") Or _
               StringInStr($__s3N, "Garuda") Then
                For $__r = $__m To $ISO_COUNT - 2
                    For $__c = 0 To 9
                        $g_aISOs[$__r][$__c] = $g_aISOs[$__r + 1][$__c]
                    Next
                Next
                For $__c = 0 To 9
                    $g_aISOs[$ISO_COUNT - 1][$__c] = ""
                Next
                $ISO_COUNT -= 1
                $__bMigrated = True
                _Log("Migration: Veraltete/Entfernte Distro aus INI gelöscht: " & $__s3N)
            EndIf
        Next

        ; Schritt 4: Zorin-Name normalisieren — wiederholte Versionsanhänge entfernen
        ; Ursache: _AutoApplyUpdate-Bug hängte "18" wiederholt an → "Zorin OS 18 Core 18 18 18..."
        ; Fix: ^(Zorin OS Version Word) schneidet alles Nachfolgende (nur Leerzeichen+Ziffern) ab
        For $__z = 0 To $ISO_COUNT - 1
            If Not StringInStr($g_aISOs[$__z][0], "Zorin") Then ContinueLoop
            Local $__zN = $g_aISOs[$__z][0]
            Local $__zF = StringRegExpReplace($__zN, "^(Zorin\s+OS\s+[\d\.]+\s+\w+)[\s\d]*$", "$1")
            If $__zF <> $__zN And StringLen($__zF) >= 12 Then
                $g_aISOs[$__z][0] = $__zF
                $__bMigrated = True
                _Log("Migration: Zorin-Name normalisiert: '" & $__zN & "' -> '" & $__zF & "'")
            EndIf
            ExitLoop
        Next

        ; ── Schritt 5: v14.82/v14.88/v14.89 — Antivirus-Kategorie: Avira+DrWeb von "Rettung" → "Antivirus" ──
        ; Kaspersky entfernt (CDN nicht curl-zugänglich; ersetzt durch ShredOS)
        For $__m = 0 To $ISO_COUNT - 1
            If $g_aISOs[$__m][1] = "Rettung" Then
                If StringInStr($g_aISOs[$__m][0], "Avira") Or _
                   StringInStr($g_aISOs[$__m][0], "Dr.Web") Or _
                   StringInStr($g_aISOs[$__m][0], "ESET") Or _
                   StringInStr($g_aISOs[$__m][0], "G DATA") Or StringInStr($g_aISOs[$__m][0], "GDATA") Or _
                   StringInStr($g_aISOs[$__m][0], "Comodo Rescue") Or _
                   StringInStr($g_aISOs[$__m][3], "avira-rescue") Or _
                   StringInStr($g_aISOs[$__m][3], "drweb-livedisk") Or _
                   StringInStr($g_aISOs[$__m][3], "eset_sysrescue") Or _
                   StringInStr($g_aISOs[$__m][3], "gdata_bootmedium") Or StringInStr($g_aISOs[$__m][3], "gdata-bootmedium") Or _
                   StringInStr($g_aISOs[$__m][3], "comodo_rescue_disk") Then
                    $g_aISOs[$__m][1] = "Antivirus"
                    $__bMigrated = True
                    _Log("Migration: [" & $__m & "] " & $g_aISOs[$__m][0] & " Kategorie: Rettung -> Antivirus")
                EndIf
            EndIf
        Next

        ; ── Schritt 6: v14.81/v14.82 — 7 Rescue-ISOs auto-add falls fehlend ─────────────────────
        ; Struktur: [Name-Suchbegriff, Filename-Suchbegriff, Vollname, Kategorie, URL, Filename, Mirror1, Mirror2, Mirror3, GH_Repo, GH_Asset, Tooltip]
        ; Wird nur ausgeführt wenn der Eintrag noch nicht in der INI steht (ältere Version)

        ; Schritt 6a: SystemRescue 13.00
        Local $__bFound6 = False
        For $__m = 0 To $ISO_COUNT - 1
            If StringInStr($g_aISOs[$__m][0], "SystemRescue") Or StringInStr($g_aISOs[$__m][3], "systemrescue") Then
                $__bFound6 = True 
ExitLoop
            EndIf
        Next
        If Not $__bFound6 And $ISO_COUNT < $ISO_MAX Then
            Local $__i6 = $ISO_COUNT
            $g_aISOs[$__i6][0] = "SystemRescue 13.00 (Rettung)"
            $g_aISOs[$__i6][1] = "Rettung"
            $g_aISOs[$__i6][2] = "https://master.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/13.00/systemrescue-13.00-amd64.iso?viasf=1"
            $g_aISOs[$__i6][3] = "systemrescue-13.00-amd64.iso"
            $g_aISOs[$__i6][4] = "https://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/13.00/systemrescue-13.00-amd64.iso"
            $g_aISOs[$__i6][5] = "https://freefr.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/13.00/systemrescue-13.00-amd64.iso?viasf=1"
            $g_aISOs[$__i6][6] = "" 
$g_aISOs[$__i6][7] = ""
            $g_aISOs[$__i6][8] = "https://master.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/13.00/systemrescue-13.00-amd64.iso?viasf=1"
            $g_aISOs[$__i6][9] = "SystemRescue 13.00 — Arch-basiertes Rettungssystem\n- Festplattenreparatur, Datenwiederherstellung\n- fsck, TestDisk, PhotoRec, GParted enthalten\n- Groesse: ~1,3 GB"
            $ISO_COUNT += 1 
$__bMigrated = True
            _Log("Migration: SystemRescue 13.00 hinzugefuegt (fehlte in INI)")
        EndIf

        ; Schritt 6b: GParted Live 1.8.1-2
        Local $__bFound7 = False
        For $__m = 0 To $ISO_COUNT - 1
            If StringInStr($g_aISOs[$__m][0], "GParted") Or StringInStr($g_aISOs[$__m][3], "gparted-live") Then
                $__bFound7 = True 
ExitLoop
            EndIf
        Next
        If Not $__bFound7 And $ISO_COUNT < $ISO_MAX Then
            Local $__i7 = $ISO_COUNT
            $g_aISOs[$__i7][0] = "GParted Live 1.8.1-2 (Partitionierung)"
            $g_aISOs[$__i7][1] = "Rettung"
            $g_aISOs[$__i7][2] = "https://master.dl.sourceforge.net/project/gparted/gparted-live-stable/1.8.1-2/gparted-live-1.8.1-2-amd64.iso?viasf=1"
            $g_aISOs[$__i7][3] = "gparted-live-1.8.1-2-amd64.iso"
            $g_aISOs[$__i7][4] = "https://downloads.sourceforge.net/project/gparted/gparted-live-stable/1.8.1-2/gparted-live-1.8.1-2-amd64.iso"
            $g_aISOs[$__i7][5] = "https://freefr.dl.sourceforge.net/project/gparted/gparted-live-stable/1.8.1-2/gparted-live-1.8.1-2-amd64.iso?viasf=1"
            $g_aISOs[$__i7][6] = "" 
$g_aISOs[$__i7][7] = ""
            $g_aISOs[$__i7][8] = "https://master.dl.sourceforge.net/project/gparted/gparted-live-stable/1.8.1-2/gparted-live-1.8.1-2-amd64.iso?viasf=1"
            $g_aISOs[$__i7][9] = "GParted Live 1.8.1-2 — Grafische Partitionsverwaltung\n- Partitionen erstellen, verschieben, verkleinern\n- NTFS, ext4, FAT32, exFAT unterstuetzt\n- Groesse: ~635 MB"
            $ISO_COUNT += 1 
$__bMigrated = True
            _Log("Migration: GParted Live 1.8.1-2 hinzugefuegt (fehlte in INI)")
        EndIf

        ; Schritt 6c: Clonezilla Live 3.3.0-33
        Local $__bFound8 = False
        For $__m = 0 To $ISO_COUNT - 1
            If StringInStr($g_aISOs[$__m][0], "Clonezilla") Or StringInStr($g_aISOs[$__m][3], "clonezilla-live") Then
                $__bFound8 = True 
ExitLoop
            EndIf
        Next
        If Not $__bFound8 And $ISO_COUNT < $ISO_MAX Then
            Local $__i8 = $ISO_COUNT
            $g_aISOs[$__i8][0] = "Clonezilla Live 3.3.0-33 (Backup & Klon)"
            $g_aISOs[$__i8][1] = "Rettung"
            $g_aISOs[$__i8][2] = "https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.3.0-33/clonezilla-live-3.3.0-33-amd64.iso?viasf=1"
            $g_aISOs[$__i8][3] = "clonezilla-live-3.3.0-33-amd64.iso"
            $g_aISOs[$__i8][4] = "https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.3.0-33/clonezilla-live-3.3.0-33-amd64.iso"
            $g_aISOs[$__i8][5] = "https://freefr.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.3.0-33/clonezilla-live-3.3.0-33-amd64.iso?viasf=1"
            $g_aISOs[$__i8][6] = "" 
$g_aISOs[$__i8][7] = ""
            $g_aISOs[$__i8][8] = "https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.3.0-33/clonezilla-live-3.3.0-33-amd64.iso?viasf=1"
            $g_aISOs[$__i8][9] = "Clonezilla Live 3.3.0-33 — Disk-Imaging & Backup\n- Komplette Festplatten-Images erstellen\n- Bare-Metal Wiederherstellung\n- Groesse: ~460 MB"
            $ISO_COUNT += 1 
$__bMigrated = True
            _Log("Migration: Clonezilla Live 3.3.0-33 hinzugefuegt (fehlte in INI)")
        EndIf

        ; Schritt 6d: Rescuezilla 2.6.1
        Local $__bFound9 = False
        For $__m = 0 To $ISO_COUNT - 1
            If StringInStr($g_aISOs[$__m][0], "Rescuezilla") Or StringInStr($g_aISOs[$__m][3], "rescuezilla") Then
                $__bFound9 = True 
ExitLoop
            EndIf
        Next
        If Not $__bFound9 And $ISO_COUNT < $ISO_MAX Then
            Local $__i9 = $ISO_COUNT
            $g_aISOs[$__i9][0] = "Rescuezilla 2.6.1 (Grafisches Backup)"
            $g_aISOs[$__i9][1] = "Rettung"
            $g_aISOs[$__i9][2] = "https://github.com/rescuezilla/rescuezilla/releases/download/2.6.1/rescuezilla-2.6.1-64bit.oracular.iso"
            $g_aISOs[$__i9][3] = "rescuezilla-2.6.1-64bit.oracular.iso"
            $g_aISOs[$__i9][4] = "https://master.dl.sourceforge.net/project/rescuezilla/rescuezilla/2.6.1/rescuezilla-2.6.1-64bit.oracular.iso?viasf=1"
            $g_aISOs[$__i9][5] = "https://downloads.sourceforge.net/project/rescuezilla/rescuezilla/2.6.1/rescuezilla-2.6.1-64bit.oracular.iso"
            $g_aISOs[$__i9][6] = "rescuezilla/rescuezilla"
            $g_aISOs[$__i9][7] = "rescuezilla-*-64bit*.iso"
            $g_aISOs[$__i9][8] = "https://master.dl.sourceforge.net/project/rescuezilla/rescuezilla/2.6.1/rescuezilla-2.6.1-64bit.oracular.iso?viasf=1"
            $g_aISOs[$__i9][9] = "Rescuezilla 2.6.1 — Grafisches Clonezilla-Frontend\n- Einfache GUI fuer Disk-Imaging\n- Clonezilla-kompatible Images\n- Groesse: ~2,1 GB"
            $ISO_COUNT += 1 
$__bMigrated = True
            _Log("Migration: Rescuezilla 2.6.1 hinzugefuegt (fehlte in INI)")
        EndIf

        ; Schritt 6e: v2.0 — ShredOS-Migration DEAKTIVIERT (URL 404, aus DB entfernt)
        ; ShredOS v2025.11 liefert 404 auf allen SourceForge-Mirrors → nicht mehr verwenden.
        ; Kaspersky-Eintraege bleiben unberührt (werden nicht mehr migriert).
        ; Block bewusst auskommentiert.

        ; Schritt 6f: Dr.Web LiveDisk 9.0.1 (v14.88: Avira-Ersatz — CDN blockiert curl)
        ;   Bestehende Avira-Eintraege werden auf Dr.Web aktualisiert
        Local $__bFound11 = False
        For $__m = 0 To $ISO_COUNT - 1
            If StringInStr($g_aISOs[$__m][0], "Dr.Web") Or StringInStr($g_aISOs[$__m][3], "drweb-livedisk") Then
                $__bFound11 = True 
ExitLoop
            EndIf
            ; Avira-Eintrag vorhanden → auf Dr.Web upgraden
            If StringInStr($g_aISOs[$__m][0], "Avira") Or StringInStr($g_aISOs[$__m][3], "avira-rescue") Then
                $g_aISOs[$__m][0] = "Dr.Web LiveDisk 9.0.1 (Antivirus)"
                $g_aISOs[$__m][1] = "Antivirus"
                $g_aISOs[$__m][2] = "https://download.geo.drweb.com/pub/drweb/livedisk/drweb-livedisk-900-cd.iso"
                $g_aISOs[$__m][3] = "drweb-livedisk-900-cd.iso"
                $g_aISOs[$__m][4] = "https://ftp.drweb.com/pub/drweb/livedisk/drweb-livedisk-900-cd.iso"
                $g_aISOs[$__m][5] = "" 
$g_aISOs[$__m][6] = ""
$g_aISOs[$__m][7] = ""
                $g_aISOs[$__m][8] = "https://download.geo.drweb.com/pub/drweb/livedisk/drweb-livedisk-900-cd.iso"
                $g_aISOs[$__m][9] = "Dr.Web LiveDisk 9.0.1 — Antiviren-Live-System" & @LF & _
                    "- Malware, Rootkits von Windows-Systemen entfernen" & @LF & _
                    "- Automatische Signatur-Updates" & @LF & _
                    "- Groesse: ~840 MB"
                $__bFound11 = True 
$__bMigrated = True
                _Log("Migration: Avira Rescue System -> Dr.Web LiveDisk 9.0.1 (CDN-Blockierung)")
                ExitLoop
            EndIf
        Next
        If Not $__bFound11 And $ISO_COUNT < $ISO_MAX Then
            Local $__i11 = $ISO_COUNT
            $g_aISOs[$__i11][0] = "Dr.Web LiveDisk 9.0.1 (Antivirus)"
            $g_aISOs[$__i11][1] = "Antivirus"
            $g_aISOs[$__i11][2] = "https://download.geo.drweb.com/pub/drweb/livedisk/drweb-livedisk-900-cd.iso"
            $g_aISOs[$__i11][3] = "drweb-livedisk-900-cd.iso"
            $g_aISOs[$__i11][4] = "https://ftp.drweb.com/pub/drweb/livedisk/drweb-livedisk-900-cd.iso"
            $g_aISOs[$__i11][5] = "" 
$g_aISOs[$__i11][6] = ""
$g_aISOs[$__i11][7] = ""
            $g_aISOs[$__i11][8] = "https://download.geo.drweb.com/pub/drweb/livedisk/drweb-livedisk-900-cd.iso"
            $g_aISOs[$__i11][9] = "Dr.Web LiveDisk 9.0.1 — Antiviren-Live-System" & @LF & _
                "- Malware, Rootkits von Windows-Systemen entfernen" & @LF & _
                "- Automatische Signatur-Updates" & @LF & _
                "- Groesse: ~840 MB"
            $ISO_COUNT += 1 
$__bMigrated = True
            _Log("Migration: Dr.Web LiveDisk 9.0.1 hinzugefuegt (fehlte in INI)")
        EndIf

        ; Schritt 6g: v14.89 — Trinity-Eintrag → Finnix 251 migrieren
        ;   Bestehende Trinity-Eintraege werden auf Finnix 251 aktualisiert
        Local $__bFound12 = False
        For $__m = 0 To $ISO_COUNT - 1
            If StringInStr($g_aISOs[$__m][0], "Finnix") Or StringInStr($g_aISOs[$__m][3], "finnix-") Then
                $__bFound12 = True 
ExitLoop
            EndIf
            ; Trinity-Eintrag vorhanden → auf Finnix 251 upgraden
            If StringInStr($g_aISOs[$__m][0], "Trinity") Or StringInStr($g_aISOs[$__m][3], "trinity-rescue") Then
                $g_aISOs[$__m][0] = "Finnix 251 (Systemwartung)"
                $g_aISOs[$__m][1] = "Rettung"
                $g_aISOs[$__m][2] = "https://www.finnix.org/releases/251/finnix-251.iso"
                $g_aISOs[$__m][3] = "finnix-251.iso"
                $g_aISOs[$__m][4] = "https://de.mirror.finnix.org/releases/251/finnix-251.iso"
                $g_aISOs[$__m][5] = "https://uk.mirror.finnix.org/releases/251/finnix-251.iso"
                $g_aISOs[$__m][6] = "" 
$g_aISOs[$__m][7] = ""
                $g_aISOs[$__m][8] = "https://www.finnix.org/releases/251/finnix-251.iso"
                $g_aISOs[$__m][9] = "Finnix 251 — Systemwartungs-Live-CD" & @LF & _
                    "- SSH, fdisk, parted, rsync, curl vorinstalliert" & @LF & _
                    "- Debian Sid basiert, offizielle Finnix-Mirror" & @LF & _
                    "- Groesse: ~577 MB"
                $__bFound12 = True 
$__bMigrated = True
                _Log("Migration: Trinity Rescue Kit -> Finnix 251 (aktiv gewartet)")
                ExitLoop
            EndIf
        Next
        If Not $__bFound12 And $ISO_COUNT < $ISO_MAX Then
            Local $__i12 = $ISO_COUNT
            $g_aISOs[$__i12][0] = "Finnix 251 (Systemwartung)"
            $g_aISOs[$__i12][1] = "Rettung"
            $g_aISOs[$__i12][2] = "https://www.finnix.org/releases/251/finnix-251.iso"
            $g_aISOs[$__i12][3] = "finnix-251.iso"
            $g_aISOs[$__i12][4] = "https://de.mirror.finnix.org/releases/251/finnix-251.iso"
            $g_aISOs[$__i12][5] = "https://uk.mirror.finnix.org/releases/251/finnix-251.iso"
            $g_aISOs[$__i12][6] = "" 
$g_aISOs[$__i12][7] = ""
            $g_aISOs[$__i12][8] = "https://www.finnix.org/releases/251/finnix-251.iso"
            $g_aISOs[$__i12][9] = "Finnix 251 — Systemwartungs-Live-CD" & @LF & _
                "- SSH, fdisk, parted, rsync, curl vorinstalliert" & @LF & _
                "- Debian Sid basiert, offizielle Finnix-Mirror" & @LF & _
                "- Groesse: ~577 MB"
            $ISO_COUNT += 1 
$__bMigrated = True
            _Log("Migration: Finnix 251 hinzugefuegt (fehlte in INI)")
        EndIf

        ; Schritt 7: Namen von Editionen vereinheitlichen
        For $__m = 0 To $ISO_COUNT - 1
            If $g_aISOs[$__m][0] = "Linux Mint 22.3 MATE" Then
                $g_aISOs[$__m][0] = "Linux Mint 22.3 (MATE)"
                $__bMigrated = True
            EndIf
            If $g_aISOs[$__m][0] = "Ubuntu 26.04 LTS" Then
                $g_aISOs[$__m][0] = "Ubuntu 26.04 LTS (Desktop)"
                $__bMigrated = True
            EndIf
            If $g_aISOs[$__m][0] = "Manjaro 26.0.3 KDE" Then
                $g_aISOs[$__m][0] = "Manjaro 26.0.3 (KDE)"
                $__bMigrated = True
            EndIf
        Next

        ; Schritt 8: Neue Editionen auto-add falls fehlend
        Local $__sNewEds[5][10] = [ _
            ["Linux Mint 22.3 (Cinnamon)", "Einsteiger", "https://pub.linuxmint.io/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso", "linuxmint-22.3-cinnamon-64bit.iso", "https://mirrors.edge.kernel.org/linuxmint/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso", "https://ftp.gwdg.de/pub/linux/debian/mint/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso", "", "", "https://linuxmint.com/download.php", "Cinnamon Edition"], _
            ["Linux Mint 22.3 (XFCE)", "Leichtgewichtig", "https://pub.linuxmint.io/stable/22.3/linuxmint-22.3-xfce-64bit.iso", "linuxmint-22.3-xfce-64bit.iso", "https://mirrors.edge.kernel.org/linuxmint/stable/22.3/linuxmint-22.3-xfce-64bit.iso", "https://ftp.gwdg.de/pub/linux/debian/mint/stable/22.3/linuxmint-22.3-xfce-64bit.iso", "", "", "https://linuxmint.com/download.php", "XFCE Edition"], _
            ["Manjaro 26.0.3 (GNOME)", "Fortgeschrittene", "https://download.manjaro.org/gnome/26.0.3/manjaro-gnome-26.0.3-260228-linux618.iso", "manjaro-gnome-26.0.3-260228-linux618.iso", "https://mirror.alpix.eu/manjaro/gnome/26.0.3/manjaro-gnome-26.0.3-260228-linux618.iso", "https://mirror.netcologne.de/manjaro/gnome/26.0.3/manjaro-gnome-26.0.3-260228-linux618.iso", "", "", "https://manjaro.org/download/", "GNOME Edition"], _
            ["Manjaro 26.0.3 (XFCE)", "Leichtgewichtig", "https://download.manjaro.org/xfce/26.0.3/manjaro-xfce-26.0.3-260228-linux618.iso", "manjaro-xfce-26.0.3-260228-linux618.iso", "https://mirror.alpix.eu/manjaro/xfce/26.0.3/manjaro-xfce-26.0.3-260228-linux618.iso", "https://mirror.netcologne.de/manjaro/xfce/26.0.3/manjaro-xfce-26.0.3-260228-linux618.iso", "", "", "https://manjaro.org/download/", "XFCE Edition"], _
            ["Ubuntu GamePack 24.04", "Gaming", "https://master.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1", "ubuntu_game_pack-24.04-amd64.iso", "https://netcologne.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1", "https://phoenixnap.dl.sourceforge.net/project/ualinux/Ubuntu%20Pack/GamePack/ubuntu_game_pack-24.04-amd64.iso?viasf=1", "", "", "https://ualinux.com/en/ubuntu-gamepack", "Gaming Edition"] _
        ]
        
        For $__e = 0 To 4
            Local $__bFoundEd = False
            For $__m = 0 To $ISO_COUNT - 1
                If $g_aISOs[$__m][0] = $__sNewEds[$__e][0] Then
                    $__bFoundEd = True
                    ExitLoop
                EndIf
            Next
            If Not $__bFoundEd And $ISO_COUNT < $ISO_MAX Then
                For $__c = 0 To 9
                    $g_aISOs[$ISO_COUNT][$__c] = $__sNewEds[$__e][$__c]
                Next
                $ISO_COUNT += 1
                $__bMigrated = True
                _Log("Migration: Neue Edition hinzugefuegt: " & $__sNewEds[$__e][0])
            EndIf
        Next

        ; Migration abschließen und als erledigt markieren
        IniWrite($ISO_DB_INI, "VLM_INTERNAL", "MigratedTo_v2_27", "1")
        If $__bMigrated Then _SaveIsoDB()
    Else
        _GetDefaultIsoDB()
        _SaveIsoDB()   ; Defaults einmalig als INI speichern
        _Log("ISO-Datenbank: Defaults geladen und als INI gespeichert (" & $ISO_COUNT & " Einträge)")
    EndIf
EndFunc

Func _LoadIsoDBFromINI()
    $ISO_COUNT = 0
    ; Sektionsliste lesen
    Local $sSections = IniReadSectionNames($ISO_DB_INI)
    If @error Or Not IsArray($sSections) Then
        _GetDefaultIsoDB()
        Return
    EndIf
    For $s = 1 To $sSections[0]
        Local $sSec = $sSections[$s]
        If Not (StringLeft($sSec, 4) = "ISO_") Then ContinueLoop
        Local $sName = IniRead($ISO_DB_INI, $sSec, "name", "")
        If $sName = "" Then ContinueLoop
        If $ISO_COUNT >= $ISO_MAX Then ExitLoop
        Local $i = $ISO_COUNT
        $g_aISOs[$i][0] = $sName
        $g_aISOs[$i][1] = IniRead($ISO_DB_INI, $sSec, "category",  "Einsteiger")
        $g_aISOs[$i][2] = IniRead($ISO_DB_INI, $sSec, "url",       "")
        $g_aISOs[$i][3] = IniRead($ISO_DB_INI, $sSec, "filename",  "")
        $g_aISOs[$i][4] = IniRead($ISO_DB_INI, $sSec, "mirror1",   "")
        $g_aISOs[$i][5] = IniRead($ISO_DB_INI, $sSec, "mirror2",   "")
        $g_aISOs[$i][6] = IniRead($ISO_DB_INI, $sSec, "gh_repo",   "")
        $g_aISOs[$i][7] = IniRead($ISO_DB_INI, $sSec, "gh_asset",  "")
        $g_aISOs[$i][8] = IniRead($ISO_DB_INI, $sSec, "mirror3",   "")
        ; @LF-Escaped Tooltip: \n im INI → @LF
        Local $sTip = IniRead($ISO_DB_INI, $sSec, "tooltip", "")
        $g_aISOs[$i][9] = StringReplace($sTip, "\n", @LF)
        $ISO_COUNT += 1
    Next
    If $ISO_COUNT = 0 Then _GetDefaultIsoDB()   ; Fallback wenn INI leer/kaputt
EndFunc

Func _SaveIsoDB()
    ; Bestehende Datei löschen für sauberen Neuschrieb
    If FileExists($ISO_DB_INI) Then FileDelete($ISO_DB_INI)

    ; Header-Kommentar
    Local $hF = FileOpen($ISO_DB_INI, 2)
    If $hF = -1 Then
        _Log("FEHLER: Kann ISO-Datenbank nicht speichern: " & $ISO_DB_INI)
        Return False
    EndIf
    FileWriteLine($hF, "; UniversalISOManager — ISO-Datenbank  (automatisch erstellt, editierbar)")
    FileWriteLine($hF, "; Felder: name, category, url, filename, mirror1, mirror2, mirror3,")
    FileWriteLine($hF, ";         gh_repo, gh_asset, tooltip  (\\n = Zeilenumbruch im Tooltip)")
    FileWriteLine($hF, "; Neue ISO hinzufügen: neue [ISO_N]-Sektion anlegen (N = fortlaufend)")
    FileWriteLine($hF, "; Kategorien: Gaming | Sicherheit | Einsteiger | Fortgeschrittene | Leichtgewichtig | Rettung | Antivirus")
    FileWriteLine($hF, "; Gespeichert: " & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN)
    FileWriteLine($hF, "")
    FileClose($hF)

    For $i = 0 To $ISO_COUNT - 1
        Local $sSec = "ISO_" & $i
        IniWrite($ISO_DB_INI, $sSec, "name",     $g_aISOs[$i][0])
        IniWrite($ISO_DB_INI, $sSec, "category", $g_aISOs[$i][1])
        IniWrite($ISO_DB_INI, $sSec, "url",      $g_aISOs[$i][2])
        IniWrite($ISO_DB_INI, $sSec, "filename", $g_aISOs[$i][3])
        IniWrite($ISO_DB_INI, $sSec, "mirror1",  $g_aISOs[$i][4])
        IniWrite($ISO_DB_INI, $sSec, "mirror2",  $g_aISOs[$i][5])
        IniWrite($ISO_DB_INI, $sSec, "gh_repo",  $g_aISOs[$i][6])
        IniWrite($ISO_DB_INI, $sSec, "gh_asset", $g_aISOs[$i][7])
        IniWrite($ISO_DB_INI, $sSec, "mirror3",  $g_aISOs[$i][8])
        ; Tooltip: @LF → \n für INI-Einzeiligkeit
        IniWrite($ISO_DB_INI, $sSec, "tooltip",  StringReplace($g_aISOs[$i][9], @LF, "\n"))
    Next
    _Log("ISO-Datenbank gespeichert: " & $ISO_COUNT & " Einträge → " & $ISO_DB_INI)
    Return True
EndFunc

Func _OnEditIsoDB()
    If $g_bBusy Then
        MsgBox(48, "Beschäftigt", "Bitte warte bis der laufende Vorgang abgeschlossen ist.")
        Return
    EndIf

    ; ── Snapshot: ISO-Namen + alle Status-Arrays vor dem Dialog sichern ─────
    ; Fix: _ISOListDialog kann Einträge löschen, hinzufügen und umsortieren.
    ; Danach per Namen-Mapping alten Status wiederherstellen statt alles zu nullen.
    Local $iCountBefore = $ISO_COUNT
    Local $asNamesBefore[$iCountBefore]
    Local $aiUSBStatusSnap[$iCountBefore]
    Local $asUSBSizeSnap[$iCountBefore]
    Local $abURLOKSnap[$iCountBefore]
    Local $abURLCheckedSnap[$iCountBefore]
    Local $asUpdateVerSnap[$iCountBefore]
    Local $asUpdateURLSnap[$iCountBefore]
    Local $asUpdateFileSnap[$iCountBefore]
    Local $aiNodeColorSnap[$iCountBefore]
    Local $abImportedFromStickSnap[$iCountBefore]
    Local $abMemBootSnap[$iCountBefore]
    Local $__s
    For $__s = 0 To $iCountBefore - 1
        $asNamesBefore[$__s]          = $g_aISOs[$__s][0]
        $aiUSBStatusSnap[$__s]        = $g_aiUSBStatus[$__s]
        $asUSBSizeSnap[$__s]          = $g_asUSBSize[$__s]
        $abURLOKSnap[$__s]            = $g_abURLOK[$__s]
        $abURLCheckedSnap[$__s]       = $g_abURLChecked[$__s]
        $asUpdateVerSnap[$__s]        = $g_asUpdateVer[$__s]
        $asUpdateURLSnap[$__s]        = $g_asUpdateURL[$__s]
        $asUpdateFileSnap[$__s]       = $g_asUpdateFile[$__s]
        $aiNodeColorSnap[$__s]        = $g_aiNodeColor[$__s]
        $abImportedFromStickSnap[$__s] = $g_abImportedFromStick[$__s]
        $abMemBootSnap[$__s]          = $g_abMemBoot[$__s]
    Next

    _ISOListDialog()

    ; ── Node-Handles immer zurücksetzen (werden von _FillTree() neu erstellt) ─
    Local $__i
    For $__i = 0 To $ISO_MAX - 1
        $g_ahNodes[$__i]    = 0
        $g_abNodeLast[$__i] = False
    Next

    ; ── Status-Arrays per Namen-Mapping wiederherstellen ────────────────────
    ; Neue Einträge erhalten frischen Status (0/False/"").
    ; Bekannte Einträge behalten ihren Scan-Status — USB-Scan-Ergebnis bleibt erhalten!
    For $__i = 0 To $ISO_COUNT - 1
        Local $sNewName = $g_aISOs[$__i][0]
        Local $bFound = False
        For $__j = 0 To $iCountBefore - 1
            If $asNamesBefore[$__j] = $sNewName Then
                $g_aiUSBStatus[$__i]         = $aiUSBStatusSnap[$__j]
                $g_asUSBSize[$__i]           = $asUSBSizeSnap[$__j]
                $g_abURLOK[$__i]             = $abURLOKSnap[$__j]
                $g_abURLChecked[$__i]        = $abURLCheckedSnap[$__j]
                $g_asUpdateVer[$__i]         = $asUpdateVerSnap[$__j]
                $g_asUpdateURL[$__i]         = $asUpdateURLSnap[$__j]
                $g_asUpdateFile[$__i]        = $asUpdateFileSnap[$__j]
                $g_aiNodeColor[$__i]         = $aiNodeColorSnap[$__j]
                $g_abImportedFromStick[$__i] = $abImportedFromStickSnap[$__j]
                $g_abMemBoot[$__i]           = $abMemBootSnap[$__j]
                $bFound = True
                ExitLoop
            EndIf
        Next
        If Not $bFound Then
            ; Neuer Eintrag — frischen Status setzen
            $g_aiUSBStatus[$__i]         = 0
            $g_asUSBSize[$__i]           = ""
            $g_abURLOK[$__i]             = False
            $g_abURLChecked[$__i]        = False
            $g_asUpdateVer[$__i]         = ""
            $g_asUpdateURL[$__i]         = ""
            $g_asUpdateFile[$__i]        = ""
            $g_aiNodeColor[$__i]         = 0
            $g_abImportedFromStick[$__i] = False
            $g_abMemBoot[$__i]           = False
        EndIf
    Next

    ; Slots über dem neuen ISO_COUNT bereinigen
    For $__i = $ISO_COUNT To $ISO_MAX - 1
        $g_aiUSBStatus[$__i]         = 0
        $g_asUSBSize[$__i]           = ""
        $g_abURLOK[$__i]             = False
        $g_abURLChecked[$__i]        = False
        $g_asUpdateVer[$__i]         = ""
        $g_asUpdateURL[$__i]         = ""
        $g_asUpdateFile[$__i]        = ""
        $g_aiNodeColor[$__i]         = 0
        $g_abImportedFromStick[$__i] = False
        $g_abMemBoot[$__i]           = False
    Next

    _FillTree()
    _Status("ISO-Datenbank: " & $ISO_COUNT & " Einträge geladen.")
EndFunc

Func _ISOListDialog()
    Local $iW = 900, $iH = 620
    Local $hDlg = GUICreate("ISO-Datenbank bearbeiten — " & $APP_TITLE, $iW, $iH, -1, -1, _
        BitOR($WS_SIZEBOX, $WS_CAPTION, $WS_SYSMENU, $WS_MINIMIZEBOX), $WS_EX_DROPSHADOW)
    GUISetBkColor($C_W)
    GUISetFont(9, 400, 0, "Segoe UI")

    ; ── Blauer Header ─────────────────────────────────────────────────────
    GUICtrlCreateLabel("", 0, 0, $iW, 52)
    GUICtrlSetBkColor(-1, $C_BLUE)
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUICtrlCreateLabel("✎  ISO-Datenbank bearbeiten", 18, 8, $iW - 36, 22)
    GUICtrlSetFont(-1, 12, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUICtrlSetBkColor(-1, $C_BLUE)
    GUICtrlCreateLabel($ISO_COUNT & " / " & $ISO_MAX & " Einträge  ·  " & $ISO_DB_INI, 18, 32, $iW - 36, 14)
    GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0x93C5FD)
    GUICtrlSetBkColor(-1, $C_BLUE)

    ; ── Spaltenheader ─────────────────────────────────────────────────────
    Local $iListY = 58
    GUICtrlCreateLabel("", 0, $iListY, $iW, 20)
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUICtrlCreateLabel("#",       8,   $iListY + 3, 28,  14)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlCreateLabel("Name",    38,  $iListY + 3, 220, 14)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlCreateLabel("Kategorie",260,$iListY + 3, 120, 14)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlCreateLabel("Primär-URL",382,$iListY + 3,$iW-520,14)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlCreateLabel("Dateiname",$iW-136,$iListY + 3, 120, 14)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetColor(-1, $C_MID)

    ; ── ListBox ───────────────────────────────────────────────────────────
    Local $hList = GUICtrlCreateList("", 0, $iListY + 20, $iW, $iH - 170, _
        BitOR($LBS_NOTIFY, $WS_VSCROLL, $WS_BORDER))
    GUICtrlSetFont(-1, 9, 400, 0, "Consolas")
    GUICtrlSetBkColor(-1, $C_W)
    GUICtrlSetColor(-1, $C_TXT)

    ; Liste befüllen
    _RefreshISOList($hList)

    ; ── Aktions-Buttons ───────────────────────────────────────────────────
    Local $iBY = $iH - 106
    GUICtrlCreateLabel("", 0, $iBY, $iW, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUICtrlCreateLabel("", 0, $iBY + 1, $iW, 48)
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    Local $hBtnNew  = GUICtrlCreateButton("➕  Neu",       10,  $iBY + 8, 110, 30)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_LGRN)
    GUICtrlSetColor(-1, $C_GRN)
    GUICtrlSetTip(-1, "Neue Distribution zur Datenbank hinzufügen")

    Local $hBtnEdit = GUICtrlCreateButton("✏  Bearbeiten", 128, $iBY + 8, 130, 30)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_LBLU)
    GUICtrlSetColor(-1, $C_BLUE)
    GUICtrlSetTip(-1, "Ausgewählten Eintrag bearbeiten (Name, URLs, Dateiname ...)")

    Local $hBtnDel  = GUICtrlCreateButton("🗑  Löschen",   266, $iBY + 8, 110, 30)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_LRED)
    GUICtrlSetColor(-1, $C_RED)
    GUICtrlSetTip(-1, "Ausgewählten Eintrag aus der Datenbank entfernen")

    Local $hBtnUp   = GUICtrlCreateButton("▲",             384, $iBY + 8, 44, 30)
    GUICtrlSetFont(-1, 10, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetTip(-1, "Eintrag in der Liste nach oben verschieben (ändert Download-Reihenfolge)")

    Local $hBtnDown = GUICtrlCreateButton("▼",             434, $iBY + 8, 44, 30)
    GUICtrlSetFont(-1, 10, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetTip(-1, "Eintrag in der Liste nach unten verschieben")

    Local $hBtnReset = GUICtrlCreateButton("↺  Defaults",  486, $iBY + 8, 110, 30)
    GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_LAMB)
    GUICtrlSetColor(-1, $C_AMB)
    GUICtrlSetTip(-1, "Alle Änderungen verwerfen und Original-Datenbank (18 Distros) wiederherstellen")

    Local $hBtnSave = GUICtrlCreateButton("💾  Speichern & Schließen", $iW - 220, $iBY + 8, 210, 30)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI Semibold")
    GUICtrlSetBkColor(-1, $C_BLUE)
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUICtrlSetTip(-1, "Alle Änderungen in vlm_isos.ini speichern und Dialog schließen")

    ; ── Status-Zeile ─────────────────────────────────────────────────────
    GUICtrlCreateLabel("", 0, $iH - 56, $iW, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)
    Local $hStatusBar = GUICtrlCreateLabel("Einträge: " & $ISO_COUNT & "  ·  " & $ISO_DB_INI, 10, $iH - 48, $iW - 20, 14)
    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_W)

    Local $hInfo = GUICtrlCreateLabel("", 10, $iH - 30, $iW - 20, 22)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_W)
    GUICtrlSetData($hInfo, "Tipp: Doppelklick oder 'Bearbeiten' zum Ändern · vlm_isos.ini kann auch direkt im Texteditor bearbeitet werden")

    GUISetState(@SW_SHOW, $hDlg)

    ; ── Event-Loop ────────────────────────────────────────────────────────
    While True
        Local $ev = GUIGetMsg()
        If $ev = $GUI_EVENT_CLOSE Then ExitLoop

        If $ev = $hBtnSave Then
            _SaveIsoDB()
            MsgBox(64, "Gespeichert", $ISO_COUNT & " Einträge gespeichert." & @CRLF & $ISO_DB_INI)
            ExitLoop
        EndIf

        If $ev = $hBtnNew Then
            Local $iNew = _ISOEditDialog(-1, $hDlg)   ; -1 = neuer Eintrag
            If $iNew >= 0 Then
                _RefreshISOList($hList)
                GUICtrlSetData($hStatusBar, "Einträge: " & $ISO_COUNT & "  ·  " & $ISO_DB_INI)
            EndIf
        EndIf

        If $ev = $hBtnEdit Or $ev = $hList Then
            Local $iSel = _GetListSel($hList)
            If $iSel >= 0 Then
                _ISOEditDialog($iSel, $hDlg)
                _RefreshISOList($hList)
                _ListSetSel($hList, $iSel)
            EndIf
        EndIf

        If $ev = $hBtnDel Then
            Local $iDel = _GetListSel($hList)
            If $iDel >= 0 Then
                If MsgBox(292, "Löschen?", "Eintrag #" & ($iDel+1) & " wirklich löschen?" & @CRLF & @CRLF & "  " & $g_aISOs[$iDel][0]) = 6 Then
                    _IsoDBRemove($iDel)
                    _RefreshISOList($hList)
                    GUICtrlSetData($hStatusBar, "Einträge: " & $ISO_COUNT & "  ·  " & $ISO_DB_INI)
                EndIf
            EndIf
        EndIf

        If $ev = $hBtnUp Then
            Local $iUp = _GetListSel($hList)
            If $iUp > 0 Then
                _IsoDBSwap($iUp, $iUp - 1)
                _RefreshISOList($hList)
                _ListSetSel($hList, $iUp - 1)
            EndIf
        EndIf

        If $ev = $hBtnDown Then
            Local $iDn = _GetListSel($hList)
            If $iDn >= 0 And $iDn < $ISO_COUNT - 1 Then
                _IsoDBSwap($iDn, $iDn + 1)
                _RefreshISOList($hList)
                _ListSetSel($hList, $iDn + 1)
            EndIf
        EndIf

        If $ev = $hBtnReset Then
            If MsgBox(292, "Defaults wiederherstellen?", _
                "Alle aktuellen Einträge werden durch die Original-Datenbank" & @CRLF & _
                "mit den Standard-Distributionen ersetzt." & @CRLF & @CRLF & _
                "Eigene hinzugefügte Distros gehen verloren. Fortfahren?") = 6 Then
                _GetDefaultIsoDB()
                _RefreshISOList($hList)
                GUICtrlSetData($hStatusBar, "Einträge: " & $ISO_COUNT & "  ·  Defaults geladen")
            EndIf
        EndIf
    WEnd
    GUIDelete($hDlg)
EndFunc

Func _ISOEditDialog($iIdx, $hParent = 0)
    Local $bNew = ($iIdx < 0)
    Local $iW = 680, $iH = 560

    ; Felder vorbelegen
    Local $sName = "", $sCat = "Einsteiger", $sURL = "", $sFile = ""
    Local $sMirr1 = "", $sMirr2 = "", $sMirr3 = ""
    Local $sGHRepo = "", $sGHAsset = "", $sTip = ""
    If Not $bNew Then
        $sName   = $g_aISOs[$iIdx][0]
        $sCat    = $g_aISOs[$iIdx][1]
        $sURL    = $g_aISOs[$iIdx][2]
        $sFile   = $g_aISOs[$iIdx][3]
        $sMirr1  = $g_aISOs[$iIdx][4]
        $sMirr2  = $g_aISOs[$iIdx][5]
        $sGHRepo = $g_aISOs[$iIdx][6]
        $sGHAsset= $g_aISOs[$iIdx][7]
        $sMirr3  = $g_aISOs[$iIdx][8]
        $sTip    = StringReplace($g_aISOs[$iIdx][9], @LF, @CRLF)
    EndIf

    Local $sTitle = $bNew ? "Neue Distribution hinzufügen" : "Bearbeiten: " & $sName
    Local $hDlg = GUICreate($sTitle, $iW, $iH, -1, -1, _
        BitOR($WS_CAPTION, $WS_SYSMENU), $WS_EX_DROPSHADOW, $hParent)
    GUISetBkColor($C_W)
    GUISetFont(9, 400, 0, "Segoe UI")

    ; Header
    GUICtrlCreateLabel("", 0, 0, $iW, 44)
    GUICtrlSetBkColor(-1, $bNew ? $C_GRN : $C_BLUE)
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUICtrlCreateLabel($bNew ? "➕  Neue Distribution" : "✏  Bearbeiten", 14, 8, $iW-28, 20)
    GUICtrlSetFont(-1, 11, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUICtrlSetBkColor(-1, $bNew ? $C_GRN : $C_BLUE)
    Local $sSubHdr = $bNew ? "Fülle alle Pflichtfelder aus (Name, Kategorie, URL, Dateiname)" : "Index " & $iIdx & "  ·  Änderungen werden erst nach 'OK & Speichern' übernommen"
    GUICtrlCreateLabel($sSubHdr, 14, 28, $iW-28, 13)
    GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0xC7D7F5)
    GUICtrlSetBkColor(-1, $bNew ? $C_GRN : $C_BLUE)

    ; Hilfs-Funktion: Label + Edit-Zeile
    Local $iY = 54
    Local $iLH = 18, $iEH = 22, $iGap = 6

    ; Name *
    GUICtrlCreateLabel("Name  *", 14, $iY, 160, $iLH)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, $C_W)
    Local $hName = GUICtrlCreateEdit($sName, 14, $iY + $iLH, $iW - 28, $iEH, $ES_AUTOHSCROLL)
    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
    $iY += $iLH + $iEH + $iGap

    ; Kategorie *
    GUICtrlCreateLabel("Kategorie  *", 14, $iY, 160, $iLH)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, $C_W)
    Local $hCat = GUICtrlCreateCombo($sCat, 14, $iY + $iLH, 300, 22, $CBS_DROPDOWNLIST)
    GUICtrlSetData($hCat, "Gaming|Sicherheit|Einsteiger|Leichtgewicht|Fortgeschrittene|Rettung|Antivirus|WinPE", $sCat)
    $iY += $iLH + $iEH + $iGap + 2

    ; Primär-URL *
    GUICtrlCreateLabel("Primär-URL  *  (direkter .iso-Download-Link, https://...)", 14, $iY, $iW-28, $iLH)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, $C_W)
    Local $hURL = GUICtrlCreateEdit($sURL, 14, $iY + $iLH, $iW - 28, $iEH, $ES_AUTOHSCROLL)
    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
    $iY += $iLH + $iEH + $iGap

    ; Dateiname *
    GUICtrlCreateLabel("Dateiname  *  (nur Dateiname, z.B. ubuntu-24.04.4-desktop-amd64.iso)", 14, $iY, $iW-28, $iLH)
    GUICtrlSetFont(-1, 8, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, $C_W)
    Local $hFile = GUICtrlCreateEdit($sFile, 14, $iY + $iLH, $iW - 28, $iEH, $ES_AUTOHSCROLL)
    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
    $iY += $iLH + $iEH + $iGap

    ; Trennlinie
    GUICtrlCreateLabel("", 14, $iY, $iW - 28, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)
    $iY += 6

    ; Mirror 1
    GUICtrlCreateLabel("Mirror 1  (optional)", 14, $iY, 300, $iLH)
    GUICtrlSetFont(-1, 8, 600, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_W)
    Local $hM1 = GUICtrlCreateEdit($sMirr1, 14, $iY + $iLH, $iW - 28, $iEH, $ES_AUTOHSCROLL)
    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
    $iY += $iLH + $iEH + $iGap

    ; Mirror 2
    GUICtrlCreateLabel("Mirror 2  (optional)", 14, $iY, 300, $iLH)
    GUICtrlSetFont(-1, 8, 600, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_W)
    Local $hM2 = GUICtrlCreateEdit($sMirr2, 14, $iY + $iLH, $iW - 28, $iEH, $ES_AUTOHSCROLL)
    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
    $iY += $iLH + $iEH + $iGap

    ; Mirror 3
    GUICtrlCreateLabel("Mirror 3  (optional)", 14, $iY, 300, $iLH)
    GUICtrlSetFont(-1, 8, 600, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_W)
    Local $hM3 = GUICtrlCreateEdit($sMirr3, 14, $iY + $iLH, $iW - 28, $iEH, $ES_AUTOHSCROLL)
    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
    $iY += $iLH + $iEH + $iGap

    ; GitHub (Repo + Asset-Pattern nebeneinander)
    GUICtrlCreateLabel("GitHub-Repo  (optional, z.B. ublue-os/nobara-project)", 14, $iY, 340, $iLH)
    GUICtrlSetFont(-1, 8, 600, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_W)
    GUICtrlCreateLabel("Asset-Pattern  (z.B. Nobara-43-Official.iso)", 360, $iY, 310, $iLH)
    GUICtrlSetFont(-1, 8, 600, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_W)
    Local $hGHR = GUICtrlCreateEdit($sGHRepo,  14,  $iY + $iLH, 338, $iEH, $ES_AUTOHSCROLL)
    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
    Local $hGHA = GUICtrlCreateEdit($sGHAsset, 360, $iY + $iLH, $iW-374, $iEH, $ES_AUTOHSCROLL)
    GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
    $iY += $iLH + $iEH + $iGap

    ; Tooltip / Highlights
    GUICtrlCreateLabel("Beschreibung / Tooltip  (eine Zeile pro Bullet, optional)", 14, $iY, $iW-28, $iLH)
    GUICtrlSetFont(-1, 8, 600, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_W)
    Local $hTip = GUICtrlCreateEdit($sTip, 14, $iY + $iLH, $iW - 28, 56, BitOR($ES_MULTILINE, $WS_VSCROLL))
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    $iY += $iLH + 56 + $iGap

    ; Buttons
    GUICtrlCreateLabel("", 0, $iH - 52, $iW, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)
    Local $hBtnOK = GUICtrlCreateButton("✓  OK & Speichern", $iW - 220, $iH - 42, 206, 30)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI Semibold")
    GUICtrlSetBkColor(-1, $C_BLUE)
    GUICtrlSetColor(-1, 0xFFFFFF)
    Local $hBtnCancel2 = GUICtrlCreateButton("Abbrechen", 14, $iH - 42, 120, 30)
    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetColor(-1, $C_MID)

    ; Pflichtfeld-Hinweis
    GUICtrlCreateLabel("*  = Pflichtfeld", 142, $iH - 34, 100, 14)
    GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, $C_W)

    GUISetState(@SW_SHOW, $hDlg)

    Local $iResultIdx = -1
    While True
        Local $ev2 = GUIGetMsg()
        If $ev2 = $GUI_EVENT_CLOSE Or $ev2 = $hBtnCancel2 Then ExitLoop

        If $ev2 = $hBtnOK Then
            Local $vName  = StringStripWS(GUICtrlRead($hName),  3)
            Local $vCat   = GUICtrlRead($hCat)
            Local $vURL   = StringStripWS(GUICtrlRead($hURL),   3)
            Local $vFile  = StringStripWS(GUICtrlRead($hFile),  3)

            ; Validierung
            If $vName = "" Or $vURL = "" Or $vFile = "" Then
                MsgBox(16, "Pflichtfelder", "Bitte Name, Primär-URL und Dateiname ausfüllen.")
                ContinueLoop
            EndIf
            If Not StringLeft($vURL, 4) = "http" Then
                MsgBox(16, "Ungültige URL", "Die Primär-URL muss mit http:// oder https:// beginnen.")
                ContinueLoop
            EndIf
            If Not StringRight($vFile, 4) = ".iso" Then
                If MsgBox(292, "Dateiname", "Der Dateiname endet nicht auf .iso. Trotzdem speichern?") <> 6 Then ContinueLoop
            EndIf

            ; In Array schreiben
            If $bNew Then
                If $ISO_COUNT >= $ISO_MAX Then
                    MsgBox(16, "Maximum erreicht", "Es können maximal " & $ISO_MAX & " Einträge gespeichert werden.")
                    ExitLoop
                EndIf
                $iResultIdx = $ISO_COUNT
                $ISO_COUNT += 1
            Else
                $iResultIdx = $iIdx
            EndIf

            ; Dateiname-Änderung im Edit-Modus → USB-Status anpassen
            If Not $bNew And $g_aISOs[$iResultIdx][3] <> $vFile Then
                If $g_aiUSBStatus[$iResultIdx] = 1 Then
                    $g_aiUSBStatus[$iResultIdx] = 2
                    _Log("  [Edit] Dateiname geändert → USB-Status: veraltet")
                ElseIf $g_aiUSBStatus[$iResultIdx] = 2 Then
                    ; bleibt veraltet
                Else
                    $g_aiUSBStatus[$iResultIdx] = 0   ; unbekannt — kein Scan seit Änderung
                EndIf
            EndIf

            $g_aISOs[$iResultIdx][0] = $vName
            $g_aISOs[$iResultIdx][1] = $vCat
            $g_aISOs[$iResultIdx][2] = $vURL
            $g_aISOs[$iResultIdx][3] = $vFile
            $g_aISOs[$iResultIdx][4] = StringStripWS(GUICtrlRead($hM1),   3)
            $g_aISOs[$iResultIdx][5] = StringStripWS(GUICtrlRead($hM2),   3)
            $g_aISOs[$iResultIdx][6] = StringStripWS(GUICtrlRead($hGHR),  3)
            $g_aISOs[$iResultIdx][7] = StringStripWS(GUICtrlRead($hGHA),  3)
            $g_aISOs[$iResultIdx][8] = StringStripWS(GUICtrlRead($hM3),   3)
            Local $sTipRaw = StringStripWS(GUICtrlRead($hTip), 3)
            $g_aISOs[$iResultIdx][9] = StringReplace($sTipRaw, @CRLF, @LF)

            _Log("ISO-DB " & ($bNew ? "NEU" : "EDIT") & " [" & $iResultIdx & "]: " & $vName)
            ExitLoop
        EndIf
    WEnd

    GUIDelete($hDlg)
    Return $iResultIdx
EndFunc

Func _RefreshISOList($hList)
    GUICtrlSetData($hList, "")
    For $i = 0 To $ISO_COUNT - 1
        Local $sLine = StringFormat("%2d  %-28s  %-18s  %s", _
            $i + 1, _
            StringLeft($g_aISOs[$i][0], 28), _
            StringLeft($g_aISOs[$i][1], 18), _
            StringLeft($g_aISOs[$i][2], 55))
        GUICtrlSetData($hList, $sLine)
    Next
EndFunc

Func _GetListSel($hList)
    Local $sRead = GUICtrlRead($hList)
    If $sRead = "" Then Return -1
    ; Erste zwei Zeichen = 1-basierter Index
    Local $iSel = Int(StringStripWS(StringLeft($sRead, 4), 3)) - 1
    If $iSel < 0 Or $iSel >= $ISO_COUNT Then Return -1
    Return $iSel
EndFunc

Func _ListSetSel($hList, $iIdx)
    ; ListBox-Selektion auf Zeile $iIdx setzen via SendMessage LB_SETCURSEL
    Local $hCtrl = GUICtrlGetHandle($hList)
    _SendMessage($hCtrl, 0x0186, $iIdx, 0)  ; LB_SETCURSEL
EndFunc

Func _IsoDBRemove($iIdx)
    ; Fix: Status-Arrays beim Löschen mitschieben — sonst falsche Index-Zuordnung!
    For $i = $iIdx To $ISO_COUNT - 2
        For $col = 0 To 9
            $g_aISOs[$i][$col] = $g_aISOs[$i + 1][$col]
        Next
        $g_aiUSBStatus[$i]         = $g_aiUSBStatus[$i + 1]
        $g_asUSBSize[$i]           = $g_asUSBSize[$i + 1]
        $g_abURLOK[$i]             = $g_abURLOK[$i + 1]
        $g_abURLChecked[$i]        = $g_abURLChecked[$i + 1]
        $g_asUpdateVer[$i]         = $g_asUpdateVer[$i + 1]
        $g_asUpdateURL[$i]         = $g_asUpdateURL[$i + 1]
        $g_asUpdateFile[$i]        = $g_asUpdateFile[$i + 1]
        $g_aiNodeColor[$i]         = $g_aiNodeColor[$i + 1]
        $g_abImportedFromStick[$i] = $g_abImportedFromStick[$i + 1]
        $g_abMemBoot[$i]           = $g_abMemBoot[$i + 1]
        $g_asSortedURLs[$i]        = $g_asSortedURLs[$i + 1]
        $g_abISOHasUpdate[$i]      = $g_abISOHasUpdate[$i + 1]
    Next
    ; Letzten Slot bereinigen
    Local $iLast = $ISO_COUNT - 1
    For $col = 0 To 9
        $g_aISOs[$iLast][$col] = ""
    Next
    $g_aiUSBStatus[$iLast]         = 0
    $g_asUSBSize[$iLast]           = ""
    $g_abURLOK[$iLast]             = False
    $g_abURLChecked[$iLast]        = False
    $g_asUpdateVer[$iLast]         = ""
    $g_asUpdateURL[$iLast]         = ""
    $g_asUpdateFile[$iLast]        = ""
    $g_aiNodeColor[$iLast]         = 0
    $g_abImportedFromStick[$iLast] = False
    $g_abMemBoot[$iLast]           = False
    $g_asSortedURLs[$iLast]        = ""
    $g_abISOHasUpdate[$iLast]      = False
    $ISO_COUNT -= 1
EndFunc

Func _IsoDBSwap($iA, $iB)
    If $iA < 0 Or $iB < 0 Or $iA >= $ISO_COUNT Or $iB >= $ISO_COUNT Then Return
    ; Fix: Status-Arrays beim Umsortieren mittauschen — sonst falsche Index-Zuordnung!
    Local $aTmp[10]
    For $col = 0 To 9
        $aTmp[$col]          = $g_aISOs[$iA][$col]
        $g_aISOs[$iA][$col]  = $g_aISOs[$iB][$col]
        $g_aISOs[$iB][$col]  = $aTmp[$col]
    Next
    Local $vTmp
    $vTmp = $g_aiUSBStatus[$iA]         
$g_aiUSBStatus[$iA]         = $g_aiUSBStatus[$iB]
$g_aiUSBStatus[$iB]         = $vTmp
    $vTmp = $g_asUSBSize[$iA]           
$g_asUSBSize[$iA]           = $g_asUSBSize[$iB]
$g_asUSBSize[$iB]           = $vTmp
    $vTmp = $g_abURLOK[$iA]             
$g_abURLOK[$iA]             = $g_abURLOK[$iB]
$g_abURLOK[$iB]             = $vTmp
    $vTmp = $g_abURLChecked[$iA]        
$g_abURLChecked[$iA]        = $g_abURLChecked[$iB]
$g_abURLChecked[$iB]        = $vTmp
    $vTmp = $g_asUpdateVer[$iA]         
$g_asUpdateVer[$iA]         = $g_asUpdateVer[$iB]
$g_asUpdateVer[$iB]         = $vTmp
    $vTmp = $g_asUpdateURL[$iA]         
$g_asUpdateURL[$iA]         = $g_asUpdateURL[$iB]
$g_asUpdateURL[$iB]         = $vTmp
    $vTmp = $g_asUpdateFile[$iA]        
$g_asUpdateFile[$iA]        = $g_asUpdateFile[$iB]
$g_asUpdateFile[$iB]        = $vTmp
    $vTmp = $g_aiNodeColor[$iA]         
$g_aiNodeColor[$iA]         = $g_aiNodeColor[$iB]
$g_aiNodeColor[$iB]         = $vTmp
    $vTmp = $g_abImportedFromStick[$iA] 
$g_abImportedFromStick[$iA] = $g_abImportedFromStick[$iB]
$g_abImportedFromStick[$iB] = $vTmp
    $vTmp = $g_abMemBoot[$iA]           
$g_abMemBoot[$iA]           = $g_abMemBoot[$iB]
$g_abMemBoot[$iB]           = $vTmp
    $vTmp = $g_asSortedURLs[$iA]        
$g_asSortedURLs[$iA]        = $g_asSortedURLs[$iB]
$g_asSortedURLs[$iB]        = $vTmp
    $vTmp = $g_abISOHasUpdate[$iA]      
$g_abISOHasUpdate[$iA]      = $g_abISOHasUpdate[$iB]
$g_abISOHasUpdate[$iB]      = $vTmp
EndFunc

Func _SaveURLToISO($iIdx, $sURL)

    If $iIdx < 0 Or $iIdx >= $ISO_COUNT Then Return False
    If Not (StringLeft($sURL, 4) = "http") Then Return False

    ; 1. In Speicher übernehmen
    $g_aISOs[$iIdx][2] = $sURL
    _Log("URL aktualisiert [" & $iIdx & "] " & $g_aISOs[$iIdx][0] & ": " & $sURL)

    ; 2. Dauerhaft in ISO-Datenbank (vlm_isos.ini) speichern
    _SaveIsoDB()
    Return True
EndFunc

Func _CopyOneISOToStick($iIdx, $sDrive, $bDeleteAfterCopy)
    Local $sName     = $g_aISOs[$iIdx][0]
    Local $sFilename = $g_aISOs[$iIdx][3]
    Local $sCat      = $g_aISOs[$iIdx][1]
    Local $sSrc      = $TMP_DOWNLOAD_DIR & "\" & $sFilename

    ; Quelle prüfen
    If Not FileExists($sSrc) Or FileGetSize($sSrc) < 1048576 Then
        _Log("Auto-Copy übersprungen (nicht vorhanden/zu klein): " & $sFilename)
        Return False
    EndIf

    ; Kategorie-Unterordner auf dem Stick anlegen
    Local $sCatDir = $sDrive & "\" & $sCat
    If Not FileExists($sCatDir) Then DirCreate($sCatDir)
    Local $sDest = $sCatDir & "\" & $sFilename
    Local $iFileSize = FileGetSize($sSrc)

    ; Bereits vorhanden mit gleicher Größe?
    If FileExists($sDest) And FileGetSize($sDest) = $iFileSize Then
        _Log("Auto-Copy: Bereits vorhanden — " & $sName)
        _Status("✓ Bereits auf Stick: " & $sName)
        If $bDeleteAfterCopy Then
            FileDelete($sSrc)
            If Not FileExists($sSrc) Then _Log("  🗑 TMP-Datei gelöscht: " & $sSrc)
        EndIf
        ; Status nach "bereits vorhanden" aktualisieren
        $g_aiUSBStatus[$iIdx] = 1
        $g_aiNodeColor[$iIdx] = 1
        $g_asUSBSize[$iIdx]   = _FmtBytes($iFileSize)
        Return True
    EndIf

    ; Zieldatei ggf. löschen (falsche Größe)
    If FileExists($sDest) Then FileDelete($sDest)

    _Log("Auto-Copy: " & $sName & " (" & _FmtBytes($iFileSize) & ") → " & $sDrive)
    _Status("Kopiere auf Stick: " & $sName)

    ; ================================================================
    ;  v14.22/v14.65: robocopy /J — Unbuffered I/O für Maximalgeschwindigkeit
    ;  /J        = unbuffered I/O (umgeht Windows Cache → volle USB-Bandbreite)
    ;  /NDL      = kein Directory-Listing (weniger Stdout-Overhead)
    ;  /NJH /NJS = kein Job-Header/Summary
    ;  /R:1 /W:1 = max. 1 Wiederholung, 1 s Wartezeit
    ;  Fortschritt: robocopy-Stdout-Prozent alle 400 ms lesen (exFAT-sicher)
    ; ================================================================
    Local $sRoboArgs = '/J /NJH /NJS /NDL /R:1 /W:1 "' & _
        $TMP_DOWNLOAD_DIR & '" "' & $sCatDir & '" "' & $sFilename & '"'
    Local $iCopyPID = Run("robocopy " & $sRoboArgs, "", @SW_HIDE, $STDERR_MERGED)
    Local $tCopyStart = TimerInit()   ; Startzeit für Ø-Speed-Berechnung

    If $iCopyPID = 0 Then
        ; --- Fallback: chunk-basierte Kopie mit 16 MB-Blöcken ---
        _Log("  FEHLER: robocopy nicht startbar — Fallback 16 MB-Chunk-Kopie")
        Local $iChunkSize = 16 * 1024 * 1024
        Local $hSrc = FileOpen($sSrc,  16)
        Local $hDst = FileOpen($sDest, 18)
        If $hSrc = -1 Or $hDst = -1 Then
            If $hSrc <> -1 Then FileClose($hSrc)
            If $hDst <> -1 Then FileClose($hDst)
            Return False
        EndIf
        Local $iWritten = 0
        Local $tFbSpeedTick = TimerInit(), $iFbBase = 0, $sFbSpeed = ""
        While $iWritten < $iFileSize And Not $g_bCancel
            Local $oChunk = FileRead($hSrc, $iChunkSize)
            If @error Or BinaryLen($oChunk) = 0 Then ExitLoop
            FileWrite($hDst, $oChunk)
            $iWritten += BinaryLen($oChunk)
            If TimerDiff($tFbSpeedTick) >= 1000 Then
                Local $iFbBps = ($iWritten - $iFbBase) / (TimerDiff($tFbSpeedTick) / 1000)
                $iFbBase = $iWritten 
$tFbSpeedTick = TimerInit()
                If $iFbBps > 0 Then $sFbSpeed = _FmtBytes($iFbBps) & "/s"
            EndIf
            Local $iFbPct = Int($iWritten / $iFileSize * 100)
            If $iFbPct > 99 Then $iFbPct = 99
            _PopUpdate($iFbPct, "→ " & _FmtBytes($iWritten) & " / " & _FmtBytes($iFileSize) & "     " & $sFbSpeed, "Kopiere: " & $sName)
            GUICtrlSetData($g_hProgress, $iFbPct)
            GUICtrlSetData($g_hSpeedLbl, $sFbSpeed)
            Local $evFb = GUIGetMsg()
            If $evFb = $GUI_EVENT_CLOSE Then _Quit()
            If $evFb = $g_hBtnCancel Then $g_bCancel = True
            If $g_hPopCancel <> 0 And $evFb = $g_hPopCancel Then $g_bCancel = True
        WEnd
        FileClose($hSrc)
        FileClose($hDst)
        If $g_bCancel Then
            FileDelete($sDest)
            _Log("  Fallback-Copy abgebrochen — Zieldatei gelöscht.")
            Return False
        EndIf
    Else
        ; robocopy /J läuft — Fortschritt per StdoutRead (exFAT-sicher)
        Local $tSpeedTick = TimerInit()
        Local $iLastSize  = 0
        Local $fCopySmoothBps = 0
        Local $sLastSpeed = ""
        Local $sLastETA   = ""
        Local $iFilePct   = 0
        Local $iNowSize   = 0

        While ProcessExists($iCopyPID) And Not $g_bCancel
            Local $sOut = StdoutRead($iCopyPID)
            If $sOut <> "" Then
                Local $aMatch = StringRegExp($sOut, "(\d+(?:\.\d+)?)\s*%", 3)
                If IsArray($aMatch) And UBound($aMatch) > 0 Then
                    $iFilePct = Int($aMatch[UBound($aMatch)-1])
                EndIf
            EndIf
            If $iFilePct > 99 Then $iFilePct = 99
            $iNowSize = ($iFileSize * $iFilePct) / 100

            If TimerDiff($tSpeedTick) >= 1000 Then
                Local $iTickDiff = TimerDiff($tSpeedTick)
                Local $iDelta = $iNowSize - $iLastSize
                Local $iBps   = $iDelta / ($iTickDiff / 1000)
                $iLastSize    = $iNowSize
                $tSpeedTick   = TimerInit()

                ; v2.29: EMA-Glättung für Schreibgeschwindigkeit (filtert Prozent-Sprünge)
                If $iBps > 0 Then
                    If $fCopySmoothBps = 0 Then
                        $fCopySmoothBps = $iBps
                    Else
                        $fCopySmoothBps = ($fCopySmoothBps * 0.7) + ($iBps * 0.3)
                    EndIf
                    $sLastSpeed = _FmtBytes($fCopySmoothBps) & "/s"
                    $sLastETA   = "  ETA " & _FmtTime(($iFileSize - $iNowSize) / $fCopySmoothBps)
                EndIf
            EndIf

            Local $sDetail = "→ Stick: " & _FmtBytes($iNowSize) & " / " & _FmtBytes($iFileSize)
            If $sLastSpeed <> "" Then $sDetail &= "     " & $sLastSpeed & $sLastETA
            _PopUpdate($iFilePct, $sDetail, "Kopiere (robocopy /J): " & $sName & "  " & $iFilePct & "%")
            GUICtrlSetData($g_hProgress, $iFilePct)
            GUICtrlSetData($g_hSpeedLbl, $sLastSpeed)

            Local $ev = GUIGetMsg()
            ; v2.27: Fenster-X setzt auch Cancel-Flag (statt sofort zu beenden)
            If $ev = $GUI_EVENT_CLOSE                      Then $g_bCancel = True
            If $ev = $g_hBtnCancel                         Then $g_bCancel = True
            If $g_hPopCancel <> 0 And $ev = $g_hPopCancel Then $g_bCancel = True

            ; Poll-Intervall für höhere Reaktivität verkürzt (v2.27)
            Sleep(50)
        WEnd

        If $g_bCancel Then
            If $iCopyPID <> 0 And ProcessExists($iCopyPID) Then
                ProcessClose($iCopyPID)
                ; Kurzes Polling statt festem Sleep(500)
                Local $tK = TimerInit()
                While ProcessExists($iCopyPID) And TimerDiff($tK) < 500
                    Sleep(10)
                WEnd
            EndIf
            If FileExists($sDest) Then FileDelete($sDest)
            _Log("  Kopier-Vorgang (robocopy) sofort abgebrochen.")
            Return False
        EndIf
    EndIf

    ; Erfolgsprüfung
    Local $iFinalSize = 0
    If FileExists($sDest) Then $iFinalSize = FileGetSize($sDest)
    Local $iElapsed = TimerDiff($tCopyStart) / 1000

    If $iFinalSize >= Int($iFileSize * 0.995) Then
        Local $sAvgSpeed = ""
        If $iElapsed > 0 Then $sAvgSpeed = "  Ø " & _FmtBytes($iFileSize / $iElapsed) & "/s"
        _Log("  ✓ Auf Stick: " & $sName & " (" & _FmtBytes($iFinalSize) & ")" & $sAvgSpeed)

        ; TMP-Datei löschen wenn gewünscht
        If $bDeleteAfterCopy Then
            FileDelete($sSrc)
            If Not FileExists($sSrc) Then
                _Log("  🗑 TMP-Datei gelöscht: " & $sSrc)
            Else
                _Log("  ⚠ TMP-Datei konnte nicht gelöscht werden: " & $sSrc)
            EndIf
        EndIf

        _Status("✓ " & $sName & " auf Stick kopiert" & $sAvgSpeed)
        GUICtrlSetData($g_hSpeedLbl, "")
        ; Status nach erfolgreichem Kopieren aktualisieren
        $g_aiUSBStatus[$iIdx] = 1
        $g_aiNodeColor[$iIdx] = 1
        $g_asUSBSize[$iIdx]   = _FmtBytes($iFinalSize)
        Return True
    Else
        _Log("  ✗ FEHLER: " & $sName & " — " & _FmtBytes($iFinalSize) & " / " & _FmtBytes($iFileSize))
        _Status("✗ Kopierfehler: " & $sName)
        GUICtrlSetData($g_hSpeedLbl, "")
        Return False
    EndIf
EndFunc

Func _CopyISOsToUSB(ByRef $aQueue, $iCount, $sDrive)

    ; Ventoy-Prüfung und Speicherplatz wurden bereits in _OnCopyToUSB erledigt

    $g_bBusy   = True
    $g_bCancel = False

    ; -----------------------------------------------------------------------
    ; ABFRAGE: Lokale ISO-Kopien nach dem Kopieren löschen?
    ; Einmalig vor dem Start — gilt für alle ISOs dieser Session.
    ; -----------------------------------------------------------------------
    Local $iDeleteChoice = MsgBox(291, "Lokale Dateien nach dem Kopieren löschen?", _
        "Sollen die lokalen ISO-Dateien vom PC gelöscht werden," & @CRLF & _
        "nachdem sie erfolgreich auf den USB-Stick kopiert wurden?" & @CRLF & @CRLF & _
        "  JA      — Lokale Kopien vom PC löschen (spart Speicher)" & @CRLF & _
        "  NEIN    — Lokale Kopien behalten" & @CRLF & _
        "  ABBRUCH — Kopiervorgang nicht starten" & @CRLF & @CRLF & _
        "Betrifft: " & $iCount & " ISO(s)  →  " & $sDrive)
    ; MsgBox-Rückgabe: 6=Ja  7=Nein  2=Abbruch
    If $iDeleteChoice = 2 Then
        $g_bBusy = False
        _Status("Kopieren abgebrochen.")
        Return
    EndIf
    Local $bDeleteAfterCopy = ($iDeleteChoice = 6)   ; True = löschen, False = behalten

    _PopShow("ISOs auf USB kopieren", $iCount & " ISO(s) → " & $sDrive, True)

    Local $iCopied  = 0
    Local $iFailed  = 0
    Local $iSkipped = 0
    Local $iDeleted = 0

    ; Gesamtbytes aller zu kopierenden ISOs (für globalen Gesamtfortschritt)
    Local $iTotalBytes = 0
    For $j = 0 To $iCount - 1
        Local $sF
        If $g_bUseTmpDir Then
            $sF = $TMP_DOWNLOAD_DIR & "\" & $g_aISOs[$aQueue[$j]][3]
        Else
            $sF = $DOWNLOAD_DIR & "\" & $g_aISOs[$aQueue[$j]][3]
        EndIf
        If FileExists($sF) Then $iTotalBytes += FileGetSize($sF)
    Next
    Local $iGlobalDone = 0   ; bereits kopierte Bytes über alle ISOs

    For $j = 0 To $iCount - 1
        If $g_bCancel Then ExitLoop

        Local $sISOtmp = $TMP_DOWNLOAD_DIR & "\" & $g_aISOs[$aQueue[$j]][3]   ; 
        ; Bevorzuge TMP-Version, dann normale
        Local $sISO
        If FileExists($sISOtmp) And FileGetSize($sISOtmp) > 1048576 Then
            $sISO = $sISOtmp
        Else
            $sISO = $DOWNLOAD_DIR & "\" & $g_aISOs[$aQueue[$j]][3]
        EndIf
        Local $sName = $g_aISOs[$aQueue[$j]][0]
        ; Kategorie-Unterordner auf dem Stick anlegen
        Local $sCatDir = $sDrive & "\" & $g_aISOs[$aQueue[$j]][1]
        If Not FileExists($sCatDir) Then DirCreate($sCatDir)
        Local $sDest = $sCatDir & "\" & $g_aISOs[$aQueue[$j]][3]

        ; ISO vorhanden?
        If Not FileExists($sISO) Then
            _Log("Kopieren übersprungen (nicht vorhanden): " & $sISO)
            $iSkipped += 1
            ContinueLoop
        EndIf

        Local $iFileSize = FileGetSize($sISO)
        If $iFileSize < 1048576 Then
            _Log("Kopieren übersprungen (zu klein): " & $sISO)
            $iSkipped += 1
            ContinueLoop
        EndIf

        ; Bereits auf Stick vorhanden und korrekte Größe?
        If FileExists($sDest) And FileGetSize($sDest) = $iFileSize Then
            _Log("Bereits vorhanden (gleiche Größe): " & $sName)
            Local $iGPct
            If ($iTotalBytes > 0) Then
                $iGPct = Int(($iGlobalDone + $iFileSize) / $iTotalBytes * 100)
            Else
                $iGPct = 100
            EndIf
            _PopUpdate($iGPct, "✓ Bereits vorhanden: " & $sName, _
                "ISO " & ($j+1) & "/" & $iCount & " — übersprungen")
            GUICtrlSetData($g_hProgress, $iGPct)
            $iGlobalDone += $iFileSize
            $iCopied += 1
            ; Status nach "bereits vorhanden auf Stick" aktualisieren
            $g_aiUSBStatus[$aQueue[$j]] = 1
            $g_aiNodeColor[$aQueue[$j]] = 1
            $g_asUSBSize[$aQueue[$j]]   = _FmtBytes($iFileSize)
            ; Auch bereits vorhandene löschen wenn gewünscht
            If $bDeleteAfterCopy Then
                FileDelete($sISO)
                If Not FileExists($sISO) Then
                    $iDeleted += 1
                    _Log("  🗑 Quelldatei gelöscht (bereits auf Stick): " & $sISO)
                EndIf
            EndIf
            Sleep(300)
            ContinueLoop
        EndIf

        ; Zieldatei ggf. löschen (falsche Größe)
        If FileExists($sDest) Then
            _Log("Ersetze vorhandene Datei: " & $sDest)
            FileDelete($sDest)
        EndIf

        _Log("Kopiere: " & $sName & " (" & _FmtBytes($iFileSize) & ")")
        _Log("  Von:  " & $sISO)
        _Log("  Nach: " & $sDest)
        _Status("Kopiere " & ($j+1) & "/" & $iCount & ": " & $sName)

        ; ================================================================
        ;  robocopy /J — Unbuffered I/O für maximale Stick-Geschwindigkeit
        ;  /J        = unbuffered I/O (umgeht Windows Cache → volle USB-BW)
        ;  /NDL      = kein Dir-Listing (ohne /NFL → % bleibt im Stdout)
        ;  /NJH /NJS = kein Job-Header/Summary
        ;  /R:1 /W:1 = max. 1 Wiederholung, 1 s Wartezeit
        ;  Fortschritt: robocopy % per StdoutRead lesen
        ; ================================================================
        Local $sSrcDir    = ($sISO = $sISOtmp) ? $TMP_DOWNLOAD_DIR : $DOWNLOAD_DIR
        Local $sRArgs     = '/J /NJH /NJS /NDL /R:1 /W:1 "' & _
            $sSrcDir & '" "' & $sCatDir & '" "' & $g_aISOs[$aQueue[$j]][3] & '"'
        Local $iCPID      = Run("robocopy " & $sRArgs, "", @SW_HIDE, $STDERR_MERGED)
        Local $tStart     = TimerInit()
        Local $tSpeedTick = TimerInit()
        Local $iSpeedBase = 0
        Local $sLastSpeed = ""
        Local $sLastETA   = ""

        If $iCPID = 0 Then
            ; Fallback: chunk-basierte Kopie mit 16 MB-Blöcken
            _Log("  FEHLER: robocopy nicht startbar — Fallback 16 MB-Chunk-Kopie")
            Local $iChunkSize = 16 * 1024 * 1024
            Local $hSrc = FileOpen($sISO,  16)
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
                Local $iGlobPct = ($iTotalBytes > 0) ? Int(($iGlobalDone + $iWritten) / $iTotalBytes * 100) : $iFilePct
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
                _PopUpdate($iGlobPct, $sDetail, _
                    "ISO " & ($j+1) & "/" & $iCount & ": " & $sName & "  " & $iFilePct & "%")
                GUICtrlSetData($g_hProgress, $iGlobPct)
                Local $ev = GUIGetMsg()
                If $ev = $GUI_EVENT_CLOSE                      Then _Quit()
                If $ev = $g_hBtnCancel                         Then $g_bCancel = True
                If $g_hPopCancel <> 0 And $ev = $g_hPopCancel Then $g_bCancel = True
            WEnd
            FileClose($hSrc)
            FileClose($hDst)
            If $g_bCancel Then
                FileDelete($sDest)
                _Log("  Kopieren abgebrochen — Zieldatei gelöscht.")
                ExitLoop
            EndIf
        Else
            ; robocopy /J läuft — Fortschritt per StdoutRead + % Regex
            Local $iNowSize = 0, $iFilePct = 0
            While ProcessExists($iCPID) And Not $g_bCancel
                Local $sROut = StdoutRead($iCPID)
                If $sROut <> "" Then
                    Local $aRMatch = StringRegExp($sROut, "(\d+(?:\.\d+)?)\s*%", 3)
                    If IsArray($aRMatch) And UBound($aRMatch) > 0 Then
                        $iFilePct = Int($aRMatch[UBound($aRMatch)-1])
                    EndIf
                EndIf
                If $iFilePct > 99 Then $iFilePct = 99
                $iNowSize = ($iFileSize * $iFilePct) / 100
                Local $iGlobPct = ($iTotalBytes > 0) ? _
                    Int(($iGlobalDone + $iNowSize) / $iTotalBytes * 100) : $iFilePct
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
                Local $sDetail = "→ Stick: " & _FmtBytes($iNowSize) & " / " & _FmtBytes($iFileSize)
                If $sLastSpeed <> "" Then $sDetail &= "     " & $sLastSpeed & $sLastETA
                _PopUpdate($iGlobPct, $sDetail, _
                    "ISO " & ($j+1) & "/" & $iCount & ": " & $sName & "  " & $iFilePct & "%")
                GUICtrlSetData($g_hProgress, $iGlobPct)
                Local $ev = GUIGetMsg()
                If $ev = $GUI_EVENT_CLOSE                      Then _Quit()
                If $ev = $g_hBtnCancel                         Then $g_bCancel = True
                If $g_hPopCancel <> 0 And $ev = $g_hPopCancel Then $g_bCancel = True
                Sleep(400)
            WEnd
            If $g_bCancel Then
                If ProcessExists($iCPID) Then
                    ProcessClose($iCPID)
                    Sleep(500)
                EndIf
                FileDelete($sDest)
                _Log("  Kopieren abgebrochen — Zieldatei gelöscht.")
                ExitLoop
            EndIf
        EndIf

        ; ---- Erfolgsprüfung ----
        Local $iFinalSize
        If FileExists($sDest) Then
            $iFinalSize = FileGetSize($sDest)
        Else
            $iFinalSize = 0
        EndIf
        Local $iElapsedTotal = TimerDiff($tStart) / 1000
        If $iFinalSize >= Int($iFileSize * 0.995) Then
            $iCopied += 1
            $iGlobalDone += $iFileSize
            ; Status nach erfolgreichem Kopieren (CopyISOsToUSB) aktualisieren
            $g_aiUSBStatus[$aQueue[$j]] = 1
            $g_aiNodeColor[$aQueue[$j]] = 1
            $g_asUSBSize[$aQueue[$j]]   = _FmtBytes($iFinalSize)
            Local $sAvgSpeed
            If ($iElapsedTotal > 0) Then
                $sAvgSpeed = ("  Ø " & _FmtBytes($iFileSize / $iElapsedTotal) & "/s")
            Else
                $sAvgSpeed = ""
            EndIf
            _Log("  ✓ OK: " & $sName & " (" & _FmtBytes($iFinalSize) & ")" & $sAvgSpeed)

            ; ---- Quelldatei löschen (nur wenn Nutzer JA gewählt hat) ----
            Local $sDeleteNote = ""
            If $bDeleteAfterCopy Then
                FileDelete($sISO)
                If Not FileExists($sISO) Then
                    $iDeleted += 1
                    $sDeleteNote = " — Quelldatei gelöscht"
                    _Log("  🗑 Quelldatei gelöscht: " & $sISO)
                Else
                    $sDeleteNote = " — ⚠ Löschen fehlgeschlagen"
                    _Log("  ⚠ Quelldatei konnte nicht gelöscht werden: " & $sISO)
                EndIf
            Else
                $sDeleteNote = " — Quelldatei behalten"
                _Log("  📁 Quelldatei behalten: " & $sISO)
            EndIf

            Local $iDonePct
            If ($iTotalBytes > 0) Then
                $iDonePct = Int($iGlobalDone / $iTotalBytes * 100)
            Else
                $iDonePct = 100
            EndIf
            _PopUpdate($iDonePct, "✓ " & $sName & "  –  " & _FmtBytes($iFinalSize) & $sAvgSpeed, _
                "ISO " & ($j+1) & "/" & $iCount & " — fertig" & $sDeleteNote)
            GUICtrlSetData($g_hProgress, $iDonePct)
            Sleep(400)
        Else
            $iFailed += 1
            _Log("  ✗ FEHLER: " & $sName & " — " & _FmtBytes($iFinalSize) & " / " & _FmtBytes($iFileSize))
            _PopUpdate(Int($iGlobalDone / ($iTotalBytes + ($iTotalBytes = 0)) * 100), _
                "FEHLER: " & $sName & " — Datei unvollständig!", _
                "ISO " & ($j+1) & "/" & $iCount)
            Sleep(1500)
        EndIf
    Next

    _PopUpdate(100, _
        $iCopied & " kopiert" & ($iFailed  > 0 ? ",  " & $iFailed  & " fehlgeschlagen" : "") & _
        ($iSkipped > 0 ? ",  " & $iSkipped & " übersprungen" : ""), "Fertig")
    Sleep(800)
    _PopClose()
    $g_bBusy = False

    Local $sResult = $iCopied & " von " & $iCount & " ISO(s) auf " & $sDrive & " kopiert."
    If $bDeleteAfterCopy Then
        $sResult &= @CRLF & $iDeleted & " lokale ISO(s) gelöscht."
    Else
        $sResult &= @CRLF & "Lokale ISO-Kopien wurden behalten."
    EndIf
    If $iFailed  > 0 Then $sResult &= @CRLF & $iFailed  & " ISO(s) fehlgeschlagen (Protokoll-Tab prüfen)."
    If $iSkipped > 0 Then $sResult &= @CRLF & $iSkipped & " ISO(s) übersprungen (Datei nicht vorhanden)."
    _Status($sResult)
    _Log($sResult)

    ; /v14.45: background.png neu generieren + Ergebnis merken
    Local $bThemeUpdatedC = False
    If $iCopied > 0 Then
        _EnsureVentoyTheme($sDrive, False)
        Local $sThemeDirC = $sDrive & "\ventoy\themes\usb-stick"
        If FileExists($sThemeDirC) Then
            _Log("  v14.45: background.png aktualisieren nach _CopyISOsToUSB (" & $iCopied & " kopiert)")
            _CreateThemeBackground($sThemeDirC, $sDrive)
            $bThemeUpdatedC = True
        EndIf
    EndIf

    _FillTree()

    Local $sThemeLineC = $bThemeUpdatedC ? "✓ Boot-Bild (background.png) aktualisiert." : ""

    If $iFailed = 0 Then
        Local $sDeleteMsg
        If $bDeleteAfterCopy Then
            $sDeleteMsg = $iDeleted & " lokale ISO(s) gelöscht."
        Else
            $sDeleteMsg = "Lokale ISO-Kopien behalten."
        EndIf

        ; — TMP-Verzeichnis nach erfolgreicher Kopie komplett leeren
        Local $sTmpNote = ""
        If FileExists($TMP_DOWNLOAD_DIR) Then
            DirRemove($TMP_DOWNLOAD_DIR, 1)
            DirCreate($TMP_DOWNLOAD_DIR)
            $sTmpNote = @CRLF & "TMP-Ordner bereinigt."
            _Log("🗑 TMP-Verzeichnis nach Kopie geleert: " & $TMP_DOWNLOAD_DIR)
        EndIf

        MsgBox(64, "Fertig ✓", _
            "ISOs erfolgreich auf USB-Stick kopiert!" & @CRLF & @CRLF & _
            "Laufwerk:  " & $sDrive & @CRLF & _
            "Kopiert:   " & $iCopied & " ISO(s)" & @CRLF & _
            $sDeleteMsg & $sTmpNote & @CRLF & _
            ($sThemeLineC <> "" ? $sThemeLineC : ""))
    Else
        MsgBox(48, "Teilweise fertig", _
            $sResult & @CRLF & @CRLF & _
            ($sThemeLineC <> "" ? $sThemeLineC & @CRLF : "") & _
            "Prüfe den Protokoll-Tab für Details.")
    EndIf
EndFunc

Func _UnknownISODialog(ByRef $aUnknown, $iCount, $sDrive)
    ; ===========================================================================
    ;  v14.10 — komplett neu: feste Fensterhöhe, scrollbarer Listenbereich,
    ;           korrekte Combo-Initialisierung, Buttons immer sichtbar
    ; ===========================================================================
    Local $iW      = 700
    Local $iHeader = 96     ; Höhe des festen Header-Bereichs (Titel + Beschreibung + Spaltenkopf)
    Local $iFooter = 50     ; Höhe des festen Footer-Bereichs (Buttons)
    Local $iRowH   = 46     ; Höhe pro ISO-Zeile
    Local $iListH  = $iCount * $iRowH
    Local $iListMax = 350   ; max. Höhe des Scrollbereichs
    If $iListH > $iListMax Then $iListH = $iListMax
    Local $iH = $iHeader + $iListH + $iFooter + 10

    Local $hDlg = GUICreate("? Unbekannte ISOs auf " & $sDrive, $iW, $iH, -1, -1, _
        BitOR($WS_CAPTION, $WS_SYSMENU), $WS_EX_DROPSHADOW)
    GUISetFont(9, 400, 0, "Segoe UI", $hDlg)
    GUISetBkColor(0xFFFFFF, $hDlg)

    ; ── Header ───────────────────────────────────────────────────────────────
    GUICtrlCreateLabel("", 0, 0, $iW, 5)
    GUICtrlSetBkColor(-1, $C_AMB)
    GUICtrlSetState(-1, $GUI_DISABLE)

    GUICtrlCreateLabel("?  " & $iCount & " unbekannte ISO(s) auf " & $sDrive, 14, 12, $iW - 28, 20)
    GUICtrlSetFont(-1, 11, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    GUICtrlCreateLabel( _
        "Diese ISOs sind nicht in der App-Datenbank. Waehle aus, welche durch eine" & @LF & _
        "bekannte Distribution ersetzt werden sollen (alte Datei wird vom Stick geloescht).", _
        14, 36, $iW - 28, 32)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    GUICtrlCreateLabel("", 0, 70, $iW, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; Spaltenkopf
    GUICtrlCreateLabel("  Ersetzen?", 10, 76, 90, 14)
    GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, 0xFFFFFF)
    GUICtrlCreateLabel("ISO-Datei auf Stick", 108, 76, 220, 14)
    GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, 0xFFFFFF)
    GUICtrlCreateLabel("Ersetzen durch", 340, 76, 340, 14)
    GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, 0xFFFFFF)

    GUICtrlCreateLabel("", 0, 91, $iW, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── Scrollbarer Listenbereich via scrollbares Edit-Dummy-Fenster ─────────
    ; AutoIt hat kein natives Scroll-Panel — Lösung: Child-GUI mit WS_VSCROLL
    Local $hScroll = GUICreate("", $iW - 16, $iListH, 8, $iHeader, _
        BitOR($WS_CHILD, $WS_VSCROLL, $WS_CLIPCHILDREN), 0, $hDlg)
    GUISetBkColor(0xFFFFFF, $hScroll)
    GUISwitch($hScroll)

    ; Dropdown-Liste aller bekannten Distros (einmalig aufbauen)
    Local $sDistroList = ""
    For $i = 0 To $ISO_COUNT - 1
        $sDistroList &= $g_aISOs[$i][0] & "|"
    Next
    $sDistroList = StringTrimRight($sDistroList, 1)
    ; BUG-FIX v14.38: $sComboInit-Variable entfernt (war nie genutzt – Combo wird direkt initialisiert)

    ; Rows
    Local $ahChk[$iCount]
    Local $ahCombo[$iCount]
    Local $iRowY = 0

    For $k = 0 To $iCount - 1
        ; Zebra-Hintergrund
        If Mod($k, 2) = 0 Then
            GUICtrlCreateLabel("", 0, $iRowY, $iW - 16, $iRowH)
            GUICtrlSetBkColor(-1, 0xF8FAFC)
            GUICtrlSetState(-1, $GUI_DISABLE)
        EndIf

        ; Checkbox
        $ahChk[$k] = GUICtrlCreateCheckbox("", 12, $iRowY + 14, 18, 18)

        ; Dateiname
        Local $sLabel = $aUnknown[$k][0]
        If StringLen($sLabel) > 34 Then $sLabel = StringLeft($sLabel, 32) & "..."
        GUICtrlCreateLabel($sLabel, 36, $iRowY + 5, 262, 16)
        GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")
        GUICtrlSetColor(-1, $C_TXT)
        GUICtrlSetBkColor(-1, -2)   ; transparent

        ; Dateigröße
        GUICtrlCreateLabel($aUnknown[$k][1], 36, $iRowY + 23, 262, 14)
        GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
        GUICtrlSetColor(-1, $C_DIM)
        GUICtrlSetBkColor(-1, -2)

        ; Trennlinie
        GUICtrlCreateLabel("", 306, $iRowY + 4, 1, $iRowH - 8)
        GUICtrlSetBkColor(-1, $C_BRD)
        GUICtrlSetState(-1, $GUI_DISABLE)

        ; Combo — BUG FIX: GUICtrlCreateCombo setzt den Initial-Text,
        ; GUICtrlSetData ERGAENZT die Liste OHNE den Text zu ueberschreiben
        $ahCombo[$k] = GUICtrlCreateCombo("-- Distro waehlen --", 316, $iRowY + 11, 358, 24, _
            BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
        GUICtrlSetData(-1, $sDistroList)   ; nur die Distros hinzufügen, Initial-Text bleibt
        GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
        GUICtrlSetState(-1, $GUI_DISABLE)

        $iRowY += $iRowH
    Next

    GUISetState(@SW_SHOW, $hScroll)
    GUISwitch($hDlg)

    ; ── Footer-Linie + Buttons (immer sichtbar, feste Y-Position) ────────────
    Local $iFooterY = $iHeader + $iListH + 4
    GUICtrlCreateLabel("", 0, $iFooterY, $iW, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    Local $hBtnOK = GUICtrlCreateButton("  Ausgewahlte ersetzen", 14, $iFooterY + 10, 200, 28)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_LGRN)
    GUICtrlSetColor(-1, $C_GRN)

    Local $hBtnSkip = GUICtrlCreateButton("  Ueberspringen", $iW - 150, $iFooterY + 10, 132, 28)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_LRED)
    GUICtrlSetColor(-1, $C_RED)

    GUISetState(@SW_SHOW, $hDlg)

    ; ── Modaler Event-Loop ───────────────────────────────────────────────────
    Local $bDone = False, $bReplace = False

    While Not $bDone
        Local $m = GUIGetMsg()
        Switch $m
            Case $GUI_EVENT_CLOSE, $hBtnSkip
                $bDone    = True
                $bReplace = False

            Case $hBtnOK
                ; Validierung: mind. eine Checkbox + Distro gewählt
                Local $bValid = True
                Local $bAny   = False
                For $k = 0 To $iCount - 1
                    If GUICtrlRead($ahChk[$k]) = $GUI_CHECKED Then
                        $bAny = True
                        Local $sVal = GUICtrlRead($ahCombo[$k])
                        If $sVal = "-- Distro waehlen --" Or $sVal = "" Then
                            MsgBox(48, "Hinweis", _
                                "Bitte fuer jede angekreuzte ISO eine Ziel-Distribution auswaehlen.")
                            $bValid = False
                            ExitLoop
                        EndIf
                    EndIf
                Next
                If Not $bAny Then
                    MsgBox(48, "Hinweis", "Bitte mindestens eine ISO ankreuzen.")
                ElseIf $bValid Then
                    $bDone    = True
                    $bReplace = True
                EndIf

            Case Else
                ; Checkboxen → Combo aktivieren/deaktivieren
                GUISwitch($hScroll)
                For $k = 0 To $iCount - 1
                    If GUICtrlRead($ahChk[$k]) = $GUI_CHECKED Then
                        GUICtrlSetState($ahCombo[$k], $GUI_ENABLE)
                    Else
                        GUICtrlSetState($ahCombo[$k], $GUI_DISABLE)
                        ; BUG FIX: Platzhalter wiederherstellen ohne Liste zu verlieren
                        GUICtrlSetData($ahCombo[$k], "-- Distro waehlen --", "-- Distro waehlen --")
                    EndIf
                Next
                GUISwitch($hDlg)
        EndSwitch
    WEnd

    GUIDelete($hScroll)
    GUIDelete($hDlg)

    If Not $bReplace Then
        _Log("Unbekannte ISOs: Nutzer hat Dialog übersprungen.")
        Return
    EndIf

    ; -----------------------------------------------------------------------
    ; Ersetzen: für jede angekreuzte ISO
    ;   1. Ziel-ISO-Index aus Dropdown-Text ermitteln
    ;   2. Alte Datei vom Stick löschen
    ;   3. Falls neue ISO nicht lokal → herunterladen
    ;   4. Neue ISO auf Stick kopieren
    ; -----------------------------------------------------------------------
    $g_bBusy   = True
    $g_bCancel = False

    For $k = 0 To $iCount - 1
        If GUICtrlRead($ahChk[$k]) <> $GUI_CHECKED Then ContinueLoop

        Local $sChosen = GUICtrlRead($ahCombo[$k])
        ; ISO-Index anhand des Namens suchen
        Local $iTarget = -1
        For $i = 0 To $ISO_COUNT - 1
            If $g_aISOs[$i][0] = $sChosen Then
                $iTarget = $i
                ExitLoop
            EndIf
        Next
        If $iTarget = -1 Then ContinueLoop

        Local $sOldFile  = $aUnknown[$k][2]    ; voller Pfad auf dem Stick
        Local $sOldName  = $aUnknown[$k][0]
        Local $sNewName  = $g_aISOs[$iTarget][0]
        Local $sLocalISO = $DOWNLOAD_DIR & "\" & $g_aISOs[$iTarget][3]
        Local $sDestISO  = $sDrive & "\" & $g_aISOs[$iTarget][3]

        _Log("=== Ersetze unbekannte ISO ===")
        _Log("  Alt (Stick): " & $sOldName)
        _Log("  Neu:         " & $sNewName & "  →  " & $g_aISOs[$iTarget][3])

        ; Schritt A: Alte ISO vom Stick löschen
        _Status("Lösche alte ISO: " & $sOldName)
        If FileDelete($sOldFile) Then
            _Log("  🗑 Alte ISO gelöscht: " & $sOldFile)
        Else
            _Log("  ⚠ Konnte alte ISO nicht löschen: " & $sOldFile)
            MsgBox(48, "Hinweis", "Konnte nicht löschen:" & @CRLF & $sOldFile & @CRLF & @CRLF & _
                "Bitte manuell löschen und erneut versuchen.")
            ContinueLoop
        EndIf

        ; Schritt B: Neue ISO herunterladen falls nicht lokal vorhanden
        If Not (FileExists($sLocalISO) And FileGetSize($sLocalISO) > 1048576) Then
            _Log("  ⬇ Neue ISO nicht lokal — starte Download: " & $sNewName)
            _PopShow("Download: " & $sNewName, "Lade ISO herunter ...", True)
            _DownloadOne($iTarget, 0, 1)
            _PopClose()
        Else
            _Log("  ✓ Neue ISO bereits lokal vorhanden: " & $sLocalISO)
        EndIf

        ; Schritt C: Neue ISO auf Stick kopieren (falls Download erfolgreich)
        If FileExists($sLocalISO) And FileGetSize($sLocalISO) > 1048576 Then
            ; Lösch-Abfrage für lokale Datei nach dem Kopieren
            Local $iDelChoice = MsgBox(291, "Lokale ISO nach dem Kopieren löschen?", _
                "Soll die lokale Kopie von" & @CRLF & _
                "  " & $sNewName & @CRLF & _
                "nach dem Kopieren auf den Stick gelöscht werden?" & @CRLF & @CRLF & _
                "  JA      — Lokale Kopie löschen" & @CRLF & _
                "  NEIN    — Lokale Kopie behalten" & @CRLF & _
                "  ABBRUCH — Nicht auf Stick kopieren")
            If $iDelChoice = 2 Then
                _Log("  Kopieren auf Stick übersprungen (Nutzer).")
                ContinueLoop
            EndIf
            Local $bDelLocal = ($iDelChoice = 6)

            Local $aQ[1]
            $aQ[0] = $iTarget
            _Status("Kopiere " & $sNewName & " auf " & $sDrive & " ...")
            _PopShow("Kopiere auf Stick", $sNewName & "  →  " & $sDrive, True)

            ; Chunk-Kopier-Loop direkt (ohne Lösch-Dialog nochmal zu zeigen)
            Local $iFileSize = FileGetSize($sLocalISO)
            Local $hSrc = FileOpen($sLocalISO, 16)
            Local $hDst = FileOpen($sDestISO, 18)
            If $hSrc <> -1 And $hDst <> -1 Then
                Local $iWritten = 0, $tS = TimerInit()
                While $iWritten < $iFileSize And Not $g_bCancel
                    Local $oC = FileRead($hSrc, 4194304)
                    If @error Or BinaryLen($oC) = 0 Then ExitLoop
                    FileWrite($hDst, $oC)
                    $iWritten += BinaryLen($oC)
                    Local $iPct = Int($iWritten / $iFileSize * 100)
                    If $iPct > 99 Then $iPct = 99
                    _PopUpdate($iPct, _FmtBytes($iWritten) & " / " & _FmtBytes($iFileSize), $sNewName & "  " & $iPct & "%")
                    GUICtrlSetData($g_hProgress, $iPct)
                    Local $ev = GUIGetMsg()
                    If $ev = $GUI_EVENT_CLOSE Then _Quit()
                    If $ev = $g_hBtnCancel Or ($g_hPopCancel <> 0 And $ev = $g_hPopCancel) Then $g_bCancel = True
                WEnd
                FileClose($hSrc)
                FileClose($hDst)
            Else
                If $hSrc <> -1 Then FileClose($hSrc)
                If $hDst <> -1 Then FileClose($hDst)
            EndIf
            _PopClose()

            Local $iFinalSz
            If FileExists($sDestISO) Then
                $iFinalSz = FileGetSize($sDestISO)
            Else
                $iFinalSz = 0
            EndIf
            If $iFinalSz >= Int($iFileSize * 0.995) Then
                _Log("  ✓ Kopiert: " & $sNewName & "  →  " & $sDestISO)
                If $bDelLocal Then
                    FileDelete($sLocalISO)
                    _Log("  🗑 Lokale ISO gelöscht: " & $sLocalISO)
                EndIf
            Else
                _Log("  ✗ Kopierfehler: " & $sNewName & "  " & _FmtBytes($iFinalSz) & "/" & _FmtBytes($iFileSize))
                MsgBox(48, "Fehler", "Kopierfehler bei: " & $sNewName & @CRLF & _
                    "Erwartet: " & _FmtBytes($iFileSize) & @CRLF & _
                    "Kopiert:  " & _FmtBytes($iFinalSz))
            EndIf
        Else
            _Log("  ✗ Download fehlgeschlagen — Stick-Kopie übersprungen.")
            MsgBox(48, "Fehler", "Download fehlgeschlagen für:" & @CRLF & $sNewName & @CRLF & @CRLF & _
                "Bitte manuell herunterladen oder URL prüfen.")
        EndIf
    Next

    $g_bBusy = False
    _FillTree()
    _Status("Unbekannte ISO(s) verarbeitet — Stick-Inhalt aktualisiert.")
    _Log("=== Unbekannte ISO-Verarbeitung abgeschlossen ===")
EndFunc

Func _GuessISOCategory($sFilename)
    Local $sL = StringLower($sFilename)
    ; ── Rettung (v14.81) ──────────────────────────────────────────────────
    ; ── Antivirus Live-Systeme (v14.82) ──────────────────────────────────
    ; Kaspersky (krd.iso) entfernt aus Antivirus (CDN nicht curl-zugänglich)
    If StringInStr($sL,"avira-rescue") Or StringInStr($sL,"avira_rescue") Or _
       StringInStr($sL,"drweb-livedisk") Or StringInStr($sL,"drweb_livedisk") Then
        Return "Antivirus"
    EndIf
    If StringInStr($sL,"systemrescue") Or StringInStr($sL,"sysrescue") Or _
       StringInStr($sL,"gparted") Or StringInStr($sL,"clonezilla") Or _
       StringInStr($sL,"rescuezilla") Or StringInStr($sL,"finnix") Or _
       StringInStr($sL,"trinity-rescue") Or StringInStr($sL,"trk") Or _
       StringInStr($sL,"dban") Or StringInStr($sL,"shredos") Or _
       StringInStr($sL,"hirens") Or StringInStr($sL,"ubcd") Or _
       StringInStr($sL,"boot-repair") Then
        Return "Rettung"
    EndIf
    ; HBCD / Hiren's Boot CD PE → eigene WinPE-Kategorie
    If StringInStr($sL,"hbcd") Then
        Return "WinPE"
    EndIf
    ; ── Sicherheit ────────────────────────────────────────────────────────
    If StringInStr($sL,"kali") Or StringInStr($sL,"parrot") Or _
       StringInStr($sL,"tails") Or StringInStr($sL,"blackarch") Or _
       StringInStr($sL,"whonix") Or StringInStr($sL,"security") Or _
       StringInStr($sL,"backbox") Or StringInStr($sL,"kodachi") Or _
       StringInStr($sL,"qubes") Or StringInStr($sL,"remnux") Or _
       StringInStr($sL,"caine") Or StringInStr($sL,"deft") Then
        Return "Sicherheit"
    EndIf
    ; ── Antivirus ─────────────────────────────────────────────────────────
    If StringInStr($sL,"drweb") Or StringInStr($sL,"eset_sysrescue") Or _
       StringInStr($sL,"comodo_rescue") Or StringInStr($sL,"sysrescue_live") Or _
       StringInStr($sL,"gdata-bootmedium") Or StringInStr($sL,"gdata_bootmedium") Then
        Return "Antivirus"
    EndIf
    ; Kaspersky Rescue Disk (krd.iso) + AntivirusLiveCD
    If $sL = "krd.iso" Or StringLeft($sL, 4) = "krd-" Or StringLeft($sL, 4) = "krd_" Then
        Return "Antivirus"
    EndIf
    If StringInStr($sL, "antiviruslivecd") Or StringInStr($sL, "antivirus-live") Or _
       StringInStr($sL, "antivirus_live") Then
        Return "Antivirus"
    EndIf
    ; ── Gaming ────────────────────────────────────────────────────────────
    ; ── Gaming ────────────────────────────────────────────────────────────
    If StringInStr($sL,"nobara") Or StringInStr($sL,"garuda") Or _
       StringInStr($sL,"gaming") Or StringInStr($sL,"chimeraos") Then
        Return "Gaming"
    EndIf
    ; ── Leichtgewicht (Geschwindigkeit & Effizienz) (v14.99) ───────────────
    If StringInStr($sL,"xfce") Or StringInStr($sL,"lxqt") Or _
       StringInStr($sL,"lxde") Or StringInStr($sL,"mate") Or _
       StringInStr($sL,"antix") Or StringInStr($sL,"puppy") Or _
       StringInStr($sL,"dsl-") Or StringInStr($sL,"porteus") Or _
       StringInStr($sL,"fluxbox") Or StringInStr($sL,"openbox") Or _
       StringInStr($sL,"minimal") Then
        Return "Leichtgewicht"
    EndIf
    ; ── Fortgeschrittene (Unabhängigkeit & Stabilität) (v14.99) ───────────
    If StringInStr($sL,"arch") Or StringInStr($sL,"debian") Or _
       StringInStr($sL,"gentoo") Or StringInStr($sL,"void") Or _
       StringInStr($sL,"slackware") Or StringInStr($sL,"nixos") Or _
       StringInStr($sL,"artix") Or StringInStr($sL,"cachy") Or _
       StringInStr($sL,"endeavour") Or StringInStr($sL,"manjaro") Or _
       StringInStr($sL,"fedora") Or StringInStr($sL,"server") Or _
       StringInStr($sL,"proxmox") Or StringInStr($sL,"nas") Or _
       StringInStr($sL,"truenas") Or StringInStr($sL,"cloud") Then
        Return "Fortgeschrittene"
    EndIf
    ; ── Einsteiger (Komfort & Design) (v14.99) ────────────────────────────
    If StringInStr($sL,"ubuntu") Or StringInStr($sL,"mint") Or _
       StringInStr($sL,"pop-os") Or StringInStr($sL,"pop_os") Or _
       StringInStr($sL,"zoren") Or StringInStr($sL,"elementary") Or _
       StringInStr($sL,"cinnamon") Or StringInStr($sL,"deepin") Or _
       StringInStr($sL,"budgie") Or StringInStr($sL,"kde") Or _
       StringInStr($sL,"plasma") Or StringInStr($sL,"gnome") Or _
       StringInStr($sL,"workstation") Or StringInStr($sL,"desktop") Or _
       StringInStr($sL,"lts") Then
        Return "Einsteiger"
    EndIf
    Return "Einsteiger"
EndFunc

Func _GuessISOCandidateURLs($sFilename)
    Local $sL    = StringLower($sFilename)
    Local $aCands[0]
    Local $sRWTH = "https://ftp.halifax.rwth-aachen.de"
    Local $sFAU  = "https://ftp.fau.de"
    Local $sDots = "https://mirrors.dotsrc.org"
    Local $sSF   = "https://master.dl.sourceforge.net/project"   ; SourceForge CDN

    ; ── 1. DB-Lookup: Dateiname gegen bekannte ISOs abgleichen ───────────
    ;    Exakter Treffer → direkt die gespeicherten Mirror-URLs zurückgeben.
    ;    Dadurch werden alle 19 DB-Einträge sofort gefunden — kein Raten nötig.
    Local $iDB
    For $iDB = 0 To $ISO_COUNT - 1
        If StringLower($g_aISOs[$iDB][3]) = $sL Then
            If $g_aISOs[$iDB][2] <> "" Then _ArrayAdd($aCands, $g_aISOs[$iDB][2])
            If $g_aISOs[$iDB][4] <> "" Then _ArrayAdd($aCands, $g_aISOs[$iDB][4])
            If $g_aISOs[$iDB][5] <> "" Then _ArrayAdd($aCands, $g_aISOs[$iDB][5])
            If $g_aISOs[$iDB][8] <> "" Then _ArrayAdd($aCands, $g_aISOs[$iDB][8])
            If UBound($aCands) > 0 Then Return $aCands   ; sofort zurück
        EndIf
    Next

    ; ── 2. Bekannte Distros: spezifische Mirror-Pfade ─────────────────────

    If StringInStr($sL,"ubuntu") And Not StringInStr($sL,"lubuntu") Then
        ; Ubuntu Desktop / Server — releases.ubuntu.com + EU-Mirrors
        Local $aVU = StringRegExp($sFilename, "(\d+\.\d+(?:\.\d+)?)", 3)
        If IsArray($aVU) And UBound($aVU) > 0 Then
            Local $sMajU = StringRegExpReplace($aVU[0], "(\d+\.\d+).*", "$1")
            _ArrayAdd($aCands, "https://releases.ubuntu.com/" & $sMajU & "/" & $sFilename)
            _ArrayAdd($aCands, $sRWTH & "/ubuntu-releases/" & $sMajU & "/" & $sFilename)
            _ArrayAdd($aCands, $sFAU  & "/ubuntu-releases/" & $sMajU & "/" & $sFilename)
            _ArrayAdd($aCands, $sDots & "/ubuntu-releases/" & $sMajU & "/" & $sFilename)
        EndIf

    ElseIf StringInStr($sL,"lubuntu") Then
        ; Lubuntu — ubuntu-cdimage
        Local $aVL = StringRegExp($sFilename, "(\d+\.\d+(?:\.\d+)?)", 3)
        If IsArray($aVL) And UBound($aVL) > 0 Then
            Local $sMajL = StringRegExpReplace($aVL[0], "(\d+\.\d+).*", "$1")
            _ArrayAdd($aCands, $sRWTH & "/ubuntu-cdimage/lubuntu/releases/" & $sMajL & "/release/" & $sFilename)
            _ArrayAdd($aCands, $sFAU  & "/ubuntu-cdimage/lubuntu/releases/" & $sMajL & "/release/" & $sFilename)
        EndIf

    ElseIf StringInStr($sL,"debian") Then
        ; Debian Live / DVD
        If StringInStr($sL,"live") Then
            _ArrayAdd($aCands, "https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/" & $sFilename)
            _ArrayAdd($aCands, $sRWTH & "/debian-cd/current-live/amd64/iso-hybrid/" & $sFilename)
            _ArrayAdd($aCands, $sFAU  & "/debian-cd/current-live/amd64/iso-hybrid/" & $sFilename)
        Else
            _ArrayAdd($aCands, "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/" & $sFilename)
            _ArrayAdd($aCands, $sRWTH & "/debian-cd/current/amd64/iso-dvd/" & $sFilename)
            _ArrayAdd($aCands, $sFAU  & "/debian-cd/current/amd64/iso-dvd/" & $sFilename)
        EndIf

    ElseIf StringInStr($sL,"kali") Then
        ; Kali Linux — kali-YYYY.N Pfad
        Local $aVK = StringRegExp($sFilename, "(\d{4}\.\d+)", 3)
        If IsArray($aVK) And UBound($aVK) > 0 Then
            _ArrayAdd($aCands, "https://cdimage.kali.org/kali-" & $aVK[0] & "/" & $sFilename)
            _ArrayAdd($aCands, "https://kali.download/kali-images/kali-" & $aVK[0] & "/" & $sFilename)
            _ArrayAdd($aCands, $sRWTH & "/kali-images/kali-" & $aVK[0] & "/" & $sFilename)
            _ArrayAdd($aCands, $sFAU  & "/kali-images/kali-" & $aVK[0] & "/" & $sFilename)
        Else
            _ArrayAdd($aCands, $sRWTH & "/kali-images/current/" & $sFilename)
            _ArrayAdd($aCands, $sFAU  & "/kali-images/current/" & $sFilename)
        EndIf

    ElseIf StringInStr($sL,"parrot") Then
        ; Parrot OS Security / Home
        _ArrayAdd($aCands, "https://deb.parrot.sh/parrot/iso/current/" & $sFilename)
        _ArrayAdd($aCands, $sRWTH & "/parrot/iso/current/" & $sFilename)
        _ArrayAdd($aCands, $sFAU  & "/parrot/iso/current/" & $sFilename)
        Local $aVPar = StringRegExp($sFilename, "(\d+\.\d+)", 3)
        If IsArray($aVPar) And UBound($aVPar) > 0 Then
            _ArrayAdd($aCands, "https://deb.parrot.sh/parrot/iso/" & $aVPar[0] & "/" & $sFilename)
        EndIf

    ElseIf StringInStr($sL,"tails") Then
        ; Tails — v2.13: RWTH + dotsrc + ftp.fau.de als Kandidaten
        ; download.tails.net blockiert Curl; kernel.org 404 für 7.6.1
        Local $aVT = StringRegExp($sFilename, "(\d+\.\d+(?:\.\d+)?)", 3)
        If IsArray($aVT) And UBound($aVT) > 0 Then
            _ArrayAdd($aCands, "https://ftp.halifax.rwth-aachen.de/tails/stable/tails-amd64-" & $aVT[0] & "/" & $sFilename)
            _ArrayAdd($aCands, "https://mirrors.dotsrc.org/tails/stable/tails-amd64-" & $aVT[0] & "/" & $sFilename)
            _ArrayAdd($aCands, "https://ftp.fau.de/tails/stable/tails-amd64-" & $aVT[0] & "/" & $sFilename)
        EndIf

    ElseIf StringInStr($sL,"kodachi") Then
        ; Linux Kodachi — SourceForge
        _ArrayAdd($aCands, $sSF & "/linuxkodachi/" & $sFilename & "?viasf=1")

    ElseIf StringInStr($sL,"fedora") Then
        ; Fedora Workstation/Spins — FAU + RWTH + Dotsrc
        Local $aVF = StringRegExp($sFilename, "(\d{2,3})", 3)
        If IsArray($aVF) And UBound($aVF) > 0 Then
            _ArrayAdd($aCands, $sFAU  & "/fedora/linux/releases/" & $aVF[0] & "/Workstation/x86_64/iso/" & $sFilename)
            _ArrayAdd($aCands, $sRWTH & "/fedora/linux/releases/" & $aVF[0] & "/Workstation/x86_64/iso/" & $sFilename)
            _ArrayAdd($aCands, $sDots & "/fedora/linux/releases/" & $aVF[0] & "/Workstation/x86_64/iso/" & $sFilename)
            _ArrayAdd($aCands, $sFAU  & "/fedora/linux/releases/" & $aVF[0] & "/Spins/x86_64/iso/" & $sFilename)
            _ArrayAdd($aCands, $sRWTH & "/fedora/linux/releases/" & $aVF[0] & "/Spins/x86_64/iso/" & $sFilename)
        EndIf

    ElseIf StringInStr($sL,"manjaro") Then
        ; Manjaro — KDE/GNOME/XFCE-Pfade
        Local $aVM = StringRegExp($sFilename, "(\d+\.\d+(?:\.\d+)?)", 3)
        If IsArray($aVM) And UBound($aVM) > 0 Then
            Local $sDE = "kde"
            If StringInStr($sL,"gnome") Then $sDE = "gnome"
            If StringInStr($sL,"xfce")  Then $sDE = "xfce"
            _ArrayAdd($aCands, $sRWTH & "/manjaro/" & $sDE & "/" & $aVM[0] & "/" & $sFilename)
            _ArrayAdd($aCands, $sFAU  & "/manjaro/" & $sDE & "/" & $aVM[0] & "/" & $sFilename)
            _ArrayAdd($aCands, $sDots & "/manjaro/" & $sDE & "/" & $aVM[0] & "/" & $sFilename)
        EndIf

    ElseIf StringInStr($sL,"mint") Then
        ; Linux Mint — linuxmint.com + EU-Mirrors
        Local $aVMint = StringRegExp($sFilename, "(\d+(?:\.\d+)?)", 3)
        If IsArray($aVMint) And UBound($aVMint) > 0 Then
            _ArrayAdd($aCands, "https://mirror.accum.se/mirror/linuxmint.com/stable/" & $aVMint[0] & "/" & $sFilename)
            _ArrayAdd($aCands, $sRWTH & "/linux-mint/stable/" & $aVMint[0] & "/" & $sFilename)
            _ArrayAdd($aCands, $sDots & "/linuxmint/stable/" & $aVMint[0] & "/" & $sFilename)
        EndIf

    ElseIf StringInStr($sL,"mx") Then
        ; MX Linux — mxlinux.org Mirrors
        _ArrayAdd($aCands, $sRWTH & "/mxlinux/isos/MX/Final/Xfce/" & $sFilename)
        _ArrayAdd($aCands, $sFAU  & "/mxlinux-cd/MX/Final/Xfce/" & $sFilename)
        _ArrayAdd($aCands, $sDots & "/mxlinux/isos/MX/Final/Xfce/" & $sFilename)

    ElseIf StringInStr($sL,"zorin") Then
        ; Zorin OS — zorinos.com Mirrors
        Local $aVZ = StringRegExp($sFilename, "(\d+)", 3)
        If IsArray($aVZ) And UBound($aVZ) > 0 Then
            _ArrayAdd($aCands, $sRWTH & "/zorinos/" & $aVZ[0] & "/" & $sFilename)
            _ArrayAdd($aCands, $sDots & "/zorinos/" & $aVZ[0] & "/" & $sFilename)
        EndIf

    ElseIf StringInStr($sL,"eset_sysrescue") Or StringInStr($sL,"sysrescue_live") Or _
           StringInStr($sL,"gdata-bootmedium") Or StringInStr($sL,"gdata_bootmedium") Then
        ; G DATA BootMedium — offizieller CDN (ESET SysRescue Live ist seit Sept. 2023 EOL)
        _ArrayAdd($aCands, "https://www.gdatasoftware.com/fileadmin/web/en/documents/bootcd/GData-BootMedium.iso")
        _ArrayAdd($aCands, "https://www.gdatasoftware.com/fileadmin/web/de/documents/bootcd/GData-BootMedium.iso")

    ElseIf StringInStr($sL,"comodo_rescue") Then
        ; Comodo Rescue Disk — direkter Comodo-CDN
        _ArrayAdd($aCands, "https://download.comodo.com/crd/download/setups/comodo_rescue_disk.iso")

    ElseIf StringInStr($sL,"almalinux") Then
        ; AlmaLinux Live — repo.almalinux.org
        Local $aVAL = StringRegExp($sFilename, "(\d+\.\d+)", 3)
        If IsArray($aVAL) And UBound($aVAL) > 0 Then
            _ArrayAdd($aCands, "https://repo.almalinux.org/almalinux/" & $aVAL[0] & "/live/x86_64/" & $sFilename)
            _ArrayAdd($aCands, $sRWTH & "/almalinux/" & $aVAL[0] & "/live/x86_64/" & $sFilename)
            _ArrayAdd($aCands, $sFAU  & "/almalinux/" & $aVAL[0] & "/live/x86_64/" & $sFilename)
        Else
            Local $aVAL2 = StringRegExp($sFilename, "(\d+)", 3)
            If IsArray($aVAL2) And UBound($aVAL2) > 0 Then
                _ArrayAdd($aCands, "https://repo.almalinux.org/almalinux/" & $aVAL2[0] & "/live/x86_64/" & $sFilename)
                _ArrayAdd($aCands, $sRWTH & "/almalinux/" & $aVAL2[0] & "/live/x86_64/" & $sFilename)
            EndIf
        EndIf

    ElseIf StringInStr($sL,"cachyos") Then
        ; CachyOS — mirror.cachyos.org
        _ArrayAdd($aCands, "https://mirror.cachyos.org/ISO/kde/" & $sFilename)
        _ArrayAdd($aCands, "https://mirror.cachyos.org/ISO/gnome/" & $sFilename)
        _ArrayAdd($aCands, "https://mirror.cachyos.org/ISO/" & $sFilename)
        _ArrayAdd($aCands, "https://cdn77.cachyos.org/iso/kde/" & $sFilename)
        _ArrayAdd($aCands, $sSF & "/cachyos/" & $sFilename & "?viasf=1")

    ElseIf StringInStr($sL,"garuda") Then
        ; Garuda Linux — iso.builds.garudalinux.org + SourceForge
        _ArrayAdd($aCands, "https://iso.builds.garudalinux.org/iso/garuda/dr460nized/current/" & $sFilename)
        _ArrayAdd($aCands, "https://iso.builds.garudalinux.org/iso/garuda/gnome/current/" & $sFilename)
        _ArrayAdd($aCands, "https://iso.builds.garudalinux.org/iso/garuda/kde-lite/current/" & $sFilename)
        _ArrayAdd($aCands, $sSF & "/garuda-linux/DR460NIZED/" & $sFilename & "?viasf=1")
        _ArrayAdd($aCands, $sSF & "/garuda-linux/" & $sFilename & "?viasf=1")

    ElseIf StringInStr($sL,"archcraft") Then
        ; Archcraft — SourceForge + GitHub Releases
        _ArrayAdd($aCands, $sSF & "/archcraft/OS/" & $sFilename & "?viasf=1")
        _ArrayAdd($aCands, $sSF & "/archcraft/" & $sFilename & "?viasf=1")
        _ArrayAdd($aCands, "https://github.com/archcraft-os/archcraft/releases/latest/download/" & $sFilename)

    ElseIf StringInStr($sL,"nobara") Then
        ; Nobara Project — nobaraproject.org
        Local $aVNob = StringRegExp($sFilename, "(\d{2,3})", 3)
        If IsArray($aVNob) And UBound($aVNob) > 0 Then
            _ArrayAdd($aCands, "https://nobaraproject.org/downloads/Nobara-" & $aVNob[0] & "-Official.iso")
            _ArrayAdd($aCands, "https://nobaraproject.org/downloads/" & $sFilename)
        Else
            _ArrayAdd($aCands, "https://nobaraproject.org/downloads/" & $sFilename)
        EndIf
        _ArrayAdd($aCands, $sSF & "/nobara-linux/" & $sFilename & "?viasf=1")

    ElseIf StringInStr($sL,"pop_os") Or StringInStr($sL,"pop-os") Or StringInStr($sL,"popos") Then
        ; Pop!_OS — iso.pop-os.org (intel / nvidia Varianten)
        Local $aVPop = StringRegExp($sFilename, "(\d+\.\d+(?:\.\d+)?)", 3)
        If IsArray($aVPop) And UBound($aVPop) > 0 Then
            Local $sMajPop = StringRegExpReplace($aVPop[0], "(\d+\.\d+).*", "$1")
            If StringInStr($sL,"nvidia") Then
                _ArrayAdd($aCands, "https://iso.pop-os.org/" & $sMajPop & "/amd64/nvidia/" & $sFilename)
            Else
                _ArrayAdd($aCands, "https://iso.pop-os.org/" & $sMajPop & "/amd64/intel/" & $sFilename)
            EndIf
            _ArrayAdd($aCands, "https://iso.pop-os.org/" & $sMajPop & "/amd64/" & $sFilename)
        EndIf

    ElseIf StringInStr($sL,"nobara") Then
        ; Nobara Linux (Gaming) — GitHub Releases (Nobara-Project/nobara-images)
        ; Bazzite entfernt → Nobara als Gaming-Alternative
        ; ISO-Name: Nobara-XX-Official.iso — via GitHub API aufgelöst (Feld [6]/[7])
        _ArrayAdd($aCands, "https://github.com/Nobara-Project/nobara-images/releases/latest")

    ElseIf StringInStr($sL,"systemrescue") Or StringInStr($sL,"sysrescuecd") Then
        ; SystemRescue — SourceForge CDN
        Local $aVSR = StringRegExp($sFilename, "(\d+\.\d+(?:\.\d+)?)", 3)
        If IsArray($aVSR) And UBound($aVSR) > 0 Then
            _ArrayAdd($aCands, $sSF & "/systemrescuecd/sysresccd-x86/" & $aVSR[0] & "/" & $sFilename & "?viasf=1")
            _ArrayAdd($aCands, "https://netcologne.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/" & $aVSR[0] & "/" & $sFilename & "?viasf=1")
        EndIf
        _ArrayAdd($aCands, $sSF & "/systemrescuecd/" & $sFilename & "?viasf=1")

    ElseIf StringInStr($sL,"gparted-live") Then
        ; GParted Live — SourceForge CDN
        Local $aVGP = StringRegExp($sFilename, "(\d+\.\d+\.\d+-\d+)", 3)
        If IsArray($aVGP) And UBound($aVGP) > 0 Then
            _ArrayAdd($aCands, $sSF & "/gparted/gparted-live-stable/" & $aVGP[0] & "/" & $sFilename & "?viasf=1")
            _ArrayAdd($aCands, "https://netcologne.dl.sourceforge.net/project/gparted/gparted-live-stable/" & $aVGP[0] & "/" & $sFilename & "?viasf=1")
        EndIf
        _ArrayAdd($aCands, $sSF & "/gparted/" & $sFilename & "?viasf=1")

    ElseIf StringInStr($sL,"clonezilla") Then
        ; Clonezilla — SourceForge CDN
        Local $aVCZ = StringRegExp($sFilename, "(\d+\.\d+\.\d+-\d+)", 3)
        If IsArray($aVCZ) And UBound($aVCZ) > 0 Then
            _ArrayAdd($aCands, $sSF & "/clonezilla/clonezilla_live_stable/" & $aVCZ[0] & "/" & $sFilename & "?viasf=1")
            _ArrayAdd($aCands, "https://netcologne.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/" & $aVCZ[0] & "/" & $sFilename & "?viasf=1")
        EndIf
        _ArrayAdd($aCands, $sSF & "/clonezilla/" & $sFilename & "?viasf=1")

    ElseIf StringInStr($sL,"rescuezilla") Then
        ; Rescuezilla — GitHub + SourceForge
        Local $aVRZ = StringRegExp($sFilename, "(\d+\.\d+(?:\.\d+)?)", 3)
        If IsArray($aVRZ) And UBound($aVRZ) > 0 Then
            _ArrayAdd($aCands, "https://github.com/rescuezilla/rescuezilla/releases/download/" & $aVRZ[0] & "/" & $sFilename)
            _ArrayAdd($aCands, $sSF & "/rescuezilla/rescuezilla/" & $aVRZ[0] & "/" & $sFilename & "?viasf=1")
        EndIf
        _ArrayAdd($aCands, "https://github.com/rescuezilla/rescuezilla/releases/latest/download/" & $sFilename)

    ElseIf StringInStr($sL,"shredos") Then
        ; ShredOS — SourceForge-Mirror (curl-zugänglich) + GitHub CDN Fallback
        Local $aVSO = StringRegExp($sFilename, "shredos-([\d\.]+_[\d]+_x86-64_[\d\.]+)", 3)
        If IsArray($aVSO) And UBound($aVSO) > 0 Then
            Local $sSOVer = StringRegExp($sFilename, "shredos-([\d\.]+_[\d]+_x86-64_[\d\.]+)", 3)[0]
            ; Version aus Dateiname extrahieren (z.B. 2025.11_28_x86-64_0.40)
            Local $sSOTag = "v" & StringRegExpReplace($sSOVer, "_(\d{8})_nomodeset", "")
            _ArrayAdd($aCands, $sSF & "/shredos.mirror/" & $sSOTag & "/" & $sFilename & "?viasf=1")
            _ArrayAdd($aCands, "https://downloads.sourceforge.net/project/shredos.mirror/" & $sSOTag & "/" & $sFilename)
            _ArrayAdd($aCands, "https://freefr.dl.sourceforge.net/project/shredos.mirror/" & $sSOTag & "/" & $sFilename & "?viasf=1")
            _ArrayAdd($aCands, "https://github.com/PartialVolume/shredos.x86_64/releases/download/" & $sSOTag & "/" & $sFilename)
        EndIf
        ; Statischer Fallback auf aktuelle Version
        _ArrayAdd($aCands, "https://master.dl.sourceforge.net/project/shredos.mirror/v2025.11_28_x86-64_0.40/shredos-2025.11_28_x86-64_0.40_20260204_nomodeset.iso?viasf=1")

    ElseIf StringInStr($sL,"finnix") Then
        ; Finnix — offizielle Finnix-Mirror-Infrastruktur (round-robin)
        Local $aVFX = StringRegExp($sFilename, "finnix-(\d+)", 3)
        If IsArray($aVFX) And UBound($aVFX) > 0 Then
            Local $sFXVer = $aVFX[0]
            _ArrayAdd($aCands, "https://www.finnix.org/releases/" & $sFXVer & "/" & $sFilename)
            _ArrayAdd($aCands, "https://de.mirror.finnix.org/releases/" & $sFXVer & "/" & $sFilename)
            _ArrayAdd($aCands, "https://uk.mirror.finnix.org/releases/" & $sFXVer & "/" & $sFilename)
        EndIf
        _ArrayAdd($aCands, "https://www.finnix.org/releases/251/finnix-251.iso")

    ElseIf StringInStr($sL,"drweb-livedisk") Or StringInStr($sL,"drweb_livedisk") Then
        _ArrayAdd($aCands, "https://download.geo.drweb.com/pub/drweb/livedisk/" & $sFilename)
        _ArrayAdd($aCands, "https://ftp.drweb.com/pub/drweb/livedisk/" & $sFilename)
    ElseIf StringInStr($sL,"avira-rescue") Or $sFilename = "avira-rescue-system.iso" Then
        ; /v14.89: Avira-CDN blockiert curl (HTTP 403) — keine funktionierenden Mirrors bekannt
        ; Empfehlung: avira-rescue-system.iso durch drweb-livedisk-900-cd.iso ersetzen

    ElseIf StringInStr($sL,"trinity-rescue") Or StringInStr($sL,"trk") Then
        ; Trinity Rescue Kit — v14.89: durch Finnix 251 ersetzt; Legacy-URLs behalten für ältere INIs
        _ArrayAdd($aCands, "https://ftp.osuosl.org/pub/trk/trinity-rescue-kit.3.4-build-400.iso")
        _ArrayAdd($aCands, $sSF & "/archiveos/t/trk/trinity-rescue-kit.3.4-build-400.iso?viasf=1")
        _ArrayAdd($aCands, "https://netcologne.dl.sourceforge.net/project/archiveos/t/trk/trinity-rescue-kit.3.4-build-400.iso?viasf=1")
        ; Hinweis: Migration empfohlen auf Finnix 251 (curl-zugänglich)

    ElseIf StringInStr($sL,"garuda") Or StringInStr($sL,"dr460nized") Then
        ; Garuda Linux Dr460nized Gaming -- Arch-basiertes Gaming-Live-ISO (v2.27: Drauger OS Ersatz)
        _ArrayAdd($aCands, "https://iso.builds.garudalinux.org/iso/latest/garuda/dr460nized-gaming/latest.iso")
        _ArrayAdd($aCands, "https://iso.builds.garudalinux.org/iso/latest/garuda/dr460nized-gaming/" & $sFilename)

    ElseIf StringInStr($sL,"drauger") Then
        ; Drauger OS -- EOL seit 2024, Legacy-URLs fuer aeltere INIs; leitet auf Garuda weiter
        _ArrayAdd($aCands, "https://iso.builds.garudalinux.org/iso/latest/garuda/dr460nized-gaming/latest.iso")
        _ArrayAdd($aCands, "https://download.draugeros.org/ISOs/Drauger_OS-7.7-AMD64.iso")

    ElseIf StringInStr($sL,"pikaos") Or StringInStr($sL,"pika-nest") Or StringInStr($sL,"pika_nest") Then
        ; PikaOS (Legacy) — Ventoy mount-Fehler, v2.24 durch Drauger OS ersetzt
        _ArrayAdd($aCands, "https://iso.pika-os.com/" & $sFilename)
        _ArrayAdd($aCands, "https://iso.pika-os.com/PikaOS-Nest-KDE-4.0-amd64-v3-26.04.04-1.iso")

    ElseIf StringInStr($sL,"endeavouros") Or StringInStr($sL,"endeavour_os") Then
        ; EndeavourOS (Legacy) — war kurzzeitig in Slot [21], v2.24 durch PikaOS ersetzt
        _ArrayAdd($aCands, "https://mirror.alpix.eu/endeavouros/iso/" & $sFilename)
        _ArrayAdd($aCands, "https://mirrors.gigenet.com/endeavouros/iso/" & $sFilename)
        _ArrayAdd($aCands, "https://mirror.rznet.fr/endeavouros/iso/" & $sFilename)

    ElseIf StringInStr($sL,"bazzite") Then
        ; Bazzite (Legacy) — nur Installer, kein Live-ISO; v2.24 durch EndeavourOS ersetzt
        _ArrayAdd($aCands, "https://download.bazzite.gg/bazzite-stable-amd64.iso")
        _ArrayAdd($aCands, "https://download.bazzite.gg/" & $sFilename)

    ElseIf StringInStr($sL,"chimeraos") Or (StringInStr($sL,"chimera") And StringInStr($sL,"x86_64")) Then
        ; ChimeraOS (Legacy) — für ältere Sticks, die noch chimeraos-*.iso enthalten
        ; v2.24: ChimeraOS durch Bazzite ersetzt (Ventoy-Inkompatibilität), Legacy-Erkennung bleibt
        Local $aVCh = StringRegExp($sFilename, "(\d{4})\.(\d{2})\.(\d{2})", 3)
        If IsArray($aVCh) And UBound($aVCh) >= 3 Then
            Local $sChTag = $aVCh[0] & "-" & $aVCh[1] & "-" & $aVCh[2]
            Local $sChVer = $aVCh[0] & "." & $aVCh[1] & "." & $aVCh[2]
            Local $sChISO = "chimeraos-" & $sChVer & "-x86_64.iso"
            Local $sChBase = "https://github.com/ChimeraOS/install-media/releases/download/"
            If $sChTag = "2025-04-21" Then
                _ArrayAdd($aCands, $sChBase & "2025-04-21_8a4f21f/" & $sChISO)
            ElseIf $sChTag = "2025-02-13" Then
                _ArrayAdd($aCands, $sChBase & "2025-02-13_7e927cf/" & $sChISO)
            EndIf
            _ArrayAdd($aCands, "https://github.com/ChimeraOS/install-media/releases/latest/download/" & $sChISO)
        EndIf
        _ArrayAdd($aCands, "https://github.com/ChimeraOS/install-media/releases/latest/download/" & $sFilename)

    ; ── v2.16: Manuell hinzugefügte / nicht-DB-ISOs ─────────────────────────

    ElseIf StringInStr($sL,"hbcd") Or StringInStr($sL,"hirens") Then
        ; Hiren's Boot CD PE — hirensbootcd.org (Dateiname ist immer HBCD_PE_x64.iso)
        _ArrayAdd($aCands, "https://www.hirensbootcd.org/files/HBCD_PE_x64.iso")
        ; Alternativ mit aktuellem Dateinamen, falls Nutzer eine umbenannte Kopie hat
        If $sL <> "hbcd_pe_x64.iso" Then
            _ArrayAdd($aCands, "https://www.hirensbootcd.org/files/" & $sFilename)
        EndIf

    ElseIf $sL = "krd.iso" Or StringLeft($sL, 4) = "krd-" Or StringLeft($sL, 4) = "krd." Or _
           StringInStr($sL,"kaspersky rescue") Then
        ; Kaspersky Rescue Disk — fester CDN-Pfad
        _ArrayAdd($aCands, "https://rescuedisk.s.kaspersky-labs.com/updatable/2018/krd.iso")

    ElseIf StringInStr($sL,"antiviruslivecd") Or StringInStr($sL,"antivirus-live") Or _
           StringInStr($sL,"antivirus_live") Then
        ; AntivirusLiveCD (SourceForge) — Versions-Suffix im Dateinamen
        Local $aVAV = StringRegExp($sFilename, "([\d]+\.[\d]+-[\d\.]+)", 3)
        If IsArray($aVAV) And UBound($aVAV) > 0 Then
            ; SourceForge CDN (master)
            _ArrayAdd($aCands, "https://downloads.sourceforge.net/project/antiviruslivecd/files/" & $aVAV[0] & "/" & $sFilename)
            _ArrayAdd($aCands, $sSF & "/antiviruslivecd/files/" & $aVAV[0] & "/" & $sFilename & "?viasf=1")
        EndIf
        ; Hardcoded Fallback auf zuletzt bekannte stabile Version
        _ArrayAdd($aCands, "https://downloads.sourceforge.net/project/antiviruslivecd/files/51.0-1.5.1/AntivirusLiveCD-51.0-1.5.1.iso")

    ElseIf StringInStr($sL,"android") And (StringInStr($sL,"x86") Or StringInStr($sL,"x64")) Then
        ; Android-x86 — SourceForge (Releases-Struktur)
        Local $aVAnd = StringRegExp($sFilename, "(\d+\.\d+)", 3)
        Local $sAndVer = (IsArray($aVAnd) And UBound($aVAnd) > 0) ? $aVAnd[0] : "9.0"
        _AddSFCands($aCands, "android-x86", $sFilename)
        _ArrayAdd($aCands, $sSF & "/android-x86/files/Releases/" & $sAndVer & "/" & $sFilename & "?viasf=1")
        _ArrayAdd($aCands, $sSF & "/android-x86/files/Release%20" & $sAndVer & "/" & $sFilename & "?viasf=1")
        _ArrayAdd($aCands, "https://downloads.sourceforge.net/project/android-x86/Release%20" & $sAndVer & "/" & $sFilename)
        _ArrayAdd($aCands, "https://downloads.sourceforge.net/project/android-x86/Releases/" & $sAndVer & "/" & $sFilename)

    Else
        ; ── 3. Generischer Fallback: SourceForge-Muster ──────────────────
        ;    Ersten Namensteil als Projektnamen raten und SourceForge CDN testen.
        Local $sProjGuess = StringRegExpReplace($sL, "[-_.].*", "")   ; erstes Wort
        _AddSFCands($aCands, $sProjGuess, $sFilename)
        
        ; Zusätzlicher Versuch: erstes Wort + "-x86" (häufiges Muster)
        If StringLen($sProjGuess) >= 3 And Not StringInStr($sProjGuess, "x86") Then
            _AddSFCands($aCands, $sProjGuess & "-x86", $sFilename)
        EndIf
        
        ; Zusätzlicher Versuch: erstes Wort + "linux"
        If StringLen($sProjGuess) >= 3 And Not StringInStr($sProjGuess, "linux") Then
            _AddSFCands($aCands, $sProjGuess & "linux", $sFilename)
        EndIf

        ; Zusätzlich: OSDN-Mirrors
        _ArrayAdd($aCands, $sRWTH & "/osdn/storage/g/" & $sProjGuess & "/" & $sFilename)
        _ArrayAdd($aCands, $sFAU  & "/osdn/" & $sProjGuess & "/" & $sFilename)
    EndIf

    ; ── 3. Heuristische Generika (v2.27) ──────────────────────────────────
    ; Wenn noch nichts gefunden wurde → SourceForge & GitHub Kandidaten raten
    If UBound($aCands) = 0 Then
        Local $sB = StringRegExpReplace($sFilename, "(?i)[-_][\d].*", "")
        $sB = StringRegExpReplace($sB, "(?i)[-_](linux|os|live|amd64|x86_64).*", "")
        Local $sBLow = StringLower($sB)
        If StringLen($sBLow) > 2 Then
            _ArrayAdd($aCands, "https://master.dl.sourceforge.net/project/" & $sBLow & "/" & $sFilename & "?viasf=1")
            _ArrayAdd($aCands, "https://netcologne.dl.sourceforge.net/project/" & $sBLow & "/" & $sFilename & "?viasf=1")
            _ArrayAdd($aCands, "https://github.com/" & $sBLow & "/" & $sBLow & "/releases/latest/download/" & $sFilename)
        EndIf
    EndIf

    Return $aCands
EndFunc

Func _ImportUnknownISOsToDB($aUnknownISOs, $iCount, $sDrive)
    If $iCount = 0 Then Return

    Local $iW       = 720
    Local $iRowH    = 74        ; Höhe pro ISO-Zeile
    Local $iMaxRows = 6         ; Maximal sichtbare Zeilen (Fenster-Limit)
    Local $iVisRows = $iCount
    If $iVisRows > $iMaxRows Then $iVisRows = $iMaxRows
    Local $iListY   = 116       ; Y-Start der Liste
    Local $iListH   = $iVisRows * $iRowH
    Local $iFooterY = $iListY + $iListH + 6
    Local $iH       = $iFooterY + 58

    Local $hDlg = GUICreate("📥 Stick-ISOs importieren — " & $APP_TITLE, $iW, $iH, -1, -1, _
        BitOR($WS_CAPTION, $WS_SYSMENU), $WS_EX_DROPSHADOW, $g_hMain)
    GUISetBkColor($C_W)
    GUISetFont(9, 400, 0, "Segoe UI")

    ; ── Header ────────────────────────────────────────────────────────────
    GUICtrlCreateLabel("", 0, 0, $iW, 5)
    GUICtrlSetBkColor(-1, $C_BLUE)
    GUICtrlSetState(-1, $GUI_DISABLE)

    GUICtrlCreateLabel("📥  Unbekannte ISOs importieren  —  " & $iCount & " ISO(s) gefunden", 18, 12, $iW-36, 22)
    GUICtrlSetFont(-1, 12, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlCreateLabel("Diese ISO(s) wurden auf " & $sDrive & " gefunden, sind aber nicht in der Datenbank.", 18, 38, $iW-36, 15)
    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlCreateLabel("Nach dem Import erscheinen sie in der Übersicht und können auf Updates geprüft werden.", 18, 56, $iW-36, 15)
    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlCreateLabel("", 18, 78, $iW-36, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── Spalten-Header ────────────────────────────────────────────────────
    GUICtrlCreateLabel("", 0, 79, $iW, 36)
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUICtrlCreateLabel("✓", 20, 90, 20, 12)
    GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlCreateLabel("Dateiname  /  Anzeigename", 46, 90, 268, 12)
    GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlCreateLabel("Kategorie", 322, 90, 130, 12)
    GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlCreateLabel("Mirror-Status", 460, 90, 244, 12)
    GUICtrlSetFont(-1, 7, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlCreateLabel("", 18, 115, $iW-36, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; ── Pro-ISO-Zeilen ────────────────────────────────────────────────────
    Local $ahChk[$iCount]
    Local $ahCatCombo[$iCount]
    Local $ahStatusLbl[$iCount]
    Local $ahBtnManual[$iCount]   ; "URL manuell eingeben" pro Zeile
    Local $asAutoName[$iCount]
    Local $asAutoCat[$iCount]
    Local $asFoundURLs[$iCount]   ; gefundene URLs, |-getrennt
    Local $sCats = "Gaming|Sicherheit|Einsteiger|Leichtgewicht|Fortgeschrittene|Rettung|Antivirus|WinPE"

    Local $i
    For $i = 0 To $iCount - 1
        $asAutoName[$i]  = _GuessFriendlyName($aUnknownISOs[$i][0])
        $asAutoCat[$i]   = _GuessISOCategory($aUnknownISOs[$i][0])
        $asFoundURLs[$i] = ""
        $ahBtnManual[$i] = 0   ; noch nicht erstellt

        If $i >= $iMaxRows Then ContinueLoop   ; nur sichtbare Zeilen zeichnen

        Local $iY  = $iListY + $i * $iRowH
        Local $iBg = (Mod($i,2) = 0) ? $C_W : $C_CARD

        GUICtrlCreateLabel("", 0, $iY, $iW, $iRowH - 1)
        GUICtrlSetBkColor(-1, $iBg)
        GUICtrlSetState(-1, $GUI_DISABLE)

        $ahChk[$i] = GUICtrlCreateCheckbox("", 20, $iY + 28, 16, 16)
        GUICtrlSetState(-1, $GUI_CHECKED)
        GUICtrlSetBkColor(-1, $iBg)

        ; Dateiname (klein, grau)
        GUICtrlCreateLabel($aUnknownISOs[$i][0] & "   (" & $aUnknownISOs[$i][1] & ")", 46, $iY + 10, 268, 13)
        GUICtrlSetFont(-1, 7, 400, 2, "Consolas")
        GUICtrlSetColor(-1, $C_DIM)
        GUICtrlSetBkColor(-1, $iBg)

        ; Anzeigename (groß, schwarz)
        GUICtrlCreateLabel($asAutoName[$i], 46, $iY + 26, 268, 16)
        GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")
        GUICtrlSetColor(-1, $C_TXT)
        GUICtrlSetBkColor(-1, $iBg)

        ; Kategorie-Combo
        $ahCatCombo[$i] = GUICtrlCreateCombo($asAutoCat[$i], 322, $iY + 24, 130, 22, $CBS_DROPDOWNLIST)
        GUICtrlSetData(-1, $sCats, $asAutoCat[$i])
        GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

        ; Mirror-Status-Label (v14.79: etwas kürzer — Platz für Manual-Button)
        $ahStatusLbl[$i] = GUICtrlCreateLabel("⏳  noch nicht gesucht", 460, $iY + 24, 244, 18)
        GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
        GUICtrlSetColor(-1, $C_DIM)
        GUICtrlSetBkColor(-1, $iBg)

        ; "URL manuell eingeben" — erscheint wenn Suche fehlschlägt
        $ahBtnManual[$i] = GUICtrlCreateButton("✎  URL manuell eingeben", 460, $iY + 46, 244, 22)
        GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
        GUICtrlSetBkColor(-1, $C_LAMB)
        GUICtrlSetColor(-1, $C_AMB)
        GUICtrlSetTip(-1, "Download-URL manuell eingeben (z.B. direkter Link von der Projektseite)")
        GUICtrlSetState(-1, $GUI_HIDE)   ; zunächst versteckt

        ; Trennlinie
        GUICtrlCreateLabel("", 18, $iY + $iRowH - 1, $iW-36, 1)
        GUICtrlSetBkColor(-1, $C_BRD)
        GUICtrlSetState(-1, $GUI_DISABLE)
    Next

    ; ── Footer ────────────────────────────────────────────────────────────
    GUICtrlCreateLabel("", 0, $iFooterY, $iW, $iH - $iFooterY)
    GUICtrlSetBkColor(-1, $C_CARD)
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUICtrlCreateLabel("", 18, $iFooterY, $iW-36, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    Local $hBtnSearch = GUICtrlCreateButton("🔍  Mirrors suchen", 18, $iFooterY + 10, 180, 32)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI Semibold")
    GUICtrlSetBkColor(-1, $C_LBLU)
    GUICtrlSetColor(-1, $C_BLUE)
    GUICtrlSetTip(-1, "Testet bekannte Mirror-Server für alle markierten ISOs — wählt den schnellsten")

    Local $hBtnImport = GUICtrlCreateButton("✅  Importieren", 206, $iFooterY + 10, 148, 32)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI Semibold")
    GUICtrlSetBkColor(-1, $C_LGRN)
    GUICtrlSetColor(-1, $C_GRN)
    GUICtrlSetTip(-1, "Ausgewählte ISOs zur Datenbank hinzufügen — erscheinen danach in der Übersicht")

    Local $hBtnSkip = GUICtrlCreateButton("Überspringen", $iW - 126, $iFooterY + 10, 108, 32)
    GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_LRED)
    GUICtrlSetColor(-1, $C_RED)

    If $iCount > $iMaxRows Then
        GUICtrlCreateLabel("ℹ  " & ($iCount - $iMaxRows) & " weitere ISO(s) können nach dem Import im nächsten Scan aufgenommen werden.", _
            18, $iFooterY + 46, $iW-36, 13)
        GUICtrlSetFont(-1, 7, 400, 2, "Segoe UI")
        GUICtrlSetColor(-1, $C_AMB)
        GUICtrlSetBkColor(-1, $C_CARD)
    EndIf

    GUISetState(@SW_SHOW, $hDlg)

    ; ── Event-Loop ────────────────────────────────────────────────────────
    Local $bDone = False, $bImport = False
    Local $iMaxVis = $iCount
    If $iMaxVis > $iMaxRows Then $iMaxVis = $iMaxRows

    While Not $bDone
        Local $ev = GUIGetMsg()
        Select
            Case $ev = $GUI_EVENT_CLOSE Or $ev = $hBtnSkip
                $bDone = True

            Case $ev = $hBtnSearch
                ; ── Mirror-Suche für alle markierten ISOs ─────────────────
                GUICtrlSetData($hBtnSearch, "🔍  Suche läuft ...")
                GUICtrlSetState($hBtnSearch, $GUI_DISABLE)

                For $i = 0 To $iMaxVis - 1
                    If GUICtrlRead($ahChk[$i]) <> $GUI_CHECKED Then ContinueLoop

                    GUICtrlSetData($ahStatusLbl[$i], "🔍  Konstruiere Kandidaten ...")
                    GUICtrlSetColor($ahStatusLbl[$i], $C_AMB)

                    Local $aCands = _GuessISOCandidateURLs($aUnknownISOs[$i][0])
                    If UBound($aCands) = 0 Then
                        GUICtrlSetData($ahStatusLbl[$i], "🔍  Web-Suche (DistroWatch) ...")
                        Local $sWVer, $sWURL, $sWFile
                        If _WebSearchLatestISO($asAutoName[$i], $aUnknownISOs[$i][0], $sCurl, $sWVer, $sWURL, $sWFile) Then
                            _ArrayAdd($aCands, $sWURL)
                            _Log("    [Import] Web-Suche erfolgreich für: " & $asAutoName[$i] & " -> " & $sWURL)
                        EndIf
                    EndIf
                    
                    If UBound($aCands) = 0 Then
                        GUICtrlSetData($ahStatusLbl[$i], "✗  Keine Mirrors gefunden")
                        GUICtrlSetColor($ahStatusLbl[$i], $C_RED)
                        $asFoundURLs[$i] = ""
                        ; Manual-Button einblenden
                        If $ahBtnManual[$i] > 0 Then GUICtrlSetState($ahBtnManual[$i], $GUI_SHOW)
                        ContinueLoop
                    EndIf

                    ; HEAD-Check: nur URLs die tatsächlich existieren
                    Local $aValid[0]
                    Local $iCandCount = UBound($aCands)
                    For $u = 0 To $iCandCount - 1
                        GUICtrlSetData($ahStatusLbl[$i], "🔍  Prüfe " & ($u+1) & "/" & $iCandCount & " ...")
                        Local $iSzChk = _RemoteSize($aCands[$u])
                        If $iSzChk > 104857600 Then   ; >100 MB → echte ISO
                            _ArrayAdd($aValid, $aCands[$u])
                        EndIf
                    Next

                    If UBound($aValid) = 0 Then
                        GUICtrlSetData($ahStatusLbl[$i], "✗  Kein Mirror erreichbar")
                        GUICtrlSetColor($ahStatusLbl[$i], $C_RED)
                        $asFoundURLs[$i] = ""
                        ; Manual-Button einblenden
                        If $ahBtnManual[$i] > 0 Then GUICtrlSetState($ahBtnManual[$i], $GUI_SHOW)
                    Else
                        ; Speedtest: schnellsten Mirror zuerst sortieren
                        If UBound($aValid) > 1 Then
                            _SortURLsBySpeed($aValid, 0, UBound($aValid) - 1)
                        EndIf
                        Local $sJoined = ""
                        Local $iVC = UBound($aValid)
                        For $u = 0 To $iVC - 1
                            If $sJoined <> "" Then $sJoined &= "|"
                            $sJoined &= $aValid[$u]
                        Next
                        $asFoundURLs[$i] = $sJoined

                        ; Kategorie per URL-Hostname online verifizieren
                        Local $sCatVerified = _CatFromURL($aValid[0])
                        Local $sStatusSuffix = ""
                        If $sCatVerified <> "" And $sCatVerified <> $asAutoCat[$i] Then
                            $asAutoCat[$i] = $sCatVerified
                            If $i < $iMaxRows Then
                                GUICtrlSetData($ahCatCombo[$i], $sCats, $sCatVerified)
                            EndIf
                            $sStatusSuffix = "  [Kat. ✓ korr.]"
                        EndIf
                        GUICtrlSetData($ahStatusLbl[$i], _
                            "✓  " & $iVC & " Mirror  |  " & _URLHostname($aValid[0]) & $sStatusSuffix)
                        GUICtrlSetColor($ahStatusLbl[$i], $C_GRN)
                    EndIf
                Next

                GUICtrlSetData($hBtnSearch, "🔍  Mirrors suchen")
                GUICtrlSetState($hBtnSearch, $GUI_ENABLE)

            Case $ev = $hBtnImport
                $bDone  = True
                $bImport = True

            Case Else
                ; Manual-URL-Buttons prüfen (pro Zeile ein Button)
                Local $__jMan
                For $__jMan = 0 To $iMaxVis - 1
                    If $ahBtnManual[$__jMan] > 0 And $ev = $ahBtnManual[$__jMan] Then
                        Local $sManURL = InputBox( _
                            "🔗  Download-URL manuell eingeben", _
                            "ISO:  " & $aUnknownISOs[$__jMan][0] & @CRLF & @CRLF & _
                            "Bitte vollständige Download-URL einfügen" & @CRLF & _
                            "(z.B. https://example.org/linux.iso)", _
                            "", "", 560, 150, -1, -1)
                        If Not @error And StringLen($sManURL) > 10 Then
                            GUICtrlSetData($ahStatusLbl[$__jMan], "🔍  Prüfe URL ...")
                            GUICtrlSetColor($ahStatusLbl[$__jMan], $C_AMB)
                            GUICtrlSetState($ahBtnManual[$__jMan], $GUI_DISABLE)
                            Local $iSzMan = _RemoteSize($sManURL)
                            If $iSzMan > 104857600 Then   ; >100 MB → echte ISO
                                $asFoundURLs[$__jMan] = $sManURL
                                GUICtrlSetData($ahStatusLbl[$__jMan], _
                                    "✓  Manuell  |  " & _URLHostname($sManURL))
                                GUICtrlSetColor($ahStatusLbl[$__jMan], $C_GRN)
                                GUICtrlSetState($ahBtnManual[$__jMan], $GUI_HIDE)
                            Else
                                GUICtrlSetData($ahStatusLbl[$__jMan], _
                                    "✗  URL ungültig / ISO < 100 MB")
                                GUICtrlSetColor($ahStatusLbl[$__jMan], $C_RED)
                                GUICtrlSetState($ahBtnManual[$__jMan], $GUI_ENABLE)
                            EndIf
                        EndIf
                        ExitLoop
                    EndIf
                Next
        EndSelect
    WEnd

    ; Werte vor GUIDelete sichern
    Local $abChkOK[$iMaxVis]
    Local $asCatVal[$iMaxVis]
    For $i = 0 To $iMaxVis - 1
        $abChkOK[$i] = (GUICtrlRead($ahChk[$i]) = $GUI_CHECKED)
        $asCatVal[$i] = GUICtrlRead($ahCatCombo[$i])
    Next
    GUIDelete($hDlg)

    If Not $bImport Then Return

    ; ── Ausgewählte ISOs in Datenbank importieren ─────────────────────────
    Local $iImported = 0
    For $i = 0 To $iMaxVis - 1
        If Not $abChkOK[$i] Then ContinueLoop
        If $ISO_COUNT >= $ISO_MAX Then
            _Log("ISO-Import: Maximum (" & $ISO_MAX & ") erreicht — Abbruch.")
            ExitLoop
        EndIf

        Local $iIdx = $ISO_COUNT
        $ISO_COUNT += 1
        $g_abImportedFromStick[$iIdx] = True   ; v2.23: als Stick-Import markieren → Teal-Farbe

        Local $sCatFinal = $asCatVal[$i]
        If $sCatFinal = "" Then $sCatFinal = $asAutoCat[$i]

        $g_aISOs[$iIdx][0] = $asAutoName[$i]
        $g_aISOs[$iIdx][1] = $sCatFinal
        $g_aISOs[$iIdx][3] = $aUnknownISOs[$i][0]   ; Dateiname

        ; URLs aus Suchergebnis verteilen
        If $asFoundURLs[$i] <> "" Then
            Local $aURLArr = StringSplit($asFoundURLs[$i], "|", 2)
            $g_aISOs[$iIdx][2] = (UBound($aURLArr) > 0) ? $aURLArr[0] : ""
            $g_aISOs[$iIdx][4] = (UBound($aURLArr) > 1) ? $aURLArr[1] : ""
            $g_aISOs[$iIdx][5] = (UBound($aURLArr) > 2) ? $aURLArr[2] : ""
            $g_aISOs[$iIdx][8] = (UBound($aURLArr) > 3) ? $aURLArr[3] : ""
        Else
            $g_aISOs[$iIdx][2] = ""
            $g_aISOs[$iIdx][4] = ""
            $g_aISOs[$iIdx][5] = ""
            $g_aISOs[$iIdx][8] = ""
        EndIf
        $g_aISOs[$iIdx][6] = ""   ; kein GitHub-Repo
        $g_aISOs[$iIdx][7] = ""   ; kein GitHub-Asset-Pattern
        $g_aISOs[$iIdx][9] = "📀 " & $asAutoName[$i] & @LF & _
            "• Vom Stick importiert  (" & $aUnknownISOs[$i][1] & ")" & @LF & _
            "• Kategorie: " & $sCatFinal & @LF & _
            "• Importiert: " & @YEAR & "-" & @MON & "-" & @MDAY

        ; USB-Status sofort auf "vorhanden + aktuell" setzen
        $g_aiUSBStatus[$iIdx] = 1
        $g_asUSBSize[$iIdx]   = $aUnknownISOs[$i][1]

        $iImported += 1
        _Log("ISO importiert [" & $iIdx & "]: " & $asAutoName[$i] & " | " & $sCatFinal & " | " & $aUnknownISOs[$i][0])
    Next

    If $iImported > 0 Then
        _SaveIsoDB()
        _FillTree()
        _Status($iImported & " ISO(s) importiert — in Übersicht sichtbar, '↺ Updates prüfen' empfohlen.")
        _Log("=== " & $iImported & " ISO(s) aus Stick in Datenbank importiert ===")
        MsgBox(64, "✓ Import abgeschlossen", _
            $iImported & " ISO(s) erfolgreich importiert!" & @CRLF & @CRLF & _
            "Sie erscheinen nun in der Übersicht und können:" & @CRLF & _
            "  • mit '↺ Updates prüfen' auf dem Stick erkannt werden" & @CRLF & _
            "  • mit '⬇ Herunterladen' neu geladen werden (falls URL gefunden)" & @CRLF & _
            "  • mit '✎ Datenbank' manuell bearbeitet werden" & @CRLF & @CRLF & _
            "Tipp: Ohne gefundenen Mirror die URL im Datenbank-Editor ergänzen.")
    EndIf
EndFunc

Func _MarkOutdatedISOs(ByRef $abNeedsUpdate)
    Local $hTV = GUICtrlGetHandle($g_hTreeView)
    Local $iMarked = 0

    For $i = 0 To $ISO_COUNT - 1
        If $abNeedsUpdate[$i] And $g_ahNodes[$i] <> 0 Then
            _GUICtrlTreeView_SetChecked($hTV, $g_ahNodes[$i], True)
            $g_abNodeLast[$i] = True
            $iMarked += 1
            _Log("  [✔ markiert]  " & $g_aISOs[$i][0] & " — zum Download vorgemerkt")
        EndIf
    Next

    ; Kategorie-Checkboxen synchronisieren (falls alle Kinder einer Kategorie markiert)
    _SyncCategoryCheckboxes()

    _Log("Auto-Markierung: " & $iMarked & " ISO(s) zum Download markiert.")
    _Status("⚠ " & $iMarked & " veraltete ISO(s) markiert — einfach 'Herunterladen' klicken!")
EndFunc

Func _ISOBaseName($sFilename)
    $sFilename = StringLower($sFilename)
    ; Bekannte Prefixe — längste zuerst um Fehlmatch zu vermeiden
    ; HBCD, AntivirusLiveCD, krd als bekannte Prefixe — längste zuerst
    Local $aPrefixes[32] = [ _
        "kali-linux", _
        "parrot-security", _
        "tails-amd64", _
        "debian-live", _
        "almalinux", _
        "endeavouros", _
        "cachyos-desktop", _
        "cachyos", _
        "fedora-workstation", _
        "fedora-kde", _
        "manjaro-kde", _
        "garuda-dr460nized", _
        "ubuntu-mate", _
        "ubuntu-budgie", _
        "ubuntu-studio", _
        "zorin-os", _
        "lubuntu", _
        "pop-os", _
        "gdata-bootmedium", _
        "eset_sysrescue", _
        "nobara", _
        "chimeraos", _
        "antiviruslivecd", _
        "hbcd_pe", _
        "hbcd-pe", _
        "hbcd", _
        "archlinux", _
        "arch", _
        "mx-", _
        "tails", _
        "krd", _
        "drweb-livedisk"]
    For $k = 0 To 31
        If StringLeft($sFilename, StringLen($aPrefixes[$k])) = $aPrefixes[$k] Then
            Return $aPrefixes[$k]
        EndIf
    Next
    Return ""
EndFunc

Func _SwapISOs($iA, $iB)
    Local $iCols = UBound($g_aISOs, 2)
    Local $c
    ; ISO-Stammdaten tauschen
    Local $aTmp[$iCols]
    For $c = 0 To $iCols - 1
        $aTmp[$c] = $g_aISOs[$iA][$c]
    Next
    For $c = 0 To $iCols - 1
        $g_aISOs[$iA][$c] = $g_aISOs[$iB][$c]
    Next
    For $c = 0 To $iCols - 1
        $g_aISOs[$iB][$c] = $aTmp[$c]
    Next
    ; USB-Status-Arrays synchronisieren
    Local $iTmpStat = $g_aiUSBStatus[$iA]
    $g_aiUSBStatus[$iA] = $g_aiUSBStatus[$iB]
    $g_aiUSBStatus[$iB] = $iTmpStat
    Local $sTmpSz = $g_asUSBSize[$iA]
    $g_asUSBSize[$iA] = $g_asUSBSize[$iB]
    $g_asUSBSize[$iB] = $sTmpSz
    Local $bTmpURLOK = $g_abURLOK[$iA]
    $g_abURLOK[$iA] = $g_abURLOK[$iB]
    $g_abURLOK[$iB] = $bTmpURLOK
    Local $bTmpURLChk = $g_abURLChecked[$iA]
    $g_abURLChecked[$iA] = $g_abURLChecked[$iB]
    $g_abURLChecked[$iB] = $bTmpURLChk
    Local $sTmpUpdVer = $g_asUpdateVer[$iA]
    $g_asUpdateVer[$iA] = $g_asUpdateVer[$iB]
    $g_asUpdateVer[$iB] = $sTmpUpdVer
    Local $sTmpUpdURL = $g_asUpdateURL[$iA]
    $g_asUpdateURL[$iA] = $g_asUpdateURL[$iB]
    $g_asUpdateURL[$iB] = $sTmpUpdURL
    Local $sTmpUpdFile = $g_asUpdateFile[$iA]
    $g_asUpdateFile[$iA] = $g_asUpdateFile[$iB]
    $g_asUpdateFile[$iB] = $sTmpUpdFile
    ; Datenbank speichern + TreeView neu aufbauen
    _SaveIsoDB()
    _FillTree()
    _Status("Reihenfolge geändert: '" & $g_aISOs[$iA][0] & "' ↔ '" & $g_aISOs[$iB][0] & "'")
    _Log("Drag-Drop: Slot " & $iA & " ↔ " & $iB & " getauscht und gespeichert.")
EndFunc

Func _MoveISOToCategory($iISO, $sNewCat)
    Local $sOldCat = $g_aISOs[$iISO][1]
    $g_aISOs[$iISO][1] = $sNewCat

    ; Tooltip-Zeile "Kategorie: ..." aktualisieren falls vorhanden
    Local $sTip = $g_aISOs[$iISO][9]
    If StringInStr($sTip, "Kategorie: " & $sOldCat) Then
        $g_aISOs[$iISO][9] = StringReplace($sTip, _
            "Kategorie: " & $sOldCat, "Kategorie: " & $sNewCat)
    EndIf

    _SaveIsoDB()
    _FillTree()
    _Status("'" & $g_aISOs[$iISO][0] & "' → Kategorie geändert: " & $sOldCat & " → " & $sNewCat)
    _Log("Drag-Drop Kategorie: '" & $g_aISOs[$iISO][0] & "' von '" & $sOldCat & "' nach '" & $sNewCat & "'")
EndFunc

Func _GitHubLatestISO($sRepo, $sCurl, ByRef $sVerOut, ByRef $sURLOut, ByRef $sFileOut)
    $sVerOut  = ""
    $sURLOut  = ""
    $sFileOut = ""
    If $sRepo = "" Or $sCurl = "" Then Return False
    Local $sAPIUrl = "https://api.github.com/repos/" & $sRepo & "/releases/latest"
    Local $sArgs = '-s -L --max-time 20 --ssl-no-revoke ' & _
                   '-H "Accept: application/vnd.github+json" ' & _
                   '-H "X-GitHub-Api-Version: 2022-11-28" ' & _
                   '-A "UniversalISOManager/14.37" "' & $sAPIUrl & '"'
    Local $iPID = Run('"' & $sCurl & '" ' & $sArgs, "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
    Local $sJSON = ""
    If $iPID <> 0 Then
        While ProcessExists($iPID)
            $sJSON &= StdoutRead($iPID)
            Sleep(100)
        WEnd
        $sJSON &= StdoutRead($iPID)
    EndIf
    If StringLen($sJSON) < 50 Then Return False
    Local $aTag = StringRegExp($sJSON, '"tag_name"\s*:\s*"v?([\d\.]+)"', 1)
    If Not @error Then $sVerOut = $aTag[0]
    Local $aISO = StringRegExp($sJSON, '"browser_download_url"\s*:\s*"([^"]+\.iso)"', 3)
    If Not @error And UBound($aISO) > 0 Then
        $sURLOut = $aISO[0]
        Local $aFN = StringRegExp($sURLOut, ".*/([^/]+\.iso)", 1)
        If Not @error Then $sFileOut = $aFN[0]
    EndIf
    Return ($sURLOut <> "")
EndFunc

Func _SourceForgeLatestISO($sProject, $sCurl, ByRef $sVerOut, ByRef $sURLOut, ByRef $sFileOut)
    $sVerOut  = ""
    $sURLOut  = ""
    $sFileOut = ""
    If $sProject = "" Or $sCurl = "" Then Return False
    Local $sAPIUrl = "https://sourceforge.net/projects/" & $sProject & "/best_release.json"
    Local $sArgs = '-s -L --max-time 15 --ssl-no-revoke ' & _
                   '-A "UniversalISOManager/14.38" "' & $sAPIUrl & '"'
    Local $iPID = Run('"' & $sCurl & '" ' & $sArgs, "", @SW_HIDE, $STDOUT_CHILD)
    Local $sJSON = ""
    If $iPID <> 0 Then
        While ProcessExists($iPID)
            $sJSON &= StdoutRead($iPID)
            Sleep(100)
        WEnd
        $sJSON &= StdoutRead($iPID)
    EndIf
    If StringLen($sJSON) < 50 Then Return False
    ; JSON-Parsing (simpel via Regex für Performance/kein JSON-UDF nötig)
    Local $aISO = StringRegExp($sJSON, '"url"\s*:\s*"([^"]+\.iso[^"]*)"', 1)
    If @error Then Return False
    $sURLOut = $aISO[0]
    If Not StringInStr($sURLOut, "?viasf=1") Then $sURLOut &= "?viasf=1"
    Local $aFile = StringRegExp($sJSON, '"filename"\s*:\s*"([^"]+\.iso)"', 1)
    If Not @error Then $sFileOut = $aFile[0]
    Local $aVer = StringRegExp($sJSON, '"version"\s*:\s*"([^"]+)"', 1)
    If Not @error Then
        $sVerOut = $aVer[0]
    Else
        Local $aVFN = StringRegExp($sFileOut, "(\d+\.\d+(?:\.\d+)*)", 1)
        If Not @error Then $sVerOut = $aVFN[0]
    EndIf
    Return ($sURLOut <> "")
EndFunc

Func _WebSearchLatestISO($sName, $sFilename, $sCurl, ByRef $sVerOut, ByRef $sURLOut, ByRef $sFileOut)
    $sVerOut  = ""
    $sURLOut  = ""
    $sFileOut = ""
    If $sName = "" Or $sCurl = "" Then Return False

    _Log("    [WebSearch] Starte Online-Suche für: " & $sName)

    ; ── Suchbegriff aufbereiten ───────────────────────────────────────────────
    ; Versionsnummer aus dem Anzeigenamen entfernen → reiner Distro-Name
    Local $sBase = StringRegExpReplace($sName, "\s+[\d\.]+[\w\s\(\)_-]*$", "")
    $sBase = StringStripWS($sBase, 3)
    If StringLen($sBase) < 3 Then
        $sBase = StringRegExpReplace($sFilename, "[-_][\d].*", "")
        $sBase = StringRegExpReplace($sBase, "[-_](linux|os|live|amd64|x86_64).*", "")
        $sBase = StringStripWS($sBase, 3)
    EndIf
    ; Kleinbuchstaben-Version für URL-Matching
    Local $sBaseLow = StringLower($sBase)
    _Log("    [WebSearch] Suchbegriff: '" & $sBase & "'")

    ; ── STRATEGIE 1: DistroWatch HTML-Suche ──────────────────────────────────
    Local $sDWQuery = StringReplace(StringLower($sBase), " ", "")
    Local $sDWUrl   = "https://distrowatch.com/table.php?distribution=" & $sDWQuery
    Local $sDWTmp   = @TempDir & "\vlm_dw.html"
    FileDelete($sDWTmp)

    Local $sDWArgs = '-s -L --max-time 10 --connect-timeout 7 --ssl-no-revoke ' & _
                     '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                     '-o "' & $sDWTmp & '" "' & $sDWUrl & '"'
    Local $iDWPID = Run('"' & $sCurl & '" ' & $sDWArgs, "", @SW_HIDE)
    If $iDWPID <> 0 Then
        Local $tDW = TimerInit()
        While ProcessExists($iDWPID) And TimerDiff($tDW) < 11000
            Local $evDW = GUIGetMsg()
            If $evDW = $GUI_EVENT_CLOSE Then
                ProcessClose($iDWPID)
                _Quit()
            EndIf
            If $evDW = $g_hBtnCancel Or ($g_hPopCancel <> 0 And $evDW = $g_hPopCancel) Then
                $g_bCancel = True
            EndIf
            If $g_bCancel Then ProcessClose($iDWPID)
            Sleep(50)
        WEnd
        If ProcessExists($iDWPID) Then ProcessClose($iDWPID)
    EndIf

    If FileExists($sDWTmp) And Not $g_bCancel Then
        Local $hDW = FileOpen($sDWTmp, 0)
        If $hDW <> -1 Then
            Local $sHTMLDW = FileRead($hDW)
            FileClose($hDW)
            FileDelete($sDWTmp)

            ; Letztes Release aus DistroWatch-Tabelle extrahieren
            ; Format: <td class="TablesTitle">Letzte Version: </td><td>...</td>
            Local $aRelDW = StringRegExp($sHTMLDW, 'Latest(?:\s+(?:stable|release|version))?.*?</td>\s*<td[^>]*>([\d][^<]{1,30})</td>', 1)
            If Not @error Then
                Local $sRelVer = StringStripWS($aRelDW[0], 3)
                Local $aRelVerNum = StringRegExp($sRelVer, "([\d]+\.[\d]+(?:\.[\d]+)*)", 1)
                If Not @error Then
                    _Log("    [WebSearch] DistroWatch → Version: " & $aRelVerNum[0])
                    $sVerOut = $aRelVerNum[0]
                EndIf
            EndIf

            ; Offizielle Homepage aus DistroWatch extrahieren
            ; Format: href="https://... " title="Home Page"
            Local $aHPDW = StringRegExp($sHTMLDW, 'href="(https?://[^"]+)"[^>]*title="Home\s*Page"', 1)
            If Not @error And StringLen($aHPDW[0]) > 10 Then
                _Log("    [WebSearch] DistroWatch → Homepage: " & $aHPDW[0])
                ; Homepage holen und nach ISO-Links suchen
                Local $sHPTmp   = @TempDir & "\vlm_hp.html"
                Local $sHPArgs  = '-s -L --max-time 10 --connect-timeout 7 --ssl-no-revoke ' & _
                                  '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                                  '-o "' & $sHPTmp & '" "' & $aHPDW[0] & '"'
                FileDelete($sHPTmp)
                Local $iHPPID = Run('"' & $sCurl & '" ' & $sHPArgs, "", @SW_HIDE)
                If $iHPPID <> 0 Then
                    Local $tHP = TimerInit()
                    While ProcessExists($iHPPID) And TimerDiff($tHP) < 11000
                        Local $evHP = GUIGetMsg()
                        If $evHP = $GUI_EVENT_CLOSE Then
                            ProcessClose($iHPPID)
                            _Quit()
                        EndIf
                        If $g_bCancel Then ProcessClose($iHPPID)
                        Sleep(50)
                    WEnd
                    If ProcessExists($iHPPID) Then ProcessClose($iHPPID)
                EndIf
                If FileExists($sHPTmp) And Not $g_bCancel Then
                    Local $hHP = FileOpen($sHPTmp, 0)
                    If $hHP <> -1 Then
                        Local $sHTMLHP = FileRead($hHP)
                        FileClose($hHP)
                        FileDelete($sHPTmp)
                        ; Direkte .iso-Links auf der Homepage suchen
                        Local $aISOLinks = StringRegExp($sHTMLHP, 'href="(https?://[^"]+\.iso)"', 3)
                        If Not @error Then
                            For $u = 0 To UBound($aISOLinks) - 1
                                Local $sL = $aISOLinks[$u]
                                If StringInStr($sL, "torrent") Then ContinueLoop
                                If StringInStr($sL, ".sha")    Then ContinueLoop
                                If StringInStr($sL, ".sig")    Then ContinueLoop
                                Local $aFHP = StringRegExp($sL, "/([^/?#]+\.iso)", 1)
                                If @error Then ContinueLoop
                                $sFileOut = $aFHP[0]
                                If $sVerOut = "" Then
                                    Local $aVHP = StringRegExp($sL, "([\d]+\.[\d]+(?:\.[\d]+)*)", 1)
                                    If Not @error Then $sVerOut = $aVHP[0]
                                EndIf
                                $sURLOut = $sL
                                _Log("    [WebSearch] Homepage ISO-Link: " & $sURLOut)
                                ExitLoop 2
                            Next
                        EndIf
                    Else
                        FileDelete($sHPTmp)
                    EndIf
                EndIf
            EndIf
        Else
            FileDelete($sDWTmp)
        EndIf
    Else
        FileDelete($sDWTmp)
    EndIf
    If $g_bCancel Then Return False

    ; ── STRATEGIE 2: GitHub API-Suche ────────────────────────────────────────
    If $sURLOut = "" Then
        Local $sGHQuery  = StringReplace(StringLower($sBase), " ", "+") & "+linux+iso"
        Local $sGHAPIUrl = "https://api.github.com/search/repositories?q=" & $sGHQuery & _
                           "&sort=stars&order=desc&per_page=3"
        Local $sGHArgs   = '-s -L --max-time 10 --connect-timeout 7 --ssl-no-revoke ' & _
                           '-H "Accept: application/vnd.github+json" ' & _
                           '-H "X-GitHub-Api-Version: 2022-11-28" ' & _
                           '-A "UniversalISOManager/14.38" ' & _
                           '-o "' & @TempDir & '\vlm_ghsearch.json" "' & $sGHAPIUrl & '"'
        Local $sGHTmp = @TempDir & "\vlm_ghsearch.json"
        FileDelete($sGHTmp)
        Local $iGHPID = Run('"' & $sCurl & '" ' & $sGHArgs, "", @SW_HIDE)
        If $iGHPID <> 0 Then
            Local $tGH = TimerInit()
            While ProcessExists($iGHPID) And TimerDiff($tGH) < 11000
                Local $evGH = GUIGetMsg()
                If $evGH = $GUI_EVENT_CLOSE Then
                    ProcessClose($iGHPID)
                    _Quit()
                EndIf
                If $g_bCancel Then ProcessClose($iGHPID)
                Sleep(50)
            WEnd
            If ProcessExists($iGHPID) Then ProcessClose($iGHPID)
        EndIf
        If FileExists($sGHTmp) And Not $g_bCancel Then
            Local $hGH = FileOpen($sGHTmp, 0)
            If $hGH <> -1 Then
                Local $sJSON = FileRead($hGH)
                FileClose($hGH)
                FileDelete($sGHTmp)
                ; Repos extrahieren und Releases prüfen
                Local $aRepos = StringRegExp($sJSON, '"full_name"\s*:\s*"([^"]+)"', 3)
                If Not @error Then
                    Local $iMaxRepo = UBound($aRepos) - 1
                    If $iMaxRepo > 2 Then $iMaxRepo = 2
                    For $r = 0 To $iMaxRepo
                        If $g_bCancel Then ExitLoop
                        Local $sRepo = $aRepos[$r]
                        ; Nur wenn Distro-Name im Repo-Name vorkommt
                        If Not StringInStr(StringLower($sRepo), StringLower(StringLeft($sBaseLow, 6))) Then ContinueLoop
                        Local $sGHVer = "", $sGHURL = "", $sGHFile = ""
                        If _GitHubLatestISO($sRepo, $sCurl, $sGHVer, $sGHURL, $sGHFile) Then
                            $sVerOut  = $sGHVer
                            $sURLOut  = $sGHURL
                            $sFileOut = $sGHFile
                            _Log("    [WebSearch] GitHub Release: " & $sURLOut)
                            ExitLoop
                        EndIf
                    Next
                EndIf
            Else
                FileDelete($sGHTmp)
            EndIf
        EndIf
    EndIf
    If $g_bCancel Then Return False

    ; ── STRATEGIE 3: FTP-Heuristik über bekannte Mirror-Aggregatoren ─────────
    ; Läuft jetzt auch wenn $sFilename leer ist (nutzt $sBaseLow als Fallback-Dateiname)
    If $sURLOut = "" Then
        Local $sRWTH = "https://ftp.halifax.rwth-aachen.de"
        Local $sFAU  = "https://ftp.fau.de"
        Local $sDots = "https://mirrors.dotsrc.org"
        ; Dateiname: entweder gespeicherter oder Distro-Name als Platzhalter
        Local $sFNFTP = $sFilename
        If $sFNFTP = "" Then $sFNFTP = $sBaseLow & "-latest-x86_64.iso"
        Local $aCandidates[6]
        $aCandidates[0] = $sRWTH & "/" & $sBaseLow & "/iso/" & $sFNFTP
        $aCandidates[1] = $sFAU  & "/" & $sBaseLow & "/iso/" & $sFNFTP
        $aCandidates[2] = $sDots & "/" & $sBaseLow & "/" & $sFNFTP
        $aCandidates[3] = "https://cdimage.ubuntu.com/" & $sBaseLow & "/releases/" & $sFNFTP
        $aCandidates[4] = "https://sourceforge.net/projects/" & $sBaseLow & "/files/latest/download"
        $aCandidates[5] = "https://github.com/" & $sBaseLow & "/" & $sBaseLow & "/releases/latest/download/" & $sFNFTP
        For $c = 0 To UBound($aCandidates) - 1
            If $g_bCancel Then ExitLoop
            Local $iChkSz = _RemoteSize($aCandidates[$c])
            If $iChkSz > 104857600 Then  ; >100 MB → echte ISO
                $sURLOut  = $aCandidates[$c]
                $sFileOut = $sFNFTP
                Local $aVC = StringRegExp($sURLOut, "([\d]+\.[\d]+(?:\.[\d]+)*)", 1)
                If Not @error Then $sVerOut = $aVC[0]
                _Log("    [WebSearch] FTP-Heuristik: " & $sURLOut)
                ExitLoop
            EndIf
        Next
    EndIf
    If $g_bCancel Then Return False

    ; ── STRATEGIE 4: SourceForge Releases-RSS (v14.39 — niche distros ohne Mirror) ──
    ; Viele niche-Distros (winux, tinycore, etc.) hosten exklusiv auf SourceForge.
    If $sURLOut = "" Then
        Local $sSFRSS  = "https://sourceforge.net/projects/" & $sBaseLow & "/rss"
        Local $sSFTmp  = @TempDir & "\vlm_sf.xml"
        FileDelete($sSFTmp)
        Local $sSFArgs = '-s -L --max-time 10 --connect-timeout 7 --ssl-no-revoke ' & _
                         '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                         '-o "' & $sSFTmp & '" "' & $sSFRSS & '"'
        Local $iSFPID = Run('"' & $sCurl & '" ' & $sSFArgs, "", @SW_HIDE)
        If $iSFPID <> 0 Then
            Local $tSF = TimerInit()
            While ProcessExists($iSFPID) And TimerDiff($tSF) < 11000
                Local $evSF = GUIGetMsg()
                If $evSF = $GUI_EVENT_CLOSE Then
                    ProcessClose($iSFPID)
                    _Quit()
                EndIf
                If $evSF = $g_hBtnCancel Or ($g_hPopCancel <> 0 And $evSF = $g_hPopCancel) Then $g_bCancel = True
                If $g_bCancel Then ProcessClose($iSFPID)
                Sleep(50)
            WEnd
            If ProcessExists($iSFPID) Then ProcessClose($iSFPID)
        EndIf
        If FileExists($sSFTmp) And Not $g_bCancel Then
            Local $hSF = FileOpen($sSFTmp, 0)
            If $hSF <> -1 Then
                Local $sRSS = FileRead($hSF)
                FileClose($hSF)
                FileDelete($sSFTmp)
                ; ISO-Links im RSS-Feed suchen (SourceForge liefert Releases als Items)
                Local $aRSSLinks = StringRegExp($sRSS, '<link>(https?://[^<]+\.iso(?:/download)?)</link>', 3)
                If Not @error Then
                    For $sf = 0 To UBound($aRSSLinks) - 1
                        Local $sSFL = $aRSSLinks[$sf]
                        If StringInStr($sSFL, "torrent") Or StringInStr($sSFL, ".sig") Then ContinueLoop
                        ; amd64/x86_64 bevorzugen, sonst erstbeste akzeptieren
                        Local $bArch = StringInStr(StringLower($sSFL), "amd64") Or StringInStr(StringLower($sSFL), "x86_64")
                        If $bArch Or $sf = 0 Then
                            Local $aFSF = StringRegExp($sSFL, "/([^/?#]+\.iso)", 1)
                            If Not @error Then $sFileOut = $aFSF[0]
                            Local $aVSF = StringRegExp($sSFL, "([\d]+\.[\d]+(?:\.[\d]+)*)", 1)
                            If Not @error Then $sVerOut = $aVSF[0]
                            $sURLOut = $sSFL
                            _Log("    [WebSearch] SourceForge RSS: " & $sURLOut)
                            If $bArch Then ExitLoop
                        EndIf
                    Next
                EndIf
                ; Fallback: /files/latest/download direkt prüfen (ohne RSS-Feed)
                If $sURLOut = "" Then
                    Local $sSFDirect = "https://sourceforge.net/projects/" & $sBaseLow & "/files/latest/download"
                    Local $iSFSz = _RemoteSize($sSFDirect)
                    If $iSFSz > 104857600 Then
                        $sURLOut  = $sSFDirect
                        $sFileOut = $sBaseLow & ".iso"
                        _Log("    [WebSearch] SourceForge Direktlink: " & $sURLOut)
                    EndIf
                EndIf
            Else
                FileDelete($sSFTmp)
            EndIf
        EndIf
    EndIf
    If $g_bCancel Then Return False

    ; ── STRATEGIE 5: DistroWatch Download-Mirror-Seite (v14.39) ──────────────
    ; Für Distros, die auf DistroWatch sind aber kein direktes ISO auf der Homepage zeigen.
    If $sURLOut = "" Then
        Local $sDWMirrorUrl = "https://distrowatch.com/dwres.php?resource=links&distribution=" & StringReplace(StringLower($sBase), " ", "")
        Local $sDWMTmp = @TempDir & "\vlm_dwm.html"
        FileDelete($sDWMTmp)
        Local $sDWMArgs = '-s -L --max-time 10 --connect-timeout 7 --ssl-no-revoke ' & _
                          '-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ' & _
                          '-o "' & $sDWMTmp & '" "' & $sDWMirrorUrl & '"'
        Local $iDWMPID = Run('"' & $sCurl & '" ' & $sDWMArgs, "", @SW_HIDE)
        If $iDWMPID <> 0 Then
            Local $tDWM = TimerInit()
            While ProcessExists($iDWMPID) And TimerDiff($tDWM) < 11000
                Local $evDWM = GUIGetMsg()
                If $evDWM = $GUI_EVENT_CLOSE Then
                    ProcessClose($iDWMPID)
                    _Quit()
                EndIf
                If $evDWM = $g_hBtnCancel Or ($g_hPopCancel <> 0 And $evDWM = $g_hPopCancel) Then $g_bCancel = True
                If $g_bCancel Then ProcessClose($iDWMPID)
                Sleep(50)
            WEnd
            If ProcessExists($iDWMPID) Then ProcessClose($iDWMPID)
        EndIf
        If FileExists($sDWMTmp) And Not $g_bCancel Then
            Local $hDWM = FileOpen($sDWMTmp, 0)
            If $hDWM <> -1 Then
                Local $sHTMLDWM = FileRead($hDWM)
                FileClose($hDWM)
                FileDelete($sDWMTmp)
                ; Direkte .iso-Links auf der Mirror-Seite suchen
                Local $aMirrorISO = StringRegExp($sHTMLDWM, 'href="(https?://[^"]+\.iso)"', 3)
                If Not @error Then
                    For $mm = 0 To UBound($aMirrorISO) - 1
                        Local $sML = $aMirrorISO[$mm]
                        If StringInStr($sML, "torrent") Or StringInStr($sML, ".sig") Then ContinueLoop
                        Local $aFDWM = StringRegExp($sML, "/([^/?#]+\.iso)", 1)
                        If Not @error Then $sFileOut = $aFDWM[0]
                        Local $aVDWM = StringRegExp($sML, "([\d]+\.[\d]+(?:\.[\d]+)*)", 1)
                        If Not @error Then $sVerOut = $aVDWM[0]
                        $sURLOut = $sML
                        _Log("    [WebSearch] DistroWatch Mirror: " & $sURLOut)
                        ExitLoop
                    Next
                EndIf
            Else
                FileDelete($sDWMTmp)
            EndIf
        EndIf
    EndIf

    If $sURLOut <> "" Then
        _Log("    [WebSearch] Ergebnis: v" & $sVerOut & " @ " & $sURLOut)
        Return True
    EndIf
    _Log("    [WebSearch] Keine URL gefunden für: " & $sName)
    Return False
EndFunc

Func _OnISOSearch()
    Local $iW = 680, $iH = 590
    Local $hDlg = GUICreate("🔎 ISO Suche — " & $APP_TITLE, $iW, $iH, -1, -1, _
        BitOR($WS_CAPTION, $WS_SYSMENU, $WS_SIZEBOX), $WS_EX_DROPSHADOW, $g_hMain)
    GUISetBkColor($C_W)
    GUISetFont(9, 400, 0, "Segoe UI")

    ; === Header ===
    GUICtrlCreateLabel("", 0, 0, $iW, 5)
    GUICtrlSetBkColor(-1, $C_AMB)
    GUICtrlSetState(-1, $GUI_DISABLE)

    GUICtrlCreateLabel("🔎  Linux ISO Suche", 18, 14, $iW-36, 22)
    GUICtrlSetFont(-1, 13, 700, 0, "Segoe UI Semibold")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlCreateLabel("Distro-Name, Kategorie oder Stichwort eingeben", 18, 38, $iW-36, 14)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_MID)
    GUICtrlSetBkColor(-1, $C_W)

    GUICtrlCreateLabel("", 0, 56, $iW, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; === Suchfeld ===
    GUICtrlCreateLabel("Suche:", 18, 68, 50, 18)
    GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_TXT)
    GUICtrlSetBkColor(-1, $C_W)

    Local $hSearchEdit = GUICtrlCreateInput("", 70, 65, $iW-160, 22, $ES_AUTOHSCROLL)
    GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, 0xF8FAFC)

    Local $hBtnSearch = GUICtrlCreateButton("  🔎  Suchen", $iW-82, 64, 74, 24)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_AMB)
    GUICtrlSetColor(-1, $C_W)

    ; Schnell-Filter Buttons — Reihe 1: Gaming, Sicherheit, Einsteiger, Fortgeschr., Leichtgew.
    GUICtrlCreateLabel("Schnellfilter:", 18, 96, 80, 14)
    GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, $C_W)

    Local $hF1 = GUICtrlCreateButton("🎮 Gaming",       102, 93, 106, 20)
    Local $hF2 = GUICtrlCreateButton("🔒 Sicherheit",   212, 93, 106, 20)
    Local $hF3 = GUICtrlCreateButton("🖥 Einsteiger",   322, 93, 106, 20)
    Local $hF4 = GUICtrlCreateButton("⚙ Fortgeschr.",  432, 93, 106, 20)
    Local $hF5 = GUICtrlCreateButton("🪶 Leichtgew.",   542, 93, 120, 20)
    GUICtrlSetFont($hF1, 8, 600, 0, "Segoe UI")
    GUICtrlSetBkColor($hF1, $C_LBLU)
    GUICtrlSetColor($hF1, $C_BLUE)
    GUICtrlSetFont($hF2, 8, 600, 0, "Segoe UI")
    GUICtrlSetBkColor($hF2, $C_LBLU)
    GUICtrlSetColor($hF2, $C_BLUE)
    GUICtrlSetFont($hF3, 8, 600, 0, "Segoe UI")
    GUICtrlSetBkColor($hF3, $C_LBLU)
    GUICtrlSetColor($hF3, $C_BLUE)
    GUICtrlSetFont($hF4, 8, 600, 0, "Segoe UI")
    GUICtrlSetBkColor($hF4, $C_LBLU)
    GUICtrlSetColor($hF4, $C_BLUE)
    GUICtrlSetFont($hF5, 8, 600, 0, "Segoe UI")
    GUICtrlSetBkColor($hF5, $C_LBLU)
    GUICtrlSetColor($hF5, $C_BLUE)

    ; Schnell-Filter Buttons — Reihe 2 (v2.17): Rettung, Antivirus, WinPE, ★ Alle
    Local $hF6   = GUICtrlCreateButton("🛠 Rettung",    102, 117, 106, 20)
    Local $hF7   = GUICtrlCreateButton("🛡 Antivirus",  212, 117, 106, 20)
    Local $hF8   = GUICtrlCreateButton("🪟 WinPE",      322, 117, 106, 20)
    Local $hFAll = GUICtrlCreateButton("★ Alle",        432, 117, 230, 20)
    GUICtrlSetFont($hF6, 8, 600, 0, "Segoe UI")
    GUICtrlSetBkColor($hF6, $C_LBLU)
    GUICtrlSetColor($hF6, $C_BLUE)
    GUICtrlSetFont($hF7, 8, 600, 0, "Segoe UI")
    GUICtrlSetBkColor($hF7, $C_LBLU)
    GUICtrlSetColor($hF7, $C_BLUE)
    GUICtrlSetFont($hF8, 8, 600, 0, "Segoe UI")
    GUICtrlSetBkColor($hF8, $C_LBLU)
    GUICtrlSetColor($hF8, $C_BLUE)
    GUICtrlSetFont($hFAll, 8, 600, 0, "Segoe UI")
    GUICtrlSetBkColor($hFAll, $C_LBLU)
    GUICtrlSetColor($hFAll, $C_BLUE)

    GUICtrlCreateLabel("", 0, 142, $iW, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    ; === Treffer-Zähler ===
    Local $hSearchCount = GUICtrlCreateLabel("  Bitte Suchbegriff eingeben oder Schnellfilter wählen ...", 18, 148, $iW-36, 16)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, $C_DIM)
    GUICtrlSetBkColor(-1, $C_W)

    ; === Ergebnis-Bereich (scrollbares Edit-Control als Anzeige) ===
    Local $hResultEdit = GUICtrlCreateEdit("", 0, 168, $iW, $iH-224, _
        BitOR($ES_MULTILINE, $ES_READONLY, $ES_AUTOVSCROLL, $WS_VSCROLL))
    GUICtrlSetFont(-1, 9, 400, 0, "Consolas")
    GUICtrlSetBkColor(-1, 0xF8FAFC)
    GUICtrlSetColor(-1, $C_TXT)

    ; === Download-Buttons-Bereich (am unteren Rand) ===
    GUICtrlCreateLabel("", 0, $iH-56, $iW, 1)
    GUICtrlSetBkColor(-1, $C_BRD)
    GUICtrlSetState(-1, $GUI_DISABLE)

    Local $hBtnDownloadSelected = GUICtrlCreateButton("  ⬇  Treffer herunterladen (ankreuzen & Fenster schließen)", 18, $iH-48, 440, 32)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_BLUE)
    GUICtrlSetColor(-1, $C_W)
    GUICtrlSetTip(-1, "Schließt den Suchdialog — gewünschte Treffer bitte im Hauptfenster ankreuzen und dann 'Herunterladen' klicken")

    Local $hBtnClose = GUICtrlCreateButton("  ✕  Schließen", $iW-120, $iH-48, 102, 32)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")
    GUICtrlSetBkColor(-1, $C_LRED)
    GUICtrlSetColor(-1, $C_RED)

    GUISetState(@SW_SHOW, $hDlg)

    ; === Hilfsfunktion: Suche ausführen und Ergebnis im Edit anzeigen ===
    Local $sLastQuery = ""

    ; Initial: alle ISOs anzeigen
    _SearchAndDisplay("", $hResultEdit, $hSearchCount, $hDlg)

    ; === Event-Loop ===
    While True
        Local $ev = GUIGetMsg()

        If $ev = $GUI_EVENT_CLOSE Or $ev = $hBtnClose Then ExitLoop

        If $ev = $hBtnDownloadSelected Then
            ; Treffer im Hauptfenster ankreuzen
            Local $hTV = GUICtrlGetHandle($g_hTreeView)
            Local $iMarked = 0
            For $k = 0 To $g_iSearchHitCount - 1
                Local $iIdx2 = $g_aiSearchHits[$k]
                If $g_ahNodes[$iIdx2] <> 0 Then
                    _GUICtrlTreeView_SetChecked($hTV, $g_ahNodes[$iIdx2], True)
                    $g_abNodeLast[$iIdx2] = True
                    $iMarked += 1
                EndIf
            Next
            If $iMarked > 0 Then
                _SyncCategoryCheckboxes()
                _Status("🔎 " & $iMarked & " ISO(s) aus Suche angekreuzt — jetzt 'Herunterladen' klicken!")
            EndIf
            ExitLoop
        EndIf

        ; Schnellfilter
        If $ev = $hF1 Then
            GUICtrlSetData($hSearchEdit, "Gaming")
            _SearchAndDisplay("Gaming", $hResultEdit, $hSearchCount, $hDlg)
        ElseIf $ev = $hF2 Then
            GUICtrlSetData($hSearchEdit, "Sicherheit")
            _SearchAndDisplay("Sicherheit", $hResultEdit, $hSearchCount, $hDlg)
        ElseIf $ev = $hF3 Then
            GUICtrlSetData($hSearchEdit, "Einsteiger")
            _SearchAndDisplay("Einsteiger", $hResultEdit, $hSearchCount, $hDlg)
        ElseIf $ev = $hF4 Then
            GUICtrlSetData($hSearchEdit, "Fortgeschrittene")
            _SearchAndDisplay("Fortgeschrittene", $hResultEdit, $hSearchCount, $hDlg)
        ElseIf $ev = $hF5 Then
            GUICtrlSetData($hSearchEdit, "Leichtgewichtig")
            _SearchAndDisplay("Leichtgewichtig", $hResultEdit, $hSearchCount, $hDlg)
        ElseIf $ev = $hF6 Then
            GUICtrlSetData($hSearchEdit, "Rettung")
            _SearchAndDisplay("Rettung", $hResultEdit, $hSearchCount, $hDlg)
        ElseIf $ev = $hF7 Then
            GUICtrlSetData($hSearchEdit, "Antivirus")
            _SearchAndDisplay("Antivirus", $hResultEdit, $hSearchCount, $hDlg)
        ElseIf $ev = $hF8 Then
            GUICtrlSetData($hSearchEdit, "WinPE")
            _SearchAndDisplay("WinPE", $hResultEdit, $hSearchCount, $hDlg)
        ElseIf $ev = $hFAll Then
            GUICtrlSetData($hSearchEdit, "")
            _SearchAndDisplay("", $hResultEdit, $hSearchCount, $hDlg)
        ElseIf $ev = $hBtnSearch Then
            Local $sQuery = StringStripWS(GUICtrlRead($hSearchEdit), 3)
            _SearchAndDisplay($sQuery, $hResultEdit, $hSearchCount, $hDlg)
        EndIf

        ; Echtzeit-Suche bei Tastatureingabe (Live-Search)
        Local $sNow = GUICtrlRead($hSearchEdit)
        If $sNow <> $sLastQuery Then
            $sLastQuery = $sNow
            _SearchAndDisplay(StringStripWS($sNow, 3), $hResultEdit, $hSearchCount, $hDlg)
        EndIf
    WEnd

    GUIDelete($hDlg)
EndFunc

Func _MigrateRootISOsToCategories($sDrive)
    If $sDrive = "" Or DriveStatus($sDrive) <> "READY" Then Return 0
    _Log("=== Kategorie-Migration: Scanne Root von " & $sDrive & " ===")

    ; Alle ISO-Dateien direkt im Root (NICHT rekursiv)
    Local $aRootISOs = _FileListToArray($sDrive, "*.iso", 1)
    If @error Or Not IsArray($aRootISOs) Or $aRootISOs[0] = 0 Then
        _Log("  Keine ISOs im Root gefunden — nichts zu migrieren.")
        Return 0
    EndIf

    Local $iMoved = 0
    Local $iSkip  = 0

    For $r = 1 To $aRootISOs[0]
        Local $sRootFile = $aRootISOs[$r]
        Local $sRootPath = $sDrive & "\" & $sRootFile

        ; In DB suchen: welches ISO hat diesen Dateinamen?
        Local $sTargetCat = ""
        For $i = 0 To $ISO_COUNT - 1
            If StringLower($g_aISOs[$i][3]) = StringLower($sRootFile) Then
                $sTargetCat = $g_aISOs[$i][1]
                ExitLoop
            EndIf
        Next

        ; Keine DB-Übereinstimmung → in "Sonstige" Ordner
        If $sTargetCat = "" Then
            $sTargetCat = "Sonstige"
            _Log("  [?] " & $sRootFile & " — kein DB-Eintrag, gehe in Ordner Sonstige")
        EndIf

        ; Zielordner anlegen
        Local $sCatDir  = $sDrive & "\" & $sTargetCat
        Local $sDestPath = $sCatDir & "\" & $sRootFile
        If Not FileExists($sCatDir) Then
            DirCreate($sCatDir)
            _Log("  Ordner angelegt: " & $sCatDir)
        EndIf

        ; Datei bereits im Zielordner?
        If FileExists($sDestPath) Then
            _Log("  [=] " & $sRootFile & " → bereits in " & $sTargetCat)
            ; Doppelte Datei im Root löschen
            FileDelete($sRootPath)
            $iSkip += 1
            ContinueLoop
        EndIf

        ; Verschieben per FileMove
        If FileMove($sRootPath, $sDestPath, 1) Then
            _Log("  [✓] " & $sRootFile & " → " & $sTargetCat & "\")
            $iMoved += 1
        Else
            _Log("  [✗] " & $sRootFile & " → FEHLER beim Verschieben nach " & $sTargetCat)
        EndIf
    Next

    _Log("=== Kategorie-Migration abgeschlossen: " & $iMoved & " verschoben, " & $iSkip & " bereits korrekt ===")
    Return $iMoved
EndFunc

