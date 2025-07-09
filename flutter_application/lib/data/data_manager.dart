import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'task_db_helper.dart';
import 'package:flutter_application/data/database.dart';


part 'data_manager.g.dart';

@riverpod
class TaskController extends _$TaskController {
  // final int _nextID = 8;
  // final List<Task> sampleTask = [
  // //   Task(id: 1, title: 'Sample', requiredHours: 1, color: 1,deadline: DateTime.utc(2025, 7, 5), repete: RepeteType.daily, startTime: [DateTime.utc(2025, 6, 12, 12)]),
  // //   Task(id: 2, title: 'Sample2', requiredHours: 2, color: 0, startTime: [DateTime.utc(2025, 6, 28, 11)], comment: 'Sample dayo'),
  // //   Task(id: 3, title: 'Sample3', requiredHours: 2, color: 4, repete: RepeteType.weekly, startTime: [DateTime.utc(2025, 7, 23, 9), DateTime.utc(2025, 6, 21, 10)]),
  // //   Task(id: 4, title: 'Sample4', requiredHours: 1, color: 1,deadline: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 4, 13)]),
  // //   Task(id: 5, title: 'Sample5', requiredHours: 1, color: 3,deadline: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 2, 14)]),
  // //   Task(id: 6, title: 'Sample6', requiredHours: 1, color: 6,deadline: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 1, 15)]),
  // //   Task(id: 7, title: 'Sample7', requiredHours: 1, color: 8,deadline: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 20, 1)]),
  // ];

  @override
  List<Task> build() {
    state = [];
    loadTasksFromDB();
    return state;
  }

  Future<void> loadTasksFromDB() async {
    state = await TaskDBHelper().getTasks();
  }

  Future<void> addTask(Task task) async {
    await TaskDBHelper().insertTask(task);
    await loadTasksFromDB();
  }

  Future<void> updateTask(Task task) async {
    await TaskDBHelper().updateTask(task);
    await loadTasksFromDB();
  }

  Future<void> deleteTask(Task task) async {
    await TaskDBHelper().deleteTask(task.id);
    await loadTasksFromDB();
  }

Future<void> cleanAllConflictingSingleTimeTasks() async {
  final List<Task> updatedTasks = [];
  final List<Task> currentTasks = [...state];

  // リピートタスクが使用している (日付+時刻) を集める
  final Set<DateTime> repeatTaskTimes = {};

  for (final task in currentTasks) {
    if (task.startTime == null) continue;
    if (task.repete == RepeteType.none) continue;

    final now = DateTime.now();
    final deadline = task.deadline ?? DateTime.utc(2100); // デフォルト未来3ヶ月まで

    for (final dt in task.startTime!) {
      if (task.repete == RepeteType.daily) {
        for (int i = -30; i <= 90; i++) {
          final day = now.add(Duration(days: i));
          if (day.isAfter(deadline)) continue;

          final repeated = DateTime(day.year, day.month, day.day, dt.hour, dt.minute);
          repeatTaskTimes.add(repeated);
        }
      } else if (task.repete == RepeteType.weekly) {
        for (int i = -30; i <= 90; i++) {
          final day = now.add(Duration(days: i));
          if (day.isAfter(deadline)) continue;
          if (day.weekday != dt.weekday) continue;

          final repeated = DateTime(day.year, day.month, day.day, dt.hour, dt.minute);
          repeatTaskTimes.add(repeated);
        }
      }
    }
  }

  // 単発タスクに対して重複がある時間を削除
  for (final task in currentTasks) {
    if (task.repete != RepeteType.none || task.startTime == null) continue;

    final filteredTimes = task.startTime!.where((dt) {
      return !repeatTaskTimes.any((repDt) =>
          dt.year == repDt.year &&
          dt.month == repDt.month &&
          dt.day == repDt.day &&
          dt.hour == repDt.hour &&
          dt.minute == repDt.minute);
    }).toList();

    if (filteredTimes.length != task.startTime!.length) {
      final updated = task.copyWith(startTime: filteredTimes);
      updatedTasks.add(updated);
    }
  }

  // DBに反映
  for (final task in updatedTasks) {
    await TaskDBHelper().updateTask(task);
  }

  // 状態再読み込み
  await loadTasksFromDB();
}


}
