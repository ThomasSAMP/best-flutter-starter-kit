import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

import '../utils/logger.dart';

enum ConnectionStatus { online, offline }

@lazySingleton
class ConnectivityService {
  // Connectivity instance to monitor connectivity changes
  final Connectivity _connectivity = Connectivity();

  // Stream controller to broadcast connection status changes
  final _connectionStatusController = StreamController<ConnectionStatus>.broadcast();

  // Exposed stream so other parts of the application can listen to changes
  Stream<ConnectionStatus> get connectionStatus => _connectionStatusController.stream;

  // Current connection status
  ConnectionStatus _currentStatus = ConnectionStatus.online;
  ConnectionStatus get currentStatus => _currentStatus;

  // Subscription to connectivity changes
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityService() {
    // Initialize connection state
    _initConnectivity();
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Initialize connection state at startup
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      AppLogger.error('Error checking connectivity', e);
      _updateConnectionStatus([ConnectivityResult.none]);
    }
  }

  // Update connection state and notify listeners
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // If at least one result is not "none", then we are online
    final isOffline =
        results.isEmpty || results.every((result) => result == ConnectivityResult.none);

    final newStatus = isOffline ? ConnectionStatus.offline : ConnectionStatus.online;

    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _connectionStatusController.add(_currentStatus);

      AppLogger.info('Connection status changed to: ${_currentStatus.name}');
    }
  }

  // Manually check connection status
  Future<ConnectionStatus> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return _currentStatus;
    } catch (e) {
      AppLogger.error('Error checking connectivity', e);
      return ConnectionStatus.offline;
    }
  }

  // Clean up resources when the service is destroyed
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}
