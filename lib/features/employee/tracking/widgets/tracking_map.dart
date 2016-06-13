import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackingMap extends StatelessWidget {
  final MapController mapController;
  final LatLng currentLatLng;
  final Marker? currentLocationMarker;

  const TrackingMap({
    super.key,
    required this.mapController,
    required this.currentLatLng,
    this.currentLocationMarker,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: currentLatLng,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.app',
            ),
            if (currentLocationMarker != null)
              MarkerLayer(markers: [currentLocationMarker!]),
          ],
        ),
      ),
    );
  }
}
