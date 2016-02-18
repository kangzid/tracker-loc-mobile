// import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _employeeIdKey = 'employee_employee_id';
  static const String _employeeDepartmentKey = 'employee_department';
  static const String _employeePositionKey = 'employee_position';

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
    }
    if (employee != null) {
      await prefs.setString(_employeeIdKey, employee['employee_id']);
      await prefs.setString(_employeeDepartmentKey, employee['department']);
      await prefs.setString(_employeePositionKey, employee['position']);
    }
  }

  Future<Map<String, dynamic>> getLoginData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'user': {
        'id': prefs.getInt(_userIdKey),
        'name': prefs.getString(_userNameKey),
        'email': prefs.getString(_userEmailKey),
        'employee': {
          'employee_id': prefs.getString(_employeeIdKey),
          'department': prefs.getString(_employeeDepartmentKey),
          'position': prefs.getString(_employeePositionKey),
        },
      },
    };
  }

  Future<void> clearLoginData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_employeeIdKey);
    await prefs.remove(_employeeDepartmentKey);
    await prefs.remove(_employeePositionKey);
  }
}
