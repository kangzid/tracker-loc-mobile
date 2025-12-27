import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/features/auth/auth_storage.dart';
import 'package:flutter_application_1/features/employee/tracking/storage/track_storage.dart';
import 'package:flutter_application_1/core/config/api_config.dart';
import 'package:flutter_application_1/core/widgets/custom_app_bar.dart';
import '../widgets/tracking_info_card.dart';
import '../widgets/tracking_map.dart';
import '../widgets/tracking_controls.dart';

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
      _showSnackBar('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions permanently denied');
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

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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
      appBar: const CustomAppBar(
        title: 'Tracker Saya',
        showBackButton: false,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TrackingInfoCard(
              name: _name ?? 'Loading...',
              code: _employeeCode ?? '...',
              position: _position ?? '...',
            ),
            const SizedBox(height: 16),
            TrackingMap(
              mapController: _mapController,
              currentLatLng: _currentLatLng,
              currentLocationMarker: _currentLocationMarker,
            ),
            const SizedBox(height: 16),
            TrackingControls(
              isAutoTracking: _isAutoTracking,
              lastUpdateStatus: _lastUpdateStatus,
              onUpdateLocation: () => _getCurrentLocation(updateApi: true),
              onToggleAutoTracking: _toggleAutoTracking,
            ),
          ],
        ),
      ),
    );
  }
}
