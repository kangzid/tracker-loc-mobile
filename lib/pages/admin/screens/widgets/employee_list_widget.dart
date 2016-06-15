import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeListWidget extends StatefulWidget {
  final List<dynamic> employees;
  final VoidCallback onRefresh;

  const EmployeeListWidget({
    super.key,
    required this.employees,
    required this.onRefresh,
  });

  @override
  State<EmployeeListWidget> createState() => _EmployeeListWidgetState();
}

class _EmployeeListWidgetState extends State<EmployeeListWidget> {
  final String baseUrl = "https://locatrack.zalfyan.my.id/api/employees";
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _filteredEmployees = widget.employees;
  }

  @override
  void didUpdateWidget(EmployeeListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.employees != widget.employees) {
      _filterEmployees(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterEmployees(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = widget.employees;
      } else {
        _filteredEmployees = widget.employees.where((employee) {
          final user = employee['user'] ?? {};
          final name = (user['name'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          final employeeId =
              (employee['employee_id'] ?? '').toString().toLowerCase();
          final department =
              (employee['department'] ?? '').toString().toLowerCase();
          final position =
              (employee['position'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();

          return name.contains(searchLower) ||
              email.contains(searchLower) ||
              employeeId.contains(searchLower) ||
              department.contains(searchLower) ||
              position.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _createEmployee() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final employeeIdCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final departmentCtrl = TextEditingController();
    final positionCtrl = TextEditingController();

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
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_add,
                          color: Colors.blue, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Tambah Karyawan",
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
                _buildTextField(nameCtrl, "Nama Lengkap", Icons.person),
                const SizedBox(height: 16),
                _buildTextField(emailCtrl, "Email", Icons.email),
                const SizedBox(height: 16),
                _buildTextField(passwordCtrl, "Password", Icons.lock,
                    isPassword: true),
                const SizedBox(height: 16),
                _buildTextField(employeeIdCtrl, "ID Karyawan", Icons.badge),
                const SizedBox(height: 16),
                _buildTextField(phoneCtrl, "Nomor Telepon", Icons.phone),
                const SizedBox(height: 16),
                _buildTextField(addressCtrl, "Alamat", Icons.home),
                const SizedBox(height: 16),
                _buildTextField(departmentCtrl, "Departemen", Icons.business),
                const SizedBox(height: 16),
                _buildTextField(positionCtrl, "Posisi", Icons.work),
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
                          backgroundColor: Colors.blue,
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
                            nameCtrl.text,
                            emailCtrl.text,
                            passwordCtrl.text,
                            employeeIdCtrl.text,
                            phoneCtrl.text,
                            addressCtrl.text,
                            departmentCtrl.text,
                            positionCtrl.text,
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
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
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
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  Future<void> _performCreate(
      String name,
      String email,
      String password,
      String employeeId,
      String phone,
      String address,
      String department,
      String position) async {
    final token = await _getToken();
    final body = {
      "name": name,
      "email": email,
      "password": password,
      "role": "employee",
      "employee_id": employeeId,
      "phone": phone,
      "address": address,
      "department": department,
      "position": position,
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
            content: const Text('Karyawan berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error creating employee: $e");
    }
  }

  Future<void> _updateEmployee(Map<String, dynamic> employee) async {
    final user = employee['user'] ?? {};
    final nameCtrl = TextEditingController(text: user['name']);
    final emailCtrl = TextEditingController(text: user['email']);
    final passwordCtrl = TextEditingController();
    final employeeIdCtrl = TextEditingController(text: employee['employee_id']);
    final phoneCtrl = TextEditingController(text: employee['phone']);
    final addressCtrl = TextEditingController(text: employee['address']);
    final departmentCtrl = TextEditingController(text: employee['department']);
    final positionCtrl = TextEditingController(text: employee['position']);

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
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Icons.edit, color: Colors.blue, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Edit Karyawan",
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
                _buildTextField(nameCtrl, "Nama Lengkap", Icons.person),
                const SizedBox(height: 16),
                _buildTextField(emailCtrl, "Email", Icons.email),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password (kosongkan jika tidak diubah)",
                    prefixIcon: const Icon(Icons.lock, color: Colors.blue),
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
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(employeeIdCtrl, "ID Karyawan", Icons.badge),
                const SizedBox(height: 16),
                _buildTextField(phoneCtrl, "Nomor Telepon", Icons.phone),
                const SizedBox(height: 16),
                _buildTextField(addressCtrl, "Alamat", Icons.home),
                const SizedBox(height: 16),
                _buildTextField(departmentCtrl, "Departemen", Icons.business),
                const SizedBox(height: 16),
                _buildTextField(positionCtrl, "Posisi", Icons.work),
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
                          backgroundColor: Colors.blue,
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
                            employee['id'],
                            nameCtrl.text,
                            emailCtrl.text,
                            passwordCtrl.text,
                            employeeIdCtrl.text,
                            phoneCtrl.text,
                            addressCtrl.text,
                            departmentCtrl.text,
                            positionCtrl.text,
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

  Future<void> _performUpdate(
      int id,
      String name,
      String email,
      String password,
      String employeeId,
      String phone,
      String address,
      String department,
      String position) async {
    final token = await _getToken();
    final body = {
      "name": name,
      "email": email,
      "role": "employee",
      "employee_id": employeeId,
      "phone": phone,
      "address": address,
      "department": department,
      "position": position,
    };

    if (password.isNotEmpty) {
      body["password"] = password;
    }

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
            content: const Text('Karyawan berhasil diupdate!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error updating employee: $e");
    }
  }

  Future<void> _deleteEmployee(int id, String name) async {
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
                'Hapus Karyawan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Yakin ingin menghapus "$name"?',
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
            content: const Text('Karyawan berhasil dihapus'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error deleting employee: $e");
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
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.people,
                          color: Colors.blue,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kelola Karyawan",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Manajemen data karyawan",
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
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: _createEmployee,
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: isSmallScreen ? 18 : 20,
                          ),
                          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                          constraints: const BoxConstraints(),
                          tooltip: "Tambah Karyawan",
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
                      hintText: "Cari karyawan...",
                      hintStyle: TextStyle(
                        color: const Color(0xFF94A3B8),
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.blue,
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
                                _filterEmployees('');
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
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      isDense: true,
                    ),
                    style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    onChanged: _filterEmployees,
                  ),
                ],
              ),
            ),

            // Employee List
            Expanded(
              child: _filteredEmployees.isEmpty
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
                                    : Icons.person_off,
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
                                    ? 'Karyawan tidak ditemukan'
                                    : 'Belum ada karyawan',
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
                                    : 'Tambahkan karyawan baru',
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
                      itemCount: _filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = _filteredEmployees[index];
                        final user = employee['user'] ?? {};
                        final name = user['name'] ?? 'Unknown';
                        final initial = name.isNotEmpty
                            ? name.substring(0, 1).toUpperCase()
                            : 'U';

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
                                        Colors.blue.shade400,
                                        Colors.blue.shade600
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
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

                                // Employee Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
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
                                              color:
                                                  Colors.blue.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              employee['employee_id'] ?? '',
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 9 : 10,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              employee['department'] ?? '',
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
                                        employee['position'] ?? '',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 10 : 11,
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      SizedBox(height: isSmallScreen ? 1 : 2),
                                      Text(
                                        user['email'] ?? '',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 9 : 10,
                                          color: Colors.grey.shade500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: isSmallScreen ? 16 : 18,
                                        ),
                                        onPressed: () =>
                                            _updateEmployee(employee),
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
                                        onPressed: () => _deleteEmployee(
                                          employee['id'],
                                          name,
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
