import 'package:flutter/material.dart';

class EmployeeFormDialog extends StatefulWidget {
  final Map<String, dynamic>? employee;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  const EmployeeFormDialog({
    super.key,
    this.employee,
    required this.onSubmit,
  });

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _employeeIdCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _departmentCtrl;
  late TextEditingController _positionCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = widget.employee?['user'] ?? {};
    _nameCtrl = TextEditingController(text: user['name']);
    _emailCtrl = TextEditingController(text: user['email']);
    _passwordCtrl = TextEditingController();
    _employeeIdCtrl =
        TextEditingController(text: widget.employee?['employee_id']);
    _phoneCtrl = TextEditingController(text: widget.employee?['phone']);
    _addressCtrl = TextEditingController(text: widget.employee?['address']);
    _departmentCtrl =
        TextEditingController(text: widget.employee?['department']);
    _positionCtrl = TextEditingController(text: widget.employee?['position']);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _employeeIdCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _departmentCtrl.dispose();
    _positionCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final data = {
      "name": _nameCtrl.text,
      "email": _emailCtrl.text,
      "role": "employee",
      "employee_id": _employeeIdCtrl.text,
      "phone": _phoneCtrl.text,
      "address": _addressCtrl.text,
      "department": _departmentCtrl.text,
      "position": _positionCtrl.text,
    };

    if (_passwordCtrl.text.isNotEmpty) {
      data["password"] = _passwordCtrl.text;
    } else if (widget.employee == null) {
      // Validation for create: Password is required
      if (_passwordCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Password wajib diisi untuk karyawan baru")),
        );
        setState(() => _isLoading = false);
        return;
      }
      data["password"] = _passwordCtrl.text;
    }

    try {
      await widget.onSubmit(data);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Error handling is managed by parent or interceptors,
      // but we ensure loading state is reset if not popped
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employee != null;

    return Dialog(
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
                    child: Icon(
                      isEdit ? Icons.edit : Icons.person_add,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isEdit ? "Edit Karyawan" : "Tambah Karyawan",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(_nameCtrl, "Nama Lengkap", Icons.person),
              const SizedBox(height: 16),
              _buildTextField(_emailCtrl, "Email", Icons.email),
              const SizedBox(height: 16),
              _buildTextField(
                _passwordCtrl,
                isEdit ? "Password (kosongkan jika tetap)" : "Password",
                Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(_employeeIdCtrl, "ID Karyawan", Icons.badge),
              const SizedBox(height: 16),
              _buildTextField(_phoneCtrl, "Nomor Telepon", Icons.phone),
              const SizedBox(height: 16),
              _buildTextField(_addressCtrl, "Alamat", Icons.home),
              const SizedBox(height: 16),
              _buildTextField(_departmentCtrl, "Departemen", Icons.business),
              const SizedBox(height: 16),
              _buildTextField(_positionCtrl, "Posisi", Icons.work),
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
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isEdit ? "Update" : "Simpan",
                              style: const TextStyle(
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
}
