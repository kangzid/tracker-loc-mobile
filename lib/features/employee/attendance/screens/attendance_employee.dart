import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_1/features/auth/auth_storage.dart';
import 'package:flutter_application_1/core/config/api_config.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widgets/attendance_calendar.dart';
import '../widgets/attendance_legend.dart';
import '../widgets/attendance_stats_card.dart';

class AttendanceEmployeePage extends StatefulWidget {
  const AttendanceEmployeePage({super.key});

  @override
  State<AttendanceEmployeePage> createState() => _AttendanceEmployeePageState();
}

class _AttendanceEmployeePageState extends State<AttendanceEmployeePage> {
  Map<DateTime, String> _attendanceStatus = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _loadAttendanceData();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
  }

  Future<void> _loadAttendanceData() async {
    final data = await AuthStorage().getLoginData();
    _token = data['token'];

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.attendances}/monthly'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        Map<DateTime, String> temp = {};

        for (var item in jsonData) {
          DateTime date = DateTime.parse(item['date']).toLocal();
          String status = item['status'] ?? 'izin';
          temp[DateTime(date.year, date.month, date.day)] = status;
        }

        setState(() {
          _attendanceStatus = temp;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        debugPrint("Failed to load attendance: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching attendance: $e");
      setState(() => _isLoading = false);
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'present':
        return "Hadir";
      case 'absent':
        return "Tidak Hadir";
      case 'late':
        return "Terlambat";
      default:
        return "Izin / Tidak Ada Data";
    }
  }

  // === RINGKASAN DATA ===
  Future<Map<String, int>> _getAttendanceSummary() async {
    int present = 0, late = 0, absent = 0, izin = 0;
    _attendanceStatus.forEach((_, status) {
      switch (status) {
        case 'present':
          present++;
          break;
        case 'late':
          late++;
          break;
        case 'absent':
          absent++;
          break;
        default:
          izin++;
      }
    });
    return {'present': present, 'late': late, 'absent': absent, 'izin': izin};
  }

  // === POPUP DETAIL ===
  void _showAttendanceDetail(DateTime day) {
    final status = _attendanceStatus[DateTime(day.year, day.month, day.day)];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Detail Kehadiran"),
        content: Text(
          "${day.day}-${day.month}-${day.year}\nStatus: ${_getStatusLabel(status)}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kehadiran Saya"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AttendanceCalendar(
                    attendanceStatus: _attendanceStatus,
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    calendarFormat: _calendarFormat,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _showAttendanceDetail(selectedDay);
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const AttendanceLegend(),
                  const SizedBox(height: 20),
                  FutureBuilder<Map<String, int>>(
                    future: _getAttendanceSummary(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final data = snapshot.data!;
                      final totalDaysInMonth = DateUtils.getDaysInMonth(
                        _focusedDay.year,
                        _focusedDay.month,
                      );
                      final hadir = data['present']!;
                      final terlambat = data['late']!;
                      final absen = data['absent']!;
                      final izin = data['izin']!;

                      final hadirPercent =
                          totalDaysInMonth > 0 ? hadir / totalDaysInMonth : 0.0;
                      final terlambatPercent = totalDaysInMonth > 0
                          ? terlambat / totalDaysInMonth
                          : 0.0;
                      final absenPercent =
                          totalDaysInMonth > 0 ? absen / totalDaysInMonth : 0.0;
                      final izinPercent =
                          totalDaysInMonth > 0 ? izin / totalDaysInMonth : 0.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AttendanceStatsCard(
                            present: hadir,
                            late: terlambat,
                            absent: absen,
                            permission: izin,
                          ),
                          const Text(
                            "Persentase Kehadiran Bulan Ini",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: (hadirPercent * 1000).round(),
                                  child: Container(
                                      height: 10, color: Colors.green),
                                ),
                                Expanded(
                                  flex: (terlambatPercent * 1000).round(),
                                  child: Container(
                                      height: 10, color: Colors.orange),
                                ),
                                Expanded(
                                  flex: (absenPercent * 1000).round(),
                                  child:
                                      Container(height: 10, color: Colors.red),
                                ),
                                Expanded(
                                  flex: (izinPercent * 1000).round(),
                                  child:
                                      Container(height: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${(hadirPercent * 100).toStringAsFixed(1)}% hadir dari $totalDaysInMonth hari",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
