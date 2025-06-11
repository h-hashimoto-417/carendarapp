import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:table_calendar/table_calendar.dart';

class ScreenCalendar extends HookWidget {
  const ScreenCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDayState = useState(DateTime.now());
    final focusedDayState = useState(DateTime.now());

    void goToPreviousMonth() {
      focusedDayState.value = DateTime(
        focusedDayState.value.year,
        focusedDayState.value.month - 1,
      );
    }

    void goToNextMonth() {
      focusedDayState.value = DateTime(
        focusedDayState.value.year,
        focusedDayState.value.month + 1,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(1980, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: focusedDayState.value,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDayState.value, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              selectedDayState.value = selectedDay;
              focusedDayState.value = focusedDay;
            },
            locale: 'ja_JP',
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronVisible: false,
              rightChevronVisible: false,
            ),
            onPageChanged: (newFocusedDay) {
              focusedDayState.value = newFocusedDay;
            },
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, day) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${focusedDayState.value.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: goToPreviousMonth,
                        ),
                        Text(
                          '${focusedDayState.value.month}',
                          style: const TextStyle(fontSize: 20),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: goToNextMonth,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
