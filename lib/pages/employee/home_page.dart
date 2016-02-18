import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/employee/screens/account_employee.dart';
import 'package:flutter_application_1/pages/employee/screens/home_employee.dart';
import 'package:flutter_application_1/pages/employee/screens/info_employee.dart';
import 'package:flutter_application_1/pages/employee/screens/presence_employee.dart';
import 'package:flutter_application_1/pages/employee/screens/track_employee.dart';
import 'package:hugeicons/hugeicons.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  int _selectedIndex = 0;

  // List of pages for the Bottom Navigation Bar
  // Using IndexedStack to preserve the state of each page
  // To add a new menu, add a new page to this list
  final List<Widget> _pages = [
    const HomeEmployeePage(),
    const TrackEmployeeScreen(),
    const PresenceEmployeePage(),
    const InfoEmployeePage(),
    const AccountEmployeePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar can be added here if needed, but the request implies only body changes
      // appBar: AppBar(
      //   title: const Text('Employee Dashboard'),
      //   backgroundColor: Colors.blueAccent,
      // ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          // Beranda Menu
          BottomNavigationBarItem(
            // TODO: Replace with custom icon from hugeicons.com/icon
            // Example: Image.asset('assets/icons/employee/home_icon.png', width: 24, height: 24)
            icon: HugeIcon(icon: HugeIcons.strokeRoundedHome05),
            label: 'Beranda',
          ),
          // Track Menu
          BottomNavigationBarItem(
            // TODO: Replace with custom icon from hugeicons.com/icon
            // Example: Image.asset('assets/icons/employee/track_icon.png', width: 24, height: 24)
            icon: HugeIcon(icon: HugeIcons.strokeRoundedMapsLocation01),
            label: 'Track',
          ),
          // Presensi Menu
          BottomNavigationBarItem(
            // TODO: Replace with custom icon from hugeicons.com/icon
            // Example: Image.asset('assets/icons/employee/presence_icon.png', width: 24, height: 24)
            icon: HugeIcon(icon: HugeIcons.strokeRoundedFingerprintScan),
            label: 'Presensi',
          ),
          // Info Menu
          BottomNavigationBarItem(
            // TODO: Replace with custom icon from hugeicons.com/icon
            // Example: Image.asset('assets/icons/employee/info_icon.png', width: 24, height: 24)
            icon: HugeIcon(icon: HugeIcons.strokeRoundedNotification01),
            label: 'Info',
          ),
          // Akun Menu
          BottomNavigationBarItem(
            // TODO: Replace with custom icon from hugeicons.com/icon
            // Example: Image.asset('assets/icons/employee/account_icon.png', width: 24, height: 24)
            icon: HugeIcon(icon: HugeIcons.strokeRoundedUserCircle),
            label: 'Akun',
          ),
          // To add a new menu, uncomment and modify the following:
          /*
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'New Menu',
          ),
          */
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Customize selected item color
        unselectedItemColor: Colors.grey, // Customize unselected item color
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
      ),
    );
  }
}
