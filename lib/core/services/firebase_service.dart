import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../config/env_config.dart';
import '../di/injection.dart';
import '../utils/logger.dart';
import 'notification_service.dart';

@lazySingleton
class FirebaseService {
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();

      // Configure Crashlytics
      if (!kDebugMode && !EnvConfig.isDevelopment) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      } else {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      }

      // Configurer le gestionnaire de messages en arrière-plan
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Initialiser le service de notification
      await getIt<NotificationService>().initialize();

      AppLogger.info('Firebase initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Firebase', e, stackTrace);
      if (!kDebugMode) {
        await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }
    }
  }
}

// Cette fonction doit être au niveau supérieur (pas une méthode de classe)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialiser Firebase si nécessaire (pour les messages en arrière-plan)
  await Firebase.initializeApp();

  print('Background message received: ${message.notification?.title}');
  print('Message data: ${message.data}');

  // TODO: Stocker les données du message pour les traiter lorsque l'application est ouverte
  // TODO: Par exemple, en utilisant SharedPreferences
}
