import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final _fs = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasks(String uid) =>
      _fs.collection('users').doc(uid).collection('tasks');

  Future<void> upsertTask(String uid, Task task) async {
    await _tasks(uid).doc(task.id).set(task.toMap(), SetOptions(merge: true));
  }

  Future<List<Task>> fetchTasks(String uid) async {
    final snap = await _tasks(uid).get();
    return snap.docs
        .map((d) => Task.fromMap(d.data()))
        .where((t) => !t.isDeleted)
        .toList();
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await _tasks(uid).doc(taskId).delete();
  }

  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) async {
    await _fs.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _fs.collection('users').doc(uid).get();
    return doc.data();
  }
}
