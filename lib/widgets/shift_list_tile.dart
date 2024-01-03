import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftrek/services/utils.dart';
import 'package:shiftrek/widgets/shift_tile_menu.dart';

import '../models/shift.dart';
import '../services/my_revenue.dart';
import '../services/shift_provider.dart';

class ShiftListTile extends StatelessWidget {
  final Shift shift;
  final DateTime dateOfDay;
  const ShiftListTile({
    super.key,
    required this.shift,
    required this.dateOfDay,
  });

  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftProvider>(context);
    return ListTile(
      tileColor: MyColors.gunMetal.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: MyColors.charCoal,
          width: 2.0,
        ),
      ),
      leading: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${dateOfDay.day}',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: shift.date.isSameDate(DateTime.now())
                  ? MyColors.springGreen.withAlpha(197)
                  : MyColors.platinum.withAlpha(154),
            ),
          ),
          Text(
            DateFormat.E().format(dateOfDay),
            style: TextStyle(
              fontSize: 16.0,
              fontFamily: 'Roboto',
              color: shift.date.isSameDate(DateTime.now())
                  ? MyColors.springGreen.withAlpha(197)
                  : MyColors.platinum.withAlpha(154),
            ),
          ),
        ],
      ),
      title: Text(
        shift.title,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
          color: shift.color,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shift.timeRange,
            style: const TextStyle(
              fontSize: 16.5,
              fontFamily: 'Roboto',
              color: MyColors.platinum,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              shift.date.weekday == 3 && shift.color != Colors.transparent
                  ? TextButton.icon(
                      onPressed: null,
                      icon: const Icon(
                        Icons.schedule,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                      label: Text(
                        '${shiftProvider.getShiftHoursForWeek(shift.date)}',
                        style: TextStyle(
                            color: MyColors.platinum.withAlpha(154),
                            fontSize: 12),
                      ))
                  : const Text(''),
              shift.date.weekday == 3 && shift.color != Colors.transparent
                  ? TextButton.icon(
                      onPressed: null,
                      icon: const Icon(
                        Icons.euro,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                      label: Text(
                        '${shiftProvider.getWagesAfterTax(shiftProvider.getShiftHoursForWeek(shift.date) * MyRevenue.payRate)}',
                        style: TextStyle(
                            color: MyColors.platinum.withAlpha(154),
                            fontSize: 12),
                      ),
                    )
                  : const Text(''),
            ],
          ),
        ],
      ),
      trailing: ShiftTileMenu(shift: shift, dateOfDay: dateOfDay),
    );
  }
}
