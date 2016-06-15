import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../auth/auth_storage.dart'; // Import auth_storage.dart
import 'attendance_employee.dart';

class HomeEmployeePage extends StatefulWidget {
  const HomeEmployeePage({super.key});

  @override
  State<HomeEmployeePage> createState() => _HomeEmployeePageState();
}

class _HomeEmployeePageState extends State<HomeEmployeePage> {
  late Future<Map<String, dynamic>> _loginDataFuture;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loginDataFuture = AuthStorage().getLoginData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '$employeeId • $employeePosition',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            AssetImage("assets/images/pas-foto.png"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Banner Slider dengan OverflowBox (Edge-to-Edge)
                  SizedBox(
                    height:
                        157.43, // Proporsi 1400x600 = 7:3 ratio → untuk lebar ~400px = 171.43px tinggi
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return OverflowBox(
                          maxWidth: constraints.maxWidth +
                              32, // tambah 16 kiri + 16 kanan
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: 3,
                            padEnds: false, // Banner bisa mentok tepi
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return AnimatedBuilder(
                                animation: _pageController,
                                builder: (context, child) {
                                  // Efek floating (depth)
                                  double value = 1.0;
                                  if (_pageController.position.haveDimensions) {
                                    value = _pageController.page! - index;
                                    value = (1 - (value.abs() * 0.3))
                                        .clamp(0.0, 1.0);
                                  }

                                  // Hitung apakah ini banner pertama atau terakhir
                                  final isFirst = index == 0;
                                  final isLast = index == 2;

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: isFirst
                                          ? 16
                                          : 8, // Banner pertama ada padding kiri
                                      right: isLast
                                          ? 16
                                          : 8, // Banner terakhir ada padding kanan
                                    ),
                                    child: Transform.scale(
                                      scale: Curves.easeOut.transform(value),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          'assets/images/benner-home.png',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

// Dot Indicator (Posisi Kiri)
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // 👈 Ubah ke kiri
                      children: List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(
                              right: 6), // Jarak antar dot
                          width: _currentPage == index
                              ? 24
                              : 8, // Dot aktif lebih panjang
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? const Color(
                                    0xFF4B3B47) // Warna aktif (sesuai tema app)
                                : Colors.grey.shade300, // Warna non-aktif
                            borderRadius:
                                BorderRadius.circular(4), // Rounded rectangle
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Modern Task Cards dengan Icon di Samping (Compact untuk HP)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card Tugas Hari Ini
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF1976D2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2196F3).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                // Icon Container
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedTask01,
                                    color: Colors.white,
                                    size: 20,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Text Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        "Tugas Hari Ini",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        "3",
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Card Tugas Selesai
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF2E7D32),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                // Icon Container
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedTaskDone01,
                                    color: Colors.white,
                                    size: 20,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Text Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        "Tugas Selesai",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        "5",
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

// Menu Grid (Tanpa Shadow + Border Biru Tipis)
                  Padding(
                    padding: const EdgeInsets.only(top: 28, left: 4, right: 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: [
                        // 1️⃣ Kehadiran
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3 - 20,
                          child: _buildMenuColumn(
                            "assets/images/icon-menu1.png",
                            "Kehadiran",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AttendanceEmployeePage(),
                                ),
                              );
                            },
                          ),
                        ),

                        // 2️⃣ Menu 2
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3 - 20,
                          child: _buildMenuColumn(
                            "assets/images/icon-menu2.png",
                            "Menu 2",
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Menu 2 diklik")),
                              );
                            },
                          ),
                        ),

                        // 3️⃣ Menu 3
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3 - 20,
                          child: _buildMenuColumn(
                            "assets/images/icon-menu3.png",
                            "Menu 3",
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Menu 3 diklik")),
                              );
                            },
                          ),
                        ),

                        // 4️⃣ Menu 4
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3 - 20,
                          child: _buildMenuColumn(
                            "assets/images/icon-menu4.png",
                            "Menu 4",
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Menu 4 diklik")),
                              );
                            },
                          ),
                        ),

                        // 5️⃣ Menu 5
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3 - 20,
                          child: _buildMenuColumn(
                            "assets/images/icon-menu5.png",
                            "Menu 5",
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Menu 5 diklik")),
                              );
                            },
                          ),
                        ),

                        // 6️⃣ Menu 6
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3 - 20,
                          child: _buildMenuColumn(
                            "assets/images/icon-menu6.png",
                            "Menu 6",
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Menu 6 diklik")),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
          return const Center(child: Text('No login data found.'));
        },
      ),
    );
  }

  Widget _buildMenuCard(String assetPath, VoidCallback onTap) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap, // 🔥 Panggil callback di sini
          child: Center(
            child: Image.asset(
              assetPath,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuColumn(String assetPath, String title, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.blue.withOpacity(0.2), // 👈 Border biru tipis
                width: 1.5,
              ),
              // ❌ HAPUS boxShadow/elevation
            ),
            child: Image.asset(
              assetPath,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
