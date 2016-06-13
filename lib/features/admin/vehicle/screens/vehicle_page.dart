import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/vehicle_list_widget.dart';
import 'package:flutter_application_1/core/config/api_config.dart';
import 'package:flutter_application_1/features/admin/shared/admin_menu_card.dart';
import 'package:flutter_application_1/features/admin/shared/admin_stat_card.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_application_1/core/widgets/custom_app_bar.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  List<dynamic> _vehicles = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchVehicles() async {
    setState(() => _loading = true);
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.vehicles),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _vehicles = data is List ? data : (data['data'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error fetching vehicles: $e");
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  int _getActiveVehicles() {
    return _vehicles.where((v) => v['is_active'] == true).length;
  }

  int _getVehicleTypes() {
    final types = _vehicles
        .map((v) => v['vehicle_type'])
        .where((t) => t != null && t.toString().isNotEmpty)
        .toSet();
    return types.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: "Data Kendaraan",
        showBackButton: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedRefresh,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              onPressed: _fetchVehicles,
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
                    "Memuat data kendaraan...",
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchVehicles,
              color: Colors.orange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            icon: HugeIcons.strokeRoundedCar02,
                            title: "Total Kendaraan",
                            value: "${_vehicles.length}",
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AdminStatCard(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                            title: "Aktif",
                            value: "${_getActiveVehicles()}",
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
                            icon: HugeIcons.strokeRoundedDashboardSquare01,
                            title: "Tipe Kendaraan",
                            value: "${_getVehicleTypes()}",
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AdminStatCard(
                            icon: HugeIcons.strokeRoundedLocation01,
                            title: "Sedang Beroperasi",
                            value: "${(_getActiveVehicles() * 0.8).toInt()}",
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
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
                      icon: HugeIcons.strokeRoundedCar03,
                      title: "Data Kendaraan",
                      subtitle: "Lihat dan kelola data lengkap kendaraan",
                      color: Colors.orange,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => VehicleListWidget(
                            vehicles: _vehicles,
                            onRefresh: _fetchVehicles,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AdminMenuCard(
                      icon: HugeIcons
                          .strokeRoundedMaps, // Replaced strokeRoundedMap01
                      title: "Tracking Kendaraan",
                      subtitle: "Pantau lokasi kendaraan secara real-time",
                      color: Colors.blue,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Fitur tracking kendaraan segera hadir'),
                            backgroundColor: Colors.blue,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AdminMenuCard(
                      icon: HugeIcons.strokeRoundedTime02,
                      title: "Riwayat Perjalanan",
                      subtitle: "Lihat histori perjalanan kendaraan",
                      color: Colors.green,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Fitur riwayat perjalanan segera hadir'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AdminMenuCard(
                      icon: HugeIcons.strokeRoundedWrench01,
                      title: "Maintenance",
                      subtitle: "Jadwal dan riwayat perawatan kendaraan",
                      color: Colors.red,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Fitur maintenance segera hadir'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => VehicleListWidget(
              vehicles: _vehicles,
              onRefresh: _fetchVehicles,
            ),
          );
        },
        backgroundColor: Colors.orange,
        elevation: 4,
        icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedSettings01,
            color: Colors.white,
            size: 24),
        label: const Text(
          'Kelola Kendaraan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
