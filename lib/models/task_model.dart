import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { high, medium, low }

enum TaskCategory { work, personal, health, shopping, other }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final Priority priority;
  final TaskCategory category;
  final bool isCompleted;
  final bool hasReminder;
  final DateTime? reminderTime;
  final String userId;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.category,
    this.isCompleted = false,
    this.hasReminder = false,
    this.reminderTime,
    required this.userId,
    required this.createdAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      priority: Priority.values[data['priority'] ?? 1],
      category: TaskCategory.values[data['category'] ?? 4],
      isCompleted: data['isCompleted'] ?? false,
      hasReminder: data['hasReminder'] ?? false,
      reminderTime: data['reminderTime'] != null
          ? (data['reminderTime'] as Timestamp).toDate()
          : null,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority.index,
      'category': category.index,
      'isCompleted': isCompleted,
      'hasReminder': hasReminder,
      'reminderTime':
          reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    TaskCategory? category,
    bool? isCompleted,
    bool? hasReminder,
    DateTime? reminderTime,
    String? userId,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
