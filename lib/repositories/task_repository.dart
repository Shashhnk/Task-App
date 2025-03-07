import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to the tasks collection in Firestore for a specific user
  CollectionReference<Task> _taskCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .withConverter<Task>(
          fromFirestore: (snapshot, _) => Task.fromMap(snapshot.data()!, snapshot.id),
          toFirestore: (task, _) => task.toMap(),
        );
  }

  /// Fetches all tasks for a specific user
  Stream<List<Task>> getTasks(String userId) {
    return _taskCollection(userId)
        .orderBy('dueDate', descending: false) // Order by due date (oldest first)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Adds a new task to Firestore
  Future<void> addTask(String userId, Task task) async {
    await _taskCollection(userId).add(task);
  }

  /// Updates an existing task
  Future<void> updateTask(String userId, Task task) async {
    await _taskCollection(userId).doc(task.id).update(task.toMap());
  }

  /// Toggles task completion status
  Future<void> toggleTaskCompletion(String userId, String taskId, bool isCompleted) async {
    await _taskCollection(userId).doc(taskId).update({'isCompleted': isCompleted});
  }

  /// Deletes a task from Firestore
  Future<void> deleteTask(String userId, String taskId) async {
    await _taskCollection(userId).doc(taskId).delete();
  }
}
