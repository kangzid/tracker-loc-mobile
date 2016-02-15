import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AuthStorage {
  // Keys untuk user
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';

  // Keys untuk employee
  static const String _employeeDbIdKey = 'employee_db_id'; // PK employees.id
  static const String _employeeIdKey =
      'employee_employee_id'; // kode pegawai (EMP001)
  static const String _employeeDepartmentKey = 'employee_department';
  static const String _employeePositionKey = 'employee_position';
  
  // Key untuk login time
  static const String _loginTimeKey = 'login_time';
  
  // Timer untuk auto logout
  static Timer? _logoutTimer;

  /// Simpan data login dari API
  Future<void> saveLoginData(Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? token = data['token'];
    final Map<String, dynamic>? user = data['user'];
    final Map<String, dynamic>? employee = user?['employee'];

    if (token != null) {
      await prefs.setString(_tokenKey, token);
    }
    if (user != null) {
      await prefs.setInt(_userIdKey, user['id']);
      await prefs.setString(_userNameKey, user['name']);
      await prefs.setString(_userEmailKey, user['email']);
      await prefs.setString(_userRoleKey, user['role']);
    }
    if (employee != null) {
      // simpan id numerik employee (PK di tabel employees)
      if (employee['id'] != null) {
        await prefs.setInt(_employeeDbIdKey, employee['id']);
      }
      await prefs.setString(_employeeIdKey, employee['employee_id']);
      await prefs.setString(
          _employeeDepartmentKey, employee['department'] ?? '');
      await prefs.setString(_employeePositionKey, employee['position'] ?? '');
    }
    
    // Simpan waktu login dan mulai timer auto logout
    await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
    _startAutoLogoutTimer();
  }

  /// Ambil data login
  Future<Map<String, dynamic>> getLoginData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'user': {
        'id': prefs.getInt(_userIdKey),
        'name': prefs.getString(_userNameKey),
        'email': prefs.getString(_userEmailKey),
        'employee': {
          'id': prefs.getInt(_employeeDbIdKey), // id numerik dari DB
          'employee_id': prefs.getString(_employeeIdKey), // kode pegawai
          'department': prefs.getString(_employeeDepartmentKey),
          'position': prefs.getString(_employeePositionKey),
        },
      },
    };
  }

  /// Hapus data login
  Future<void> clearLoginData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);

    await prefs.remove(_employeeDbIdKey);
    await prefs.remove(_employeeIdKey);
    await prefs.remove(_employeeDepartmentKey);
    await prefs.remove(_employeePositionKey);
    await prefs.remove(_loginTimeKey);
    
    // Cancel timer
    _logoutTimer?.cancel();
    _logoutTimer = null;
  }
  
  /// Cek apakah user masih login dan belum expired
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(_tokenKey);
    final int? loginTime = prefs.getInt(_loginTimeKey);
    
    if (token == null || loginTime == null) {
      return false;
    }
    
    // Cek apakah sudah lebih dari 20 jam (72000000 milliseconds)
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    final int timeDiff = currentTime - loginTime;
    const int twentyHoursInMs = 20 * 60 * 60 * 1000;
    
    if (timeDiff > twentyHoursInMs) {
      await clearLoginData();
      return false;
    }
    
    return true;
  }
  
  /// Mulai timer auto logout setelah 20 jam
  void _startAutoLogoutTimer() {
    _logoutTimer?.cancel();
    
    // Timer 20 jam = 20 * 60 * 60 detik
    const Duration twentyHours = Duration(hours: 20);
    
    _logoutTimer = Timer(twentyHours, () async {
      await clearLoginData();
    });
  }
  
  /// Fungsi logout dengan callback untuk navigasi
  Future<void> logout(Function? onLogout) async {
    await clearLoginData();
    if (onLogout != null) {
      onLogout();
    }
  }
}
