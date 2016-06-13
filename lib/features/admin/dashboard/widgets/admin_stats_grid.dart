import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AdminStatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const AdminStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dashboardItems = [
      {
        'title': 'Total Karyawan',
        'value': stats['total_employees'].toString(),
        'icon': HugeIcons.strokeRoundedUserGroup,
        'color': const Color(0xFF2196F3) // Blue
      },
      {
        'title': 'Karyawan Aktif',
        'value': stats['active_employees'].toString(),
        'icon': HugeIcons.strokeRoundedUserCheck01,
        'color': const Color(0xFF4CAF50) // Green
      },
      {
        'title': 'Total Kendaraan',
        'value': stats['total_vehicles'].toString(),
        'icon': HugeIcons.strokeRoundedCar02,
        'color': const Color(0xFFFF9800) // Orange
      },
      {
        'title': 'Kendaraan Aktif',
        'value': stats['active_vehicles'].toString(),
        'icon': HugeIcons.strokeRoundedDeliveryTruck01,
        'color': const Color(0xFF009688) // Teal
      },
      {
        'title': 'Absensi Hari Ini',
        'value': stats['today_attendances'].toString(),
        'icon': HugeIcons.strokeRoundedCalendar03,
        'color': const Color(0xFF9C27B0) // Purple
      },
      {
        'title': 'Tugas Pending',
        'value': stats['pending_tasks'].toString(),
        'icon': HugeIcons.strokeRoundedTask01,
        'color': const Color(0xFFF44336) // Red
      },
    ];

    return GridView.builder(
      itemCount: dashboardItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12, // Increased spacing
        mainAxisSpacing: 12,
        childAspectRatio: 0.85, // Slightly taller for better vertical rhythm
      ),
      itemBuilder: (context, index) {
        final item = dashboardItems[index];
        return _buildModernCard(
          title: item['title'],
          value: item['value'],
          icon: item['icon'],
          color: item['color'],
        );
      },
    );
  }

  Widget _buildModernCard({
    required String title,
    required String value,
    required dynamic icon,
    required Color color,
  }) {
    return Container(
      clipBehavior: Clip.hardEdge, // Prevent overflow
      decoration: BoxDecoration(
        // Style: Soft Pastel / Bento
        color: color.withOpacity(0.08), // Light background matching the color
        borderRadius: BorderRadius.circular(24), // More rounded
        border: Border.all(
            color: color.withOpacity(0.1), width: 1), // Very subtle border
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorative circle
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon (Floating style)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: HugeIcon(
                    icon: icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 10),

                // Value
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.5),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
