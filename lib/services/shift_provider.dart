// ignore_for_file: avoid_print

import 'package:shiftrek/models/shift.dart';
import 'package:shiftrek/services/utils.dart';
import 'package:flutter/material.dart';
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
    });
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

  void getShifts() async {
    _isLoading = true;
    queryCount++;

    final ss = await gsheets.spreadsheet(spreadsheetId);
    final sheet = ss.worksheetByTitle('24');

    if (sheet == null) {
      throw Exception('Sheet not found');
    }

    await sheet.values.allRows(fromRow: 2).then((table) {
      for (var row = 0; row < table.length; row += 2) {
        for (var col = 0; col < 7; col++) {
          if (row < table.length - 1) {
            DateTime date = sheetToDate(table[row][col]);
            String cell = table[row + 1][col];

            if (cell != '.' && cell != 'Holiday' && cell != 'Off Day') {
              List<String> timeRange = cell.split('-');
              _shifts.add(Shift(
                title: 'Shift',
                date: date,
                startTime: sheetToTime(timeRange[0]),
                endTime: sheetToTime(timeRange[1]),
                isOffDay: false,
                color: MyColors.oliveGreen,
                column: col + 1,
                row: row + 3,
              ));
            } else if (cell == 'Off Day') {
              _shifts.add(Shift(
                title: 'Off Day',
                date: date,
                startTime: const TimeOfDay(hour: 0, minute: 0),
                endTime: const TimeOfDay(hour: 0, minute: 0),
                isOffDay: true,
                color: MyColors.ceruleanBlue,
                column: col + 1,
                row: row + 3,
              ));
            } else if (cell == 'Holiday') {
              _shifts.add(Shift(
                title: 'Holiday',
                date: date,
                startTime: const TimeOfDay(hour: 0, minute: 0),
                endTime: const TimeOfDay(hour: 0, minute: 0),
                isOffDay: false,
                color: MyColors.ultramarineBlue,
                column: col + 1,
                row: row + 3,
              ));
            } else if (cell == '.') {
              _shifts.add(Shift.empty(date, col + 1, row + 3));
            }
          }
        }
      }
      _isLoading = false;
      statusIcon = Icons.download_for_offline;
      statusIconColor = Colors.green.shade500;
      notifyListeners();
    });
  }

  void updateShift(Shift shift) async {
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final sheet = ss.worksheetByTitle('24');

    if (sheet == null) {
      throw Exception('Sheet not found');
    }

    String cellValue =
        '${shift.startTime.to24hours()} - ${shift.endTime.to24hours()}';

    if (shift.title == 'Off Day' || shift.title == 'Holiday') {
      cellValue = shift.title;
    }

    await sheet.values
        .insertValue(cellValue, column: shift.column!, row: shift.row!)
        .then((value) {
      if (value) {
        shifts[shifts.indexWhere(
            (element) => element.date.isSameDate(shift.date))] = shift;
        statusIcon = Icons.update;
        statusIconColor = Colors.yellow.shade500;
        notifyListeners();
      }
    });
  }

  void pasteShift(Shift originalShift) {
    if (_copiedShift != null && isCopied) {
      updateShift(Shift(
          date: originalShift.date,
          column: originalShift.column,
          row: originalShift.row,
          title: _copiedShift!.title,
          startTime: _copiedShift!.startTime,
          endTime: _copiedShift!.endTime,
          isOffDay: _copiedShift!.isOffDay,
          color: _copiedShift!.color));
      isCopied = false;
    }
  }

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
