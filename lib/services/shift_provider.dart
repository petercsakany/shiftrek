// ignore_for_file: avoid_print

import 'package:shiftrek/models/shift.dart';
import 'package:shiftrek/services/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShiftProvider with ChangeNotifier {
  List<Shift> _shifts = [];
  List<Shift> get shifts => _shifts;
  set shifts(List<Shift> shifts) {
    _shifts.addAll(shifts);
    notifyListeners();
  }

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

  int _year = DateTime.now().year;
  int _month = DateTime.now().month;

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
    DateTime startOfWeek = startDate.subtract(const Duration(days: 0));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    for (Shift shift in shifts) {
      if (!shift.date.isBefore(startOfWeek) && !shift.date.isAfter(endOfWeek)) {
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

  Future<void> fetchShifts() async {
    _isLoading = true;
    queryCount++;
    statusIcon = Icons.download_for_offline;
    final shiftsCollection = FirebaseFirestore.instance
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: DateTime(year, month, 1))
        .where('date',
            isLessThanOrEqualTo:
                DateTime(year, month + 1, 1).subtract(const Duration(days: 1)));
    final snapshot =
        await shiftsCollection.get().whenComplete(() => _isLoading = false);
    shifts = snapshot.docs.map((doc) => Shift.fromDocument(doc)).toList();
  }

  void pasteShift(DateTime date) {
    if (_copiedShift != null && isCopied) {
      addShift(_copiedShift!, date);
      isCopied = false;
    }
  }

  void addShift(Shift shift, [DateTime? newDate]) {
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
      notifyListeners();
    });
  }

  Future<void> updateShift(Shift newShift) {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(newShift.id)
        .update(newShift.toMap())
        .then((value) {
      shifts[shifts.indexWhere((element) => element.id == newShift.id)] =
          newShift;
      statusIcon = Icons.update;
      notifyListeners();
    }).catchError((err) {
      statusIcon = Icons.error;
    });
  }

  Future<void> deleteShift(Shift shift) async {
    final shiftsCollection = FirebaseFirestore.instance.collection('events');
    await shiftsCollection.doc(shift.id).delete();
    shiftsRem = _shifts.where((e) => e.id != shift.id).toList();
  }
}