import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/auth/auth_storage.dart';
import 'package:flutter_application_1/pages/employee/storage/presence_storage.dart';

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
    _loadLastPresenceFromStorage(); // ✅ baca dari storage
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

// ✅ Cek lokasi sebelum presensi
  Future<bool> _checkLocationBeforeAttendance() async {
    if (_token == null) return false;

    final url = Uri.parse(
        'https://locatrack.zalfyan.my.id/api/attendances/check-location');
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
          // ❌ Di luar area kantor
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Lokasi Tidak Valid"),
                content: Text(
                    result['message'] ?? "Anda berada di luar area kantor."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
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

    // ✅ 1. Cek lokasi kantor dulu
    final isInsideOffice = await _checkLocationBeforeAttendance();
    if (!isInsideOffice) return;

    // ✅ 2. Lanjut kirim presensi
    final url = Uri.parse('https://locatrack.zalfyan.my.id/api/attendances');
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

          // ✅ Pop-up sukses (mirip gaya alert error)
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text(
                "Presensi Berhasil",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              content: Text(
                type == "check_in"
                    ? "Check-in berhasil! Selamat bekerja 👏"
                    : "Check-out berhasil! Terima kasih atas kerja hari ini 🙌",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
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

          // ❌ Pop-up gagal (mirip lokasi tidak valid)
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Presensi Gagal"),
              content: Text(
                  "Terjadi kesalahan saat $type. (${response.statusCode})"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
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
            title: const Text("Kesalahan Jaringan"),
            content:
                const Text("Tidak dapat terhubung ke server, coba lagi nanti."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
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
        Uri.parse('https://locatrack.zalfyan.my.id/api/attendances/today');
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
        title: const Text("Presensi Saya"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _name ?? "Loading...",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              '${_employeeCode ?? '...'} • ${_position ?? '...'}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Presensi Hari Ini: ",
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                if (_todayAttendance == "success")
                  const Icon(Icons.check_circle, color: Colors.green, size: 20)
                else if (_todayAttendance == "none")
                  const Icon(Icons.cancel, color: Colors.red, size: 20)
                else if (_todayAttendance == "error")
                  const Icon(Icons.error, color: Colors.orange, size: 20)
                else
                  const Text("...", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return SizedBox(
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Check In"),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _hasCheckedOut ? null : () => _sendAttendance("check_out"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Check Out"),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Status Terakhir:",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(_lastActionStatus,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
