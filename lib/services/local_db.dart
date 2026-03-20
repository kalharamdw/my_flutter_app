import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class LocalDb {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'taskmaster.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            userId TEXT,
            title TEXT NOT NULL,
            description TEXT,
            priority TEXT,
            category TEXT,
            status TEXT,
            dueDate INTEGER,
            reminderTime INTEGER,
            createdAt INTEGER,
            updatedAt INTEGER,
            completedAt INTEGER,
            pomodoroCount INTEGER DEFAULT 0,
            estimatedPomodoros INTEGER DEFAULT 1,
            isSynced INTEGER DEFAULT 0,
            isDeleted INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  static Future<void> upsertTask(Task task) async {
    final d = await db;
    await d.insert('tasks', task.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> upsertAll(List<Task> tasks) async {
    final d = await db;
    final batch = d.batch();
    for (final t in tasks) {
      batch.insert('tasks', t.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Task>> getAllTasks(String uid) async {
    final d = await db;
    final rows = await d.query('tasks',
        where: 'userId = ? AND isDeleted = 0', whereArgs: [uid],
        orderBy: 'createdAt DESC');
    return rows.map(Task.fromSqlite).toList();
  }

  static Future<void> softDelete(String id) async {
    final d = await db;
    await d.update('tasks', {'isDeleted': 1, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> markComplete(String id) async {
    final d = await db;
    final now = DateTime.now().millisecondsSinceEpoch;
    await d.update('tasks',
        {'status': 'completed', 'completedAt': now, 'updatedAt': now},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAll(String uid) async {
    final d = await db;
    await d.delete('tasks', where: 'userId = ?', whereArgs: [uid]);
  }
}
