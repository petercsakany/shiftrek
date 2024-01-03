// ignore_for_file: avoid_print

import 'package:shiftrek/models/shift.dart';
import 'package:shiftrek/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gsheets/gsheets.dart';

import 'credentials.dart';
import 'my_revenue.dart';

class ShiftProvider with ChangeNotifier {
  List<Shift> _shifts = [];
  List<Shift> get shifts => _shifts;
  set shifts(List<Shift> shifts) {
    _shifts.addAll(shifts);
    notifyListeners();
  }

  final gsheets = GSheets(credentials);

  set shiftsRem(List<Shift> shifts) {
    _shifts = shifts;
    notifyListeners();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool isCopied = false;
  Shift? _copiedShift;
  Shift? get copiedShift => _copiedShift;
  set copiedShift(Shift? shift) {
    _copiedShift = shift;
    isCopied = true;
    notifyListeners();
  }

  int _queryCount = 0;
  int get queryCount => _queryCount;
  set queryCount(int count) {
    _queryCount = count;
    notifyListeners();
  }

  IconData statusIcon = Icons.download_for_offline;
  Color statusIconColor = Colors.blueGrey;
  String errormsg = "";

  int _year = 2024;
  int _month = 1;

  int get year => _year;
  int get month => _month;

  set year(int year) {
    _year = year;
    notifyListeners();
  }

  set month(int month) {
    _month = month;
    notifyListeners();
  }

  Shift getShiftForDay(DateTime day, List<Shift> shifts) {
    return shifts.firstWhere((shift) {
      return shift.date.isSameDate(day);
    }, orElse: () => Shift.empty(day));
  }

  double getShiftHoursForWeek(DateTime startDate) {
    double hours = 0;
    DateTime startOfWeek = startDate.subtract(const Duration(days: 3));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    for (Shift shift in shifts) {
      if (!shift.date.isBefore(startOfWeek) &&
          !shift.date.isAfter(endOfWeek) &&
          !shift.isOffDay) {
        hours += shift.getHours;
      }
    }
    return hours;
  }

  List<Shift> getShiftsForMonth() {
    return _shifts
        .where((shift) => shift.date.year == year && shift.date.month == month)
        .toList();
  }

  List<DateTime> getAllDaysOfYear(int year) {
    final List<DateTime> days = [];

    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year + 1, 1, 0);

    for (var date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      days.add(date);
    }

    return days;
  }

  Map<String, dynamic> createShift(String date, String startTime,
      String endTime, String title, bool isOffDay, int color) {
    return {
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'title': title,
      'isOffDay': isOffDay.toString(),
      'color': color
    };
  }

  void iterate() async {
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final sheet = ss.worksheetByTitle('24');

    if (sheet == null) {
      throw Exception('Sheet not found');
    }

    await sheet.values.allRows().then((table) {
      for (var row = 1; row < 2; row++) {
        for (var col = 0; col < 7; col++) {
          DateTime date = sheetToDate(table[row][col]);
          print(date);
          if (row < table.length - 1) {
            String cell = table[row + 1][col];
            if (cell != '.' && cell != 'Holiday' && cell != 'Off Day') {
              List<String> timeRange = cell.split('-');
              print(sheetToTime(timeRange[0]).to24hours());
            }
          }
        }
      }
    });
  }

  Future<void> getShifts() async {
    _isLoading = false;
    queryCount++;

    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      List<dynamic> shiftsJson = json.decode(response.body);

      //shifts = shiftsJson.map((json) => Shift.fromJson(json)).toList();
      statusIcon = Icons.download_for_offline;
      statusIconColor = Colors.green.shade500;
    } else {
      statusIcon = Icons.error;
      statusIconColor = Colors.red.shade500;
      errormsg = 'Error';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNewShift(Shift shift) async {
    final String jsonData = jsonEncode(shift.toJson());
    const String url = uri;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: jsonData);

    if (response.statusCode == 200) {
      _shifts.add(shift);
      statusIcon = Icons.add_task;
      statusIconColor = Colors.blue.shade500;
    } else {
      statusIcon = Icons.error;
      statusIconColor = Colors.red.shade500;
      errormsg = 'Error adding';
    }
    notifyListeners();
  }

  /*Future<void> fetchShifts() async {
    _isLoading = true;
    queryCount++;
    statusIcon = Icons.download_for_offline;
    statusIconColor = Colors.green.shade500;
    final shiftsCollection = FirebaseFirestore.instance
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: DateTime(year, 1, 1))
        .where('date', isLessThanOrEqualTo: DateTime(year, 12, 31));
    final snapshot =
        await shiftsCollection.get().whenComplete(() => _isLoading = false);
    shifts = snapshot.docs.map((doc) => Shift.fromDocument(doc)).toList();
  }*/

  void pasteShift(DateTime date) {
    if (_copiedShift != null && isCopied) {
      //addShift(_copiedShift!, date);
      isCopied = false;
    }
  }

  /*void addShift(Shift shift, [DateTime? newDate]) {
    DateTime shiftDate = newDate ?? shift.date;

    FirebaseFirestore.instance.collection('events').add({
      'title': shift.title,
      'date': Timestamp.fromDate(shiftDate),
      'startTime': timeOfDayToFirebase(shift.startTime),
      'endTime': timeOfDayToFirebase(shift.endTime),
      'isOffDay': shift.isOffDay,
      'color': shift.color.value,
    }).then((value) {
      _shifts.add(Shift(
          id: value.id,
          title: shift.title,
          date: shiftDate,
          startTime: shift.startTime,
          endTime: shift.endTime,
          isOffDay: shift.isOffDay,
          color: shift.color));
      statusIcon = Icons.add_task;
      statusIconColor = Colors.blue.shade500;
      notifyListeners();
    });
  }*/

  /*Future<void> updateShift(Shift newShift) {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(newShift.id)
        .update(newShift.toMap())
        .onError((error, stackTrace) {
      errormsg = error.toString();
      return null;
    }).then((value) {
      shifts[shifts.indexWhere((element) => element.id == newShift.id)] =
          newShift;
      statusIcon = Icons.update;
      statusIconColor = Colors.yellow.shade500;
      notifyListeners();
    }).catchError((err) {
      statusIcon = Icons.error;
      statusIconColor = Colors.red.shade500;
    });
  }*/

  /*Future<void> deleteShift(Shift shift) async {
    final shiftsCollection = FirebaseFirestore.instance.collection('events');
    await shiftsCollection.doc(shift.id).delete();
    shiftsRem = _shifts.where((e) => e.id != shift.id).toList();
    statusIcon = Icons.delete_forever;
    statusIconColor = Colors.deepOrange.shade500;
  }*/

  double getWagesAfterTax(double grossPay) {
    double wages = 0, paye = 0, usc = 0, prsi = 0;
    double taxCredits = MyRevenue.taxCredits;

    if (grossPay == 0 || grossPay.isNaN) {
      wages = 0;
      return wages;
    }

    //paye
    if (grossPay < MyRevenue.payeTreshold) {
      paye = (grossPay * MyRevenue.payeTresholdLowerPrc) - taxCredits;
    } else {
      paye = (grossPay * MyRevenue.payeTresholdHigherPrc) - taxCredits;
    }
    paye = paye.toFixed2();

    //usc
    if (grossPay > MyRevenue.uscTreshold1) {
      usc = (MyRevenue.uscTreshold1 * MyRevenue.uscTreshold1Prc);
      var tres = MyRevenue.uscTreshold1 + MyRevenue.uscTreshold2;
      if (grossPay < tres) {
        usc +=
            ((grossPay - MyRevenue.uscTreshold1) * MyRevenue.uscTreshold2Prc);
      } else {
        usc += (MyRevenue.uscTreshold2 * MyRevenue.uscTreshold2Prc) +
            ((grossPay - tres) * MyRevenue.uscTreshold3Prc);
      }
      usc = usc.toFixed2();
    }

    //prsi
    if (grossPay > MyRevenue.prsiMinTreshold &&
        grossPay < MyRevenue.prsiMaxTreshold) {
      prsi = (grossPay * MyRevenue.prsiTresholdPrc) -
          (12 - ((grossPay - MyRevenue.prsiMinTreshold) / 6));
    } else if (grossPay > MyRevenue.prsiMaxTreshold) {
      prsi = grossPay * MyRevenue.prsiTresholdPrc;
    }
    prsi = prsi.toFixed2();

    //wages after tax
    wages = grossPay - paye - usc - prsi;
    wages = wages.toFixed2();

    return wages;
  }
}
