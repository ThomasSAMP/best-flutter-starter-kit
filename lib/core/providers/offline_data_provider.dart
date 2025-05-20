import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/syncable_model.dart';
import '../repositories/offline_repository_base.dart';
import '../services/connectivity_service.dart';
import '../utils/logger.dart';

/// État des données hors ligne
class OfflineDataState<T extends SyncableModel> {
  final List<T> items;
  final bool isLoading;
  final String? errorMessage;
  final bool isSyncing;
  final ConnectionStatus connectionStatus;

  OfflineDataState({
    required this.items,
    required this.isLoading,
    this.errorMessage,
    required this.isSyncing,
    required this.connectionStatus,
  });

  /// État initial
  factory OfflineDataState.initial(ConnectionStatus connectionStatus) {
    return OfflineDataState<T>(
      items: [],
      isLoading: false,
      errorMessage: null,
      isSyncing: false,
      connectionStatus: connectionStatus,
    );
  }

  /// Crée une copie de l'état avec les modifications spécifiées
  OfflineDataState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    String? errorMessage,
    bool? clearError,
    bool? isSyncing,
    ConnectionStatus? connectionStatus,
  }) {
    return OfflineDataState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError == true ? null : (errorMessage ?? this.errorMessage),
      isSyncing: isSyncing ?? this.isSyncing,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }
}

/// Notifier pour les données hors ligne
class OfflineDataNotifier<T extends SyncableModel> extends StateNotifier<OfflineDataState<T>> {
  final OfflineRepositoryBase<T> repository;
  final ConnectivityService connectivityService;
  final Future<List<T>> Function() fetchItems;

  OfflineDataNotifier({
    required this.repository,
    required this.connectivityService,
    required this.fetchItems,
  }) : super(OfflineDataState.initial(connectivityService.currentStatus)) {
    // Écouter les changements de connectivité
    connectivityService.connectionStatus.listen(_handleConnectivityChange);

    // Charger les données initiales
    loadItems();
  }

  /// Gère les changements de connectivité
  void _handleConnectivityChange(ConnectionStatus status) {
    state = state.copyWith(connectionStatus: status);

    // Si nous passons de hors ligne à en ligne, synchroniser les données
    if (status == ConnectionStatus.online && state.connectionStatus == ConnectionStatus.offline) {
      syncWithServer();
    }
  }

  /// Charge les éléments
  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final items = await fetchItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      AppLogger.error('Error loading items', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load items: ${e.toString()}',
      );
    }
  }

  /// Synchronise avec le serveur
  Future<void> syncWithServer() async {
    if (state.connectionStatus == ConnectionStatus.offline) {
      state = state.copyWith(errorMessage: 'Cannot sync while offline');
      return;
    }

    state = state.copyWith(isSyncing: true, clearError: true);

    try {
      await repository.syncWithServer();
      await loadItems(); // Recharger les éléments après la synchronisation
      state = state.copyWith(isSyncing: false);
    } catch (e) {
      AppLogger.error('Error syncing with server', e);
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Failed to sync with server: ${e.toString()}',
      );
    }
  }

  /// Vérifie si un élément est synchronisé
  bool isItemSynced(String id) {
    final item = state.items.firstWhere((item) => item.id == id, orElse: () => null as T);

    return item.isSynced;
  }
}

/// Crée un provider pour les données hors ligne
StateNotifierProvider<OfflineDataNotifier<T>, OfflineDataState<T>>
createOfflineDataProvider<T extends SyncableModel>({
  required OfflineRepositoryBase<T> repository,
  required ConnectivityService connectivityService,
  required Future<List<T>> Function() fetchItems,
}) {
  return StateNotifierProvider<OfflineDataNotifier<T>, OfflineDataState<T>>(
    (ref) => OfflineDataNotifier<T>(
      repository: repository,
      connectivityService: connectivityService,
      fetchItems: fetchItems,
    ),
  );
}
