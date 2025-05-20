import 'dart:async';
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

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

      AppLogger.info('ErrorService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize ErrorService', e, stackTrace);
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
