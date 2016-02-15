import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../auth/auth_storage.dart';

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
      throw Exception("Token tidak ditemukan. Harap login ulang.");
    }

    final response = await http.get(
      Uri.parse('https://locatrack.zalfyan.my.id/api/dashboard/stats'),
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat datang,",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            adminName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Administrator • Dashboard",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 28,
                        backgroundImage:
                            AssetImage("assets/images/pas-foto.png"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // =========================
// 📊 Dashboard Grid Modern
// =========================
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
                        final stats = statsSnapshot.data!;

                        final List<Map<String, dynamic>> dashboardItems = [
                          {
                            'title': 'Total Karyawan',
                            'value': stats['total_employees'].toString(),
                            'icon': Icons.people_alt_rounded,
                            'color': Colors.blue
                          },
                          {
                            'title': 'Karyawan Aktif',
                            'value': stats['active_employees'].toString(),
                            'icon': Icons.verified_user_rounded,
                            'color': Colors.green
                          },
                          {
                            'title': 'Total Kendaraan',
                            'value': stats['total_vehicles'].toString(),
                            'icon': Icons.directions_car_filled_rounded,
                            'color': Colors.orange
                          },
                          {
                            'title': 'Kendaraan Aktif',
                            'value': stats['active_vehicles'].toString(),
                            'icon': Icons.local_shipping_rounded,
                            'color': Colors.teal
                          },
                          {
                            'title': 'Absensi Hari Ini',
                            'value': stats['today_attendances'].toString(),
                            'icon': Icons.event_available_rounded,
                            'color': Colors.purple
                          },
                          {
                            'title': 'Tugas Pending',
                            'value': stats['pending_tasks'].toString(),
                            'icon': Icons.pending_actions_rounded,
                            'color': Colors.redAccent
                          },
                        ];

                        return GridView.builder(
                          itemCount: dashboardItems.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // ✅ 3 kolom
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio:
                                0.9, // ✅ agar bentuk kotaknya sedikit vertikal
                          ),
                          itemBuilder: (context, index) {
                            final item = dashboardItems[index];
                            return _buildModernCard(
                              title: item['title'],
                              value: item['value'],
                              icon: item['icon'],
                              color: item['color'],
                            );
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),

                  const SizedBox(height: 32),

                  // Menu Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: [
                        _buildMenuItem(
                            "assets/images/icon-menu1.png", "Data Karyawan"),
                        _buildMenuItem(
                            "assets/images/icon-menu2.png", "Data Kendaraan"),
                        _buildMenuItem(
                            "assets/images/icon-menu3.png", "Absensi"),
                        _buildMenuItem("assets/images/icon-menu4.png", "Tugas"),
                        _buildMenuItem(
                            "assets/images/icon-menu5.png", "Laporan"),
                        _buildMenuItem(
                            "assets/images/icon-menu6.png", "Pengaturan"),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No admin data found.'));
        },
      ),
    );
  }

  // Modern Dashboard Card
  Widget _buildModernCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Icon besar transparan background
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              icon,
              size: 60,
              color: color.withOpacity(0.07),
            ),
          ),

          // Konten utama di tengah
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String assetPath, String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3 - 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title diklik')),
                  );
                },
                child: Center(
                  child: Image.asset(
                    assetPath,
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
