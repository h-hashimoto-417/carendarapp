

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
  final DateTime startTime;

  const Task({
    required this.title,
    this.limit,
    required this.requiredHours,
    required this.color,
    this.repete = RepeteType.none,
    this.comment,
    required this.startTime,
  });

}