import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

@lazySingleton
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Initialize Hive
  Future<void> initHive() async {
    try {
      await Hive.initFlutter();
      // Register adapters here if needed
      // Hive.registerAdapter(MyModelAdapter());
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing Hive', e, stackTrace);
    }
  }

  // SharedPreferences methods

  Future<bool> saveString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e, stackTrace) {
      AppLogger.error('Error saving string', e, stackTrace);
      return false;
    }
  }

  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting string', e, stackTrace);
      return null;
    }
  }

  Future<bool> saveBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e, stackTrace) {
      AppLogger.error('Error saving bool', e, stackTrace);
      return false;
    }
  }

  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting bool', e, stackTrace);
      return null;
    }
  }

  Future<bool> saveInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e, stackTrace) {
      AppLogger.error('Error saving int', e, stackTrace);
      return false;
    }
  }

  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting int', e, stackTrace);
      return null;
    }
  }

  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e, stackTrace) {
      AppLogger.error('Error removing key', e, stackTrace);
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing preferences', e, stackTrace);
      return false;
    }
  }

  // Hive methods

  Future<Box<T>> openBox<T>(String boxName) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (e, stackTrace) {
      AppLogger.error('Error opening box', e, stackTrace);
      rethrow;
    }
  }

  Future<void> closeBox<T>(Box<T> box) async {
    try {
      await box.close();
    } catch (e, stackTrace) {
      AppLogger.error('Error closing box', e, stackTrace);
    }
  }

  Future<void> clearBox<T>(Box<T> box) async {
    try {
      await box.clear();
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing box', e, stackTrace);
    }
  }
}
