import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted; 

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false, 
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isCompleted': isCompleted, 
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      priority: map['priority'] ?? 'Medium',
      isCompleted: map['isCompleted'] ?? false,
    );
  }


  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted, 
    );
  }
}
