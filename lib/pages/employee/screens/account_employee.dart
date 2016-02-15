import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/auth/auth_storage.dart';
import 'package:flutter_application_1/utils/logout_helper.dart';
import 'package:hugeicons/hugeicons.dart';

class AccountEmployeePage extends StatefulWidget {
  const AccountEmployeePage({super.key});

  @override
  State<AccountEmployeePage> createState() => _AccountEmployeePageState();
}

class _AccountEmployeePageState extends State<AccountEmployeePage> {
  String? _name;
  String? _email;
  String? _position;
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await AuthStorage().getLoginData();
    final user = data['user'];
    final employee = user['employee'];

    setState(() {
      _name = user['name'];
      _email = user['email'];
      _employeeId = employee['employee_id'];
      _position = employee['position'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Akun"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Profile Karyawan
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundImage:
                              AssetImage("assets/images/pas-foto.png"),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name ?? "Loading...",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "ID: ${_employeeId ?? '...'}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "Divisi: ${_position ?? '...'}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Status Karyawan",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Aktif",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Menu ListTile
            ListTile(
              leading:
                  HugeIcon(icon: HugeIcons.strokeRoundedStudentCard, size: 28),
              title: const Text("Kartu Karyawan Elektronik"),
              subtitle: Text("ID Karyawan: ${_employeeId ?? '...'}"),
            ),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedMail01, size: 28),
              title: const Text("Email Perusahaan"),
              subtitle: Text(_email ?? "..."),
            ),
            ListTile(
              leading: HugeIcon(
                  icon: HugeIcons.strokeRoundedCertificate01, size: 28),
              title: const Text("Sertifikat & Training"),
              subtitle: const Text("Lihat riwayat training"),
            ),

            const SizedBox(height: 12),

            // Section Atasan / HRD
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Atasan / HRD",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedUser, size: 28),
              title: const Text("Nama Atasan"),
              subtitle: const Text("Manager Divisi"),
            ),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedMail01, size: 28),
              title: const Text("Email Atasan"),
              subtitle: const Text("manager@company.com"),
            ),
            ListTile(
              leading:
                  HugeIcon(icon: HugeIcons.strokeRoundedContact02, size: 28),
              title: const Text("Telepon Atasan"),
              subtitle: const Text("+62 8123456789"),
            ),

            const SizedBox(height: 12),

            // Section Personalisasi
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Personalisasi",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SwitchListTile(
              value: false,
              onChanged: (val) {},
              secondary:
                  HugeIcon(icon: HugeIcons.strokeRoundedMoon01, size: 22),
              title: const Text("Mode Gelap"),
            ),
            SwitchListTile(
              value: true,
              onChanged: (val) {},
              secondary: HugeIcon(icon: HugeIcons.strokeRoundedGrid, size: 22),
              title: const Text("Tampilan Garis Tepi"),
            ),

            const SizedBox(height: 24),
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => LogoutHelper.showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
