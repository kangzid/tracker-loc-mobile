import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/auth/auth_storage.dart';
import 'package:flutter_application_1/pages/auth/login_page.dart';

class LogoutHelper {
  /// Fungsi logout dengan konfirmasi dialog
  static Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop();
                await performLogout(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// Fungsi logout langsung tanpa konfirmasi
  static Future<void> performLogout(BuildContext context) async {
    await AuthStorage().clearLoginData();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }
}