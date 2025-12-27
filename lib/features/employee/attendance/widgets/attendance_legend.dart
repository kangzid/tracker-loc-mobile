import 'package:flutter/material.dart';

class AttendanceLegend extends StatelessWidget {
  const AttendanceLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildLegend(Colors.green, "Hadir"),
        _buildLegend(Colors.orange, "Terlambat"),
        _buildLegend(Colors.red, "Tidak Hadir"),
        _buildLegend(Colors.grey, "Izin / Tidak Ada Data"),
      ],
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
