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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_add, color: Colors.green, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Tambah Karyawan",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Nama Lengkap",
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: employeeIdCtrl,
                  decoration: InputDecoration(
                    labelText: "ID Karyawan",
                    prefixIcon: const Icon(Icons.badge, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: "Nomor Telepon",
                    prefixIcon: const Icon(Icons.phone, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressCtrl,
                  decoration: InputDecoration(
                    labelText: "Alamat",
                    prefixIcon: const Icon(Icons.home, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: departmentCtrl,
                  decoration: InputDecoration(
                    labelText: "Departemen",
                    prefixIcon: const Icon(Icons.business, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: positionCtrl,
                  decoration: InputDecoration(
                    labelText: "Posisi",
                    prefixIcon: const Icon(Icons.work, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
                        child: const Text("Simpan", style: TextStyle(color: Colors.white)),
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

  Future<void> _performCreate(String name, String email, String password, String employeeId, String phone, String address, String department, String position) async {
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
          const SnackBar(content: Text('Karyawan berhasil ditambahkan!'), backgroundColor: Colors.green),
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
          child: SingleChildScrollView(
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
                      child: const Icon(Icons.edit, color: Colors.orange, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Edit Karyawan",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Nama Lengkap",
                    prefixIcon: const Icon(Icons.person, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password (kosongkan jika tidak diubah)",
                    prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: employeeIdCtrl,
                  decoration: InputDecoration(
                    labelText: "ID Karyawan",
                    prefixIcon: const Icon(Icons.badge, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: "Nomor Telepon",
                    prefixIcon: const Icon(Icons.phone, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressCtrl,
                  decoration: InputDecoration(
                    labelText: "Alamat",
                    prefixIcon: const Icon(Icons.home, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: departmentCtrl,
                  decoration: InputDecoration(
                    labelText: "Departemen",
                    prefixIcon: const Icon(Icons.business, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: positionCtrl,
                  decoration: InputDecoration(
                    labelText: "Posisi",
                    prefixIcon: const Icon(Icons.work, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
                        child: const Text("Update", style: TextStyle(color: Colors.white)),
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

  Future<void> _performUpdate(int id, String name, String email, String password, String employeeId, String phone, String address, String department, String position) async {
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
          const SnackBar(content: Text('Karyawan berhasil diupdate!'), backgroundColor: Colors.green),
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
      builder: (context) => AlertDialog(
        title: const Text('Hapus Karyawan'),
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
        Uri.parse("$baseUrl/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karyawan berhasil dihapus'), backgroundColor: Colors.orange),
        );
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Error deleting employee: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: const Icon(Icons.people, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Kelola Karyawan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _createEmployee,
                  icon: const Icon(Icons.add, color: Colors.green),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: widget.employees.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Belum ada karyawan', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.employees.length,
                      itemBuilder: (context, index) {
                        final employee = widget.employees[index];
                        final user = employee['user'] ?? {};
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              child: Text(
                                (user['name'] ?? 'U').substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(user['name'] ?? 'Unknown'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${employee['employee_id']} • ${employee['department']}'),
                                Text('${employee['position']}', style: const TextStyle(fontSize: 12)),
                                Text('${user['email']}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => _updateEmployee(employee),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteEmployee(employee['id'], user['name']),
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