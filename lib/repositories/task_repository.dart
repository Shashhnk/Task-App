import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


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

  Stream<List<Task>> getTasks(String userId) {
    return _taskCollection(userId)
        .orderBy('dueDate', descending: false) 
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }


  Future<void> addTask(String userId, Task task) async {
    await _taskCollection(userId).add(task);
  }

  
  Future<void> updateTask(String userId, Task task) async {
    await _taskCollection(userId).doc(task.id).update(task.toMap());
  }


  Future<void> toggleTaskCompletion(String userId, String taskId, bool isCompleted) async {
    await _taskCollection(userId).doc(taskId).update({'isCompleted': isCompleted});
  }


  Future<void> deleteTask(String userId, String taskId) async {
    await _taskCollection(userId).doc(taskId).delete();
  }
}
