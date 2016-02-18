import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../auth/auth_storage.dart'; // Import auth_storage.dart

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
                        backgroundColor: Colors.grey,
                        child:
                            Icon(Icons.person, color: Colors.white, size: 30),
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

                  // Grid Menu
                  Text(
                    'Fitur Utama',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3, // Changed to 3 columns
                    childAspectRatio: 1.0, // Adjusted for more square boxes
                    crossAxisSpacing: 8, // Reduced spacing
                    mainAxisSpacing: 8, // Reduced spacing
                    children: [
                      _buildMenuColumn(
                          HugeIcon(
                              icon: HugeIcons.strokeRoundedHome01,
                              size: 40,
                              color: Colors.blue),
                          'MENU1'),
                      _buildMenuColumn(
                          HugeIcon(
                              icon: HugeIcons.strokeRoundedSettings01,
                              size: 40,
                              color: Colors.blue),
                          'MENU2'),
                      _buildMenuColumn(
                          HugeIcon(
                              icon: HugeIcons.strokeRoundedChart01,
                              size: 40,
                              color: Colors.blue),
                          'MENU3'),
                      _buildMenuColumn(
                          HugeIcon(
                              icon: HugeIcons.strokeRoundedChart01,
                              size: 40,
                              color: Colors.blue),
                          'MENU4'),
                      _buildMenuColumn(
                          HugeIcon(
                              icon: HugeIcons.strokeRoundedCalendar01,
                              size: 40,
                              color: Colors.blue),
                          'MENU5'),
                      _buildMenuColumn(
                          HugeIcon(
                              icon: HugeIcons.strokeRoundedChart01,
                              size: 40,
                              color: Colors.blue),
                          'MENU6'),
                    ],
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No login data found.'));
        },
      ),
    );
  }

  Widget _buildMenuCard(Widget iconWidget) {
    return SizedBox(
      width: 80, // Fixed width for the card
      height: 80, // Fixed height for the card to make it square
      child: Card(
        elevation:
            0, // <--- Change this to 0 to remove the shadow, or a higher number for more shadow
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                25)), // <--- Change '0' to adjust roundedness (e.g., 8 for slightly rounded, 20 for more rounded)
        color: const Color.fromARGB(255, 255, 255, 255),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Menu tapped!')),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40, // Keep icon size consistent
                height: 40, // Keep icon size consistent
                child: iconWidget,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuColumn(Widget iconWidget, String title) {
    return Column(
      children: [
        _buildMenuCard(iconWidget), // Card is now fixed size
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12, // Smaller font size for outside text
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
