import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/login_page.dart';
import 'package:flutter_application_1/features/admin/dashboard/home_page.dart';
import 'package:flutter_application_1/features/employee/dashboard/home_page.dart';
import 'package:flutter_application_1/features/admin/geofence/screens/geofence_page.dart';
import 'package:flutter_application_1/features/admin/settings/settings_admin.dart';
import 'package:flutter_application_1/features/admin/employee/screens/employee_page.dart';
import 'package:flutter_application_1/features/admin/vehicle/screens/vehicle_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String adminHome = '/admin-home';
  static const String employeeHome = '/employee-home';
  static const String geofence = '/geofence';
  static const String settingsAdmin = '/settings-admin';
  static const String employeeManagement = '/employee-management';
  static const String vehicleManagement = '/vehicle-management';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginPage(),
        adminHome: (context) => const AdminHomePage(),
        employeeHome: (context) => const EmployeeHomePage(),
        geofence: (context) => const GeofencePage(),
        settingsAdmin: (context) => const SettingsAdminPage(),
        employeeManagement: (context) => const EmployeePage(),
        vehicleManagement: (context) => const VehiclePage(),
      };
}
