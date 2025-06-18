import 'package:flutter/material.dart';
import 'package:flutter_application/data/TaskManager.dart';
import 'package:flutter_application/data/database.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ScreenCalendar extends HookConsumerWidget {
  const ScreenCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDayState = useState(DateTime.now());
    final focusedDayState = useState(DateTime.now());
    final panelController = useMemoized(() => PanelController());
    final selectedTasksState = useState([]);
    final taskProvider = ref.watch(taskControllerProvider);
    final taskColors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.pink,
    Colors.cyan,
    Colors.orange,
    Colors.purple,
    Colors.lightGreen,
    Colors.black,
    ];


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

    List<Task> getTasksForDay(DateTime day) {
      final tasks = taskProvider
          .where((task) => isSameDay(task.startTime, day))
          .toList();
      tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
      return tasks;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
      ),

      body: 
      SlidingUpPanel(
        controller: panelController,
        minHeight: 60,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
        panelBuilder: (sc) {
          final tasks = getTasksForDay(selectedDayState.value);
          return Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4)
                ),
              ),
              Text(
                '${selectedDayState.value.year}/${selectedDayState.value.month}/${selectedDayState.value.day}の予定',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: sc,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(
                        '${task.startTime.hour}時：${task.title}',
                        ),
                      subtitle: Text('必要時間：${task.requiredHours}h'),
                      leading: CircleAvatar(
                        backgroundColor: Color(task.color),
                      ),
                    );
                  },
                )
              )
            ],
          );
        },
      
      body: 
          TableCalendar<Task>(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: focusedDayState.value,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDayState.value, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              selectedDayState.value = selectedDay;
              focusedDayState.value = focusedDay;
              if (panelController.isPanelClosed) {
                  panelController.open(); // 日付タップ時にパネル開く
                }
            },
            eventLoader: (date){
              return getTasksForDay(date);
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
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.take(3).map((event) {
                    final task = event as Task;
                    final colorIndex = task.color.clamp(0, 9);
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: taskColors[colorIndex],
                      ),
                    );
                  }).toList(),
                );
              }
            ),
          ),
      ),
    );
  }
}
