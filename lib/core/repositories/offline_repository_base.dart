import 'dart:async';

import '../models/syncable_model.dart';
import '../services/connectivity_service.dart';
import '../services/local_storage_service.dart';
import '../utils/logger.dart';

/// Classe de base pour les repositories avec prise en charge du mode hors ligne
abstract class OfflineRepositoryBase<T extends SyncableModel> {
  final ConnectivityService connectivityService;
  final LocalStorageService localStorageService;

  // Clé pour le stockage local des données
  final String storageKey;

  // Clé pour le stockage local des opérations en attente
  final String pendingOperationsKey;

  // File d'attente des opérations en attente
  final List<PendingOperation<T>> pendingOperations = [];

  // Abonnement aux changements de connectivité
  StreamSubscription<ConnectionStatus>? _connectivitySubscription;

  // Fonction pour créer un modèle à partir d'un JSON
  final T Function(Map<String, dynamic> json) fromJson;

  OfflineRepositoryBase({
    required this.connectivityService,
    required this.localStorageService,
    required this.storageKey,
    required this.pendingOperationsKey,
    required this.fromJson,
  }) {
    // Écouter les changements de connectivité
    _connectivitySubscription = connectivityService.connectionStatus.listen(
      _handleConnectivityChange,
    );

    // Charger les opérations en attente
    _loadPendingOperations();
  }

  // Méthode appelée lorsque la connectivité change
  void _handleConnectivityChange(ConnectionStatus status) {
    if (status == ConnectionStatus.online) {
      AppLogger.info('Connection restored. Processing pending operations...');
      processPendingOperations();
    }
  }

  // Traiter les opérations en attente lorsque la connexion est rétablie
  Future<void> processPendingOperations() async {
    if (pendingOperations.isEmpty) return;

    AppLogger.info('Processing ${pendingOperations.length} pending operations');

    // Créer une copie de la liste pour éviter les problèmes de modification pendant l'itération
    final operations = List<PendingOperation<T>>.from(pendingOperations);

    for (final operation in operations) {
      try {
        await operation.execute();
        pendingOperations.remove(operation);
        AppLogger.debug('Successfully processed pending operation: ${operation.type}');
      } catch (e) {
        AppLogger.error('Failed to process pending operation: ${operation.type}', e);
        // Garder l'opération dans la file d'attente pour réessayer plus tard
      }
    }

    // Sauvegarder les opérations en attente mises à jour
    await savePendingOperations();
  }

  // Ajouter une opération à la file d'attente
  void addPendingOperation(PendingOperation<T> operation) {
    pendingOperations.add(operation);
    AppLogger.debug('Added pending operation: ${operation.type}');

    // Si nous sommes en ligne, traiter immédiatement l'opération
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      processPendingOperations();
    }
  }

  // Charger les opérations en attente depuis le stockage local
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

  // Sauvegarder les opérations en attente dans le stockage local
  Future<void> savePendingOperations() async {
    await localStorageService.savePendingOperations<T>(pendingOperationsKey, pendingOperations);
  }

  // Sauvegarder localement
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

  // Supprimer localement
  Future<void> deleteLocally(String id) async {
    final items = loadAllLocally();
    final updatedItems = items.where((item) => item.id != id).toList();
    await localStorageService.saveModelList<T>(storageKey, updatedItems);
  }

  // Charger toutes les données locales
  List<T> loadAllLocally() {
    return localStorageService.loadModelList<T>(storageKey, fromJson);
  }

  // Méthodes abstraites à implémenter dans les sous-classes

  /// Sauvegarde un élément sur le serveur distant
  Future<void> saveToRemote(T item);

  /// Supprime un élément du serveur distant
  Future<void> deleteFromRemote(String id);

  /// Charge tous les éléments depuis le serveur distant
  Future<List<T>> loadAllFromRemote();

  /// Synchronise les données avec le serveur
  Future<void> syncWithServer() async {
    try {
      // Traiter les opérations en attente
      await processPendingOperations();

      // Récupérer les données depuis le serveur
      final remoteItems = await loadAllFromRemote();

      // Récupérer les données locales
      final localItems = loadAllLocally();

      // Identifier les éléments qui existent localement mais pas sur le serveur
      final localOnlyItems =
          localItems.where((local) => !remoteItems.any((remote) => remote.id == local.id)).toList();

      // Synchroniser les éléments locaux uniquement avec le serveur
      for (final item in localOnlyItems) {
        if (!item.isSynced) {
          await saveToRemote(item);
        }
      }

      // Mettre à jour le stockage local avec tous les éléments
      final allItems = [...remoteItems, ...localOnlyItems];
      await localStorageService.saveModelList<T>(storageKey, allItems);

      AppLogger.info('Data synchronized with server');
    } catch (e) {
      AppLogger.error('Error synchronizing data with server', e);
      rethrow;
    }
  }

  // Nettoyer les ressources lors de la destruction du repository
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
