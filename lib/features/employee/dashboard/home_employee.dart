import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/auth_storage.dart';
import 'widgets/employee_header.dart';
import 'widgets/employee_banner_slider.dart';
import 'widgets/employee_task_summary.dart';
import 'widgets/employee_menu_grid.dart';

import 'package:flutter_application_1/features/auth/login_page.dart';
import 'package:flutter_application_1/core/widgets/custom_confirmation_dialog.dart';
import 'package:flutter/scheduler.dart';

// ...

class HomeEmployeePage extends StatefulWidget {
  const HomeEmployeePage({super.key});

  @override
  State<HomeEmployeePage> createState() => _HomeEmployeePageState();
}

class _HomeEmployeePageState extends State<HomeEmployeePage> {
  late Future<Map<String, dynamic>> _loginDataFuture;

  @override
  void initState() {
    super.initState();
    _loginDataFuture = _checkSessionAndLoadData();
  }

  Future<Map<String, dynamic>> _checkSessionAndLoadData() async {
    final loginData = await AuthStorage().getLoginData();
    final token = loginData['token'];

    if (token == null) {
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _showSessionExpiredDialog();
        });
      }
      throw Exception("Sesi berakhir.");
    }
    return loginData;
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
      backgroundColor: const Color.fromARGB(255, 244, 249, 251),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loginDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final loginData = snapshot.data!;
            final user = loginData['user'] ?? {};
            final employee = user['employee'] ?? {};

            final String userName = user['name'] ?? 'N/A';
            final String employeeId = employee['employee_id'] ?? 'N/A';
            final String employeePosition = employee['position'] ?? 'N/A';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: kToolbarHeight),
                  EmployeeHeader(
                    userName: userName,
                    employeeId: employeeId,
                    employeePosition: employeePosition,
                  ),
                  const SizedBox(height: 24),
                  const EmployeeBannerSlider(),
                  const SizedBox(height: 24),
                  const EmployeeTaskSummary(),
                  const EmployeeMenuGrid(),
                ],
              ),
            );
          }
          return const Center(child: Text('No login data found.'));
        },
      ),
    );
  }
}
