import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_application/data/database.dart';

part 'data_manager.g.dart';

@riverpod


class TaskController extends _$TaskController{
  final List<Task> sampleTask = [
    Task(title: 'Sample', requiredHours: 1, color: 1,limit: DateTime.utc(2025, 7, 5), repete: RepeteType.daily, startTime: [DateTime.utc(2025, 6, 12, 12)]),
    Task(title: 'Sample2', requiredHours: 2, color: 0, startTime: [DateTime.utc(2025, 6, 28, 11)], comment: 'Sample dayo'),
    Task(title: 'Sample3', requiredHours: 2, color: 4, repete: RepeteType.weekly, startTime: [DateTime.utc(2025, 7, 23, 9), DateTime.utc(2025, 6, 21, 10)]),
    Task(title: 'Sample4', requiredHours: 1, color: 1,limit: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 4, 13)]),
    Task(title: 'Sample5', requiredHours: 1, color: 3,limit: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 2, 14)]),
    Task(title: 'Sample6', requiredHours: 1, color: 6,limit: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 1, 15)]),
    Task(title: 'Sample7', requiredHours: 1, color: 8,limit: DateTime.utc(2025, 7, 5),  startTime: [DateTime.utc(2025, 7, 20, 1)]),
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

