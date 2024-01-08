import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/shift.dart';
import '../screens/add_shift.dart';
import '../services/shift_provider.dart';

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
          child: const Row(
            children: [
              Icon(Icons.content_copy),
              SizedBox(width: 8.0),
              Text('Copy'),
            ],
          ),
          onTap: () {
            shiftProvider.copiedShift = shift;
            shiftProvider.statusIcon = Icons.copy_outlined;
            shiftProvider.statusIconColor = Colors.blueGrey;
          },
        ),
        PopupMenuItem(
          value: 'paste',
          enabled: shiftProvider.isCopied,
          child: const Row(
            children: [
              Icon(Icons.content_paste),
              SizedBox(width: 8.0),
              Text('Paste'),
            ],
          ),
          onTap: () {
            shiftProvider.pasteShift(shift);
          },
        ),
        PopupMenuItem(
          value: 'edit',
          child: const Row(
            children: [
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
