import 'package:firebase_remote_config/firebase_remote_config.dart';

class ApiConfig {
  static String _baseUrl = 'https://locatrack.zalfyan.my.id/api'; // fallback
  
  static String get baseUrl => _baseUrl;
  
  static Future<void> initialize() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      
      await remoteConfig.fetchAndActivate();
      _baseUrl = remoteConfig.getString('api_base_url');
    } catch (e) {
      // Gunakan fallback URL jika Firebase gagal
      print('Firebase Remote Config error: $e');
    }
  }
  
  // Endpoints
  static String get dashboardStats => '$baseUrl/dashboard/stats';
  static String get login => '$baseUrl/login';
  static String get logout => '$baseUrl/logout';
  static String get employees => '$baseUrl/employees';
  static String get vehicles => '$baseUrl/vehicles';
  static String get attendance => '$baseUrl/attendance';
  static String get attendances => '$baseUrl/attendances';
  static String get geofences => '$baseUrl/geofences';
  static String get locations => '$baseUrl/locations';
  static String get tasks => '$baseUrl/tasks';
}
