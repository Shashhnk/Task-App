import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

/// Provider for TaskRepository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

/// Task list provider (manages task state)
final taskListProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final repository = ref.read(taskRepositoryProvider);
  return TaskNotifier(repository);
});

/// TaskNotifier manages CRUD operations
class TaskNotifier extends StateNotifier<List<Task>> {
  final TaskRepository _repository;
  String? _userId;

  TaskNotifier(this._repository) : super([]);

  /// Set User ID when authenticated
  void setUserId(String userId) {
    _userId = userId;
    fetchTasks();
  }

  /// Fetch all tasks for the current user
  void fetchTasks() {
    if (_userId == null) return;
    _repository.getTasks(_userId!).listen((tasks) {
      state = tasks;
    });
  }

  /// Add a new task
  Future<void> addTask(Task task) async {
    if (_userId == null) return;
    await _repository.addTask(_userId!, task);
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    if (_userId == null) return;
    await _repository.updateTask(_userId!, task);
  }

  /// Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    if (_userId == null) return;
    await _repository.toggleTaskCompletion(_userId!, taskId, isCompleted);
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    if (_userId == null) return;
    await _repository.deleteTask(_userId!, taskId);
  }
}
