# Panduan Struktur Folder & Architecture (Future-Proof)

Saat ini project Anda menggunakan struktur yang cukup sederhana (flat). Ini bagus untuk memulai, tapi akan sulit dimaintain saat aplikasi makin besar (seperti `vehicle_page.dart` yang sudah 400+ baris).

Berikut adalah saran struktur folder yang lebih **Scalable** dan **Clean** untuk jangka panjang.

## 1. Konsep Utama: Clean Architecture (Simplified)

Kita memisahkan code menjadi 3 lapisan utama agar tidak campur aduk:

1.  **Presentation (UI)**: Halaman (Screen) dan Widget. Tugasnya hanya menampilkan data. **DILARANG** ada logic `http.get` atau logic bisnis rumit di sini.
2.  **Domain/Logic (Business Process)**: Penghubung antara UI dan Data. Ini bisa berupa Controller, Bloc, atau Provider.
3.  **Data (Repository/Service)**: Mengurus data mentah (API, Database, SharedPref).

## 2. Struktur Folder Rekomendasi: "Feature-First"

Alih-alih mengelompokkan `pages` sendiri dan `services` sendiri, lebih baik kelompokkan berdasarkan **FITUR**. Ini memudahkan maintenance karena semua yang berhubungan dengan satu fitur ada di satu folder.

```text
lib/
├── main.dart
├── firebase_options.dart
├── config/                 # Konfigurasi Global (Routes, API URL, Themes)
│   ├── api_config.dart
│   └── routes.dart
├── core/                   # Code yang dipakai rame-rame di seluruh aplikasi
│   ├── constants/          # Warna, String tetap, Asset paths
│   ├── utils/              # Format tanggal, format currency
│   └── widgets/            # Widget umum (CustomButton, LoadingWidget)
├── data/                   # (Opsional) Service Global
│   ├── services/           # Http Client wrapper, LocalStorage service
│   └── models/             # Model umum (User, Token)
└── features/               # INTI APLIKASI DI SINI
    ├── auth/               # Fitur Login/Register
    │   ├── data/           # Auth Service, Auth Model
    │   └── presentation/   # Login Page, Register Page
    ├── admin_vehicle/      # Fitur Kelola Kendaraan (Admin)
    │   ├── data/
    │   │   ├── models/     # vehicle_model.dart (Class Vehicle)
    │   │   └── services/   # vehicle_service.dart (Isinya http.get vehicle)
    │   └── presentation/
    │       ├── screens/    # vehicle_page.dart (Isi UI saja)
    │       └── widgets/    # vehicle_stats_card.dart, vehicle_list_item.dart
    ├── admin_employee/     # Fitur Pegawai
    └── tracking/           # Fitur Peta & Lokasi
```

## 3. Contoh Implementasi Refactoring (`VehiclePage`)

Bagaimana mengubah code 400 baris menjadi bersih?

### Langkah 1: Buat Model (Data Layer)
Alih-alih pakai `vehicle['plate_number']`, kita buat Class.
```dart
// features/admin_vehicle/data/models/vehicle_model.dart
class Vehicle {
  final String id;
  final String plateNumber;
  final bool isActive;

  Vehicle({required this.id, required this.plateNumber, required this.isActive});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      plateNumber: json['plate_number'],
      isActive: json['is_active'],
    );
  }
}
```

### Langkah 2: Buat Service (Data Layer)
Pindahkan logic `http` keluar dari UI.
```dart
// features/admin_vehicle/data/services/vehicle_service.dart
class VehicleService {
  Future<List<Vehicle>> getVehicles() async {
    // Logic http.get, ambil token, json.decode di sini.
    // Return List<Vehicle>
  }
}
```

### Langkah 3: Bersihkan UI (Presentation Layer)
Di `vehicle_page.dart`, Anda tinggal panggil:
```dart
List<Vehicle> vehicles = await VehicleService().getVehicles();
```
Semua logic parsing JSON dan error handling API hilang dari UI. UI jadi jauh lebih pendek dan mudah dibaca.

## 4. Keuntungan
1.  **Mudah Dibaca**: Saat buka `vehicle_page.dart`, Anda cuma lihat desain. Mau lihat logic API? Buka `vehicle_service.dart`.
2.  **Reusable**: `VehicleService` bisa dipakai di halaman lain (misal halaman Dashboard) tanpa copy-paste kode `http` request.
3.  **Safety**: Dengan Model, kalau ada salah ketik nama field (`plate_number` vs `plateNumber`), error-nya ketahuan sebelum aplikasi dijalankan (compile time error).

## 5. Rencana Migrasi (Bertahap)
Anda tidak perlu ubah semua sekarang. Lakukan pelan-pelan:
1.  Buat folder `features` baru.
2.  Saat mau edit/fix bug di halaman tertentu (misal `VehiclePage`), baru lakukan refactor untuk halaman itu saja.
3.  Halaman lain biarkan dulu sampai giliran mereka diedit.
