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

    List<ScheduledTask> getScheduledTasksForDay(DateTime day) {
      final List<ScheduledTask> scheduledTasks = [];

      for (final task in taskProvider) {
        if (task.startTime == null) continue;
          for (final dt in task.startTime!) {
            if (isSameDay(dt, day)) {
              scheduledTasks.add(ScheduledTask(task: task, dateTime: dt));
            }
          }
      }

  // 開始日時でソート 
      scheduledTasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return scheduledTasks;
    }

    List<Widget> buildTaskTitles(DateTime date) {
      final tasks = getScheduledTasksForDay(date);
      final displayTasks = tasks.take(3).toList();

      if (displayTasks.isEmpty) return [];

      return displayTasks.map((scheduledTask) {
        final task = scheduledTask.task;
        final shortTitle = task.title.length > 7
          ? task.title.substring(0, 7)
          : task.title;
        final colorIndex = task.color.clamp(0, 9);
        return Text(
          shortTitle,
          style: TextStyle(
            fontSize: 10,
            color: taskColors[colorIndex],
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          '${focusedDayState.value.year}',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),

      body: 
      SlidingUpPanel(
        controller: panelController,
        minHeight: 60,
        maxHeight: MediaQuery.of(context).size.height * 0.4,
        panelBuilder: (sc) {
          final tasks = getScheduledTasksForDay(selectedDayState.value);
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
                    final scheduledTask = tasks[index];
                    final task = scheduledTask.task;
                    final dt = scheduledTask.dateTime;
                    return ListTile(
                      title: Text('${dt.hour}:00　${task.title}'),
                      subtitle: Text(task.comment != null? 'コメント：${task.comment}': 'コメントなし'),
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
            rowHeight: 80,
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
              return taskProvider.where((task) {
                final times = task.startTime;
                return times != null && times.any((dt) => isSameDay(dt, date));
              }).toList();
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
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              tablePadding: EdgeInsets.symmetric(horizontal: 10),
              cellMargin: EdgeInsets.all(2),
              cellPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            calendarBuilders: CalendarBuilders(
              selectedBuilder: (context, date, focusedDay) {
                return Container(
                  decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  children: [
                    Text(
                      '${date.day}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    ...buildTaskTitles(date), // カスタムタスク表示
                  ],
                ),
              );
            },
            todayBuilder: (context, date, focusedDay) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    ...buildTaskTitles(date), // カスタムタスク表示
                  ],
                ),
              );
            },
              headerTitleBuilder: (context, day) {
                return Row(
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
                );
              },
              defaultBuilder: (context, date, focusedDay) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day}',
                      style: const TextStyle(

                        fontWeight: FontWeight.bold,                        
                        fontSize: 17,
                      ),
                    ),
                    ...buildTaskTitles(date),
                  ],
                );
              },
              markerBuilder: (context, date, events) {
                // if (events.isEmpty) return const SizedBox();

                // return Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: events.take(3).map((event) {
                //     final task = event;
                //     final colorIndex = task.color.clamp(0, 9);
                //     return Container(
                //       width: 6,
                //       height: 6,
                //       margin: const EdgeInsets.symmetric(horizontal: 1.5),
                //       decoration: BoxDecoration(
                //         shape: BoxShape.circle,
                //         color: taskColors[colorIndex],
                //       ),
                //     );
                //   }).toList(),
                // );
                return const SizedBox.shrink();
              }
            ),
          ),
      ),
    );
  }
}
