import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class TrackMarkerBuilder {
  static DateTime? _parseDateTime(String? s) {
    if (s == null) return null;
    try {
      return DateTime.parse(s).toLocal();
    } catch (_) {
      return null;
    }
  }

  static String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  static Color _employeeStatusColor(String? lastUpdateStr) {
    final now = DateTime.now();
    final upd = _parseDateTime(lastUpdateStr);
    if (upd == null) return Colors.red;
    if (upd.year == now.year && upd.month == now.month && upd.day == now.day) {
      return Colors.green;
    }
    return Colors.red;
  }

  static Color _vehicleStatusColor(String? lastUpdateStr) {
    final now = DateTime.now();
    final upd = _parseDateTime(lastUpdateStr);
    if (upd == null) return Colors.red;
    final diff = now.difference(upd).inDays;
    return diff <= 2 ? Colors.green : Colors.red;
  }

  static Widget _buildMarkerIcon(IconData iconData, Color bgColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 32,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        Positioned(
          top: 6,
          child: Icon(iconData, color: Colors.white, size: 16),
        ),
      ],
    );
  }

  static void _showDetailDialog({
    required BuildContext ctx,
    required String title,
    required String subtitle,
    required String body,
    required Color accentColor,
    IconData? leadingIcon,
  }) {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 36),
                    padding: const EdgeInsets.fromLTRB(20, 46, 20, 20),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 12),
                        Text(body,
                            style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w400)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text('Tutup'),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: accentColor,
                    child: Icon(leadingIcon ?? Icons.info,
                        color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static List<Marker> buildMarkers({
    required List<dynamic> employees,
    required List<dynamic> vehicles,
    required BuildContext context,
  }) {
    final List<Marker> markers = [];

    // Employee markers
    for (var e in employees) {
      final latStr = e['latitude'];
      final lonStr = e['longitude'];
      if (latStr == null || lonStr == null) continue;
      final lat = double.tryParse(latStr.toString());
      final lon = double.tryParse(lonStr.toString());
      if (lat == null || lon == null) continue;

      final color = _employeeStatusColor(e['last_location_update']);
      final name = e['user']?['name'] ?? 'Employee';
      final dept = e['department'] ?? '-';
      final pos = e['position'] ?? '-';
      final phone = e['phone'] ?? '-';
      final lastUpd = _parseDateTime(e['last_location_update']);

      markers.add(
        Marker(
          point: LatLng(lat, lon),
          width: 32,
          height: 40,
          child: GestureDetector(
            onTap: () {
              _showDetailDialog(
                ctx: context,
                title: name,
                subtitle: '$dept • $pos',
                body:
                    'Nama: $name\nDepartemen: $dept\nPosisi: $pos\nTelepon: $phone\nLast update: ${_formatDateTime(lastUpd)}',
                accentColor: color,
                leadingIcon: Icons.person,
              );
            },
            child: _buildMarkerIcon(Icons.person, color),
          ),
        ),
      );
    }

    // Vehicle markers
    for (var v in vehicles) {
      final latStr = v['latitude'];
      final lonStr = v['longitude'];
      if (latStr == null || lonStr == null) continue;
      final lat = double.tryParse(latStr.toString());
      final lon = double.tryParse(lonStr.toString());
      if (lat == null || lon == null) continue;

      final color = _vehicleStatusColor(v['last_location_update']);
      final lastUpd = _parseDateTime(v['last_location_update']);
      final number = v['vehicle_number'] ?? '-';
      final type = v['vehicle_type'] ?? '-';
      final brand = v['brand'] ?? '-';
      final model = v['model'] ?? '-';

      markers.add(
        Marker(
          point: LatLng(lat, lon),
          width: 32,
          height: 40,
          child: GestureDetector(
            onTap: () {
              _showDetailDialog(
                ctx: context,
                title: number,
                subtitle: '$brand • $type',
                body:
                    'Nomor: $number\nTipe: $type\nMerek: $brand\nModel: $model\nLast update: ${_formatDateTime(lastUpd)}',
                accentColor: color,
                leadingIcon: Icons.directions_car,
              );
            },
            child: _buildMarkerIcon(Icons.directions_car, color),
          ),
        ),
      );
    }

    return markers;
  }
}