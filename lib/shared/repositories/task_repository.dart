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

  // Collection Firestore pour les tâches
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

  // Créer une nouvelle tâche
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

    // Sauvegarder localement
    await saveLocally(task);

    // Si nous sommes en ligne, synchroniser avec le serveur
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await saveToRemote(task);
    } else {
      // Sinon, ajouter à la file d'attente des opérations en attente
      addPendingOperation(
        PendingOperation<TaskModel>(
          type: OperationType.create,
          data: task,
          execute: () => saveToRemote(task),
        ),
      );

      // Sauvegarder les opérations en attente
      await savePendingOperations();
    }

    return task;
  }

  // Mettre à jour une tâche existante
  Future<TaskModel> updateTask(TaskModel task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now(), isSynced: false);

    // Sauvegarder localement
    await saveLocally(updatedTask);

    // Si nous sommes en ligne, synchroniser avec le serveur
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await saveToRemote(updatedTask);
    } else {
      // Sinon, ajouter à la file d'attente des opérations en attente
      addPendingOperation(
        PendingOperation<TaskModel>(
          type: OperationType.update,
          data: updatedTask,
          execute: () => saveToRemote(updatedTask),
        ),
      );

      // Sauvegarder les opérations en attente
      await savePendingOperations();
    }

    return updatedTask;
  }

  // Marquer une tâche comme terminée
  Future<TaskModel> completeTask(String taskId, bool isCompleted) async {
    final tasks = loadAllLocally();
    final task = tasks.firstWhere((t) => t.id == taskId);

    return updateTask(task.copyWith(isCompleted: isCompleted));
  }

  // Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    // Supprimer localement
    await deleteLocally(taskId);

    // Si nous sommes en ligne, supprimer du serveur
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await deleteFromRemote(taskId);
    } else {
      // Sinon, ajouter à la file d'attente des opérations en attente
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

      // Sauvegarder les opérations en attente
      await savePendingOperations();
    }
  }

  // Obtenir toutes les tâches
  Future<List<TaskModel>> getTasks() async {
    try {
      // Si nous sommes en ligne, essayer de récupérer depuis Firestore
      if (connectivityService.currentStatus == ConnectionStatus.online) {
        final tasks = await loadAllFromRemote();

        // Mettre à jour le stockage local avec les données du serveur
        for (final task in tasks) {
          await saveLocally(task.copyWith(isSynced: true));
        }

        return tasks;
      } else {
        // Sinon, charger depuis le stockage local
        return loadAllLocally();
      }
    } catch (e) {
      AppLogger.error('Error getting tasks', e);
      // En cas d'erreur, charger depuis le stockage local
      return loadAllLocally();
    }
  }

  // Obtenir les tâches filtrées par état de complétion
  Future<List<TaskModel>> getTasksByCompletion(bool isCompleted) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  @override
  Future<void> saveToRemote(TaskModel task) async {
    try {
      final updatedTask = task.copyWith(isSynced: true);
      await _tasksCollection.doc(task.id).set(updatedTask.toJson());

      // Mettre à jour le stockage local avec la tâche synchronisée
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
