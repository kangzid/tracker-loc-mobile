import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class PresenceInfoCard extends StatelessWidget {
  final String name;
  final String employeeCode;
  final String position;
  final String todayAttendanceStatus;

  const PresenceInfoCard({
    super.key,
    required this.name,
    required this.employeeCode,
    required this.position,
    required this.todayAttendanceStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedUserCircle,
                  color: Colors.blue,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$employeeCode • $position',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Status Presensi: ",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              _buildStatusIndicator(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (todayAttendanceStatus == "success") {
      return Row(
        children: const [
          HugeIcon(
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            color: Colors.green,
            size: 16.0,
          ),
          SizedBox(width: 4),
          Text(
            "Sudah Presensi",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      );
    } else if (todayAttendanceStatus == "none") {
      return Row(
        children: const [
          HugeIcon(
            icon: HugeIcons.strokeRoundedCancelCircle,
            color: Colors.red,
            size: 16.0,
          ),
          SizedBox(width: 4),
          Text(
            "Belum Presensi",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      );
    } else if (todayAttendanceStatus == "error") {
      return Row(
        children: const [
          HugeIcon(
            icon: HugeIcons.strokeRoundedAlert02,
            color: Colors.orange,
            size: 16.0,
          ),
          SizedBox(width: 4),
          Text(
            "Error",
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    return Text(
      "...",
      style: TextStyle(color: Colors.grey.shade400),
    );
  }
}
