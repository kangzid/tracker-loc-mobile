// lib/main.dart
// File ini hanya untuk routing awal dan pengaturan dasar aplikasi.
// Jangan letakkan kode halaman Home di sini.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/pages/admin/home_page.dart';
import 'package:flutter_application_1/pages/employee/home_page.dart';
import 'package:flutter_application_1/pages/auth/login_page.dart';
import 'package:flutter_application_1/pages/admin/screens/geofence_page.dart';
import 'package:flutter_application_1/pages/admin/screens/settings_admin.dart';
import 'package:flutter_application_1/pages/admin/screens/employee_page.dart';
import 'package:flutter_application_1/pages/admin/screens/vehicle_page.dart';
import 'package:flutter_application_1/config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ApiConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialPage =
      const CircularProgressIndicator(); // Tampilkan loading saat memeriksa token

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Initialize Firebase Remote Config
    await ApiConfig.initialize();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? role = prefs.getString('user_role');

    setState(() {
      if (token != null && role != null) {
        // Jika token dan role ada, arahkan ke halaman Home yang sesuai
        if (role == 'admin') {
          _initialPage = const AdminHomePage();
          // Komentar: Jika ingin menambahkan role baru (misal: 'manager'), tambahkan kondisi di sini:
          // else if (role == 'manager') {
          //   _initialPage = const ManagerHomePage();
          // }
        } else if (role == 'employee') {
          _initialPage = const EmployeeHomePage();
        } else {
          // Jika role tidak dikenali, arahkan ke halaman Login
          _initialPage = const LoginPage();
        }
      } else {
        // Jika tidak ada token, arahkan ke halaman Login
        _initialPage = const LoginPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff Tracker', // Nama aplikasi yang sudah diubah
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _initialPage, // Halaman awal berdasarkan status login dan role
      routes: {
        '/geofence': (context) => const GeofencePage(),
        '/settings-admin': (context) => const SettingsAdminPage(),
        '/employee': (context) => const EmployeePage(),
        '/vehicle': (context) => const VehiclePage(),
      },
    );
  }
}

// Hapus kelas MyHomePage dan _MyHomePageState karena halaman Home sudah dipisahkan per role.
