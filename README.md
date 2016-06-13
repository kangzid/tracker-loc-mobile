#  Staff Tracker - Mobile Application

**Staff Tracker** adalah aplikasi mobile berbasis Android yang dikembangkan untuk membantu pemantauan kehadiran karyawan, lokasi kendaraan operasional, serta aktivitas lapangan secara real-time. Aplikasi ini dirancang untuk mendukung operasional manajemen tenaga kerja dan armada kendaraan secara lebih efisien, terstruktur, dan transparan.

Melalui **Staff Tracker**, administrator dapat memonitor aktivitas karyawan dan kendaraan melalui peta interaktif, sementara karyawan dapat melakukan absensi digital serta mengaktifkan mode pelacakan GPS saat menjalankan tugas lapangan.

---

##  Tujuan Pengembangan

Aplikasi ini dikembangkan dengan tujuan:
- Meningkatkan efisiensi monitoring karyawan lapangan
- Menyediakan sistem absensi digital berbasis lokasi
- Mendukung pemantauan kendaraan operasional melalui GPS tracker
- Menyediakan data aktivitas sebagai bahan evaluasi operasional
- Mengurangi proses manual dalam pengelolaan kehadiran dan pelacakan

---

##  Teknologi yang Digunakan

Aplikasi dibangun menggunakan teknologi modern untuk memastikan performa, stabilitas, dan kemudahan pengembangan.

| Kategori | Teknologi | Deskripsi |
|----------|----------|-----------|
| **Framework** | Flutter | Framework utama untuk pengembangan aplikasi mobile cross-platform |
| **Language** | Dart | Bahasa pemrograman utama |
| **Maps** | Flutter Map (OpenStreetMap) | Menampilkan peta interaktif untuk pelacakan lokasi |
| **Location** | Geolocator | Mengambil koordinat GPS perangkat |
| **Backend** | Laravel REST API | Pengelolaan data dan autentikasi |
| **Remote Config** | Firebase | Konfigurasi dan Realtime Data |
| **Local Storage** | Shared Preferences | Penyimpanan sesi dan data pengguna |
| **UI Support** | Lottie & HugeIcons | Animasi dan ikon antarmuka |

---

## ✨ Fitur Utama

###  Modul Administrator
- Monitoring lokasi karyawan dan kendaraan operasional secara real-time
- GPS Tracker untuk armada kendaraan aktif
- Manajemen data karyawan dan kendaraan
- Dashboard statistik operasional
- Pengaturan akun dan profil administrator

###  Modul Karyawan
- Absensi digital (check-in & check-out)
- Mode GPS Tracking saat bertugas
- Riwayat aktivitas dan kehadiran
- Informasi akun dan status kerja

### 🔐 Keamanan & Pengalaman Pengguna
- Manajemen sesi dan token otomatis
- Penanganan error yang informatif dan ramah pengguna
- Antarmuka modern dengan dialog konfirmasi dan animasi transisi

---

##  GPS Vehicle Tracking

Staff Tracker menyediakan fitur **GPS Vehicle Tracking** untuk memantau kendaraan operasional secara langsung melalui peta interaktif.

Fitur ini memungkinkan administrator untuk:
- Melihat posisi kendaraan secara real-time
- Memantau status kendaraan aktif dan nonaktif
- Mendukung pengawasan distribusi dan operasional lapangan
- Membantu analisis rute dan efisiensi penggunaan kendaraan

Sistem pelacakan terintegrasi langsung dengan backend dan menerapkan pengelolaan data lokasi yang terkontrol dan aman.

---

##  Arsitektur Aplikasi

Proyek ini menerapkan **Feature-First Architecture**, di mana struktur kode dikelompokkan berdasarkan fitur (auth, admin, employee, tracking), bukan berdasarkan jenis file.

Pendekatan ini memberikan keuntungan:
- Struktur kode lebih bersih dan mudah dipahami
- Skalabilitas lebih baik untuk penambahan fitur baru
- Pemeliharaan dan refactor menjadi lebih terkontrol

---

##  Pratinjau Aplikasi

Untuk melihat tampilan antarmuka dan alur penggunaan aplikasi **Staff Tracker**, silakan merujuk ke dokumen pratinjau visual yang telah disediakan dalam bentuk PDF.

📄 **Dokumentasi Pratinjau Aplikasi (PDF)**  
🔗 https://drive.google.com/drive/folders/1gZvLTyfKeo8hMsVjG1sSlNfBiyD2QLvW?usp=drive_link


---

## 📦 Informasi Rilis

Riwayat pembaruan dan detail versi dapat dilihat pada dokumentasi rilis:
- Release v1.1.0 (Latest)
- Release v1.0.0

---

## 👥 Tim Pengembang — Kelompok 11

| Nama | Peran |
|-----|------|
| **Zalfyan** | Fullstack Developer (Flutter & Backend) |
| **Brillian** | Project Planner & UI/UX Designer |

Proyek ini dikembangkan oleh **Kelompok 11** sebagai bagian dari pengembangan aplikasi mobile dengan fokus pada implementasi sistem tracking, integrasi backend, dan arsitektur aplikasi yang terstruktur.

---

<p align="center">
  Dibuat oleh Tim Staff Tracker (Kelompok 11)  
  © 2025 Staff Tracker Project
</p>
