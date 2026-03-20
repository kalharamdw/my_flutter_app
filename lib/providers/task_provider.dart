import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/local_db.dart';
import '../services/firestore_service.dart';

enum TaskFilter { all, today, upcoming, overdue, done }

class TaskProvider extends ChangeNotifier {
  final _fs = FirestoreService();
  List<Task> _tasks = [];
  TaskFilter filter = TaskFilter.today;
  String searchQuery = '';
  bool loading = false;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  List<Task> get allTasks => _tasks;

  List<Task> get filteredTasks {
    var list = _tasks.where((t) => !t.isDeleted).toList();

    // Search
    if (searchQuery.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              t.description.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Filter
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    switch (filter) {
      case TaskFilter.today:
        list = list
            .where((t) =>
                t.dueDate != null &&
                t.dueDate!.isAfter(todayStart) &&
                t.dueDate!.isBefore(todayEnd))
            .toList();
        break;
      case TaskFilter.upcoming:
        list = list
            .where((t) =>
                t.dueDate != null &&
                t.dueDate!.isAfter(todayEnd) &&
                !t.isCompleted)
            .toList();
        break;
      case TaskFilter.overdue:
        list = list.where((t) => t.isOverdue).toList();
        break;
      case TaskFilter.done:
        list = list.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.all:
        break;
    }

    // Sort: incomplete first, then by priority, then by due date
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      final pc = a.priority.index.compareTo(b.priority.index);
      if (pc != 0) return pc;
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return 0;
    });

    return list;
  }

  List<Task> get todayTasks {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _tasks
        .where((t) =>
            !t.isDeleted &&
            t.dueDate != null &&
            t.dueDate!.isAfter(start) &&
            t.dueDate!.isBefore(end))
        .toList();
  }

  List<Task> get overdueTasks =>
      _tasks.where((t) => !t.isDeleted && t.isOverdue).toList();

  int get completedToday {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return _tasks
        .where((t) =>
            t.isCompleted &&
            t.completedAt != null &&
            t.completedAt!.isAfter(start))
        .length;
  }

  int get todayTotal => todayTasks.length;

  List<Task> tasksForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _tasks
        .where((t) =>
            !t.isDeleted &&
            t.dueDate != null &&
            t.dueDate!.isAfter(start) &&
            t.dueDate!.isBefore(end))
        .toList();
  }

  Future<void> loadTasks() async {
    if (uid.isEmpty) return;
    loading = true;
    notifyListeners();
    _tasks = await LocalDb.getAllTasks(uid);
    loading = false;
    notifyListeners();
    // Sync from Firestore in background
    _syncFromFirestore();
  }

  Future<void> _syncFromFirestore() async {
    if (uid.isEmpty) return;
    try {
      final remote = await _fs.fetchTasks(uid);
      await LocalDb.upsertAll(remote);
      _tasks = await LocalDb.getAllTasks(uid);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addTask(Task task) async {
    final t = Task(
      id: task.id,
      userId: uid,
      title: task.title,
      description: task.description,
      priority: task.priority,
      category: task.category,
      status: task.status,
      dueDate: task.dueDate,
      reminderTime: task.reminderTime,
      estimatedPomodoros: task.estimatedPomodoros,
    );
    await LocalDb.upsertTask(t);
    _tasks.insert(0, t);
    notifyListeners();
    _fs.upsertTask(uid, t).catchError((_) {});
  }

  Future<void> updateTask(Task task) async {
    await LocalDb.upsertTask(task);
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) _tasks[i] = task;
    notifyListeners();
    _fs.upsertTask(uid, task).catchError((_) {});
  }

  Future<void> completeTask(String id) async {
    await LocalDb.markComplete(id);
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i != -1) {
      _tasks[i] = _tasks[i].copyWith(
          status: TaskStatus.completed, completedAt: DateTime.now());
    }
    notifyListeners();
    if (i != -1) _fs.upsertTask(uid, _tasks[i]).catchError((_) {});
  }

  Future<void> deleteTask(String id) async {
    await LocalDb.softDelete(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    _fs.deleteTask(uid, id).catchError((_) {});
  }

  void setFilter(TaskFilter f) { filter = f; notifyListeners(); }
  void setSearch(String q) { searchQuery = q; notifyListeners(); }
}
