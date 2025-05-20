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
  // Initialiser le service de gestion des erreurs
  Future<void> initialize() async {
    try {
      // Activer Crashlytics seulement en production et staging
      final enableCrashlytics = !kDebugMode && !EnvConfig.isDevelopment;
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enableCrashlytics);

      // Capturer les erreurs Flutter
      FlutterError.onError = _handleFlutterError;

      // Capturer les erreurs asynchrones
      PlatformDispatcher.instance.onError = _handlePlatformError;

      // Capturer les erreurs d'isolate
      Isolate.current.addErrorListener(
        RawReceivePort((pair) {
          final List<dynamic> errorAndStacktrace = pair;
          _handleIsolateError(errorAndStacktrace[0], errorAndStacktrace[1]);
        }).sendPort,
      );

      // Définir les informations sur l'appareil
      if (enableCrashlytics) {
        await setDeviceInfo();
      }

      AppLogger.info('ErrorService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize ErrorService', e, stackTrace);
    }
  }

  // Méthode pour ajouter plusieurs clés personnalisées en une seule fois
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    if (kDebugMode || EnvConfig.isDevelopment) return;

    for (final entry in keys.entries) {
      await FirebaseCrashlytics.instance.setCustomKey(entry.key, entry.value);
      AppLogger.debug('Crashlytics: Set custom key ${entry.key} = ${entry.value}');
    }
  }

  // Méthode pour ajouter des informations sur l'appareil
  Future<void> setDeviceInfo() async {
    if (kDebugMode || EnvConfig.isDevelopment) return;

    try {
      // Utiliser package_info_plus pour obtenir des informations sur l'application
      final packageInfo = await PackageInfo.fromPlatform();
      await setCustomKeys({
        'app_name': packageInfo.appName,
        'app_version': packageInfo.version,
        'build_number': packageInfo.buildNumber,
        'package_name': packageInfo.packageName,
      });

      // Utiliser device_info_plus pour obtenir des informations sur l'appareil
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

  // Méthode pour ajouter des informations sur l'utilisateur actuel
  Future<void> setUserInfo(String? userId, {String? email, String? name, String? role}) async {
    if (kDebugMode || EnvConfig.isDevelopment) return;

    try {
      // Définir l'identifiant de l'utilisateur
      if (userId != null) {
        await FirebaseCrashlytics.instance.setUserIdentifier(userId);
        AppLogger.debug('Crashlytics: User identifier set to $userId');
      }

      // Ajouter d'autres informations sur l'utilisateur
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

  // Méthode pour ajouter des breadcrumbs (étapes de navigation)
  Future<void> addBreadcrumb(String message, {Map<String, dynamic>? data}) async {
    if (kDebugMode || EnvConfig.isDevelopment) return;

    try {
      // Créer un message formaté avec les données
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

  // Gérer les erreurs Flutter
  void _handleFlutterError(FlutterErrorDetails details) {
    AppLogger.error('Flutter error: ${details.exception}', details.exception, details.stack);

    if (!kDebugMode && !EnvConfig.isDevelopment) {
      // Envoyer l'erreur à Crashlytics
      FirebaseCrashlytics.instance.recordFlutterError(details);
    } else {
      // En mode debug, afficher l'erreur dans la console
      FlutterError.dumpErrorToConsole(details);
    }
  }

  // Gérer les erreurs de plateforme
  bool _handlePlatformError(Object error, StackTrace stack) {
    AppLogger.error('Platform error', error, stack);

    if (!kDebugMode && !EnvConfig.isDevelopment) {
      // Envoyer l'erreur à Crashlytics
      FirebaseCrashlytics.instance.recordError(error, stack);
    }

    // Retourner true pour empêcher la propagation de l'erreur
    return true;
  }

  // Gérer les erreurs d'isolate
  void _handleIsolateError(dynamic error, dynamic stackTrace) {
    AppLogger.error('Isolate error', error, stackTrace);

    if (!kDebugMode && !EnvConfig.isDevelopment) {
      // Envoyer l'erreur à Crashlytics
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }

  // Méthode pour enregistrer manuellement une erreur
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
        // Convertir information en non-nullable si nécessaire
        information: information ?? const <Object>[],
        fatal: fatal,
      );
    }
  }

  // Méthode pour définir des attributs utilisateur
  Future<void> setUserIdentifier(String? userId) async {
    if (!kDebugMode && !EnvConfig.isDevelopment) {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? 'anonymous');
    }
  }

  // Méthode pour définir des clés personnalisées
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!kDebugMode && !EnvConfig.isDevelopment) {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    }
  }

  // Méthode pour enregistrer un message de log
  Future<void> log(String message) async {
    AppLogger.debug('Crashlytics log: $message');

    if (!kDebugMode && !EnvConfig.isDevelopment) {
      await FirebaseCrashlytics.instance.log(message);
    }
  }

  // Méthode pour forcer un crash (utile pour les tests)
  void forceCrash() {
    if (kDebugMode) {
      AppLogger.warning('Force crash called in debug mode - no crash will occur');
      return;
    }

    FirebaseCrashlytics.instance.crash();
  }
}
