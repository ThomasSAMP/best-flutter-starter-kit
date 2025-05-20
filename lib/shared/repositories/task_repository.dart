import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../core/repositories/offline_repository_base.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/utils/logger.dart';
import '../models/task_model.dart';

@lazySingleton
class TaskRepository extends OfflineRepositoryBase<TaskModel> {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  // Firestore collection for tasks
  CollectionReference<Map<String, dynamic>> get _tasksCollection => _firestore.collection('tasks');

  TaskRepository(
    this._firestore,
    LocalStorageService localStorageService,
    ConnectivityService connectivityService,
  ) : super(
        connectivityService: connectivityService,
        localStorageService: localStorageService,
        storageKey: 'offline_tasks',
        pendingOperationsKey: 'pending_task_operations',
        fromJson: TaskModel.fromJson,
      );

  // Create a new task
  Future<TaskModel> createTask(
    String title,
    String description, {
    DateTime? dueDate,
    String? userId,
  }) async {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      isCompleted: false,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      userId: userId,
    );

    // Save locally
    await saveLocally(task);

    // If we are online, synchronize with the server
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await saveToRemote(task);
    } else {
      // Otherwise, add to the pending operations queue
      addPendingOperation(
        PendingOperation<TaskModel>(
          type: OperationType.create,
          data: task,
          execute: () => saveToRemote(task),
        ),
      );

      // Save pending operations
      await savePendingOperations();
    }

    return task;
  }

  // Update an existing task
  Future<TaskModel> updateTask(TaskModel task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now(), isSynced: false);

    // Save locally
    await saveLocally(updatedTask);

    // If we are online, synchronize with the server
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await saveToRemote(updatedTask);
    } else {
      // Otherwise, add to the pending operations queue
      addPendingOperation(
        PendingOperation<TaskModel>(
          type: OperationType.update,
          data: updatedTask,
          execute: () => saveToRemote(updatedTask),
        ),
      );

      // Save pending operations
      await savePendingOperations();
    }

    return updatedTask;
  }

  // Mark a task as completed
  Future<TaskModel> completeTask(String taskId, bool isCompleted) async {
    final tasks = loadAllLocally();
    final task = tasks.firstWhere((t) => t.id == taskId);

    return updateTask(task.copyWith(isCompleted: isCompleted));
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    // Delete locally
    await deleteLocally(taskId);

    // If we are online, delete from server
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await deleteFromRemote(taskId);
    } else {
      // Otherwise, add to the pending operations queue
      final tasks = loadAllLocally();
      final taskToDelete = tasks.firstWhere(
        (task) => task.id == taskId,
        orElse:
            () => TaskModel(
              id: taskId,
              title: '',
              description: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      );

      addPendingOperation(
        PendingOperation<TaskModel>(
          type: OperationType.delete,
          data: taskToDelete,
          execute: () => deleteFromRemote(taskId),
        ),
      );

      // Save pending operations
      await savePendingOperations();
    }
  }

  // Get all tasks
  Future<List<TaskModel>> getTasks() async {
    try {
      // If we are online, try to retrieve from Firestore
      if (connectivityService.currentStatus == ConnectionStatus.online) {
        final tasks = await loadAllFromRemote();

        // Update local storage with server data
        for (final task in tasks) {
          await saveLocally(task.copyWith(isSynced: true));
        }

        return tasks;
      } else {
        // Otherwise, load from local storage
        return loadAllLocally();
      }
    } catch (e) {
      AppLogger.error('Error getting tasks', e);
      // In case of error, load from local storage
      return loadAllLocally();
    }
  }

  // Get tasks filtered by completion status
  Future<List<TaskModel>> getTasksByCompletion(bool isCompleted) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  @override
  Future<void> saveToRemote(TaskModel task) async {
    try {
      final updatedTask = task.copyWith(isSynced: true);
      await _tasksCollection.doc(task.id).set(updatedTask.toJson());

      // Update local storage with synchronized task
      await saveLocally(updatedTask);

      AppLogger.debug('Task saved to Firestore: ${task.id}');
    } catch (e) {
      AppLogger.error('Error saving task to Firestore', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteFromRemote(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
      AppLogger.debug('Task deleted from Firestore: $id');
    } catch (e) {
      AppLogger.error('Error deleting task from Firestore', e);
      rethrow;
    }
  }

  @override
  Future<List<TaskModel>> loadAllFromRemote() async {
    try {
      final snapshot = await _tasksCollection.get();
      return snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();
    } catch (e) {
      AppLogger.error('Error loading tasks from Firestore', e);
      rethrow;
    }
  }
}
