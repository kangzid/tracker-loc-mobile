// lib/pages/admin/screens/track_admin.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../auth/auth_storage.dart';

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

  static const String _apiBase = 'https://locatrack.zalfyan.my.id';

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

      final uri = Uri.parse('$_apiBase/api/locations/live');
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

  DateTime? _parseDateTime(String? s) {
    if (s == null) return null;
    try {
      return DateTime.parse(s).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  Color _employeeStatusColor(String? lastUpdateStr) {
    final now = DateTime.now();
    final upd = _parseDateTime(lastUpdateStr);
    if (upd == null) return Colors.red;
    if (upd.year == now.year && upd.month == now.month && upd.day == now.day) {
      return Colors.green;
    }
    return Colors.red;
  }

  Color _vehicleStatusColor(String? lastUpdateStr) {
    final now = DateTime.now();
    final upd = _parseDateTime(lastUpdateStr);
    if (upd == null) return Colors.red;
    final diff = now.difference(upd).inDays;
    return diff <= 2 ? Colors.green : Colors.red;
  }

  Widget _buildMarkerIcon(IconData iconData, Color bgColor) {
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

  Widget _buildLegendItem(IconData icon, Color color, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color.withOpacity(0.85), color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog({
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

  List<Marker> _buildMarkers() {
    final List<Marker> markers = [];

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

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracker - Admin'),
        centerTitle: true,
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
          Positioned(
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
                border:
                    Border.all(color: Colors.white.withOpacity(0.8), width: 1),
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
                  if (_loading) ...[
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
                  ] else if (_error != null) ...[
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _error!,
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
                      'Employees: ${employees.length} • Vehicles: ${vehicles.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _fetchLiveLocations,
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
          ),

          // Modern Legend
          Positioned(
            right: 12,
            bottom: 80,
            child: AnimatedOpacity(
              opacity: _showLegend ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Visibility(
                visible: _showLegend,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.black54),
                          SizedBox(width: 6),
                          Text(
                            'Informations',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem(
                          Icons.person, Colors.green, 'Employee (today)'),
                      _buildLegendItem(
                          Icons.person, Colors.red, 'Employee (no update)'),
                      _buildLegendItem(Icons.directions_car, Colors.green,
                          'Vehicle (≤ 2 days)'),
                      _buildLegendItem(Icons.directions_car, Colors.red,
                          'Vehicle (> 2 days)'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 🧩 Bottom Sheet Daftar Employee & Vehicle
          // 🧩 Bottom Sheet Daftar Employee & Vehicle
          if (_showListSheet)
            DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.25,
              maxChildSize: 0.8,
              snap: true,
              builder: (context, scrollController) {
                // gunakan StatefulBuilder agar bottom sheet punya state lokal
                return StatefulBuilder(
                  builder: (context, setSheetState) {
                    // simpan query di luar function agar tidak reset setiap rebuild
                    String searchQuery = '';

                    // fungsi untuk melakukan filter data
                    List<dynamic> getFilteredEmployees() {
                      if (searchQuery.isEmpty) return employees;
                      return employees.where((e) {
                        final name =
                            (e['user']?['name'] ?? '').toString().toLowerCase();
                        final id =
                            (e['employee_id'] ?? '').toString().toLowerCase();
                        return name.contains(searchQuery) ||
                            id.contains(searchQuery);
                      }).toList();
                    }

                    List<dynamic> getFilteredVehicles() {
                      if (searchQuery.isEmpty) return vehicles;
                      return vehicles.where((v) {
                        final number = (v['vehicle_number'] ?? '')
                            .toString()
                            .toLowerCase();
                        final model =
                            (v['model'] ?? '').toString().toLowerCase();
                        return number.contains(searchQuery) ||
                            model.contains(searchQuery);
                      }).toList();
                    }

                    // state sementara untuk rebuild setelah search
                    List<dynamic> filteredEmployees = employees;
                    List<dynamic> filteredVehicles = vehicles;

                    return StatefulBuilder(
                      builder: (context, innerSetState) {
                        void _filterList(String query) {
                          innerSetState(() {
                            searchQuery = query.toLowerCase();
                            filteredEmployees = getFilteredEmployees();
                            filteredVehicles = getFilteredVehicles();
                          });
                        }

                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Daftar Employee & Vehicle",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 🔍 Search Field
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText:
                                        "Cari nama, ID, atau nomor kendaraan...",
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 0),
                                  ),
                                  onChanged: _filterList,
                                ),
                              ),

                              // ISI LIST (scrollable)
                              Expanded(
                                child: ListView(
                                  controller: scrollController,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  children: [
                                    if (filteredEmployees.isNotEmpty) ...[
                                      const Text(
                                        "👤 Employees",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 6),
                                      ...filteredEmployees.map((e) {
                                        final name =
                                            e['user']?['name'] ?? 'Unknown';
                                        final id = e['employee_id'] ?? '-';
                                        final lat = double.tryParse(
                                            e['latitude']?.toString() ?? '');
                                        final lon = double.tryParse(
                                            e['longitude']?.toString() ?? '');
                                        return Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ListTile(
                                            leading: const Icon(Icons.person,
                                                color: Colors.blue),
                                            title: Text(name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            subtitle: Text("ID: $id"),
                                            onTap: () {
                                              if (lat != null && lon != null) {
                                                _mapController.move(
                                                    LatLng(lat, lon), 15);
                                              }
                                            },
                                          ),
                                        );
                                      }),
                                    ],
                                    const SizedBox(height: 10),
                                    if (filteredVehicles.isNotEmpty) ...[
                                      const Text(
                                        "🚗 Vehicles",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 6),
                                      ...filteredVehicles.map((v) {
                                        final number =
                                            v['vehicle_number'] ?? '-';
                                        final model = v['model'] ?? '-';
                                        final lat = double.tryParse(
                                            v['latitude']?.toString() ?? '');
                                        final lon = double.tryParse(
                                            v['longitude']?.toString() ?? '');
                                        return Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ListTile(
                                            leading: const Icon(
                                                Icons.directions_car,
                                                color: Colors.red),
                                            title: Text(number,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            subtitle: Text("Model: $model"),
                                            onTap: () {
                                              if (lat != null && lon != null) {
                                                _mapController.move(
                                                    LatLng(lat, lon), 15);
                                              }
                                            },
                                          ),
                                        );
                                      }),
                                    ],
                                    if (filteredEmployees.isEmpty &&
                                        filteredVehicles.isEmpty)
                                      const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Text(
                                              "Tidak ada hasil yang cocok"),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
        ],
      ),

      // Tombol info di pojok kanan bawah
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tombol daftar employee & vehicle (kiri bawah)
            FloatingActionButton(
              heroTag: "listBtn",
              onPressed: () => setState(() => _showListSheet = !_showListSheet),
              backgroundColor: Colors.blueAccent,
              child: Icon(
                _showListSheet ? Icons.close : Icons.people_alt,
              ),
            ),

            // Tombol info (kanan bawah)
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
