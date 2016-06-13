// lib/pages/admin/screens/track_admin.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/features/auth/auth_storage.dart';
import 'package:flutter_application_1/core/config/api_config.dart';
import '../widgets/track_status_bar.dart';
import '../widgets/track_legend.dart';
import '../widgets/track_marker_builder.dart';
import '../widgets/track_bottom_sheet.dart';

class TrackAdminPageContent extends StatefulWidget {
  const TrackAdminPageContent({super.key});

  @override
  State<TrackAdminPageContent> createState() => _TrackAdminPageContentState();
}

class _TrackAdminPageContentState extends State<TrackAdminPageContent> {
  final MapController _mapController = MapController();

  List<dynamic> employees = [];
  List<dynamic> vehicles = [];
  List<dynamic> _apiVehicles = []; // Store raw API data
  Map<String, dynamic> _firebaseVehicleLocations =
      {}; // Store raw Firebase locations
  Timer? _refreshTimer;
  StreamSubscription? _vehicleSubscription;
  final DatabaseReference _vehicleRef =
      FirebaseDatabase.instance.ref().child('vehicles');
  bool _loading = true;
  String? _error;
  bool _showLegend = false;
  bool _showListSheet = false;

  final LatLng _initialCenter = LatLng(-6.200000, 106.816666);
  final double _initialZoom = 6.0;

  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _fetchAndSchedule();
    // Monitor connection
    try {
      _vehicleRef.root.child(".info/connected").onValue.listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        if (mounted) {
          setState(() {
            _isConnected = connected;
          });
        }
      });
    } catch (e) {
      debugPrint("Firebase connection monitor error: $e");
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _vehicleSubscription?.cancel();
    super.dispose();
  }

  void _fetchAndSchedule() async {
    await _fetchLiveLocations(); // Fetch employees
    _listenToVehicles(); // Listen to Firebase for vehicles
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchLiveLocations();
    });
  }

  void _listenToVehicles() {
    try {
      _vehicleSubscription = _vehicleRef.onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          final Map<String, dynamic> loadedLocations = {};
          data.forEach((key, value) {
            if (value is Map) {
              loadedLocations[key] = value;
            }
          });

          _firebaseVehicleLocations = loadedLocations;
          _mergeVehicleData();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Firebase Error: $e";
        });
      }
    }
  }

  void _mergeVehicleData() {
    // ... existing merge logic ...
    if (!mounted) return;

    final List<dynamic> mergedVehicles = [];

    for (var v in _apiVehicles) {
      final String rawPlate = v['vehicle_number'] ?? '';
      final String normalizedPlate = rawPlate.toUpperCase().replaceAll(' ', '');
      final firebaseData = _firebaseVehicleLocations[normalizedPlate];

      if (firebaseData != null) {
        mergedVehicles.add({
          ...v,
          'latitude': firebaseData['latitude'],
          'longitude': firebaseData['longitude'],
          'last_location_update': firebaseData['timestamp'],
          'speed': firebaseData['speed'],
          'heading': firebaseData['heading'],
          'is_live': true,
        });
      } else {
        mergedVehicles.add({
          ...v,
          'is_live': false,
        });
      }
    }

    setState(() {
      vehicles = mergedVehicles;
      // Append connection status to error if offline, to inform user
      if (!_isConnected && _firebaseVehicleLocations.isEmpty) {
        _error = "Offline (Menunggu Koneksi...)";
      } else if (_error == "Offline (Menunggu Koneksi...)") {
        _error = null;
      }
    });
  }

  Future<void> _fetchLiveLocations() async {
    // ... logic same as original ...
    try {
      final auth = await AuthStorage().getLoginData();
      final token = auth['token'] as String?;
      if (token == null) {
        setState(() {
          _error = 'Token tidak ditemukan. Silakan login ulang.';
          _loading = false;
        });
        return;
      }

      final uriEmployees = Uri.parse('${ApiConfig.locations}/live');
      final responseEmployees = await http.get(
        uriEmployees,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final uriVehicles = Uri.parse(ApiConfig.vehicles);
      final responseVehicles = await http.get(
        uriVehicles,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (responseEmployees.statusCode == 200 &&
          responseVehicles.statusCode == 200) {
        final Map<String, dynamic> payloadEmp =
            json.decode(responseEmployees.body);
        final Map<String, dynamic> payloadVeh =
            json.decode(responseVehicles.body);

        final List<dynamic> rawVehicles = payloadVeh['data'] ?? [];

        setState(() {
          employees = payloadEmp['employees'] ?? [];
          _apiVehicles = rawVehicles;
          _loading = false;
          _error = null;
        });

        _mergeVehicleData();
      } else {
        setState(() {
          _error = 'Gagal memuat data (API Error)';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = TrackMarkerBuilder.buildMarkers(
      employees: employees,
      vehicles: vehicles,
      context: context,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Status bar
          TrackStatusBar(
            loading: _loading,
            error: _error,
            employeeCount: employees.length,
            vehicleCount: vehicles.length,
            onRefresh: _fetchLiveLocations,
          ),

          // Legend
          TrackLegend(showLegend: _showLegend),
          // Bottom Sheet
          if (_showListSheet)
            TrackBottomSheet(
              employees: employees,
              vehicles: vehicles,
              mapController: _mapController,
            ),
        ],
      ),

      // Floating Action Buttons
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: "listBtn",
              onPressed: () => setState(() => _showListSheet = !_showListSheet),
              backgroundColor: Colors.blueAccent,
              child: Icon(
                _showListSheet ? Icons.close : Icons.people_alt,
              ),
            ),
            FloatingActionButton(
              heroTag: "infoBtn",
              onPressed: () => setState(() => _showLegend = !_showLegend),
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.info_outline),
            ),
          ],
        ),
      ),
    );
  }
}
