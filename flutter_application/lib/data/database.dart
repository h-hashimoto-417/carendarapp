

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