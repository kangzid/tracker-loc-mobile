import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VehicleListWidget extends StatefulWidget {
  final List<dynamic> vehicles;
  final VoidCallback onRefresh;

  const VehicleListWidget({
    super.key,
    required this.vehicles,
    required this.onRefresh,
  });

  @override
  State<VehicleListWidget> createState() => _VehicleListWidgetState();
}

class _VehicleListWidgetState extends State<VehicleListWidget> {
  final String baseUrl = "https://locatrack.zalfyan.my.id/api/vehicles";
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredVehicles = [];

  @override
  void initState() {
    super.initState();
    _filteredVehicles = widget.vehicles;
  }

  @override
  void didUpdateWidget(VehicleListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicles != widget.vehicles) {
      _filterVehicles(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterVehicles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVehicles = widget.vehicles;
      } else {
        _filteredVehicles = widget.vehicles.where((vehicle) {
          final vehicleNumber =
              (vehicle['vehicle_number'] ?? '').toString().toLowerCase();
          final vehicleType =
              (vehicle['vehicle_type'] ?? '').toString().toLowerCase();
          final brand = (vehicle['brand'] ?? '').toString().toLowerCase();
          final model = (vehicle['model'] ?? '').toString().toLowerCase();
          final year = (vehicle['year'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();

          return vehicleNumber.contains(searchLower) ||
              vehicleType.contains(searchLower) ||
              brand.contains(searchLower) ||
              model.contains(searchLower) ||
              year.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _createVehicle() async {
    final vehicleNumberCtrl = TextEditingController();
    final vehicleTypeCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final yearCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_road,
                          color: Colors.orange, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Tambah Kendaraan",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(vehicleNumberCtrl, "Nomor Kendaraan",
                    Icons.confirmation_number),
                const SizedBox(height: 16),
                _buildTextField(
                    vehicleTypeCtrl, "Tipe Kendaraan", Icons.category),
                const SizedBox(height: 16),
                _buildTextField(brandCtrl, "Merek", Icons.branding_watermark),
                const SizedBox(height: 16),
                _buildTextField(modelCtrl, "Model", Icons.directions_car),
                const SizedBox(height: 16),
                _buildTextField(yearCtrl, "Tahun", Icons.calendar_today),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _performCreate(
                            vehicleNumberCtrl.text,
                            vehicleTypeCtrl.text,
                            brandCtrl.text,
                            modelCtrl.text,
                            yearCtrl.text,
                          );
                        },
                        child: const Text(
                          "Simpan",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }

  Future<void> _performCreate(String vehicleNumber, String vehicleType,
      String brand, String model, String year) async {
    final token = await _getToken();
    final body = {
      "vehicle_number": vehicleNumber,
      "vehicle_type": vehicleType,
      "brand": brand,
      "model": model,
      "year": int.tryParse(year) ?? 0,
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kendaraan berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error creating vehicle: $e");
    }
  }

  Future<void> _updateVehicle(Map<String, dynamic> vehicle) async {
    final vehicleNumberCtrl =
        TextEditingController(text: vehicle['vehicle_number']);
    final vehicleTypeCtrl =
        TextEditingController(text: vehicle['vehicle_type']);
    final brandCtrl = TextEditingController(text: vehicle['brand']);
    final modelCtrl = TextEditingController(text: vehicle['model']);
    final yearCtrl = TextEditingController(text: vehicle['year'].toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit,
                          color: Colors.orange, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Edit Kendaraan",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(vehicleNumberCtrl, "Nomor Kendaraan",
                    Icons.confirmation_number),
                const SizedBox(height: 16),
                _buildTextField(
                    vehicleTypeCtrl, "Tipe Kendaraan", Icons.category),
                const SizedBox(height: 16),
                _buildTextField(brandCtrl, "Merek", Icons.branding_watermark),
                const SizedBox(height: 16),
                _buildTextField(modelCtrl, "Model", Icons.directions_car),
                const SizedBox(height: 16),
                _buildTextField(yearCtrl, "Tahun", Icons.calendar_today),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _performUpdate(
                            vehicle['id'],
                            vehicleNumberCtrl.text,
                            vehicleTypeCtrl.text,
                            brandCtrl.text,
                            modelCtrl.text,
                            yearCtrl.text,
                          );
                        },
                        child: const Text(
                          "Update",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
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

  Future<void> _performUpdate(int id, String vehicleNumber, String vehicleType,
      String brand, String model, String year) async {
    final token = await _getToken();
    final body = {
      "vehicle_number": vehicleNumber,
      "vehicle_type": vehicleType,
      "brand": brand,
      "model": model,
      "year": int.tryParse(year) ?? 0,
    };

    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kendaraan berhasil diupdate!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error updating vehicle: $e");
    }
  }

  Future<void> _deleteVehicle(int id, String vehicleNumber) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_rounded,
                    color: Colors.red, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hapus Kendaraan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Yakin ingin menghapus "$vehicleNumber"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _performDelete(id);
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performDelete(int id) async {
    final token = await _getToken();

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kendaraan berhasil dihapus'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error deleting vehicle: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: screenSize.width * 0.9,
        height: screenSize.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Title Row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.orange,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kelola Kendaraan",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Manajemen data kendaraan",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12,
                                color: const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: _createVehicle,
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: isSmallScreen ? 18 : 20,
                          ),
                          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                          constraints: const BoxConstraints(),
                          tooltip: "Tambah Kendaraan",
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 6),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: const Color(0xFF64748B),
                          size: isSmallScreen ? 18 : 20,
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 10 : 14),
                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari kendaraan...",
                      hintStyle: TextStyle(
                        color: const Color(0xFF94A3B8),
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.orange,
                        size: isSmallScreen ? 18 : 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: isSmallScreen ? 18 : 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterVehicles('');
                              },
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.orange, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      isDense: true,
                    ),
                    style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    onChanged: _filterVehicles,
                  ),
                ],
              ),
            ),

            // Vehicle List
            Expanded(
              child: _filteredVehicles.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _searchController.text.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.directions_car_outlined,
                                size: isSmallScreen ? 48 : 56,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                _searchController.text.isNotEmpty
                                    ? 'Kendaraan tidak ditemukan'
                                    : 'Belum ada kendaraan',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                _searchController.text.isNotEmpty
                                    ? 'Coba kata kunci lain'
                                    : 'Tambahkan kendaraan baru',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      itemCount: _filteredVehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = _filteredVehicles[index];
                        final vehicleNumber =
                            vehicle['vehicle_number'] ?? 'Unknown';
                        final initial = vehicleNumber.isNotEmpty
                            ? vehicleNumber.substring(0, 1).toUpperCase()
                            : 'V';

                        return Container(
                          margin:
                              EdgeInsets.only(bottom: isSmallScreen ? 8 : 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 12,
                              vertical: isSmallScreen ? 8 : 10,
                            ),
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: isSmallScreen ? 40 : 46,
                                  height: isSmallScreen ? 40 : 46,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.shade400,
                                        Colors.orange.shade600
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 16 : 18,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 10 : 12),

                                // Vehicle Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicleNumber,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSmallScreen ? 13 : 15,
                                          color: const Color(0xFF1E293B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      SizedBox(height: isSmallScreen ? 3 : 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isSmallScreen ? 6 : 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              vehicle['vehicle_type'] ?? '',
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 9 : 10,
                                                color: Colors.orange,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              '${vehicle['brand']} ${vehicle['model']}',
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 10 : 11,
                                                color: Colors.grey.shade700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isSmallScreen ? 2 : 3),
                                      Text(
                                        'Tahun: ${vehicle['year']}',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 10 : 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Action Buttons
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.orange,
                                          size: isSmallScreen ? 16 : 18,
                                        ),
                                        onPressed: () =>
                                            _updateVehicle(vehicle),
                                        padding: EdgeInsets.all(
                                            isSmallScreen ? 6 : 8),
                                        constraints: const BoxConstraints(),
                                        tooltip: "Edit",
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 4 : 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: isSmallScreen ? 16 : 18,
                                        ),
                                        onPressed: () => _deleteVehicle(
                                          vehicle['id'],
                                          vehicleNumber,
                                        ),
                                        padding: EdgeInsets.all(
                                            isSmallScreen ? 6 : 8),
                                        constraints: const BoxConstraints(),
                                        tooltip: "Hapus",
                                      ),
                                    ),
                                  ],
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
