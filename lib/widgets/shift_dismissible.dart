import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:provider/provider.dart';
import 'package:shiftrek/widgets/shift_list_tile.dart';

import '../models/shift.dart';
// ignore: unused_import
import '../services/shift_provider.dart';

class ShiftDismissible extends StatelessWidget {
  final Shift shift;
  final DateTime dateOfDay;
  const ShiftDismissible({
    super.key,
    required this.shift,
    required this.dateOfDay,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: shift.color == Colors.transparent
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete Shift'),
                content:
                    const Text('Are you sure you want to delete this shift?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          //Provider.of<ShiftProvider>(context, listen: false).deleteShift(shift);
        }
      },
      child: ShiftListTile(
        shift: shift,
        dateOfDay: dateOfDay,
      ),
    );
  }
}
