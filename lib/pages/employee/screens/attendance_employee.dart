import 'package:flutter/material.dart';

class AttendanceEmployeePage extends StatelessWidget {
  const AttendanceEmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kehadiran Saya"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: const Center(
        child: Text(
          "Halaman Kehadiran Karyawan",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
