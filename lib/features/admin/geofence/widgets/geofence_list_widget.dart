import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/core/config/api_config.dart';

class GeofenceListWidget extends StatefulWidget {
  final List<dynamic> geofences;
  final VoidCallback onRefresh;

  const GeofenceListWidget({
    super.key,
    required this.geofences,
    required this.onRefresh,
  });

  @override
  State<GeofenceListWidget> createState() => _GeofenceListWidgetState();
}

class _GeofenceListWidgetState extends State<GeofenceListWidget> {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Color _getGeofenceColor(String type) {
    switch (type) {
      case 'office':
        return Colors.blue;
      case 'work_area':
        return Colors.green;
      case 'restricted':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'office':
        return 'Office';
      case 'work_area':
        return 'Work Area';
      case 'restricted':
        return 'Restricted';
      default:
        return 'Office';
    }
  }

  Future<void> _updateGeofence(Map<String, dynamic> geofence) async {
    final nameCtrl = TextEditingController(text: geofence['name']);
    final radiusCtrl =
        TextEditingController(text: geofence['radius']?.toString() ?? '100');
    String type = geofence['type'] ?? 'office';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_location,
                          color: Colors.orange, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Edit Geofence",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Nama Lokasi",
                    prefixIcon:
                        const Icon(Icons.label_outline, color: Colors.orange),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: radiusCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Radius (meter)",
                    prefixIcon: const Icon(Icons.radio_button_unchecked,
                        color: Colors.orange),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: "Tipe Lokasi",
                    prefixIcon:
                        const Icon(Icons.business, color: Colors.orange),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: "office", child: Text("Office")),
                    DropdownMenuItem(
                        value: "work_area", child: Text("Work Area")),
                    DropdownMenuItem(
                        value: "restricted", child: Text("Restricted")),
                  ],
                  onChanged: (val) => setDialogState(() => type = val!),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _performUpdate(geofence['id'], nameCtrl.text,
                              double.tryParse(radiusCtrl.text) ?? 100, type);
                        },
                        child: const Text("Update",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performUpdate(
      int id, String name, double radius, String type) async {
    final token = await _getToken();
    final body = {
      "name": name,
      "radius": radius,
      "type": type,
    };

    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.geofences}/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Geofence berhasil diupdate!'),
              backgroundColor: Colors.green),
        );
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error updating geofence: $e");
    }
  }

  Future<void> _deleteGeofence(int id, String name) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Geofence'),
        content: Text('Yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(int id) async {
    final token = await _getToken();

    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.geofences}/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Geofence berhasil dihapus'),
              backgroundColor: Colors.orange),
        );
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error deleting geofence: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "GeofenceListWidget - geofences count: ${widget.geofences.length}");
    debugPrint("GeofenceListWidget - geofences data: ${widget.geofences}");

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.list_alt, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Kelola Geofence",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: widget.geofences.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Belum ada geofence',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.geofences.length,
                      itemBuilder: (context, index) {
                        final geo = widget.geofences[index];
                        final color =
                            _getGeofenceColor(geo['type'] ?? 'office');
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.1),
                              child: Icon(Icons.location_on, color: color),
                            ),
                            title: Text(geo['name'] ?? 'Unknown'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${_getTypeLabel(geo['type'] ?? 'office')} • ${geo['radius'] ?? '100'}m'),
                                Text(
                                    '${geo['center_lat'] ?? '0'}, ${geo['center_lng'] ?? '0'}',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () => _updateGeofence(geo),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteGeofence(geo['id'], geo['name']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
