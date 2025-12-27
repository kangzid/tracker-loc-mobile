import 'package:flutter/material.dart';

class AttendanceStatsCard extends StatelessWidget {
  final int present;
  final int late;
  final int absent;
  final int permission;

  const AttendanceStatsCard({
    super.key,
    required this.present,
    required this.late,
    required this.absent,
    required this.permission,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat("Hadir", present, Colors.green),
            _buildStat("Terlambat", late, Colors.orange),
            _buildStat("Absen", absent, Colors.red),
            _buildStat("Izin", permission, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
