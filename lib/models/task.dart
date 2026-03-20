import 'package:flutter/material.dart' show Color;
import 'package:uuid/uuid.dart';

enum Priority { high, medium, low }
enum TaskStatus { pending, inProgress, completed }
enum Category { work, personal, health, learning, finance, other }

extension PriorityExt on Priority {
  String get label {
    switch (this) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  String get emoji {
    switch (this) {
      case Priority.high:
        return '🔴';
      case Priority.medium:
        return '🟡';
      case Priority.low:
        return '🟢';
    }
  }

  int get colorValue {
    switch (this) {
      case Priority.high:
        return 0xFFFF4D6D;
      case Priority.medium:
        return 0xFFFF9A3C;
      case Priority.low:
        return 0xFF43E97B;
    }
  }

  Color get color => Color(colorValue);
}

extension CategoryExt on Category {
  String get label {
    switch (this) {
      case Category.work:
        return 'Work';
      case Category.personal:
        return 'Personal';
      case Category.health:
        return 'Health';
      case Category.learning:
        return 'Learning';
      case Category.finance:
        return 'Finance';
      case Category.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case Category.work:
        return '💼';
      case Category.personal:
        return '👤';
      case Category.health:
        return '💪';
      case Category.learning:
        return '📚';
      case Category.finance:
        return '💰';
      case Category.other:
        return '📌';
    }
  }
}

class Task {
  final String id;
  final String userId;
  final String title;
  final String description;
  final Priority priority;
  final Category category;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final int pomodoroCount;
  final int estimatedPomodoros;
  final bool isSynced;
  final bool isDeleted;

  Task({
    String? id,
    this.userId = '',
    required this.title,
    this.description = '',
    this.priority = Priority.medium,
    this.category = Category.personal,
    this.status = TaskStatus.pending,
    this.dueDate,
    this.reminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.completedAt,
    this.pomodoroCount = 0,
    this.estimatedPomodoros = 1,
    this.isSynced = false,
    this.isDeleted = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isCompleted => status == TaskStatus.completed;

  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;

  Task copyWith({
    String? title,
    String? description,
    Priority? priority,
    Category? category,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? reminderTime,
    DateTime? completedAt,
    int? pomodoroCount,
    int? estimatedPomodoros,
    bool? isSynced,
    bool? isDeleted,
  }) =>
      Task(
        id: id,
        userId: userId,
        title: title ?? this.title,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        category: category ?? this.category,
        status: status ?? this.status,
        dueDate: dueDate ?? this.dueDate,
        reminderTime: reminderTime ?? this.reminderTime,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        completedAt: completedAt ?? this.completedAt,
        pomodoroCount: pomodoroCount ?? this.pomodoroCount,
        estimatedPomodoros:
        estimatedPomodoros ?? this.estimatedPomodoros,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'priority': priority.name,
    'category': category.name,
    'status': status.name,
    'dueDate': dueDate?.millisecondsSinceEpoch,
    'reminderTime': reminderTime?.millisecondsSinceEpoch,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'completedAt': completedAt?.millisecondsSinceEpoch,
    'pomodoroCount': pomodoroCount,
    'estimatedPomodoros': estimatedPomodoros,
    'isDeleted': isDeleted,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    priority: Priority.values.firstWhere(
            (e) => e.name == map['priority'],
        orElse: () => Priority.medium),
    category: Category.values.firstWhere(
            (e) => e.name == map['category'],
        orElse: () => Category.personal),
    status: TaskStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => TaskStatus.pending),
    dueDate: map['dueDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
        : null,
    reminderTime: map['reminderTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['reminderTime'])
        : null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ??
            DateTime.now().millisecondsSinceEpoch),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] ??
            DateTime.now().millisecondsSinceEpoch),
    completedAt: map['completedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
        map['completedAt'])
        : null,
    pomodoroCount: map['pomodoroCount'] ?? 0,
    estimatedPomodoros: map['estimatedPomodoros'] ?? 1,
    isSynced: true,
    isDeleted: map['isDeleted'] ?? false,
  );

  Map<String, dynamic> toSqlite() => {
    ...toMap(),
    'isSynced': isSynced ? 1 : 0,
    'isDeleted': isDeleted ? 1 : 0,
  };

  factory Task.fromSqlite(Map<String, dynamic> map) => Task.fromMap({
    ...map,
    'isSynced': map['isSynced'] == 1,
    'isDeleted': map['isDeleted'] == 1
  });
}