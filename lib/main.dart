// ignore_for_file: non_constant_identifier_names, avoid_print
import 'package:shiftrek/screens/schedule_list.dart';
import 'package:shiftrek/services/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shiftrek',
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ),
        home: const ScheduleList(),
      ),
    );
  }
}
