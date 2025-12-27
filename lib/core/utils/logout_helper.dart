import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/auth_storage.dart';
import 'package:flutter_application_1/core/widgets/custom_confirmation_dialog.dart';
import 'package:flutter_application_1/features/auth/login_page.dart';

class LogoutHelper {
  /// Fungsi logout dengan konfirmasi dialog
  static Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomConfirmationDialog(
          title: 'Keluar',
          message:
              'Apakah anda yakin ingin keluar dari Aplikasi Staff Tracker?',
          confirmText: 'YA',
          cancelText: 'TIDAK',
          onConfirm: () async {
            await performLogout(context);
          },
          onCancel: () {}, // Trigger close
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
