import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class GpsTrackerPage extends StatefulWidget {
  const GpsTrackerPage({super.key});

  @override
  State<GpsTrackerPage> createState() => _GpsTrackerPageState();
}

class _GpsTrackerPageState extends State<GpsTrackerPage> {
  final TextEditingController _plateController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  bool _isTracking = false;
  String? _statusMessage;
  StreamSubscription<Position>? _positionStream;

  // Fungsi untuk meminta izin lokasi
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Layanan lokasi (GPS) tidak aktif. Mohon aktifkan.')));
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi ditolak.')));
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Izin lokasi ditolak permanen. Buka pengaturan.')));
      }
      return false;
    }

    return true;
  }

  void _toggleTracking() async {
    if (_isTracking) {
      // STOP TRACKING
      _positionStream?.cancel();
      // Update status jadi inactive di Firebase sebelum stop
      if (_plateController.text.isNotEmpty) {
        final plate = _plateController.text.toUpperCase().replaceAll(' ', '');
        await _dbRef.child('vehicles/$plate').update({'is_active': false});
      }

      setState(() {
        _isTracking = false;
        _statusMessage = "Tracking Dihentikan";
      });
    } else {
      // START TRACKING
      if (_plateController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mohon masukkan Plat Nomor dulu.')));
        return;
      }

      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;

      setState(() {
        _isTracking = true;
        _statusMessage = "Menghubungkan ke GPS...";
      });

      final plate = _plateController.text.toUpperCase().replaceAll(' ', '');

      // Konfigurasi Stream Lokasi
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update setiap pindah 10 meter
      );

      _positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
        setState(() {
          _statusMessage =
              "Tracking Aktif\nLat: ${position.latitude}\nLng: ${position.longitude}";
        });

        // Kirim ke Firebase Realtime Database
        _dbRef.child('vehicles/$plate').set({
          'plate_number': _plateController.text.toUpperCase(),
          'latitude': position.latitude,
          'longitude': position.longitude,
          'heading': position.heading,
          'speed': position.speed, // dalam m/s
          'timestamp': DateTime.now().toIso8601String(),
          'is_active': true,
        }).catchError((error) {
          debugPrint("Error writing to Firebase: $error");
        });
      }, onError: (e) {
        setState(() {
          _statusMessage = "Error GPS: $e";
          _isTracking = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _plateController.dispose();
    super.dispose();
  }

  InputBorder _thinBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(width: 0.5, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "GPS Tracker Mode",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Status Icon with Pulse Effect (Optional visual cue)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isTracking
                    ? Colors.green.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
                size: 80,
                color: _isTracking ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isTracking ? "TRACKING AKTIF" : "SIAP MELACAK",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isTracking ? Colors.green : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Masukkan Plat Nomor kendaraan sesuai data di Admin.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),

            // Input Field (Style matched with Login Page)
            TextField(
              controller: _plateController,
              enabled: !_isTracking,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'B 1234 XXX',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: _thinBorder(),
                enabledBorder: _thinBorder(),
                focusedBorder: _thinBorder(),
                filled: true,
                fillColor: _isTracking ? Colors.grey[100] : Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Action Button (Style matched with Login Page)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _toggleTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? Colors.red : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isTracking ? "STOP TRACKING" : "MULAI TRACKING",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Status Log Area
            if (_statusMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
