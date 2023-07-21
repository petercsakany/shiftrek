import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftrek/services/utils.dart';
import '../models/shift.dart';
import '../services/shift_provider.dart';

class AddShiftPage extends StatefulWidget {
  final Shift? shiftToEdit;
  const AddShiftPage({super.key, this.shiftToEdit});

  @override
  // ignore: library_private_types_in_public_api
  _AddShiftPageState createState() => _AddShiftPageState();
}

class _AddShiftPageState extends State<AddShiftPage> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late String _selectedTitle;
  late Color _selectedColor;
  late bool _isOffDay;

  final List<String> _titleList = ['Shift', 'Off Day', 'Holiday', 'Sick Leave'];
  final List<Color> _colorList = [
    MyColors.oliveGreen,
    MyColors.ceruleanBlue,
    MyColors.ultramarineBlue,
  ];

  late bool snackShown;

  @override
  void initState() {
    super.initState();
    if (widget.shiftToEdit == null) {
      _selectedDate = DateTime.now();
      _selectedStartTime = TimeOfDay.now();
      _selectedEndTime = TimeOfDay.now();
      _selectedTitle = 'Shift';
      _selectedColor = const Color(0xFF81b051);
      _isOffDay = false;
    } else {
      _selectedDate = widget.shiftToEdit!.date;
      _selectedStartTime = widget.shiftToEdit!.startTime;
      _selectedEndTime = widget.shiftToEdit!.endTime;
      _selectedTitle = widget.shiftToEdit!.title;
      _selectedColor = widget.shiftToEdit!.color;
      _isOffDay = widget.shiftToEdit!.isOffDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shiftToEdit == null ? 'Add Shift' : 'Edit Shift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedTitle,
                onChanged: (value) {
                  setState(() {
                    _selectedTitle = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                items: _titleList.map<DropdownMenuItem<String>>((title) {
                  return DropdownMenuItem<String>(
                    value: title,
                    child: Text(title),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextButton(
                      child: Text(
                          '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              _selectedDate = value;
                            });
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  const Icon(Icons.schedule),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextButton(
                      child: Text(_selectedStartTime.format(context)),
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: _selectedStartTime,
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              _selectedStartTime = value;
                            });
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextButton(
                      child: Text(_selectedEndTime.format(context)),
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: _selectedEndTime,
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              _selectedEndTime = value;
                            });
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(children: [
                const Text('Is Off Day'),
                const SizedBox(width: 16.0),
                Checkbox(
                  value: _isOffDay,
                  onChanged: (value) {
                    setState(() {
                      _isOffDay = value!;
                    });
                  },
                ),
              ]),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<Color>(
                value: _selectedColor,
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Color',
                ),
                items: _colorList.map<DropdownMenuItem<Color>>((color) {
                  return DropdownMenuItem<Color>(
                    value: color,
                    child: Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Shift newShift = Shift(
                      title: _selectedTitle,
                      date: _selectedDate,
                      startTime: _selectedStartTime,
                      endTime: _selectedEndTime,
                      isOffDay: _isOffDay,
                      color: _selectedColor,
                    );
                    snackShown = true;
                    if (widget.shiftToEdit != null) {
                      shiftProvider
                          .updateShift(newShift..id = widget.shiftToEdit?.id);
                    } else {
                      shiftProvider.addShift(newShift);
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
