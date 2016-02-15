import 'package:flutter/material.dart';
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

                  // Banner Slider
                  SizedBox(
                    height: 130.0,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 3,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/benner-home.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Dot Indicator
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start, // rata kiri
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8), // kasih jarak biar rapi
                        child: Row(
                          children: List.generate(3, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 12 : 8,
                              height: _currentPage == index ? 12 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colors.blue
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Fake Widget untuk Tugas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12), // <--- diperkecil
                            child: Column(
                              children: const [
                                Text("Tugas Hari Ini",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black54)),
                                SizedBox(
                                    height: 4), // jarak teks & angka diperkecil
                                Text("3",
                                    style: TextStyle(
                                        fontSize: 22, // sedikit kecil
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // diperkecil dari 12
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Column(
                              children: const [
                                Text("Tugas Selesai",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black54)),
                                SizedBox(height: 4),
                                Text("5",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

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
        _buildMenuCard(assetPath, onTap),
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
