import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceCalendar extends StatelessWidget {
  final Map<DateTime, String> attendanceStatus;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;

  const AttendanceCalendar({
    super.key,
    required this.attendanceStatus,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
  });

  Color _getColorForStatus(String? status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'id_ID',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      calendarFormat: calendarFormat,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final status =
              attendanceStatus[DateTime(day.year, day.month, day.day)];
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
          final status =
              attendanceStatus[DateTime(day.year, day.month, day.day)];
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _getColorForStatus(status).withOpacity(0.25),
              border: Border.all(color: Colors.blueAccent, width: 2),
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
    );
  }
}
