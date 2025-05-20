import 'dart:async';

import '../models/syncable_model.dart';
import '../services/connectivity_service.dart';
import '../services/local_storage_service.dart';
import '../utils/logger.dart';

/// Base class for repositories with offline mode support
abstract class OfflineRepositoryBase<T extends SyncableModel> {
  final ConnectivityService connectivityService;
  final LocalStorageService localStorageService;

  // Key for local data storage
  final String storageKey;

  // Key for local pending operations storage
  final String pendingOperationsKey;

  // Queue of pending operations
  final List<PendingOperation<T>> pendingOperations = [];

  // Subscription to connectivity changes
  StreamSubscription<ConnectionStatus>? _connectivitySubscription;

  // Function to create a model from JSON
  final T Function(Map<String, dynamic> json) fromJson;

  OfflineRepositoryBase({
    required this.connectivityService,
    required this.localStorageService,
    required this.storageKey,
    required this.pendingOperationsKey,
    required this.fromJson,
  }) {
    // Listen to connectivity changes
    _connectivitySubscription = connectivityService.connectionStatus.listen(
      _handleConnectivityChange,
    );

    // Load pending operations
    _loadPendingOperations();
  }

  // Method called when connectivity changes
  void _handleConnectivityChange(ConnectionStatus status) {
    if (status == ConnectionStatus.online) {
      AppLogger.info('Connection restored. Processing pending operations...');
      processPendingOperations();
    }
  }

  // Process pending operations when connection is restored
  Future<void> processPendingOperations() async {
    if (pendingOperations.isEmpty) return;

    AppLogger.info('Processing ${pendingOperations.length} pending operations');

    // Create a copy of the list to avoid modification issues during iteration
    final operations = List<PendingOperation<T>>.from(pendingOperations);

    for (final operation in operations) {
      try {
        await operation.execute();
        pendingOperations.remove(operation);
        AppLogger.debug('Successfully processed pending operation: ${operation.type}');
      } catch (e) {
        AppLogger.error('Failed to process pending operation: ${operation.type}', e);
        // Keep the operation in the queue to retry later
      }
    }

    // Save updated pending operations
    await savePendingOperations();
  }

  // Add an operation to the queue
  void addPendingOperation(PendingOperation<T> operation) {
    pendingOperations.add(operation);
    AppLogger.debug('Added pending operation: ${operation.type}');

    // If we are online, process the operation immediately
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      processPendingOperations();
    }
  }

  // Load pending operations from local storage
  Future<void> _loadPendingOperations() async {
    try {
      final operationsData = localStorageService.loadPendingOperationsData(pendingOperationsKey);

      for (final data in operationsData) {
        final type = OperationType.values[data['type'] as int];
        final modelData = data['data'] as Map<String, dynamic>;
        final model = fromJson(modelData);

        switch (type) {
          case OperationType.create:
          case OperationType.update:
            addPendingOperation(
              PendingOperation<T>(type: type, data: model, execute: () => saveToRemote(model)),
            );
            break;
          case OperationType.delete:
            addPendingOperation(
              PendingOperation<T>(
                type: type,
                data: model,
                execute: () => deleteFromRemote(model.id),
              ),
            );
            break;
        }
      }

      AppLogger.debug('Loaded ${operationsData.length} pending operations');
    } catch (e) {
      AppLogger.error('Error loading pending operations', e);
    }
  }

  // Save pending operations to local storage
  Future<void> savePendingOperations() async {
    await localStorageService.savePendingOperations<T>(pendingOperationsKey, pendingOperations);
  }

  // Save locally
  Future<void> saveLocally(T item) async {
    final items = loadAllLocally();
    final index = items.indexWhere((i) => i.id == item.id);

    if (index >= 0) {
      items[index] = item;
    } else {
      items.add(item);
    }

    await localStorageService.saveModelList<T>(storageKey, items);
  }

  // Delete locally
  Future<void> deleteLocally(String id) async {
    final items = loadAllLocally();
    final updatedItems = items.where((item) => item.id != id).toList();
    await localStorageService.saveModelList<T>(storageKey, updatedItems);
  }

  // Load all local data
  List<T> loadAllLocally() {
    return localStorageService.loadModelList<T>(storageKey, fromJson);
  }

  // Abstract methods to implement in subclasses

  /// Save an item to the remote server
  Future<void> saveToRemote(T item);

  /// Delete an item from the remote server
  Future<void> deleteFromRemote(String id);

  /// Load all items from the remote server
  Future<List<T>> loadAllFromRemote();

  /// Synchronize data with server
  Future<void> syncWithServer() async {
    try {
      // Process pending operations
      await processPendingOperations();

      // Retrieve data from the server
      final remoteItems = await loadAllFromRemote();

      // Recover local data
      final localItems = loadAllLocally();

      // Identify items that exist locally but not on the server
      final localOnlyItems =
          localItems.where((local) => !remoteItems.any((remote) => remote.id == local.id)).toList();

      // Synchronize local-only items with the server
      for (final item in localOnlyItems) {
        if (!item.isSynced) {
          await saveToRemote(item);
        }
      }

      // Update local storage with all items
      final allItems = [...remoteItems, ...localOnlyItems];
      await localStorageService.saveModelList<T>(storageKey, allItems);

      AppLogger.info('Data synchronized with server');
    } catch (e) {
      AppLogger.error('Error synchronizing data with server', e);
      rethrow;
    }
  }

  // Clean up resources when the repository is destroyed
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
