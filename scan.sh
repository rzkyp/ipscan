#!/usr/bin/env bash
# scanip.sh v6.3 – Pilih proxy → RustScan → SEMUA exploit jalan + report lengkap
# chmod +x scanip.sh && ./scanip.sh

set -euo pipefail
shopt -s lastpipe

# ---------- Warna ----------
red='\033[1;31m'; grn='\033[1;32m'; ylw='\033[1;33m'; blu='\033[1;34m'; rst='\033[0m'

# ---------- 5 TEMA BANNER KMIPN ----------
mapfile -t BANNER_POOL <<'EOF'
 _  __     _          _ _       _           _       _ _          _
| |/ /   _| |__   ___| | | ___ | |__   ___ | |_    | | |__   ___| |
| ' / | | | '_ \ / _ \ | |/ _ \| '_ \ / _ \| __|   | | '_ \ / _ \ |
| . \ |_| | |_) |  __/ | | (_) | | | | (_) | |_    |_| | | |  __/_|
|_|\_\__,_|_.__/ \___|_|_|\___/|_| |_|\___/ \__|   (_)_| |_|\___(_)
-----------------------------------KMIPN-----------------------------------
 __  __ _____ _   _ _   _ ___  ___  ___
|  \/  |  ___| \ | | | | / _ \/ |/ / |_ )
| |\/| | |_  |  \| | | | | | | ' /   | \
| |  | |  _| | |\  | |_| | |_| | . \   __)
|_|  |_|_|   |_| \_|\___/ \___/|_|\_\ |___/
-----------------------------------KMIPN-------------------------------------------------------------------------------
 _  __  __   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
| |/ / /  \ / _ \ / _ \ / _ \ / _ \ / _ \ / _ \ / _ \ / _ \ / _ \ / _ \
| ' / | () | (_) | (_) | (_) | (_) | (_) | (_) | (_) | (_) | (_) | (_) |
| . \  \__/ \___/ \___/ \___/ \___/ \___/ \___/ \___/ \___/ \___/ \___/
-----------------------------------KMIPN-------------------------------------------------------------------------------
 _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _
| || || || || || || || || || || || || || || || || || || || || || || |
|_||_||_||_||_||_||_||_||_||_||_||_||_||_||_||_||_||_||_||_||_||_||_|
-----------------------------------KMIPN-------------------------------------------------------------------------------
 _  __  __   __  __  __  __  __  __  __  __  __  __  __  __  __  __
| |/ / /  \ /  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \
| ' / | () | |\/| |\/| |\/| |\/| |\/| |\/| |\/| |\/| |\/| |\/| |
| . \  \__/|_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|
-----------------------------------KMIPN-------------------------------------------------------------------------------
EOF

# ---------- Util ----------
bar() { printf -- "${blu}--------------------------------------------${rst}\n"; }

# ---------- Fungsi instalasi 1-per-1 ----------
install_rustscan(){ sudo snap install rustscan -y; }
install_nmap(){ sudo apt install -y nmap; }
install_hydra(){ sudo apt install -y hydra; }
install_gobuster(){ sudo apt install -y gobuster; }
install_whatweb(){ sudo apt install -y whatweb; }
install_nikto(){ sudo apt install -y nikto; }
install_enum4linux-ng(){ sudo apt install -y enum4linux-ng; }
install_smbmap(){ sudo apt install -y smbmap; }
install_msfconsole(){
  curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb -o msfinstall
  chmod +x msfinstall && ./msfinstall
  rm -f msfinstall
}

# ---------- Mapping tool → fungsi ----------
declare -A INSTALL_CMD=(
 [rustscan]=install_rustscan
 [nmap]=install_nmap
 [hydra]=install_hydra
 [gobuster]=install_gobuster
 [whatweb]=install_whatweb
 [nikto]=install_nikto
 [enum4linux-ng]=install_enum4linux-ng
 [smbmap]=install_smbmap
 [msfconsole]=install_msfconsole
)

# ---------- 0. PILIH PROXY (awal) ----------
PROXY=""   # akan diisi socks5://127.0.0.1:9050  atau custom
echo -e "${ylw}[*] Pilih proxy (semua tool akan lewat proxy ini)${rst}"
echo "1) Tor (auto-start, socks5://127.0.0.1:9050)"
echo "2) Proxy custom (masukkan URL)"
echo "3) Tidak pakai proxy"
echo -n -e "${grn}KMIPN>>${rst} pilih [1-3] : "
read -r PROXY_CHOICE
case $PROXY_CHOICE in
  1)
    PROXY="socks5://127.0.0.1:9050"
    echo -e "${ylw}[*] Starting Tor di background...${rst}"
    sudo systemctl start tor 2>/dev/null || sudo tor &
    sleep 3
    echo -e "${grn}[+] Tor berjalan, proxy aktif: $PROXY${rst}"
    ;;
  2)
    read -e -p "${grn}KMIPN>>${rst} URL proxy (contoh socks5://ip:port) : " CUSTOM
    PROXY="$CUSTOM"
    echo -e "${grn}[+] Proxy custom di-set: $PROXY${rst}"
    ;;
  3)
    PROXY=""
    echo -e "${grn}[+] Tidak pakai proxy${rst}"
    ;;
  *) echo -e "${red}Invalid${rst}"; exit 1 ;;
esac

# ---------- EXPORT PROXY ENV (global untuk tool yang support) ----------
if [[ -n $PROXY ]]; then
  export ALL_PROXY="$PROXY"
  export HTTP_PROXY="$PROXY"
  export HTTPS_PROXY="$PROXY"
  echo -e "${blu}[proxy-env] $PROXY${rst}"
fi

# ---------- 1. Check + 3 Pilihan ----------
echo -e "${ylw}[*] Checking required tools...${rst}"
declare -A TOOLS=(
 [rustscan]="rustscan" [nmap]="nmap" [hydra]="hydra" [gobuster]="gobuster"
 [whatweb]="whatweb" [nikto]="nikto" [enum4linux-ng]="enum4linux-ng"
 [smbmap]="smbmap" [msfconsole]="metasploit-framework"
)
MISS=()
for t in "${!TOOLS[@]}"; do
  command -v "$t" &>/dev/null || MISS+=("$t")
done

if [[ ${#MISS[@]} -gt 0 ]]; then
  bar
  echo -e "${red}Tools belum terinstall:${rst}"
  for m in "${MISS[@]}"; do printf "  - %-20s (pkg: %s)\n" "$m" "${TOOLS[$m]}"; done
  bar
  echo -e "${ylw}Pilihan:${rst}"
  echo "1) Otomatis install 1-per-1"
  echo "2) Tampilkan guide install manual"
  echo "3) Keluar"
  echo -n -e "${grn}KMIPN>>${rst} pilih [1-3] : "
  read -r PIL
  case $PIL in
    1)
      echo -e "${grn}[*] Install otomatis 1-per-1...${rst}"
      for tool in "${!INSTALL_CMD[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
          echo -n -e "${ylw}  Installing $tool ...${rst}"
          ${INSTALL_CMD[$tool]} && echo -e " ${grn}DONE${rst}" || echo -e " ${red}FAIL${rst}"
        fi
      done
      echo -e "${grn}[+] Semua tool selesai!${rst}"
      ;;
    2)
      for m in "${MISS[@]}"; do echo "  sudo apt install -y ${TOOLS[$m]}"; done
      exit 0 ;;
    3) exit 0 ;;
    *) echo -e "${red}Invalid${rst}"; exit 1 ;;
  esac
fi

# ---------- 2. Clear → Banner ----------
clear
RANDOM_BANNER=${BANNER_POOL[$((RANDOM % ${#BANNER_POOL[@]}))]}
echo -e "${blu}$RANDOM_BANNER${rst}"
echo -e "${red}# Coded By 0xZer0r - @Insider${rst}\n"

# ---------- 3. Langsung Console ----------
TARGET=""
WUSER=/usr/share/wordlists/metasploit/unix_users.txt
WPASS=/usr/share/wordlists/metasploit/unix_passwords.txt
WDIR=/usr/share/wordlists/dirb/common.txt
OUTDIR=""

# ---------- Fungsi Console ----------
show_status() {
  echo -e "${blu}=== STATUS ===${rst}"
  echo -e "TARGET    : ${grn}${TARGET:-<empty>}${rst}"
  echo -e "WORDLIST U: ${grn}$WUSER${rst}"
  echo -e "WORDLIST P: ${grn}$WPASS${rst}"
  echo -e "WORDLIST D: ${grn}$WDIR${rst}"
}
show_help() {
  bar
  echo -e "${ylw}KMIPN-Console Help${rst}"
  echo " set target <IP>        : set alamat target"
  echo " set wordlist user      : pilih wordlist username (default/custom)"
  echo " set wordlist pass      : pilih wordlist password (default/custom)"
  echo " set wordlist dir       : pilih wordlist directory (default/custom)"
  echo " status                 : tampilkan nilai saat ini"
  echo " run                    : jalankan scan + exploit"
  echo " ?/help                 : tampilkan menu ini"
  echo " exit                   : keluar"
  bar
}
choose_wordlist() {
  local typ=$1 cur=$2
  echo -e "${ylw}[*] Pilih wordlist $typ${rst}"
  echo "1) Default ($cur)"
  echo "2) Masukkan path file sendiri"
  echo -n -e "${grn}KMIPN>>${rst} pilih [1-2] : "
  read -r P
  if [[ $P == 2 ]]; then
    read -e -p "${grn}KMIPN>>${rst} path file : " NF
    if [[ -f $NF ]]; then
      echo "$NF"
    else
      echo -e "${red}File tidak ada!${rst}" >&2
      echo "$cur"
    fi
  else
    echo "$cur"
  fi
}

# ---------- REPORT EXPLOIT: TAMPIL + SIMPAN + CUPLIK ----------
exploit_report(){
  local desc="$1"; shift
  local out_file="$1"; shift
  echo -e "${ylw}[+] $desc${rst}"
  # jalankan & capture full log
  "$@" &> "$out_file"
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    echo -e "  ${grn}✔ Berhasil${rst}"
    # cuplik 5 baris terakhir hasil
    echo -e "${grn}    Hasil:${rst}"
    tail -n 5 "$out_file" | sed 's/^/    /'
  else
    echo -e "  ${red}✘ Gagal (exit $rc)${rst}"
    echo -e "${red}    Log gagal:${rst}"
    tail -n 5 "$out_file" | sed 's/^/    /'
  fi
  # tandai file sebagai report
  echo -e "${blu}    → Laporan lengkap: $out_file${rst}"
}

# ---------- Console Loop ----------
while true; do
  echo -n -e "${grn}KMIPN>>${rst} "
  read -r CMD ARG1 ARG2
  case "$CMD" in
    set)
      case "$ARG1" in
        target) TARGET="$ARG2"; echo -e "${grn}TARGET => $TARGET${rst}" ;;
        wordlist)
          case "$ARG2" in
            user) WUSER=$(choose_wordlist USER "$WUSER") ;;
            pass) WPASS=$(choose_wordlist PASS "$WPASS") ;;
            dir)  WDIR=$(choose_wordlist DIR "$WDIR") ;;
            *) echo -e "${red}Usage: set wordlist {user|pass|dir}${rst}" ;;
          esac
          ;;
        *) echo -e "${red}Usage: set {target|wordlist} ...${rst}" ;;
      esac
      ;;
    status|st) show_status ;;
    ?|help) show_help ;;
    run)
      [[ -z $TARGET ]] && { echo -e "${red}TARGET belum di-set!${rst}"; continue; }
      OUTDIR="scan-$TARGET-$(date +%F-%H%M)"
      mkdir -p "$OUTDIR"
      bar
      echo -e "${ylw}[*] RustScan 6 detik → $TARGET${rst}"
      # ---------- RUSTSCAN: TIDAK PAKAI PROXY ----------
      rustscan -a "$TARGET" --ulimit 5000 -g 2>&1 | tee "$OUTDIR/rustscan.txt"
      # ---------- PARSER PORT UNIVERSAL ----------
      RAW_PORT=$(grep -oP '\d+(?=/tcp|(?=:))' "$OUTDIR/rustscan.txt" | sort -un | tr '\n' ',' | sed 's/,$//')
      if [[ -z $RAW_PORT ]]; then
        echo -e "${red}[!] RustScan tidak mengembalikan port terbuka (output kosong atau format tidak dikenal)${rst}"
        echo -e "${ylw}    Kemungkinan:${rst}"
        echo -e "    - Target tidak online / firewall drop semua probe"
        echo -e "    - RustScan error / format keluaran beda"
        echo -e "${grn}    Tips:${rst} coba jalankan: rustscan -a $TARGET --ulimit 5000 secara manual"
        continue
      fi
      OPEN_PORTS="$RAW_PORT"

      echo -e "${grn}[+] Port terbuka: $OPEN_PORTS${rst}"
      bar
      echo -e "${ylw}[*] General scan & enum pada semua port terbuka...${rst}"
      # 1. Nmap detail + banner + service (dengan timeout hindari hang)
      if [[ -n $PROXY ]]; then
        echo -e "${blu}[proxy-env] $PROXY${rst}"
        exploit_report "Nmap detail" "$OUTDIR/general-nmap.txt" nmap -sV -sC -p"$OPEN_PORTS" --open --max-retries 1 --host-timeout 10s "$TARGET"
      else
        exploit_report "Nmap detail" "$OUTDIR/general-nmap.txt" nmap -sV -sC -p"$OPEN_PORTS" --open --max-retries 1 --host-timeout 10s "$TARGET"
      fi
      # 2. Cek jika nmap return 0 open
      if [[ -z $(grep -oP '^\d+/tcp\s+open' "$OUTDIR/general-nmap.txt") ]]; then
        echo -e "${ylw}[!] Nmap return 0 open – kemungkinan filtered oleh firewall${rst}"
      fi
      # 3. Banner grab cepat
      exploit_report "Banner grab" "$OUTDIR/banner.txt" nmap -p"$OPEN_PORTS" --script banner "$TARGET"
      # 4. Service enum ringan
      exploit_report "Service enum" "$OUTDIR/service-light.txt" nmap -p"$OPEN_PORTS" -sV --version-intensity 0 "$TARGET"

      # ---------- EXPLOIT SPESIFIK (jika port match) ----------
      if echo "$OPEN_PORTS" | grep -q '\b22\b'; then
        exploit_report "SSH brute" "$OUTDIR/hydra-ssh.txt" hydra -L "$WUSER" -P "$WPASS" -t 30 ssh://"$TARGET"
      fi
      if echo "$OPEN_PORTS" | grep -q '\b21\b'; then
        exploit_report "FTP anon+brute" "$OUTDIR/ftp.txt" nmap -p21 --script ftp-anon,ftp-brute --script-args userdb="$WUSER",passdb="$WPASS" "$TARGET"
      fi
      if echo "$OPEN_PORTS" | grep -q '\b445\b'; then
        exploit_report "SMB enum" "$OUTDIR/enum4linux.txt" enum4linux-ng -A "$TARGET"
        exploit_report "SMB map" "$OUTDIR/smbmap.txt" smbmap -H "$TARGET"
      fi
      if echo "$OPEN_PORTS" | grep -q '\b80\b'; then
        if [[ -n $PROXY ]]; then
          exploit_report "HTTP dirs" "$OUTDIR/gobuster-80.txt" gobuster dir -u "http://$TARGET" -w "$WDIR" -q --proxy "$PROXY"
        else
          exploit_report "HTTP dirs" "$OUTDIR/gobuster-80.txt" gobuster dir -u "http://$TARGET" -w "$WDIR" -q
        fi
        exploit_report "HTTP whatweb" "$OUTDIR/whatweb-80.txt" whatweb "http://$TARGET"
      fi
      if echo "$OPEN_PORTS" | grep -q '\b443\b'; then
        if [[ -n $PROXY ]]; then
          exploit_report "HTTPS dirs" "$OUTDIR/gobuster-443.txt" gobuster dir -u "https://$TARGET" -w "$WDIR" -q --proxy "$PROXY"
        else
          exploit_report "HTTPS dirs" "$OUTDIR/gobuster-443.txt" gobuster dir -u "https://$TARGET" -w "$WDIR" -q
        fi
        exploit_report "HTTPS whatweb" "$OUTDIR/whatweb-443.txt" whatweb "https://$TARGET"
      fi

      bar
      echo -e "${grn}[*] Selesai! Hasil di $OUTDIR ${rst}"
      ;;
    exit) echo -e "${grn}Happy hacking!${rst}"; exit 0 ;;
    *) echo -e "${red}Perintah tidak dikenal. Ketik ? untuk bantuan.${rst}" ;;
  esac
done
