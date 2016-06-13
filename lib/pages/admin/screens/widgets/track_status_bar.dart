import 'package:flutter/material.dart';

class TrackStatusBar extends StatelessWidget {
  final bool loading;
  final String? error;
  final int employeeCount;
  final int vehicleCount;
  final VoidCallback onRefresh;

  const TrackStatusBar({
    super.key,
    required this.loading,
    this.error,
    required this.employeeCount,
    required this.vehicleCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      top: 12,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Memuat lokasi...',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
            ] else if (error != null) ...[
              const Icon(Icons.error_outline, color: Colors.redAccent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  error!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else ...[
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.blueAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Employees: $employeeCount • Vehicles: $vehicleCount',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: Colors.black87,
                ),
              ),
            ],
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRefresh,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.blueAccent,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}