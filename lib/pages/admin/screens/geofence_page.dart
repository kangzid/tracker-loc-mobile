import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeofencePage extends StatefulWidget {
  const GeofencePage({super.key});

  @override
  State<GeofencePage> createState() => _GeofencePageState();
}

class _GeofencePageState extends State<GeofencePage> {
  final MapController _mapController = MapController();
  List<dynamic> _geofences = [];
  LatLng? _selectedPoint;

  bool _loading = false;
  final String baseUrl = "https://locatrack.zalfyan.my.id/api/geofences";

  @override
  void initState() {
    super.initState();
    _fetchGeofences();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchGeofences() async {
    setState(() => _loading = true);
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _geofences = data['data'] ?? data; // tergantung format API kamu
        });
      } else {
        debugPrint("Failed to fetch geofences: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching geofences: $e");
    }
    setState(() => _loading = false);
  }

  Future<void> _createGeofence(
      String name, double lat, double lng, double radius, String type) async {
    final token = await _getToken();
    final body = {
      "name": name,
      "center_lat": lat,
      "center_lng": lng,
      "radius": radius,
      "type": type,
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geofence berhasil dibuat!')),
        );
        _fetchGeofences();
      } else {
        debugPrint("Failed to create geofence: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error creating geofence: $e");
    }
  }

  Future<void> _deleteGeofence(int id) async {
    final token = await _getToken();

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geofence berhasil dihapus')),
        );
        _fetchGeofences();
      } else {
        debugPrint("Failed to delete geofence: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error deleting geofence: $e");
    }
  }

  void _onMapTap(LatLng point) {
    setState(() => _selectedPoint = point);
    _showCreateDialog(point);
  }

  void _showCreateDialog(LatLng point) {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController radiusCtrl = TextEditingController(text: "100");
    String type = "office";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Buat Geofence Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Koordinat: ${point.latitude}, ${point.longitude}"),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nama Lokasi"),
            ),
            TextField(
              controller: radiusCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Radius (meter)"),
            ),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: "Tipe"),
              items: const [
                DropdownMenuItem(value: "office", child: Text("Office")),
                DropdownMenuItem(value: "branch", child: Text("Branch")),
              ],
              onChanged: (val) => type = val!,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Simpan"),
            onPressed: () {
              Navigator.pop(context);
              _createGeofence(
                nameCtrl.text,
                point.latitude,
                point.longitude,
                double.tryParse(radiusCtrl.text) ?? 100,
                type,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      ..._geofences.map((geo) {
        final lat = geo['center_lat']?.toDouble() ?? 0.0;
        final lng = geo['center_lng']?.toDouble() ?? 0.0;
        return Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onLongPress: () => _deleteGeofence(geo['id']),
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        );
      }),
      if (_selectedPoint != null)
        Marker(
          point: _selectedPoint!,
          width: 40,
          height: 40,
          child: const Icon(Icons.add_location, color: Colors.blue, size: 40),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Titik Lokasi (Geofence)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchGeofences,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(-6.2, 106.816666),
                initialZoom: 13,
                onTap: (_, p) => _onMapTap(p),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                CircleLayer(
                  circles: _geofences.map((geo) {
                    final lat = geo['center_lat']?.toDouble() ?? 0.0;
                    final lng = geo['center_lng']?.toDouble() ?? 0.0;
                    final radius = (geo['radius'] ?? 100).toDouble();
                    return CircleMarker(
                      point: LatLng(lat, lng),
                      color: Colors.blue.withOpacity(0.3),
                      borderStrokeWidth: 2,
                      borderColor: Colors.blue,
                      radius: radius / 2,
                    );
                  }).toList(),
                ),
                MarkerLayer(markers: markers),
              ],
            ),
    );
  }
}
