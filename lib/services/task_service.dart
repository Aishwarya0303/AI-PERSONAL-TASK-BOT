import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  CollectionReference get _tasksCollection =>
      _firestore.collection('users').doc(userId).collection('tasks');

  // Add Task
  Future<void> addTask(TaskModel task) async {
    await _tasksCollection.add(task.toFirestore());
  }

  // Update Task
  Future<void> updateTask(TaskModel task) async {
    await _tasksCollection.doc(task.id).update(task.toFirestore());
  }

  // Delete Task
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  // Toggle Complete
  Future<void> toggleTaskComplete(String taskId, bool isCompleted) async {
    await _tasksCollection.doc(taskId).update({'isCompleted': isCompleted});
  }

  // Get All Tasks Stream
  Stream<List<TaskModel>> getTasksStream() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  // Get Today's Tasks
  Stream<List<TaskModel>> getTodayTasksStream() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _tasksCollection
        .where('dueDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  // Get Pending Tasks
  Stream<List<TaskModel>> getPendingTasksStream() {
  return _tasksCollection
      .where('isCompleted', isEqualTo: false)
      .snapshots()
      .map((snapshot) {
        final tasks = snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList();
        return tasks;
      });
}

  // Get Tasks by Priority
  Stream<List<TaskModel>> getTasksByPriority(Priority priority) {
    return _tasksCollection
        .where('priority', isEqualTo: priority.index)
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  // Get Task Stats
  Future<Map<String, int>> getTaskStats() async {
    final allTasks = await _tasksCollection.get();
    final completedTasks =
        await _tasksCollection.where('isCompleted', isEqualTo: true).get();
    final pendingTasks =
        await _tasksCollection.where('isCompleted', isEqualTo: false).get();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final todayTasks = await _tasksCollection
        .where('dueDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return {
      'total': allTasks.docs.length,
      'completed': completedTasks.docs.length,
      'pending': pendingTasks.docs.length,
      'today': todayTasks.docs.length,
    };
  }
}
