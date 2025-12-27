import 'package:flutter/material.dart';

class AdminHeader extends StatelessWidget {
  final String adminName;

  const AdminHeader({super.key, required this.adminName});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          backgroundImage: AssetImage("assets/images/admin-avatar.png"),
        ),
      ],
    );
  }
}
