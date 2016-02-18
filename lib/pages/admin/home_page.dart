import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
import 'package:flutter_application_1/pages/admin/home_admin.dart';
import 'package:flutter_application_1/pages/admin/screens/track_admin.dart';
import 'package:flutter_application_1/pages/admin/screens/info_admin.dart';
import 'package:flutter_application_1/pages/admin/screens/account_admin.dart';

/// Halaman Wrapper untuk Admin.
///
/// Halaman ini berfungsi sebagai wrapper utama untuk navigasi admin,
/// menampilkan BottomNavigationBar dengan beberapa menu dan menggunakan IndexedStack
/// untuk menjaga state setiap halaman saat berpindah tab.
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan di IndexedStack
  final List<Widget> _pages = [
    const HomeAdminPageContent(), // Beranda Admin
    const TrackAdminPageContent(), // Track Admin
    const InfoAdminPageContent(), // Info Admin
    const AccountAdminPageContent(), // Akun Admin
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            // Komentar: Ganti ikon Beranda di sini jika diperlukan
            icon: HugeIcon(icon: HugeIcons.strokeRoundedHome05),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            // Komentar: Ganti ikon Track di sini jika diperlukan
            icon: HugeIcon(icon: HugeIcons.strokeRoundedMapsLocation01),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            // Komentar: Ganti ikon Info di sini jika diperlukan
            icon: HugeIcon(icon: HugeIcons.strokeRoundedNotification01),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            // Komentar: Ganti ikon Akun di sini jika diperlukan
            icon: HugeIcon(icon: HugeIcons.strokeRoundedUserCircle),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Warna ikon yang dipilih
        unselectedItemColor: Colors.grey, // Warna ikon yang tidak dipilih
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Agar semua item terlihat
      ),
    );
  }
}
