import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/shift_provider.dart';

class YearDropDown extends StatelessWidget {
  const YearDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftProvider>(context);
    return DropdownButton<int>(
      value: shiftProvider.year,
      items: const [
        DropdownMenuItem(
          value: 2023,
          child: Text('2023'),
        ),
        DropdownMenuItem(
          value: 2024,
          child: Text('2024'),
        ),
      ],
      onChanged: (value) {
        shiftProvider.year = value!;
      },
    );
  }
}
