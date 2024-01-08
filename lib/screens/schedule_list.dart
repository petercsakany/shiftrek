import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shiftrek/services/utils.dart';
import '../models/shift.dart';
import '../services/shift_provider.dart';
import '../widgets/shift_dismissible.dart';
import '../widgets/year_dropdown.dart';

class ScheduleList extends StatefulWidget {
  const ScheduleList({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  List<Shift> shifts = [];
  List<DateTime> days = [];
  late ItemScrollController _itemScrollController;
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    _itemScrollController = ItemScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Provider.of<ShiftProvider>(context, listen: false).shifts.isEmpty) {
        Provider.of<ShiftProvider>(context, listen: false).getShifts();
      }
    });
  }

  @override
  Widget build(BuildContext mainContext) {
    final shiftProvider = Provider.of<ShiftProvider>(mainContext);
    shifts = shiftProvider.shifts;
    days = shiftProvider.getAllDaysOfYear(2024);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Schedule List v1.3'),
            TextButton.icon(
                onPressed: null,
                icon: Icon(
                  shiftProvider.statusIcon,
                  color: shiftProvider.statusIconColor,
                ),
                label: shiftProvider.statusIcon == Icons.download_for_offline
                    ? Text('${shiftProvider.queryCount}')
                    : Text(shiftProvider.errormsg.toString()))
          ],
        ),
      ),
      body: shiftProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Consumer<ShiftProvider>(
                builder: (context, shiftProvider, child) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: YearDropDown(),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ValueListenableBuilder(
                                valueListenable:
                                    _itemPositionsListener.itemPositions,
                                builder: (context, positions, _) {
                                  int? monthDisplayed;
                                  if (positions.isNotEmpty) {
                                    monthDisplayed = DateTime(2024, 1, 1)
                                        .add(Duration(
                                            days: positions.first.index))
                                        .month;
                                  }
                                  return DropdownButton<int>(
                                    isExpanded: true,
                                    value: monthDisplayed,
                                    items: [
                                      for (int i = 1; i <= 12; i++)
                                        DropdownMenuItem(
                                          value: i,
                                          child: Text(DateTime.now().month == i
                                              ? DateFormat.MMMM()
                                                  .format(DateTime(2024, i))
                                              : DateFormat.MMMM()
                                                  .format(DateTime(2024, i))),
                                        ),
                                    ],
                                    onChanged: (value) {
                                      DateTime firstDay =
                                          DateTime(2024, value!, 1);
                                      shiftProvider.month = value;
                                      _itemScrollController.scrollTo(
                                          index: firstDay.dayNumberOfYear(),
                                          duration: const Duration(seconds: 1));
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                  icon: const Icon(Icons.gps_fixed),
                                  onPressed: () {
                                    _itemScrollController.scrollTo(
                                        index: DateTime.now().dayNumberOfYear(),
                                        duration: const Duration(seconds: 2));
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Card(
                        color: const Color(0xFF202123),
                        child: ScrollablePositionedList.builder(
                          itemScrollController: _itemScrollController,
                          itemPositionsListener: _itemPositionsListener,
                          initialScrollIndex: DateTime.now().dayNumberOfYear(),
                          itemBuilder: (context, index) {
                            DateTime dateOfDay = days[index];

                            Shift shift =
                                shiftProvider.getShiftForDay(dateOfDay, shifts);

                            return ShiftDismissible(
                              shift: shift,
                              dateOfDay: dateOfDay,
                            );
                          },
                          itemCount: days.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
