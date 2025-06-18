
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_application/data/database.dart';

part 'TaskManager.g.dart';

@riverpod

class TaskController extends _$TaskController{
  final List<Task> sampleTask = [
    Task(title: 'Sample', requiredHours: 1, color: 1, startTime: DateTime.utc(2025, 6, 12, 12)),
    Task(title: 'Sample2', requiredHours: 2, color: 0, startTime: DateTime.utc(2025, 6, 12, 11)),
  ];

  @override
  List<Task> build(){
    state = sampleTask;
    return state;
  }

  void addTask(Task task){
    state = [...state, task];
  }

  void deleteTask(Task task){
    state = state.where((t) => t != task).toList();
  }

  
}

