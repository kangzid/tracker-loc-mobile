import 'package:shared_preferences/shared_preferences.dart';

class TrackStorage {
  static const String _lastLocationKey = 'employee_last_location';

  Future<void> saveLastLocation(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, message);
  }

  Future<String?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastLocationKey);
  }

  Future<void> clearLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastLocationKey);
  }
}
