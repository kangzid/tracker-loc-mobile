import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/core/config/api_config.dart';
import 'employee_form_dialog.dart';
import 'employee_delete_dialog.dart';
import 'employee_list_item.dart';

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

  Future<void> _handleCreateEmployee(Map<String, dynamic> data) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.employees),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        _showSuccessSnackBar('Karyawan berhasil ditambahkan!');
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error creating employee: $e");
    }
  }

  Future<void> _handleUpdateEmployee(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.employees}/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        _showSuccessSnackBar('Karyawan berhasil diupdate!');
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error updating employee: $e");
    }
  }

  Future<void> _handleDeleteEmployee(int id) async {
    final token = await _getToken();
    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.employees}/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        _showSuccessSnackBar('Karyawan berhasil dihapus', color: Colors.orange);
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error deleting employee: $e");
    }
  }

  void _showSuccessSnackBar(String message, {Color color = Colors.green}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => EmployeeFormDialog(
        onSubmit: _handleCreateEmployee,
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => EmployeeFormDialog(
        employee: employee,
        onSubmit: (data) => _handleUpdateEmployee(employee['id'], data),
      ),
    );
  }

  void _showDeleteDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => EmployeeDeleteDialog(
        employeeName: name,
        onConfirm: () => _handleDeleteEmployee(id),
      ),
    );
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]),
                        child: IconButton(
                          onPressed: _showCreateDialog,
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

                        return EmployeeListItem(
                          employee: employee,
                          onEdit: () => _showEditDialog(employee),
                          onDelete: () =>
                              _showDeleteDialog(employee['id'], name),
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
