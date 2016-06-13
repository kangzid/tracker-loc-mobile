// lib/pages/admin/screens/track_admin.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../auth/auth_storage.dart';
import '../../../config/api_config.dart';
import 'widgets/track_status_bar.dart';
import 'widgets/track_legend.dart';
import 'widgets/track_marker_builder.dart';
import 'widgets/track_bottom_sheet.dart';

class TrackAdminPageContent extends StatefulWidget {
  const TrackAdminPageContent({super.key});

  @override
  State<TrackAdminPageContent> createState() => _TrackAdminPageContentState();
}

class _TrackAdminPageContentState extends State<TrackAdminPageContent> {
  final MapController _mapController = MapController();

  List<dynamic> employees = [];
  List<dynamic> vehicles = [];
  Timer? _refreshTimer;
  bool _loading = true;
  String? _error;
  bool _showLegend = false;
  bool _showListSheet = false;

  final LatLng _initialCenter = LatLng(-6.200000, 106.816666);
  final double _initialZoom = 6.0;

  @override
  void initState() {
    super.initState();
    _fetchAndSchedule();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _fetchAndSchedule() async {
    await _fetchLiveLocations();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchLiveLocations();
    });
  }

  Future<void> _fetchLiveLocations() async {
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

      final uri = Uri.parse('${ApiConfig.locations}/live');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> payload = json.decode(response.body);
        setState(() {
          employees = payload['employees'] ?? [];
          vehicles = payload['vehicles'] ?? [];
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat data (${response.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
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
