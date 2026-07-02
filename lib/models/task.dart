enum TaskType { water, fertilize, inspect, treat, other }

TaskType taskTypeFromString(String s) =>
    TaskType.values.firstWhere((e) => e.name == s, orElse: () => TaskType.other);

class Task {
  final String id;
  final String? cropId;
  final String? plotId;
  final TaskType type;
  final DateTime dueDate;
  final bool isRecurring;
  final int? recurrenceDays;
  final bool completed;
  final DateTime? completedAt;
  final String? title;

  Task({
    required this.id,
    this.cropId,
    this.plotId,
    required this.type,
    required this.dueDate,
    this.isRecurring = false,
    this.recurrenceDays,
    this.completed = false,
    this.completedAt,
    this.title,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'cropId': cropId,
        'plotId': plotId,
        'type': type.name,
        'dueDate': dueDate.toIso8601String(),
        'isRecurring': isRecurring ? 1 : 0,
        'recurrenceDays': recurrenceDays,
        'completed': completed ? 1 : 0,
        'completedAt': completedAt?.toIso8601String(),
        'title': title,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'] as String,
        cropId: map['cropId'] as String?,
        plotId: map['plotId'] as String?,
        type: taskTypeFromString(map['type'] as String),
        dueDate: DateTime.parse(map['dueDate'] as String),
        isRecurring: (map['isRecurring'] as int) == 1,
        recurrenceDays: map['recurrenceDays'] as int?,
        completed: (map['completed'] as int) == 1,
        completedAt: map['completedAt'] == null
            ? null
            : DateTime.parse(map['completedAt'] as String),
        title: map['title'] as String?,
      );

  Task copyWith({
    bool? completed,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? dueDate,
  }) => Task(
        id: id,
        cropId: cropId,
        plotId: plotId,
        type: type,
        dueDate: dueDate ?? this.dueDate,
        isRecurring: isRecurring,
        recurrenceDays: recurrenceDays,
        completed: completed ?? this.completed,
        completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
        title: title,
      );
}
