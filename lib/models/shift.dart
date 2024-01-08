import 'package:shiftrek/services/utils.dart';
import 'package:flutter/material.dart';

class Shift {
  String? id;
  int? column;
  int? row;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isOffDay;
  final Color color;

  Shift({
    this.id,
    this.column,
    this.row,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isOffDay,
    required this.color,
  });

  Shift.empty(DateTime dateData, int this.column, int this.row)
      : title = '',
        date = dateData,
        startTime = const TimeOfDay(hour: 0, minute: 0),
        endTime = const TimeOfDay(hour: 0, minute: 0),
        isOffDay = false,
        color = Colors.transparent;

  String get timeRange {
    String range = '${startTime.to24hours()} - ${endTime.to24hours()}';
    return range == "00:00 - 00:00" ? '' : range;
  }

  double get getHours {
    double hours;
    if (title == 'Holiday') {
      return 8;
    }
    int startTimeSec = (startTime.hour * 60 + startTime.minute) * 60;
    int endTimeSec = (endTime.hour * 60 + endTime.minute) * 60;
    int midNightSec = 24 * 60 * 60;
    if (endTimeSec < startTimeSec) {
      hours = ((midNightSec - startTimeSec) + endTimeSec) / 3600;
      if (hours > 6) {
        hours -= 0.25;
      }
      return hours;
    }
    hours = (endTimeSec - startTimeSec) / 3600;
    if (hours > 6) {
      hours -= 0.25;
    }
    return hours;
  }

  @override
  String toString() {
    return "(${date.year},${date.month},${date.day},$title)";
  }
}
