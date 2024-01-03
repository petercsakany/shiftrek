// ignore_for_file: avoid_print

import 'package:shiftrek/services/utils.dart';
import 'package:flutter/material.dart';

class Shift {
  String? id;
  String? cellName;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isOffDay;
  final Color color;

  Shift({
    this.id,
    this.cellName,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isOffDay,
    required this.color,
  });

  Shift.empty(DateTime dateData)
      : title = '',
        date = dateData,
        startTime = const TimeOfDay(hour: 0, minute: 0),
        endTime = const TimeOfDay(hour: 0, minute: 0),
        isOffDay = false,
        color = Colors.transparent;

  /*factory Shift.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Shift(
      id: doc.id,
      title: data['title'],
      date: (data['date'] as Timestamp).toDate(),
      startTime: firebaseToTimeOfDay(data['startTime']),
      endTime: firebaseToTimeOfDay(data['endTime']),
      isOffDay: data['isOffDay'],
      color: Color(data['color']),
    );
  }*/

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
        title: json['title'],
        date: DateTime.parse(json['date']),
        startTime: TimeOfDay(
            hour: int.parse(json['startTime'].split(':')[0]),
            minute: int.parse(json['startTime'].split(':')[1])),
        endTime: TimeOfDay(
            hour: int.parse(json['endTime'].split(':')[0]),
            minute: int.parse(json['endTime'].split(':')[1])),
        isOffDay: json['isOffDay'] == 'true',
        color: Color(json['color']),
        cellName: json['cellName']);
  }

  /*Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'startTime': timeOfDayToFirebase(startTime),
      'endTimeHour': timeOfDayToFirebase(endTime),
      'isOffDay': isOffDay,
      'color': color.value,
    };
  }*/

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'isOffDay': isOffDay.toString(),
      'cellName': cellName
    };
  }

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
