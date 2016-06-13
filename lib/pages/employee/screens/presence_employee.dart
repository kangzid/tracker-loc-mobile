import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_application_1/pages/auth/auth_storage.dart';
import 'package:flutter_application_1/pages/employee/storage/presence_storage.dart';
import '../../../config/api_config.dart';

class PresenceEmployeePage extends StatefulWidget {
  const PresenceEmployeePage({super.key});

  @override
  State<PresenceEmployeePage> createState() => _PresenceEmployeePageState();
}

class _PresenceEmployeePageState extends State<PresenceEmployeePage> {
  final MapController _mapController = MapController();

  String? _name;
  String? _position;
  String? _employeeCode;
  String? _token;

  LatLng _currentLatLng = const LatLng(-7.797068, 110.370529);
  Marker? _currentLocationMarker;
  String _lastActionStatus = "Belum ada";
  String _todayAttendance = "Belum cek";

  bool _hasCheckedIn = false;
  bool _hasCheckedOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndInitialLocation();
    _loadLastPresenceFromStorage();
  }

  Future<void> _loadUserDataAndInitialLocation() async {
    final data = await AuthStorage().getLoginData();

    setState(() {
      _token = data['token'];
      final user = data['user'];
      _name = user['name'];
      final employee = user['employee'];
      _employeeCode = employee['employee_id'];
      _position = employee['position'];
    });

    _updateMarker(_currentLatLng);
    _getCurrentLocation();
    _fetchTodayAttendance();
  }

  Future<void> _loadLastPresenceFromStorage() async {
    final saved = await PresenceStorage().getLastPresence();
    if (saved != null) {
      setState(() {
        _lastActionStatus = saved;
      });
    }
  }

  Future<bool> _checkLocationBeforeAttendance() async {
    if (_token == null) return false;

    final url = Uri.parse(
        '${ApiConfig.attendances}/check-location');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          "latitude": _currentLatLng.latitude,
          "longitude": _currentLatLng.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['is_in_office'] == true) {
          return true;
        } else {
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: const [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedLocationRemove01,
                      color: Colors.red,
                      size: 24.0,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Lokasi Tidak Valid",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  result['message'] ?? "Anda berada di luar area kantor.",
                  style: const TextStyle(fontSize: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
          return false;
        }
      } else {
        debugPrint("Check location failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error check-location: $e");
      return false;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng newLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLatLng = newLatLng;
        _updateMarker(newLatLng);
      });

      _mapController.move(newLatLng, 15.0);
    } catch (e) {
      debugPrint("Error get location: $e");
    }
  }

  void _updateMarker(LatLng latLng) {
    setState(() {
      _currentLocationMarker = Marker(
        width: 80,
        height: 80,
        point: latLng,
        child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
      );
    });
  }

  Future<void> _sendAttendance(String type) async {
    if (_token == null) return;

    final isInsideOffice = await _checkLocationBeforeAttendance();
    if (!isInsideOffice) return;

    final url = Uri.parse(ApiConfig.attendances);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          "latitude": _currentLatLng.latitude,
          "longitude": _currentLatLng.longitude,
          "type": type,
        }),
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final successMsg =
              "Sukses $type: ${DateTime.now().toLocal().toString().substring(11, 19)}";

          setState(() {
            _lastActionStatus = successMsg;
            if (type == "check_in") _hasCheckedIn = true;
            if (type == "check_out") _hasCheckedOut = true;
          });

          await PresenceStorage().saveLastPresence(successMsg);
          _fetchTodayAttendance();

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                    color: Colors.green,
                    size: 24.0,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Presensi Berhasil",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              content: Text(
                type == "check_in"
                    ? "Check-in berhasil! Selamat bekerja 👏"
                    : "Check-out berhasil! Terima kasih atas kerja hari ini 🙌",
                style: const TextStyle(fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else {
          debugPrint("ERROR: ${response.body}");
          setState(() {
            _lastActionStatus = "Gagal $type (${response.statusCode})";
          });

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedAlert02,
                    color: Colors.red,
                    size: 24.0,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Presensi Gagal",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Text(
                "Terjadi kesalahan saat $type. (${response.statusCode})",
                style: const TextStyle(fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastActionStatus = "Error network";
        });
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedWifiOff01,
                  color: Colors.orange,
                  size: 24.0,
                ),
                SizedBox(width: 12),
                Text(
                  "Kesalahan Jaringan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Tidak dapat terhubung ke server, coba lagi nanti.",
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _fetchTodayAttendance() async {
    if (_token == null) return;

    final url =
        Uri.parse('${ApiConfig.attendances}/today');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          setState(() {
            _todayAttendance = "success";
            _hasCheckedIn = data['check_in'] != null;
            _hasCheckedOut = data['check_out'] != null;
          });
        } else {
          setState(() {
            _todayAttendance = "none";
          });
        }
      }
    } catch (e) {
      setState(() {
        _todayAttendance = "error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Presensi Saya",
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmployeeInfoCard(),
            const SizedBox(height: 16),
            _buildMapView(),
            const SizedBox(height: 16),
            _buildPresenceControls(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      _name ?? "Loading...",
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
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Status Presensi: ",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              if (_todayAttendance == "success")
                Row(
                  children: const [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      color: Colors.green,
                      size: 16.0,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Sudah Presensi",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              else if (_todayAttendance == "none")
                Row(
                  children: const [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCancelCircle,
                      color: Colors.red,
                      size: 16.0,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Belum Presensi",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              else if (_todayAttendance == "error")
                Row(
                  children: const [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedAlert02,
                      color: Colors.orange,
                      size: 16.0,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Error",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  "...",
                  style: TextStyle(color: Colors.grey.shade400),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLatLng,
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
            if (_currentLocationMarker != null)
              MarkerLayer(markers: [_currentLocationMarker!]),
          ],
        ),
      ),
    );
  }

  Widget _buildPresenceControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _hasCheckedIn ? null : () => _sendAttendance("check_in"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade500,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              HugeIcon(
                icon: HugeIcons.strokeRoundedLogin01,
                color: Colors.white,
                size: 20.0,
              ),
              SizedBox(width: 8),
              Text(
                "Check In",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _hasCheckedOut ? null : () => _sendAttendance("check_out"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade500,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              HugeIcon(
                icon: HugeIcons.strokeRoundedLogout01,
                color: Colors.white,
                size: 20.0,
              ),
              SizedBox(width: 8),
              Text(
                "Check Out",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedClock01,
                    color: Colors.blue,
                    size: 20.0,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Status Terakhir",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _lastActionStatus,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
