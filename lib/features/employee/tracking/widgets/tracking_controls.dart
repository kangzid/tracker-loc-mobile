import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class TrackingControls extends StatelessWidget {
  final bool isAutoTracking;
  final String lastUpdateStatus;
  final VoidCallback onUpdateLocation;
  final ValueChanged<bool> onToggleAutoTracking;

  const TrackingControls({
    super.key,
    required this.isAutoTracking,
    required this.lastUpdateStatus,
    required this.onUpdateLocation,
    required this.onToggleAutoTracking,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tombol Update Lokasi
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: onUpdateLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedGps01,
                  color: Colors.white,
                  size: 18.0,
                ),
                SizedBox(width: 8),
                Text(
                  'Update Lokasi Sekarang',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Card Auto Tracking
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                // Toggle Auto Tracking
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isAutoTracking
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedLocation01,
                        color: isAutoTracking
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Auto Tracking',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Switch(
                      value: isAutoTracking,
                      onChanged: onToggleAutoTracking,
                      activeColor: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 14),

                // Status Info
                _buildInfoRow(
                  'Status Auto',
                  isAutoTracking ? 'ON' : 'OFF',
                  isAutoTracking ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  'Lokasi Terakhir',
                  lastUpdateStatus,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: valueColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
