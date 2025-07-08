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
  final int id;
  final String title;
  final DateTime? deadline;
  final int requiredHours;
  final int color;
  final RepeteType repete;
  final String? comment;
  final List<DateTime>? startTime;

  const Task({
    this.id = 0,
    required this.title,
    this.deadline,
    required this.requiredHours,
    required this.color,
    this.repete = RepeteType.none,
    this.comment,
    this.startTime,
  });
  Task copyWith({
    int? id,
    String? title,
    DateTime? deadline,
    int? requiredHours,
    int? color,
    RepeteType? repete,
    String? comment,
    List<DateTime>? startTime,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      requiredHours: requiredHours ?? this.requiredHours,
      color: color ?? this.color,
      repete: repete ?? this.repete,
      comment: comment ?? this.comment,
      startTime: startTime ?? this.startTime,
    );
  }

  Map<String, dynamic> toMap({bool withoutId = false}) {
    final map = <String, dynamic>{
      'title': title,
      'deadline': deadline?.toIso8601String(),
      'requiredHours': requiredHours,
      'color': color,
      'repete': repete.index,
      'comment': comment,
      'startTime': startTime?.map((dt) => dt.toIso8601String()).join(','),
    };

    if (!withoutId) {
      map['id'] = id;
    }

    return map;
  }

  static Task fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
    requiredHours: map['requiredHours'],
    color: map['color'],
    repete: RepeteType.values[map['repete']],
    comment: map['comment'],
    startTime: map['startTime'] != null && map['startTime'] != ''
        ? (map['startTime'] as String)
            .split(',')
            .map((e) => DateTime.parse(e))
            .toList()
        : null,
  );

}

class ScheduledTask {
  final Task task;        // 元のタスク
  final DateTime dateTime; // このスケジュールの開始日時

  ScheduledTask({
    required this.task,
    required this.dateTime,
  });


}
