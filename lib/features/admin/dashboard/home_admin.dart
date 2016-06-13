import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../auth/auth_storage.dart';
import 'package:flutter_application_1/core/config/api_config.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_stats_grid.dart';
import 'widgets/admin_menu_grid.dart';
import 'package:flutter_application_1/features/auth/login_page.dart';
import 'package:flutter_application_1/core/widgets/custom_confirmation_dialog.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  late Future<Map<String, dynamic>> _loginDataFuture;
  late Future<Map<String, dynamic>> _dashboardStatsFuture;

  @override
  void initState() {
    super.initState();
    _loginDataFuture = AuthStorage().getLoginData();
    _dashboardStatsFuture = _loadDashboardData();
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    final loginData = await AuthStorage().getLoginData();
    final token = loginData['token'];

    if (token == null) {
      if (mounted) {
        _showSessionExpiredDialog();
      }
      throw Exception("Sesi berakhir. Harap login ulang.");
    }

    final response = await http.get(
      Uri.parse(ApiConfig.dashboardStats),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat data dashboard (${response.statusCode})');
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomConfirmationDialog(
        title: "Sesi Berakhir",
        message:
            "Sesi anda telah berakhir atau token hilang. Silakan login kembali.",
        confirmText: "Login Ulang",
        onConfirm: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loginDataFuture,
        builder: (context, loginSnapshot) {
          if (loginSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (loginSnapshot.hasError) {
            return Center(child: Text('Error: ${loginSnapshot.error}'));
          } else if (loginSnapshot.hasData) {
            final user = loginSnapshot.data!['user'] ?? {};
            final String adminName = user['name'] ?? 'Admin';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  AdminHeader(adminName: adminName),
                  const SizedBox(height: 24),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _dashboardStatsFuture,
                    builder: (context, statsSnapshot) {
                      if (statsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (statsSnapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${statsSnapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (statsSnapshot.hasData) {
                        return AdminStatsGrid(stats: statsSnapshot.data!);
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 32),
                  const AdminMenuGrid(),
                ],
              ),
            );
          }
          return const Center(child: Text('No admin data found.'));
        },
      ),
    );
  }
}
