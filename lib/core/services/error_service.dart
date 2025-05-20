import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/env_config.dart';
import '../utils/logger.dart';

@lazySingleton
class ErrorService {
  // Initialize the error handling service
  Future<void> initialize() async {
    try {
      // Enable Crashlytics only in production and staging
      final enableCrashlytics = !kDebugMode && !EnvConfig.isDevelopment;
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enableCrashlytics);

      // Capture Flutter errors
      FlutterError.onError = _handleFlutterError;

      // Capture asynchronous errors
      PlatformDispatcher.instance.onError = _handlePlatformError;

      // Capture isolate errors
      Isolate.current.addErrorListener(
        RawReceivePort((pair) {
          final List<dynamic> errorAndStacktrace = pair;
          _handleIsolateError(errorAndStacktrace[0], errorAndStacktrace[1]);
        }).sendPort,
      );

      // Set device information
      if (enableCrashlytics) {
        await setDeviceInfo();
      }

      AppLogger.info('ErrorService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize ErrorService', e, stackTrace);
    }
  }

  // Method to add multiple custom keys at once
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    if (kDebugMode || EnvConfig.isDevelopment) return;

    for (final entry in keys.entries) {
      await FirebaseCrashlytics.instance.setCustomKey(entry.key, entry.value);
      AppLogger.debug('Crashlytics: Set custom key ${entry.key} = ${entry.value}');
    }
  }

  // Method to add device information
  Future<void> setDeviceInfo() async {
    if (kDebugMode || EnvConfig.isDevelopment) return;

    try {
      // Use package_info_plus to get application information
      final packageInfo = await PackageInfo.fromPlatform();
      await setCustomKeys({
        'app_name': packageInfo.appName,
        'app_version': packageInfo.version,
        'build_number': packageInfo.buildNumber,
        'package_name': packageInfo.packageName,
      });

      // Use device_info_plus to get device information
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        await setCustomKeys({
          'device_type': 'android',
          'android_version': androidInfo.version.release,
          'android_sdk': androidInfo.version.sdkInt.toString(),
          'device_model': androidInfo.model,
          'device_brand': androidInfo.brand,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        await setCustomKeys({
          'device_type': 'ios',
          'ios_version': iosInfo.systemVersion,
          'device_model': iosInfo.model,
          'device_name': iosInfo.name,
        });
      }

      AppLogger.debug('Crashlytics: Device info set successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set device info', e, stackTrace);
    }
  }

  // Method to add information about the current user
  Future<void> setUserInfo(String? userId, {String? email, String? name, String? role}) async {
    if (kDebugMode || EnvConfig.isDevelopment) return;

    try {
      // Set user identifier
      if (userId != null) {
        await FirebaseCrashlytics.instance.setUserIdentifier(userId);
        AppLogger.debug('Crashlytics: User identifier set to $userId');
      }

      // Add other user information
      final userInfo = <String, String>{};
      if (email != null) userInfo['user_email'] = email;
      if (name != null) userInfo['user_name'] = name;
      if (role != null) userInfo['user_role'] = role;

      if (userInfo.isNotEmpty) {
        await setCustomKeys(userInfo);
      }

      AppLogger.debug('Crashlytics: User info set successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set user info', e, stackTrace);
    }
  }

  // Method to add breadcrumbs (navigation steps)
  Future<void> addBreadcrumb(String message, {Map<String, dynamic>? data}) async {
    if (kDebugMode || EnvConfig.isDevelopment) return;

    try {
      // Create a formatted message with data
      var formattedMessage = message;
      if (data != null && data.isNotEmpty) {
        formattedMessage += ' - ${data.toString()}';
      }

      await FirebaseCrashlytics.instance.log(formattedMessage);
      AppLogger.debug('Crashlytics: Added breadcrumb - $formattedMessage');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add breadcrumb', e, stackTrace);
    }
  }

  // Handle Flutter errors
  void _handleFlutterError(FlutterErrorDetails details) {
    AppLogger.error('Flutter error: ${details.exception}', details.exception, details.stack);

    if (!kDebugMode && !EnvConfig.isDevelopment) {
      // Send the error to Crashlytics
      FirebaseCrashlytics.instance.recordFlutterError(details);
    } else {
      // In debug mode, display error in console
      FlutterError.dumpErrorToConsole(details);
    }
  }

  // Handle platform errors
  bool _handlePlatformError(Object error, StackTrace stack) {
    AppLogger.error('Platform error', error, stack);

    if (!kDebugMode && !EnvConfig.isDevelopment) {
      // Send the error to Crashlytics
      FirebaseCrashlytics.instance.recordError(error, stack);
    }

    // Return true to prevent error propagation
    return true;
  }

  // Handle isolate errors
  void _handleIsolateError(dynamic error, dynamic stackTrace) {
    AppLogger.error('Isolate error', error, stackTrace);

    if (!kDebugMode && !EnvConfig.isDevelopment) {
      // Send the error to Crashlytics
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }

  // Method to manually record an error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    Iterable<Object>? information,
    bool fatal = false,
  }) async {
    AppLogger.error(reason ?? 'Recorded error', exception, stack);

    if (!kDebugMode && !EnvConfig.isDevelopment) {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: reason,
        // Convert information to non-nullable if necessary
        information: information ?? const <Object>[],
        fatal: fatal,
      );
    }
  }

  // Method to set user attributes
  Future<void> setUserIdentifier(String? userId) async {
    if (!kDebugMode && !EnvConfig.isDevelopment) {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? 'anonymous');
    }
  }

  // Method to set custom keys
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!kDebugMode && !EnvConfig.isDevelopment) {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    }
  }

  // Method to record a log message
  Future<void> log(String message) async {
    AppLogger.debug('Crashlytics log: $message');

    if (!kDebugMode && !EnvConfig.isDevelopment) {
      await FirebaseCrashlytics.instance.log(message);
    }
  }

  // Method to force a crash (useful for testing)
  void forceCrash() {
    if (kDebugMode) {
      AppLogger.warning('Force crash called in debug mode - no crash will occur');
      return;
    }

    FirebaseCrashlytics.instance.crash();
  }
}
