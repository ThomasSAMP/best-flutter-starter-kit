import 'dart:async';

import '../services/connectivity_service.dart';
import '../utils/logger.dart';

/// Classe de base pour les repositories avec prise en charge du mode hors ligne
abstract class OfflineRepositoryBase<T> {
  // Rendre connectivityService protégé (accessible aux sous-classes)
  final ConnectivityService connectivityService;

  // File d'attente des opérations en attente
  final List<PendingOperation<T>> pendingOperations = [];

  // Abonnement aux changements de connectivité
  StreamSubscription<ConnectionStatus>? _connectivitySubscription;

  OfflineRepositoryBase(this.connectivityService) {
    // Écouter les changements de connectivité
    _connectivitySubscription = connectivityService.connectionStatus.listen(
      _handleConnectivityChange,
    );
  }

  // Méthode appelée lorsque la connectivité change
  void _handleConnectivityChange(ConnectionStatus status) {
    if (status == ConnectionStatus.online) {
      AppLogger.info('Connection restored. Processing pending operations...');
      processPendingOperations();
    }
  }

  // Traiter les opérations en attente lorsque la connexion est rétablie
  // Rendre cette méthode protégée (accessible aux sous-classes)
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

  // Sauvegarder les données localement
  Future<void> saveLocally(T data);

  // Charger les données locales
  Future<List<T>> loadLocally();

  // Synchroniser les données avec le serveur
  Future<void> syncWithServer();

  // Nettoyer les ressources lors de la destruction du repository
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

/// Types d'opérations en attente
enum OperationType { create, update, delete }

/// Classe représentant une opération en attente
class PendingOperation<T> {
  final OperationType type;
  final T data;
  final Future<void> Function() execute;

  PendingOperation({required this.type, required this.data, required this.execute});
}
