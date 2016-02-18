import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/auth/auth_storage.dart';

class TrackEmployeeScreen extends StatefulWidget {
  const TrackEmployeeScreen({super.key});

  @override
  State<TrackEmployeeScreen> createState() => _TrackEmployeeScreenState();
}

class _TrackEmployeeScreenState extends State<TrackEmployeeScreen> {
  final MapController _mapController = MapController();

  String? _name;
  int? _employeeDbId; // <-- PK dari tabel employees
  String? _employeeCode; // kode pegawai (EMP001)
  String? _position;
  String? _token;

  LatLng _currentLatLng =
      const LatLng(-7.797068, 110.370529); // Default Yogyakarta
  Marker? _currentLocationMarker;
  bool _isAutoTracking = false;
  Timer? _trackingTimer;
  String _lastUpdateStatus = "Belum ada";

  @override
  void initState() {
    super.initState();
    _loadUserDataAndInitialLocation();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserDataAndInitialLocation() async {
    final data = await AuthStorage().getLoginData();

    setState(() {
      _token = data['token'];
      final user = data['user'];
      _name = user['name'];

      final employee = user['employee'];
      _employeeDbId = employee['id']; // id numerik dari DB
      _employeeCode = employee['employee_id'];
      _position = employee['position'];

      if (employee['latitude'] != null && employee['longitude'] != null) {
        try {
          _currentLatLng = LatLng(
            double.parse(employee['latitude'].toString()),
            double.parse(employee['longitude'].toString()),
          );
        } catch (_) {}
      }
    });

    _updateMarker(_currentLatLng);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation({bool updateApi = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permissions permanently denied')),
        );
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng newLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLatLng = newLatLng;
        _updateMarker(newLatLng);
      });

      _mapController.move(newLatLng, 15.0);

      if (updateApi) {
        _sendLocationToApi(position);
      }
    } catch (e) {
      // bisa log error jika perlu
    }
  }

  void _updateMarker(LatLng latLng) {
    setState(() {
      _currentLocationMarker = Marker(
        width: 80.0,
        height: 80.0,
        point: latLng,
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40.0,
        ),
      );
    });
  }

  Future<void> _sendLocationToApi(Position position) async {
    if (_token == null || _employeeDbId == null) return;

    final url = Uri.parse('https://locatrack.zalfyan.my.id/api/locations');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'trackable_type': 'employee', // FIX → sesuai dokumentasi API
          'trackable_id': _employeeDbId, // pastikan ini PK numerik employee
          'speed': position.speed,
          'accuracy': position.accuracy,
        }),
      );

      if (mounted) {
        setState(() {
          if (response.statusCode == 201 || response.statusCode == 200) {
            _lastUpdateStatus =
                "Sukses: ${DateTime.now().toLocal().toString().substring(11, 19)}";
          } else {
            _lastUpdateStatus = "Gagal: ${response.statusCode}";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastUpdateStatus = "Error: Network";
        });
      }
    }
  }

  void _toggleAutoTracking(bool value) {
    setState(() {
      _isAutoTracking = value;
    });
    if (_isAutoTracking) {
      _trackingTimer?.cancel();
      _trackingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _getCurrentLocation(updateApi: true);
      });
      _getCurrentLocation(updateApi: true);
    } else {
      _trackingTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker Saya'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmployeeInfoCard(),
            const SizedBox(height: 16),
            _buildMapView(),
            const SizedBox(height: 16),
            _buildTrackingControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _name ?? 'Loading...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_employeeCode ?? '...'} • ${_position ?? '...'}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLatLng,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            if (_currentLocationMarker != null)
              MarkerLayer(markers: [_currentLocationMarker!]),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => _getCurrentLocation(updateApi: true),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Update Lokasi Sekarang'),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Auto Tracking',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: _isAutoTracking,
                      onChanged: _toggleAutoTracking,
                    ),
                  ],
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status Auto:',
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        _isAutoTracking ? 'ON' : 'OFF',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isAutoTracking ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lokasi Terakhir:',
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        _lastUpdateStatus,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
