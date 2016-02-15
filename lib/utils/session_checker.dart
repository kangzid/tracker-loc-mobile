import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/auth/auth_storage.dart';

class SessionChecker {
  /// Cek session dan redirect ke login jika expired
  static Future<bool> checkSession(BuildContext context) async {
    final bool isLoggedIn = await AuthStorage().isLoggedIn();
    
    if (!isLoggedIn && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return false;
    }
    
    return true;
  }
  
  /// Widget wrapper yang otomatis cek session
  static Widget withSessionCheck({
    required Widget child,
    required BuildContext context,
  }) {
    return FutureBuilder<bool>(
      future: checkSession(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.data == true) {
          return child;
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}