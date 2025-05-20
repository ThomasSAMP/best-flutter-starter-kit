import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../config/env_config.dart';
import '../utils/logger.dart';

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
      
      // Configure FCM
      await _configureFCM();
      
      AppLogger.info('Firebase initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Firebase', e, stackTrace);
      if (!kDebugMode) {
        await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }
    }
  }

  Future<void> _configureFCM() async {
    // Request permission for iOS
    if (!kIsWeb) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      AppLogger.debug('FCM permission status: ${settings.authorizationStatus}');
    }
    
    // Get FCM token
    final token = await FirebaseMessaging.instance.getToken();
    AppLogger.debug('FCM Token: $token');
    
    // Configure FCM handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.debug('Foreground message received: ${message.notification?.title}');
    // Handle the message display, e.g., show a local notification
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.debug('App opened from notification: ${message.notification?.title}');
    // Navigate to a specific screen based on the notification
  }
}

// This function must be top-level (not a class method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed (for background messages)
  await Firebase.initializeApp();
  
  print('Background message received: ${message.notification?.title}');
  // Handle background message
}