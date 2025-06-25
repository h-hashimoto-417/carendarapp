import 'package:table_calendar/table_calendar.dart';
import '../data/database.dart';

List<ScheduledTask> getScheduledTasksForDay(DateTime day, List<Task> tasks) {
  final List<ScheduledTask> scheduledTasks = [];

  for (final task in tasks) {
    final times = task.startTime;
    if (times == null) continue;

    for (final dt in times) {
      switch (task.repete) {
        case RepeteType.none:
          if (isSameDay(dt, day)) {
            scheduledTasks.add(ScheduledTask(task: task, dateTime: dt));
          }
          break;

        case RepeteType.daily:
          if (dt.isBefore(day) || isSameDay(dt, day)) {
            final repeated = DateTime(day.year, day.month, day.day, dt.hour, dt.minute);
            scheduledTasks.add(ScheduledTask(task: task, dateTime: repeated));
          }
          break;

        case RepeteType.weekly:
          if ((dt.isBefore(day) || isSameDay(dt, day)) && dt.weekday == day.weekday) {
            final repeated = DateTime(day.year, day.month, day.day, dt.hour, dt.minute);
            scheduledTasks.add(ScheduledTask(task: task, dateTime: repeated));
          }
          break;
      }
    }
  }

  scheduledTasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return scheduledTasks;
}
