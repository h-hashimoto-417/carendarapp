import 'package:flutter/material.dart';
import 'package:flutter_application/data/data_manager.dart';
import 'package:flutter_application/data/database.dart';
import 'package:flutter_application/screens/screen_homeToday.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_application/models/schedule_utils.dart';

class ScreenCalendar extends HookConsumerWidget {
  const ScreenCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDayState = useState(DateTime.now());
    final focusedDayState = useState(DateTime.now());
    final panelController = useMemoized(() => PanelController());
    final taskProvider = ref.watch(taskControllerProvider);

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

    // List<ScheduledTask> getScheduledTasksForDay(DateTime day) {
    //   final List<ScheduledTask> scheduledTasks = [];

    //   for (final task in taskProvider) {
    //     final times = task.startTime;
    //     if (times == null) continue;

    //       for (final dt in times) {
    //         switch (task.repete) {
    //           case RepeteType.none:
    //             if (isSameDay(dt, day)) {
    //               scheduledTasks.add(ScheduledTask(task: task, dateTime: dt));
    //             }
    //           break;

    //           case RepeteType.daily:
    //             // 指定日以降、毎日繰り返す
    //             if (dt.isBefore(day) || isSameDay(dt, day)) {
    //               final repeated = DateTime(day.year, day.month, day.day, dt.hour, dt.minute);
    //               scheduledTasks.add(ScheduledTask(task: task, dateTime: repeated));
    //             }
    //             break;

    //           case RepeteType.weekly:
    //             // 指定日以降、毎週同じ曜日に繰り返す
    //             if ((dt.isBefore(day) || isSameDay(dt, day)) && dt.weekday == day.weekday) {
    //               final repeated = DateTime(day.year, day.month, day.day, dt.hour, dt.minute);
    //               scheduledTasks.add(ScheduledTask(task: task, dateTime: repeated));
    //             }
    //             break;
    //         }
    //       }
    //   }

    //   scheduledTasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    //   return scheduledTasks;
    // }

    List<Widget> buildTaskTitles(DateTime date) {
      final tasks = getScheduledTasksForDay(date, taskProvider);
      final displayTasks = tasks.take(3).toList();

      if (displayTasks.isEmpty) return [];

      return displayTasks.map((scheduledTask) {
        final task = scheduledTask.task;
        final shortTitle =
            task.title.length > 7 ? task.title.substring(0, 7) : task.title;
        final colorIndex = task.color.clamp(0, 9);
        return Text(
          shortTitle,
          style: TextStyle(
            fontSize: 9,
            color: taskColors[colorIndex],
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: Icon(Icons.calendar_today, color: Colors.black, size: 45),
          onPressed: () {
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (context) => ScreenHomeToday(today: DateTime.now()),
              ),
            );
          },
        ),

        title: Text(
          '${focusedDayState.value.year}',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),

      body: SlidingUpPanel(
        controller: panelController,
        minHeight: 60,
        maxHeight: MediaQuery.of(context).size.height * 0.35,
        panelBuilder: (sc) {
          final tasks = getScheduledTasksForDay(
            selectedDayState.value,
            taskProvider,
          );
          final deadlineTasks =
              taskProvider.where((task) {
                return task.limit != null &&
                    isSameDay(task.limit!, selectedDayState.value);
              }).toList();

          return Column(
            children: [
              Container(
                width: 40,
                height: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        '${selectedDayState.value.year}/${selectedDayState.value.month}/${selectedDayState.value.day}の予定',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (context) => ScreenHomeToday(
                                    today: selectedDayState.value,
                                  ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.visibility,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: Text(
                //     '締切のあるタスク: ${deadlineTasks.length}件',
                //     style: const TextStyle(fontWeight: FontWeight.bold),
                //   ),
                // ),

              const Divider(),

              Expanded(
                child: ListView(
                  controller: sc,
                  children: [
                    if (deadlineTasks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                const TextSpan(
                                  text: '〆切: ',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                ...deadlineTasks.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final task = entry.value;
                                  final color = taskColors[task.color.clamp(0, 9)];
                                  final title = task.title;
                                  return TextSpan(
                                    text:
                                        i == deadlineTasks.length - 1
                                            ? title
                                            : '$title、',
                                    style: TextStyle(color: color),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ...tasks.map((scheduledTask) {
                      final task = scheduledTask.task;
                      final dt = scheduledTask.dateTime;
                      return ListTile(
                        title: Text('${dt.hour}:00　${task.title}'),
                        subtitle: Text(
                          task.comment != null ? '${task.comment}' : 'コメントなし',
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Color(task.color),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        },

        body: TableCalendar<Task>(
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(fontSize: 11, color: Colors.black),
            weekendStyle: TextStyle(fontSize: 11, color: Colors.black26),
          ),
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
          // eventLoader: (date) {
          //   return taskProvider.where((task) {
          //     final limit = task.limit;
          //     return limit != null && isSameDay(limit, date);
          //   }).toList();
          // },
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
              final events =
                  taskProvider
                      .where(
                        (task) =>
                            task.limit != null && isSameDay(task.limit!, date),
                      )
                      .toList();
              return Container(
                
                decoration: BoxDecoration(
                  color: isSameDay(date, DateTime.now())
                      ? Colors.orange[100]
                      : Colors.white,
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
                    const SizedBox(height: 2),
                    if (events.isNotEmpty) // イベントがある場合のみ表示
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            events.take(5).map((task) {
                              final colorIndex = task.color.clamp(0, 9);
                              return Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: taskColors[colorIndex],
                                ),
                              );
                            }).toList(),
                      ),
                    ...buildTaskTitles(date), // カスタムタスク表示
                  ],
                ),
              );
            },
            todayBuilder: (context, date, focusedDay) {
              final events =
                  taskProvider
                      .where(
                        (task) =>
                            task.limit != null && isSameDay(task.limit!, date),
                      )
                      .toList();
              return Container(
                decoration: BoxDecoration(
                  color: Colors.orange[100],
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
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (events.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            events.take(5).map((task) {
                              final colorIndex = task.color.clamp(0, 9);
                              return Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: taskColors[colorIndex],
                                ),
                              );
                            }).toList(),
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
              final events =
                  taskProvider.where((task) {
                    final limit = task.limit;
                    return limit != null && isSameDay(limit, date);
                  }).toList();

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
                  const SizedBox(height: 2),
                  if (events.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          events.take(5).map((task) {
                            final colorIndex = task.color.clamp(0, 9);
                            return Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 1.5,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: taskColors[colorIndex],
                              ),
                            );
                          }).toList(),
                    ),
                  ...buildTaskTitles(date),
                ],
              );
            },
            // markerBuilder: (context, date, events) {
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
            //   return const SizedBox.shrink();
            // },
          ),
        ),
      ),
    );
  }
}
