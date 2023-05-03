import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models/shift.dart';
import '../services/shift_provider.dart';
import '../widgets/month_dropdown.dart';
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
  late ItemScrollController _itemScrollController;

  @override
  void initState() {
    super.initState();
    _itemScrollController = ItemScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Provider.of<ShiftProvider>(context, listen: false).shifts.isEmpty) {
        Provider.of<ShiftProvider>(context, listen: false).fetchShifts();
      }
    });
  }

  @override
  Widget build(BuildContext mainContext) {
    final shiftProvider = Provider.of<ShiftProvider>(mainContext);
    shifts = shiftProvider.getShiftsForMonth();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Schedule List v1.1'),
            TextButton.icon(
                onPressed: null,
                icon: Icon(shiftProvider.statusIcon),
                label: shiftProvider.statusIcon == Icons.download_for_offline
                    ? Text('${shiftProvider.queryCount}')
                    : const Text(''))
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
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: MonthDropDown(),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                  icon: const Icon(Icons.gps_fixed),
                                  onPressed: () {
                                    _itemScrollController.scrollTo(
                                        index: DateTime.now().day - 1,
                                        duration: const Duration(seconds: 1));
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
                          initialScrollIndex: DateTime.now().day - 1,
                          itemBuilder: (context, index) {
                            DateTime dateOfDay = DateTime(shiftProvider.year,
                                shiftProvider.month, index + 1);

                            Shift shift =
                                shiftProvider.getShiftForDay(dateOfDay, shifts);

                            return ShiftDismissible(
                              shift: shift,
                              dateOfDay: dateOfDay,
                            );
                          },
                          itemCount: DateTime(shiftProvider.year,
                                  shiftProvider.month + 1, 0)
                              .day,
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
