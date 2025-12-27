import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PresenceMap extends StatelessWidget {
  final MapController mapController;
  final LatLng currentLatLng;
  final Marker? currentLocationMarker;

  const PresenceMap({
    super.key,
    required this.mapController,
    required this.currentLatLng,
    this.currentLocationMarker,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: currentLatLng,
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
            if (currentLocationMarker != null)
              MarkerLayer(markers: [currentLocationMarker!]),
          ],
        ),
      ),
    );
  }
}
