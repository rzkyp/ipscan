📌 **Apa itu scanip.sh v6.3?**  
`scanip.sh` adalah **shell-script pendamping penetration-tester** yang mengotomasikan rangkaian tugas membosankan:  
- menentukan proxy (Tor/custom/none)  
- menjalankan **RustScan ultra-cepat (6 detik)** untuk memetakan port terbuka  
- **mem-parse hasilnya secara cerdas** → exploit hanya dijalankan pada port yang memang terbuka  
- menyimpan **laporan lengkap & rapi** dalam folder tersendiri  

Dengan **satu perintah `run`** kamu mendapatkan:  
daftar port, fingerprint layanan, banner, brute-force SSH/FTP, enumerasi SMB, directory-busting web, serta tech-fingerprint – **tanpa mengetik puluhan command manual**.

---

## ⚙️ Cara instalasi

1. **Clone & masuk ke direktori**
   ```bash
   git clone https://github.com/rzkyp/scanip.sh.git
   cd scanip.sh
   ```

2. **Berikan hak eksekusi**
   ```bash
   chmod +x scanip.sh
   ```

3. **Luncurkan untuk pertama kali**
   ```bash
   ./scanip.sh
   ```
   - Script **otomatis mengecek 9 tool** penting (rustscan, nmap, hydra, gobuster, whatweb, nikto, enum4linux-ng, smbmap, msfconsole).  
   - Bila ada yang belum terinstall, kamu disodori 3 pilihan:  
     1) **Otomatis install 1-per-1** (rekomen)  
     2) Tampilkan command manual  
     3) Keluar  
   - Setelah semua dependensi terpenuhi, script masuk ke **console interaktif KMIPN**.

---

## 🎮 Cara pemakaian step-by-step

1. **Pilih proxy (hanya ditanyakan sekali di awal)**  
   ```
   [*] Pilih proxy (semua tool akan lewat proxy ini)
   1) Tor (auto-start, socks5://127.0.0.1:9050)
   2) Proxy custom
   3) Tidak pakai proxy
   KMIPN>> pilih [1-3] : 1
   ```  
   *Tor langsung distart di background.*

2. **Console KMIPN muncul**  
   ```
   KMIPN>>
   ```

3. **Tentukan target**  
   ```
   KMIPN>> set target 192.168.1.77
   TARGET => 192.168.1.77
   ```

4. *(Opsional)* Ganti wordlist  
   ```
   KMIPN>> set wordlist user
   1) Default (/usr/share/wordlists/metasploit/unix_users.txt)
   2) Masukkan path sendiri
   KMIPN>> pilih [1-2] : 2
   KMIPN>> path file : /media/myuser.txt
   ```

5. **Cek konfigurasi**  
   ```
   KMIPN>> status
   === STATUS ===
   TARGET    : 192.168.1.77
   WORDLIST U: /media/myuser.txt
   WORDLIST P: /usr/share/.../unix_passwords.txt
   WORDLIST D: /usr/share/.../common.txt
   ```

6. **TANCAP!**  
   ```
   KMIPN>> run
   ```
   - RustScan → port terbuka misal 22,21,80,445  
   - Nmap detail, banner, service enum  
   - Hydra SSH, FTP anon+brute, enum4linux & smbmap, gobuster + whatweb web 80 & 443  
   - Semua log masuk folder `scan-192.168.1.77-2025-11-15-1342/`

7. **Selesai**  
   ```
   [*] Selesai! Hasil di scan-192.168.1.77-2025-11-15-1342
   KMIPN>> exit
   Happy hacking!
   ```

---

## ✨ Fitur lengkap

| Fitur | Manfaat nyata |
|-------|---------------|
| **🚀 RustScan 6 detik** | Hemat waktu 70 % |
| **🔍 Parser port cerdas** | Exploit cuma jalan di port yang buka → irit bandwidth & CPU |
| **🧅 Proxy-aware** | Tor otomatis start; custom socks5/http; atau direct |
| **🔧 Auto-installer** | Pilih “1” → semua tool terinstall sendiri |
| **📂 Report terstruktur** | Tiap target punya folder sendiri, siap di-zip atau dikirim klien |
| **🎨 5 banner ASCII random** | Biar terminal nggak keliatan membosankan |
| **⏱️ Timeout & retry aman** | Anti hang saat firewall drop paket |
| **🧠 Console interaktif** | Tanpa edit script terus-menerus |
| **📈 Cuplikan 5 baris** | Langsung tahu exploit sukses/gagal tanpa buka file besar |

---

## 📂 Struktur hasil (contoh)

```
scan-192.168.1.77-2025-11-15-1342/
├── rustscan.txt        # port terbuka
├── general-nmap.txt    # -sV -sC detail
├── banner.txt          # banner grab
├── hydra-ssh.txt       # brute SSH (port 22)
├── ftp.txt             # anon + brute FTP (port 21)
├── enum4linux.txt      # SMB enum (port 445)
├── smbmap.txt          # daftar share SMB
├── gobuster-80.txt     # direktori HTTP
├── whatweb-80.txt      # tech fingerprint HTTP
├── gobuster-443.txt    # direktori HTTPS
└── whatweb-443.txt     # tech fingerprint HTTPS
```

---

## 🎭 Credit & Warning (langsung di README)

**Credit:**  
Script oleh **Zero – @Insider** | Kontribusi: KMIPN CTF Team & open-source community.  
Terima-kasih kepada RustScan, Nmap, Hydra, Gobuster, WhatWeb, Nikto, enum4linux-ng, smbmap, Metasploit & distro Kali/Parrot.

**⚠️ Warning / Disclaimer:**  
- **EDUKASI & LEGAL ONLY** – Lab pribadi, CTF, atau audit dengan **IZIN TERTULIS**.  
- **DILARANG** menyerang target tanpa izin → risiko hukum ditanggung sendiri.  
- Brute-force dapat **lockout account** – gunakan dengan bijak.  
- Penulis & kontributor **TIDAK BERTANGGUNG-JAWAB** atas penyalah-gunaan script.  
- Jika tidak setuju, **HAPUS** script ini sekarang.

**License:** MIT – lihat file `LICENSE` terpisah.

---

🎉 **Kesimpulan**  
Magere? Butuh hasil cepat & rapi? Tetep mau anonim?  
Cukup:  
```
./scanip.sh
set target <IP>
run
```
**Selesai!**  
Star ⭐ repo kalau bermanfaat – **stay legal, stay ethical, happy hacking!**
