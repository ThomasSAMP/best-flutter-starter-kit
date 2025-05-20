import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../di/injection.dart';
import '../utils/logger.dart';
import 'analytics_service.dart';
import 'error_service.dart';
import 'notification_service.dart';
import 'update_service.dart';

@lazySingleton
class FirebaseService {
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();

      // Initialize the error service first
      await getIt<ErrorService>().initialize();

      // Configure the background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Initialize notification service
      await getIt<NotificationService>().initialize();

      // Initialize analytics service
      await getIt<AnalyticsService>().initialize();

      // Initialize the update service
      await getIt<UpdateService>().initialize();

      // Initialize the connectivity service
      // await getIt<ConnectivityService>().initialize();
      // ==> No need to initialize the connectivity service explicitly as the manufacturer takes care of it

      AppLogger.info('Firebase initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Firebase', e, stackTrace);
      if (!kDebugMode) {
        // Use FirebaseCrashlytics directly here as ErrorService might not be initialized
        await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }
    }
  }
}

// This function must be at the top level (not a class method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if necessary (for background messages)
  await Firebase.initializeApp();

  print('Background message received: ${message.notification?.title}');
  print('Message data: ${message.data}');

  // TODO: Store message data to process when the application is opened
  // TODO: For example, using SharedPreferences
}
