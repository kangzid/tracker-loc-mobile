import 'package:shared_preferences/shared_preferences.dart';

class PresenceStorage {
  static const String _lastPresenceKey = 'employee_last_presence';

  Future<void> saveLastPresence(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPresenceKey, message);
  }

  Future<String?> getLastPresence() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPresenceKey);
  }

  Future<void> clearLastPresence() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastPresenceKey);
  }
}
