import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/shift_provider.dart';

class MonthDropDown extends StatelessWidget {
  const MonthDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftProvider>(context);
    return DropdownButton<int>(
      value: shiftProvider.month,
      items: [
        for (int i = 1; i <= 12; i++)
          DropdownMenuItem(
            value: i,
            child: Text(DateTime.now().month == i
                ? DateFormat.MMMM().format(DateTime(2023, i))
                : DateFormat.MMMM().format(DateTime(2023, i))),
          ),
      ],
      onChanged: (value) {
        shiftProvider.month = value!;
      },
    );
  }
}
