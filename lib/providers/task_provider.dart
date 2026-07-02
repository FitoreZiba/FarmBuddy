import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  List<Task> _tasks = [];
  bool isLoading = false;

  List<Task> get tasks => _tasks;

  List<Task> get pendingToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return _tasks
        .where((t) => !t.completed && t.dueDate.isBefore(tomorrow))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<Task> tasksForCropOrPlot({String? cropId, String? plotId}) => _tasks
      .where((t) => (cropId != null && t.cropId == cropId) || (plotId != null && t.plotId == plotId))
      .toList();

  Map<DateTime, List<Task>> get groupedByDueDate {
    final Map<DateTime, List<Task>> map = {};
    for (final t in _tasks) {
      final day = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      map.putIfAbsent(day, () => []).add(t);
    }
    return map;
  }

  Future<void> loadTasks(List<String> plotIds, List<String> cropIds) async {
    isLoading = true;
    notifyListeners();
    final rows = await _db.queryAll('tasks', orderBy: 'dueDate ASC');
    _tasks = rows
        .map((r) => Task.fromMap(r))
        .where((t) =>
            (t.plotId != null && plotIds.contains(t.plotId)) ||
            (t.cropId != null && cropIds.contains(t.cropId)))
        .toList();
    isLoading = false;
    notifyListeners();
  }

  Future<Task> addTask({
    String? cropId,
    String? plotId,
    required TaskType type,
    required DateTime dueDate,
    bool isRecurring = false,
    int? recurrenceDays,
    String? title,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      cropId: cropId,
      plotId: plotId,
      type: type,
      dueDate: dueDate,
      isRecurring: isRecurring,
      recurrenceDays: recurrenceDays,
      title: title,
    );
    await _db.insert('tasks', task.toMap());
    _tasks.add(task);
    NotificationService.instance.scheduleTaskReminder(
      id: task.id.hashCode.abs(),
      title: task.title ?? task.type.name,
      dueDate: task.dueDate,
    );
    notifyListeners();
    return task;
  }

  Future<void> markComplete(Task task) async {
    final updated = task.copyWith(completed: true, completedAt: DateTime.now());
    await _db.update('tasks', updated.toMap(), task.id);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = updated;

    if (task.isRecurring && task.recurrenceDays != null) {
      await addTask(
        cropId: task.cropId,
        plotId: task.plotId,
        type: task.type,
        dueDate: task.dueDate.add(Duration(days: task.recurrenceDays!)),
        isRecurring: true,
        recurrenceDays: task.recurrenceDays,
        title: task.title,
      );
    }
    notifyListeners();
  }

  Future<void> toggleComplete(Task task) async {
    if (task.completed) {
      final updated = task.copyWith(completed: false, clearCompletedAt: true);
      await _db.update('tasks', updated.toMap(), task.id);
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) _tasks[idx] = updated;
      notifyListeners();
    } else {
      await markComplete(task);
    }
  }

  Future<void> reschedule(Task task, DateTime newDate) async {
    final updated = task.copyWith(dueDate: newDate);
    await _db.update('tasks', updated.toMap(), task.id);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = updated;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _db.delete('tasks', id);
    final task = _tasks.firstWhere((t) => t.id == id, orElse: () => _tasks.first);
    NotificationService.instance.cancelReminder(task.id.hashCode.abs());
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
