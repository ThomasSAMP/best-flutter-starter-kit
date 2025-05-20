import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/syncable_model.dart';
import '../utils/logger.dart';

@lazySingleton
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  /// Save a list of models to local storage
  Future<bool> saveModelList<T extends SyncableModel>(String key, List<T> items) async {
    try {
      final jsonList = items.map((item) => jsonEncode(item.toJson())).toList();
      final result = await _prefs.setStringList(key, jsonList);

      AppLogger.debug('Saved ${items.length} items to local storage with key: $key');
      return result;
    } catch (e) {
      AppLogger.error('Error saving items to local storage', e);
      return false;
    }
  }

  /// Load a list of models from local storage
  List<T> loadModelList<T extends SyncableModel>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    try {
      final jsonList = _prefs.getStringList(key) ?? [];
      final items =
          jsonList.map((json) => fromJson(jsonDecode(json) as Map<String, dynamic>)).toList();

      AppLogger.debug('Loaded ${items.length} items from local storage with key: $key');
      return items;
    } catch (e) {
      AppLogger.error('Error loading items from local storage', e);
      return [];
    }
  }

  /// Save an individual model to local storage
  Future<bool> saveModel<T extends SyncableModel>(String key, T item) async {
    try {
      final jsonString = jsonEncode(item.toJson());
      final result = await _prefs.setString(key, jsonString);

      AppLogger.debug('Saved item to local storage with key: $key');
      return result;
    } catch (e) {
      AppLogger.error('Error saving item to local storage', e);
      return false;
    }
  }

  /// Load an individual model from local storage
  T? loadModel<T extends SyncableModel>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;

      final item = fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

      AppLogger.debug('Loaded item from local storage with key: $key');
      return item;
    } catch (e) {
      AppLogger.error('Error loading item from local storage', e);
      return null;
    }
  }

  /// Remove an entry from local storage
  Future<bool> remove(String key) async {
    try {
      final result = await _prefs.remove(key);

      AppLogger.debug('Removed item from local storage with key: $key');
      return result;
    } catch (e) {
      AppLogger.error('Error removing item from local storage', e);
      return false;
    }
  }

  /// Check if a key exists in local storage
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Save pending operations to local storage
  Future<bool> savePendingOperations<T extends SyncableModel>(
    String key,
    List<PendingOperation<T>> operations,
  ) async {
    try {
      final jsonList =
          operations
              .map((op) => jsonEncode({'type': op.type.index, 'data': op.data.toJson()}))
              .toList();

      final result = await _prefs.setStringList(key, jsonList);

      AppLogger.debug(
        'Saved ${operations.length} pending operations to local storage with key: $key',
      );
      return result;
    } catch (e) {
      AppLogger.error('Error saving pending operations to local storage', e);
      return false;
    }
  }

  /// Load pending operations from local storage
  List<Map<String, dynamic>> loadPendingOperationsData(String key) {
    try {
      final jsonList = _prefs.getStringList(key) ?? [];
      final operations = jsonList.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();

      AppLogger.debug(
        'Loaded ${operations.length} pending operations from local storage with key: $key',
      );
      return operations;
    } catch (e) {
      AppLogger.error('Error loading pending operations from local storage', e);
      return [];
    }
  }
}

/// Types of pending operations
enum OperationType { create, update, delete }

/// Class representing a pending operation
class PendingOperation<T extends SyncableModel> {
  final OperationType type;
  final T data;
  final Future<void> Function() execute;

  PendingOperation({required this.type, required this.data, required this.execute});
}
