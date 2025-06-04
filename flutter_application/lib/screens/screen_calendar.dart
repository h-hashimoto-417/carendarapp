import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScreenCalendar extends StatelessWidget{
  const ScreenCalendar({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
      ),
      body: TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1), 
      lastDay: DateTime.utc(2050, 12, 31),
      focusedDay: DateTime.now(),
      locale: 'ja_JP',
      )
    );
  }
}