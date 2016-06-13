import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import '../../auth/auth_storage.dart';
import '../../../config/api_config.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  Color _getColorForStatus(String? status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey; // izin atau null
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
                  // === KALENDER KEHADIRAN ===
                  TableCalendar(
                    locale: 'id_ID',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final status = _attendanceStatus[
                            DateTime(day.year, day.month, day.day)];
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getColorForStatus(status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: _getColorForStatus(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final status = _attendanceStatus[
                            DateTime(day.year, day.month, day.day)];
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getColorForStatus(status).withOpacity(0.25),
                            border:
                                Border.all(color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: _getColorForStatus(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Colors.redAccent),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // === LEGEND WARNA ===
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildLegend(Colors.green, "Hadir"),
                      _buildLegend(Colors.orange, "Terlambat"),
                      _buildLegend(Colors.red, "Tidak Hadir"),
                      _buildLegend(Colors.grey, "Izin / Tidak Ada Data"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // === STATISTIK BULANAN ===
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

                      final hadirPercent = hadir / totalDaysInMonth;
                      final terlambatPercent = terlambat / totalDaysInMonth;
                      final absenPercent = absen / totalDaysInMonth;
                      final izinPercent = izin / totalDaysInMonth;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStat("Hadir", hadir, Colors.green),
                                  _buildStat(
                                      "Terlambat", terlambat, Colors.orange),
                                  _buildStat("Absen", absen, Colors.red),
                                  _buildStat("Izin", izin, Colors.grey),
                                ],
                              ),
                            ),
                          ),

                          const Text(
                            "Persentase Kehadiran Bulan Ini",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 6),

                          // === MODERN MULTICOLOR BAR ===
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

  // === LEGEND ===
  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  // === STAT CARD ===
  Widget _buildStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
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
}
