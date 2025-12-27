import 'package:flutter/material.dart';

class AdminMenuGrid extends StatelessWidget {
  const AdminMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: [
          _buildMenuItem(
              context, "assets/images/icon-menu1.png", "Data Karyawan"),
          _buildMenuItem(
              context, "assets/images/icon-menu2.png", "Data Kendaraan"),
          _buildMenuItem(context, "assets/images/icon-menu3.png", "Absensi"),
          _buildMenuItem(context, "assets/images/icon-menu4.png", "Tugas"),
          _buildMenuItem(context, "assets/images/icon-menu5.png", "Laporan"),
          _buildMenuItem(context, "assets/images/icon-menu6.png", "Pengaturan"),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String assetPath, String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3 - 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (title == "Pengaturan") {
                Navigator.pushNamed(context, '/settings-admin');
              } else if (title == "Data Karyawan") {
                Navigator.pushNamed(context, '/employee-management');
              } else if (title == "Data Kendaraan") {
                Navigator.pushNamed(context, '/vehicle-management');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title diklik')),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Image.asset(
                assetPath,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
