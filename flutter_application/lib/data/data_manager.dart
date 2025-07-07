import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_application/data/database.dart';

part 'data_manager.g.dart';

@riverpod


class TaskController extends _$TaskController{
  int _nextID = 8;
  final List<Task> sampleTask = [
    Task(id: 1, title: 'Sample', requiredHours: 1, color: 1,limit: DateTime.utc(2025, 7, 5), repete: RepeteType.daily, startTime: [DateTime.utc(2025, 6, 12, 12)]),
    Task(id: 2, title: 'Sample2', requiredHours: 2, color: 0, startTime: [DateTime.utc(2025, 6, 28, 11)], comment: 'Sample dayo'),
    Task(id: 3, title: 'Sample3', requiredHours: 2, color: 4, repete: RepeteType.weekly, startTime: [DateTime.utc(2025, 7, 23, 9), DateTime.utc(2025, 6, 21, 10)]),
    Task(id: 4, title: 'Sample4', requiredHours: 1, color: 1,limit: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 4, 13)]),
    Task(id: 5, title: 'Sample5', requiredHours: 1, color: 3,limit: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 2, 14)]),
    Task(id: 6, title: 'Sample6', requiredHours: 1, color: 6,limit: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 1, 15)]),
    Task(id: 7, title: 'Sample7', requiredHours: 1, color: 8,limit: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 20, 1)]),
  ];

  @override
  List<Task> build(){
    state = sampleTask;
    return state;
  }

  void addTask(Task task){
    final newTask = task.copyWith(id: _nextID++);
    state = [...state, newTask];
  }

  void updateTask(Task updatedTask) {
  state = [
    for (final task in state)
      if (task.id == updatedTask.id) updatedTask else task,
  ];
}
  void deleteTask(Task task){
    state = state.where((t) => t != task).toList();
  }

  

  
}

