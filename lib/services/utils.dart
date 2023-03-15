import 'package:flutter/material.dart';

Map timeOfDayToFirebase(TimeOfDay timeOfDay) {
  return {'hour': timeOfDay.hour, 'minute': timeOfDay.minute};
}

TimeOfDay firebaseToTimeOfDay(Map data) {
  return TimeOfDay(hour: data['hour'], minute: data['minute']);
}

SnackBar snackBar(String text) {
  return SnackBar(
      backgroundColor: Colors.black54,
      content: Text(
        text,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ));
}

class MyColors {
  static const Color oliveGreen = Color(0xFF81b051);
  static const Color ceruleanBlue = Color(0xFF039BE5);
  static const Color ultramarineBlue = Color(0xFF7986CB);
  static const Color gunMetal = Color(0xFF575b6d);
  static const Color charCoal = Color(0xFF202123);
  static const Color springGreen = Color(0xFF69F0AF);
  static const Color platinum = Color(0xFFE0E3D2);
  static const Color eggBlue = Color(0xFF9AE0E3);
}

extension TimeOfDayConverter on TimeOfDay {
  String to24hours() {
    final hour = this.hour.toString().padLeft(2, "0");
    final min = minute.toString().padLeft(2, "0");
    return "$hour:$min";
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension WeekNumberFromDate on DateTime {
  int weekNumber() {
    final firstJan = DateTime(DateTime.now().year, 1, 1);
    final from = DateTime.utc(firstJan.year, firstJan.month, firstJan.day);
    final to = DateTime.utc(year, month, day);
    return (to.difference(from).inDays / 7).ceil();
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
