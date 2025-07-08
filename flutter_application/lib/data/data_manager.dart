import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'task_db_helper.dart';
import 'package:flutter_application/data/database.dart';

part 'data_manager.g.dart';

@riverpod


class TaskController extends _$TaskController{
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
  List<Task> build(){
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

  
}

