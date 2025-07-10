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

    // すべての単発タスクやリピートタスクを含む日時を収集
    final Set<DateTime> occupiedTimes = {};

    for (final task in currentTasks) {
      final times = task.startTime;
      if (times == null) continue;

      for (final dt in times) {
        if (task.repete == RepeteType.none) {
          occupiedTimes.add(dt);
        } else {
          final now = DateTime.now();
          final deadline = task.deadline ?? DateTime.utc(2100);

          for (int i = -30; i <= 90; i++) {
            final day = now.add(Duration(days: i));
            if (day.isAfter(deadline)) continue;

            if (task.repete == RepeteType.daily ||
                (task.repete == RepeteType.weekly &&
                    day.weekday == dt.weekday)) {
              final repeated = DateTime(
                day.year,
                day.month,
                day.day,
                dt.hour,
                dt.minute,
              );
              occupiedTimes.add(repeated);
            }
          }
        }
      }
    }

    // リピートタスクに対して衝突チェック（自身の繰り返し先は除外する）
    for (final task in currentTasks) {
      if (task.repete == RepeteType.none || task.startTime == null) continue;

      final now = DateTime.now();
      final deadline = task.deadline ?? DateTime.utc(2100);
      final newExcepts =
          task.excepts != null ? [...task.excepts!] : <DateTime>[];

      for (final dt in task.startTime!) {
        for (int i = -30; i <= 90; i++) {
          final day = now.add(Duration(days: i));
          if (day.isAfter(deadline)) continue;

          if (task.repete == RepeteType.daily ||
              (task.repete == RepeteType.weekly && day.weekday == dt.weekday)) {
            final repeated = DateTime(
              day.year,
              day.month,
              day.day,
              dt.hour,
              dt.minute,
            );

            // 他のタスクに占有されているが、自分のものではない
            final isOccupied = currentTasks.any((other) {
              if (other.id == task.id) return false; // 自分自身は除外
              if (other.startTime == null) return false;
              return other.startTime!.any(
                (t) =>
                    t.year == repeated.year &&
                    t.month == repeated.month &&
                    t.day == repeated.day &&
                    t.hour == repeated.hour &&
                    t.minute == repeated.minute,
              );
            });

            if (isOccupied && !newExcepts.contains(repeated)) {
              newExcepts.add(repeated);
            }
          }
        }
      }

      if (newExcepts.length != (task.excepts?.length ?? 0)) {
        final updated = task.copyWith(excepts: newExcepts);
        updatedTasks.add(updated);
      }
    }

    // DBに反映
    for (final task in updatedTasks) {
      await TaskDBHelper().updateTask(task);
    }

    // 状態更新
    await loadTasksFromDB();
  }
}
