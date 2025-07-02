import 'package:flutter/material.dart';
// 曜日のデータ
List<String> weekdayName = ['', 'MON', 'TUE', 'WED', 'THUR', 'FRY', 'SAT', 'SUN'];


final taskColors = [
  Colors.yellow,
  Colors.lightGreen,
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.pink,
  Colors.cyan,
  Colors.orange,
  Colors.purple,
  Colors.black,
];


enum RepeteType{
  none,
  daily,
  weekly,
}

class Task {
  final String title;
  final DateTime? limit;
  final int requiredHours;
  final int color;
  final RepeteType repete;
  final String? comment;
  final List<DateTime>? startTime;

  const Task({
    required this.title,
    this.limit,
    required this.requiredHours,
    required this.color,
    this.repete = RepeteType.none,
    this.comment,
    this.startTime,
  });

}

class ScheduledTask {
  final Task task;        // 元のタスク
  final DateTime dateTime; // このスケジュールの開始日時

  ScheduledTask({
    required this.task,
    required this.dateTime,
  });
}