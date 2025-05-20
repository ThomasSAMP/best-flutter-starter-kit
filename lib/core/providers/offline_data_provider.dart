import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/syncable_model.dart';
import '../repositories/offline_repository_base.dart';
import '../services/connectivity_service.dart';
import '../utils/logger.dart';

/// Offline data state
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

  /// Initial state
  factory OfflineDataState.initial(ConnectionStatus connectionStatus) {
    return OfflineDataState<T>(
      items: [],
      isLoading: false,
      errorMessage: null,
      isSyncing: false,
      connectionStatus: connectionStatus,
    );
  }

  /// Create a copy of the state with specified modifications
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

/// Notifier for offline data
class OfflineDataNotifier<T extends SyncableModel> extends StateNotifier<OfflineDataState<T>> {
  final OfflineRepositoryBase<T> repository;
  final ConnectivityService connectivityService;
  final Future<List<T>> Function() fetchItems;

  OfflineDataNotifier({
    required this.repository,
    required this.connectivityService,
    required this.fetchItems,
  }) : super(OfflineDataState.initial(connectivityService.currentStatus)) {
    // Listen to connectivity changes
    connectivityService.connectionStatus.listen(_handleConnectivityChange);

    // Load initial data
    loadItems();
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectionStatus status) {
    state = state.copyWith(connectionStatus: status);

    // If we go from offline to online, synchronize data
    if (status == ConnectionStatus.online && state.connectionStatus == ConnectionStatus.offline) {
      syncWithServer();
    }
  }

  /// Load items
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

  /// Synchronize with server
  Future<void> syncWithServer() async {
    if (state.connectionStatus == ConnectionStatus.offline) {
      state = state.copyWith(errorMessage: 'Cannot sync while offline');
      return;
    }

    state = state.copyWith(isSyncing: true, clearError: true);

    try {
      await repository.syncWithServer();
      await loadItems(); // Reload items after synchronization
      state = state.copyWith(isSyncing: false);
    } catch (e) {
      AppLogger.error('Error syncing with server', e);
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Failed to sync with server: ${e.toString()}',
      );
    }
  }

  /// Check if an item is synchronized
  bool isItemSynced(String id) {
    final item = state.items.firstWhere((item) => item.id == id, orElse: () => null as T);

    return item.isSynced;
  }
}

/// Create a provider for offline data
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
