import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScreenCalendar extends StatefulWidget {
  const ScreenCalendar({super.key});

  @override
  State<ScreenCalendar> createState() => _ScreenCalendarState();
}

class _ScreenCalendarState extends State<ScreenCalendar>{
  DateTime _focusedDay = DateTime.now();

  void _goToPreviousMonth(){
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
  }

  void _goToNextMonth(){
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
      ),
      body: TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1), 
      lastDay: DateTime.utc(2050, 12, 31),
      focusedDay: _focusedDay,
      locale: 'ja_JP',
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronVisible: false,
        rightChevronVisible: false,
      ),
      onPageChanged: (newFocusedDay){
        setState(() {
          _focusedDay = newFocusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, day){
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  Text(
                    '${day.year}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ), 
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _goToPreviousMonth,
                  ),
                
                  Text(
                    '${day.month}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _goToNextMonth,
                  ),
                ],
              ),
           ],
          );
        },
      ),
      )
    );
  }
}