import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class EmployeeTaskSummary extends StatelessWidget {
  const EmployeeTaskSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildTaskCard(
            title: "Tugas Hari Ini",
            count: "3",
            icon: HugeIcons.strokeRoundedTask01,
            colors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
            borderColor: const Color(0xFF1976D2),
            shadowColor: const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTaskCard(
            title: "Tugas Selesai",
            count: "5",
            icon: HugeIcons.strokeRoundedTaskDone01,
            colors: [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
            borderColor: const Color(0xFF2E7D32),
            shadowColor: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String count,
    required dynamic icon,
    required List<Color> colors,
    required Color borderColor,
    required Color shadowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: HugeIcon(
                icon: icon,
                color: Colors.white,
                size: 20,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count,
                    style: const TextStyle(
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
    );
  }
}
