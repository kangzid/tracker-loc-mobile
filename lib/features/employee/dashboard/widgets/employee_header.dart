import 'package:flutter/material.dart';

class EmployeeHeader extends StatelessWidget {
  final String userName;
  final String employeeId;
  final String employeePosition;

  const EmployeeHeader({
    super.key,
    required this.userName,
    required this.employeeId,
    required this.employeePosition,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          backgroundImage: AssetImage("assets/images/pas-foto.png"),
        ),
      ],
    );
  }
}
