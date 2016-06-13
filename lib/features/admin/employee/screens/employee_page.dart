import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/employee_list_widget.dart';
import 'package:flutter_application_1/core/config/api_config.dart';
import 'package:flutter_application_1/features/admin/shared/admin_menu_card.dart';
import 'package:flutter_application_1/features/admin/shared/admin_stat_card.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_application_1/core/widgets/custom_app_bar.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  List<dynamic> _employees = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchEmployees() async {
    setState(() => _loading = true);
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.employees),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _employees = data is List ? data : (data['data'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error fetching employees: $e");
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  int _getActiveEmployees() {
    // Simulasi: hitung karyawan aktif (bisa disesuaikan dengan logika real)
    return _employees.length;
  }

  int _getDepartmentCount() {
    // Hitung jumlah departemen unik
    final departments = _employees
        .map((e) => e['department'])
        .where((d) => d != null && d.toString().isNotEmpty)
        .toSet();
    return departments.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: "Data Karyawan",
        showBackButton: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedRefresh,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              onPressed: _fetchEmployees,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Memuat data karyawan...",
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchEmployees,
              color: Colors.blue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistik Cards
                    const Text(
                      "Statistik",
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AdminStatCard(
                            icon: HugeIcons.strokeRoundedUserGroup,
                            title: "Total Karyawan",
                            value: "${_employees.length}",
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AdminStatCard(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                            title: "Aktif",
                            value: "${_getActiveEmployees()}",
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AdminStatCard(
                            icon: HugeIcons.strokeRoundedBuilding02,
                            title: "Departemen",
                            value: "${_getDepartmentCount()}",
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AdminStatCard(
                            icon: HugeIcons.strokeRoundedCalendar03,
                            title: "Hadir Hari Ini",
                            value: "${(_employees.length * 0.85).toInt()}",
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Menu Section
                    const Text(
                      "Menu",
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    AdminMenuCard(
                      icon: HugeIcons.strokeRoundedUserSearch01,
                      title: "Data Karyawan",
                      subtitle: "Lihat dan kelola data lengkap karyawan",
                      color: Colors.blue,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => EmployeeListWidget(
                            employees: _employees,
                            onRefresh: _fetchEmployees,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    AdminMenuCard(
                      icon: HugeIcons.strokeRoundedTaskDaily01,
                      title: "Laporan Kehadiran",
                      subtitle: "Rekap absensi dan kehadiran karyawan",
                      color: Colors.green,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Fitur laporan kehadiran segera hadir'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    AdminMenuCard(
                      icon: HugeIcons.strokeRoundedTime02,
                      title: "Jam Kerja",
                      subtitle: "Atur dan lihat jadwal kerja karyawan",
                      color: Colors.orange,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Fitur jam kerja segera hadir'),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    AdminMenuCard(
                      icon: HugeIcons.strokeRoundedAnalytics01,
                      title: "Performa Karyawan",
                      subtitle: "Analisis kinerja dan produktivitas",
                      color: Colors.purple,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Fitur performa karyawan segera hadir'),
                            backgroundColor: Colors.purple,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    AdminMenuCard(
                      icon: HugeIcons.strokeRoundedAllBookmark,
                      title: "Dokumen Karyawan",
                      subtitle: "Kelola dokumen dan berkas penting",
                      color: Colors.teal,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Fitur dokumen karyawan segera hadir'),
                            backgroundColor: Colors.teal,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    AdminMenuCard(
                      icon: HugeIcons.strokeRoundedCalendar03,
                      title: "Cuti & Izin",
                      subtitle: "Kelola permohonan cuti dan izin",
                      color: Colors.red,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Fitur cuti & izin segera hadir'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => EmployeeListWidget(
              employees: _employees,
              onRefresh: _fetchEmployees,
            ),
          );
        },
        backgroundColor: Colors.blue,
        elevation: 4,
        icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedSettings01,
            color: Colors.white,
            size: 24),
        label: const Text(
          'Kelola Karyawan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
