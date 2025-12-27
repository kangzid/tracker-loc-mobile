# Dokumentasi Mobile Apps - Staff Tracker

Dokumentasi ini berisi panduan cara menjalankan aplikasi, mengubah konfigurasi API, dan penjelasan struktur folder project.

## 1. Cara Menjalankan Aplikasi

Aplikasi ini dibangun menggunakan Flutter. Pastikan Flutter SDK sudah terinstall dengan benar.

### Persiapan (Pertama Kali)
Jika baru pertama kali men-clone repository, jalankan perintah ini di terminal root folder project:
```bash
flutter pub get
```

### Menjalankan di Chrome (Web)
Pastikan Anda menggunakan Chrome sebagai device target:
```bash
flutter run -d chrome
```
*Gunakan `-d chrome` untuk spesifik membuka di Chrome.*

### Menjalankan di Android (HP Asli)
1.  Aktifkan **USB Debugging** di HP Anda.
2.  Sambungkan HP ke Laptop dengan kabel USB.
3.  Jalankan perintah:
    ```bash
    flutter run
    ```
    Atau jika ada banyak device terhubung, pilih device ID-nya (lihat dengan `flutter devices`).

---

## 2. Cara Mengubah API Base URL

Konfigurasi URL API terpusat di satu file, namun aplikasi ini menggunakan fitur **Firebase Remote Config** untuk fleksibilitas.

### Metode A: Melalui Kodingan (Fallback)
Jika Firebase bermasalah atau belum dikonfigurasi, aplikasi akan menggunakan URL cadangan yang ada di kodingan.

1.  Buka file: `lib/config/api_config.dart`
2.  Cari baris berikut (sekitar baris 4):
    ```dart
    static String _baseUrl = 'https://locatrack.zalfyan.my.id/api'; // fallback
    ```
3.  Ubah URL di dalam tanda kutip menjadi URL API baru Anda.

### Metode B: Melalui Firebase Remote Config (Recommended)
Aplikasi ini diatur untuk mengambil URL dari Firebase agar bisa diganti tanpa update aplikasi di PlayStore.

1.  Buka Firebase Console project ini.
2.  Masuk ke menu **Remote Config**.
3.  Cari parameter bernama `api_base_url`.
4.  Ubah valuenya menjadi URL baru.
5.  Publish changes.
6.  Restart aplikasi, URL akan otomatis terupdate.

---

## 3. Struktur Folder & File

Berikut adalah penjelasan fungsi dari folder dan file utama di dalam `lib/`:

| Path | Fungsi Utama |
| :--- | :--- |
| `lib/main.dart` | **Pintu Masuk Aplikasi**. Berisi inisialisasi Firebase, routing awal, dan logika pengecekan login (apakah user Admin atau Employee). |
| `lib/firebase_options.dart` | **Konfigurasi Firebase**. File auto-generate yang berisi API Key dan App ID untuk koneksi ke Firebase (Web & Android). |
| **`lib/config/`** | **Folder Konfigurasi**. |
| `lib/config/api_config.dart` | Menyimpan *Base URL* dan *Endpoint* API. Berisi logic `RemoteConfig`. |
| **`lib/pages/`** | **Halaman UI (Tampilan)**. Dikelompokkan berdasarkan peran user. |
| `lib/pages/auth/` | Halaman Login (`login_page.dart`). |
| `lib/pages/admin/` | Halaman-halaman khusus **Admin**. Berisi dashboard admin, manajemen kendaraan, pegawai, dll. |
| `lib/pages/employee/` | Halaman-halaman khusus **Pegawai**. Berisi absen, tugas harian, dll. |
| **`lib/utils/`** | **Folder Utilitas**. Berisi helper function kecil atau formatting yang dipakai berulang. |

---

## Catatan Penting untuk Maintenance

1.  **Aset Lottie (Animasi Loading)**
    File animasi loading disimpan secara lokal di `assets/lottie/loading.json`. Jika ingin mengganti animasi:
    - Download file `.json` baru dari LottieFiles.
    - Timpa file lama di folder `assets/lottie/` dengan nama yang sama (`loading.json`), atau;
    - Simpan dengan nama baru dan update path-nya di `lib/main.dart`.

2.  **Package Naming**
    Meskipun nama folder project berubah, nama paket internal aplikasi masih `flutter_application_1` (sesuai `pubspec.yaml`). Jangan kaget jika melihat import seperti:
    `import 'package:flutter_application_1/...'`
    Ini normal dan tidak perlu diubah kecuali Anda ingin melakukan refactor total.
