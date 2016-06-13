import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_application_1/pages/auth/auth_storage.dart';
import 'package:flutter_application_1/pages/employee/storage/track_storage.dart';
import '../../../config/api_config.dart';

class TrackEmployeeScreen extends StatefulWidget {
  const TrackEmployeeScreen({super.key});

  @override
  State<TrackEmployeeScreen> createState() => _TrackEmployeeScreenState();
}

class _TrackEmployeeScreenState extends State<TrackEmployeeScreen> {
  final MapController _mapController = MapController();

  String? _name;
  int? _employeeDbId;
  String? _employeeCode;
  String? _position;
  String? _token;

  LatLng _currentLatLng = const LatLng(-7.797068, 110.370529);
  Marker? _currentLocationMarker;
  bool _isAutoTracking = false;
  Timer? _trackingTimer;
  String _lastUpdateStatus = "Belum ada";

  @override
  void initState() {
    super.initState();
    _loadUserDataAndInitialLocation();
    _loadLastStatus();
  }

  Future<void> _loadLastStatus() async {
    final saved = await TrackStorage().getLastLocation();
    if (saved != null) {
      setState(() {
        _lastUpdateStatus = saved;
      });
    }
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
      _employeeDbId = employee['id'];
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

    final url = Uri.parse(ApiConfig.locations);
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
          'trackable_type': 'employee',
          'trackable_id': _employeeDbId,
          'speed': position.speed,
          'accuracy': position.accuracy,
        }),
      );

      if (mounted) {
        if (response.statusCode == 201 || response.statusCode == 200) {
          final status =
              "Sukses: ${DateTime.now().toLocal().toString().substring(11, 19)}";
          setState(() {
            _lastUpdateStatus = status;
          });
          await TrackStorage().saveLastLocation(status);
        } else {
          final status = "Gagal: ${response.statusCode}";
          setState(() {
            _lastUpdateStatus = status;
          });
          await TrackStorage().saveLastLocation(status);
        }
      }
    } catch (e) {
      if (mounted) {
        const status = "Error: Network";
        setState(() {
          _lastUpdateStatus = status;
        });
        await TrackStorage().saveLastLocation(status);
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
        title: const Text(
          'Tracker Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      backgroundColor: Colors.grey.shade50,
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
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
                  _name ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_employeeCode ?? '...'} • ${_position ?? '...'}',
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
    );
  }

  Widget _buildMapView() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLatLng,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.app',
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
            onPressed: () => _getCurrentLocation(updateApi: true),
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
                        color: _isAutoTracking
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedLocation01,
                        color: _isAutoTracking
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
                      value: _isAutoTracking,
                      onChanged: _toggleAutoTracking,
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
                  _isAutoTracking ? 'ON' : 'OFF',
                  _isAutoTracking ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  'Lokasi Terakhir',
                  _lastUpdateStatus,
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
