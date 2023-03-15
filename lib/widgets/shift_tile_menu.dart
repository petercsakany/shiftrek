import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/shift.dart';
import '../screens/add_shift.dart';
import '../services/shift_provider.dart';
import '../services/utils.dart';

class ShiftTileMenu extends StatelessWidget {
  final DateTime dateOfDay;
  final Shift shift;
  const ShiftTileMenu({
    super.key,
    required this.shift,
    required this.dateOfDay,
  });

  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftProvider>(context);
    return PopupMenuButton(
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddShiftPage(
                shiftToEdit: shift,
              ),
            ),
          );
        }
      },
      icon: const Icon(
        Icons.more_vert,
        color: Color(0xFFe0e3d2),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          value: 'copy',
          enabled: !shiftProvider.isCopied && shift.color != Colors.transparent,
          child: Row(
            children: const [
              Icon(Icons.content_copy),
              SizedBox(width: 8.0),
              Text('Copy'),
            ],
          ),
          onTap: () {
            shiftProvider.copiedShift = shift;
            ScaffoldMessenger.of(context)
                .showSnackBar(snackBar('Shift copied'));
          },
        ),
        PopupMenuItem(
          value: 'paste',
          enabled: shiftProvider.isCopied,
          child: Row(
            children: const [
              Icon(Icons.content_paste),
              SizedBox(width: 8.0),
              Text('Paste'),
            ],
          ),
          onTap: () {
            shiftProvider.pasteShift(dateOfDay);
            ScaffoldMessenger.of(context)
                .showSnackBar(snackBar('Shift pasted'));
          },
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit),
              SizedBox(width: 8.0),
              Text('Edit'),
            ],
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
