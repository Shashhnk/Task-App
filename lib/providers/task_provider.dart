import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';


final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});


final taskListProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final repository = ref.read(taskRepositoryProvider);
  return TaskNotifier(repository);
});


class TaskNotifier extends StateNotifier<List<Task>> {
  final TaskRepository _repository;
  String? _userId;

  TaskNotifier(this._repository) : super([]);

  void setUserId(String userId) {
    _userId = userId;
    fetchTasks();
  }


  void fetchTasks() {
    if (_userId == null) return;
    _repository.getTasks(_userId!).listen((tasks) {
      state = tasks;
    });
  }


  Future<void> addTask(Task task) async {
    if (_userId == null) return;
    await _repository.addTask(_userId!, task);
  }


  Future<void> updateTask(Task task) async {
    if (_userId == null) return;
    await _repository.updateTask(_userId!, task);
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    if (_userId == null) return;
    await _repository.toggleTaskCompletion(_userId!, taskId, isCompleted);
  }


  Future<void> deleteTask(String taskId) async {
    if (_userId == null) return;
    await _repository.deleteTask(_userId!, taskId);
  }
}
