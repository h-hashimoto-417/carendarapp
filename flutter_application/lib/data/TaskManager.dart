// ignore: file_names

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_application/data/database.dart';

part 'TaskManager.g.dart';

@riverpod

class TaskController extends _$TaskController{
  final List<Task> sampleTask = [
    Task(title: 'Sample', requiredHours: 1, color: 1, startTime: DateTime.utc(2025, 6, 12, 12)),
    Task(title: 'Sample2', requiredHours: 2, color: 0, startTime: DateTime.utc(2025, 6, 18, 11)),
    Task(title: 'Sample3', requiredHours: 2, color: 5, startTime: DateTime.utc(2025, 6, 12, 9)),
    Task(title: 'Sample4', requiredHours: 1, color: 1, startTime: DateTime.utc(2025, 6, 12, 1)),
    Task(title: 'Sample5', requiredHours: 2, color: 6, startTime: DateTime.utc(2025, 6, 12, 7)),
    Task(title: 'Sample6', requiredHours: 2, color: 8, startTime: DateTime.utc(2025, 6, 12, 15)),
    Task(title: 'Sample7', requiredHours: 1, color: 2, startTime: DateTime.utc(2025, 6, 12, 17)),
    Task(title: 'Sample8', requiredHours: 2, color: 4, startTime: DateTime.utc(2025, 6, 12, 20)),
    Task(title: 'Sample9', requiredHours: 2, color: 6, startTime: DateTime.utc(2025, 6, 12, 3)),
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

