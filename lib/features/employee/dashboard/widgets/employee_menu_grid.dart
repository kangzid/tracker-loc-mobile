import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/employee/attendance/screens/attendance_employee.dart';

class EmployeeMenuGrid extends StatelessWidget {
  const EmployeeMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 4, right: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: [
          _buildMenuItem(
            context,
            "assets/images/icon-menu1.png",
            "Kehadiran",
            () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AttendanceEmployeePage()),
            ),
          ),
          _buildMenuItem(
            context,
            "assets/images/icon-menu2.png",
            "Menu 2",
            () => _showSnackBar(context, "Menu 2 diklik"),
          ),
          _buildMenuItem(
            context,
            "assets/images/icon-menu3.png",
            "Menu 3",
            () => _showSnackBar(context, "Menu 3 diklik"),
          ),
          _buildMenuItem(
            context,
            "assets/images/icon-menu4.png",
            "Menu 4",
            () => _showSnackBar(context, "Menu 4 diklik"),
          ),
          _buildMenuItem(
            context,
            "assets/images/icon-menu5.png",
            "Menu 5",
            () => _showSnackBar(context, "Menu 5 diklik"),
          ),
          _buildMenuItem(
            context,
            "assets/images/icon-menu6.png",
            "Menu 6",
            () => _showSnackBar(context, "Menu 6 diklik"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildMenuItem(BuildContext context, String assetPath, String title,
      VoidCallback onTap) {
    final width = MediaQuery.of(context).size.width / 3 - 20;

    return SizedBox(
      width: width,
      child: Column(
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
                  color: Colors.blue.withOpacity(0.2),
                  width: 1.5,
                ),
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
      ),
    );
  }
}
