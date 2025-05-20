import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../di/injection.dart';
import '../utils/logger.dart';
import 'navigation_service.dart';

// Notification Channel for Android
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications', // description
  importance: Importance.high,
);

@lazySingleton
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final NavigationService _navigationService = getIt<NavigationService>();

  // To store FCM token
  String? _token;
  String? get token => _token;

  // Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Configure message handlers
      _configureForegroundHandler();
      _configureBackgroundOpenedAppHandler();

      // Get FCM token
      await _getToken();

      AppLogger.info('NotificationService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize NotificationService', e, stackTrace);
    }
  }

  // Request permission for notifications
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    AppLogger.debug('Notification permission status: ${settings.authorizationStatus}');
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Initialize parameters for Android
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize parameters for iOS
    const iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize global parameters
    const initSettings = InitializationSettings(android: androidInitSettings, iOS: iosInitSettings);

    // Initialize plugin with parameters
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Configure foreground message handler
  void _configureForegroundHandler() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Configure background message handler when app is opened
  void _configureBackgroundOpenedAppHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  // Get FCM token
  Future<void> _getToken() async {
    _token = await _messaging.getToken();
    AppLogger.debug('FCM Token: $_token');

    // Listen for token changes
    _messaging.onTokenRefresh.listen((newToken) {
      _token = newToken;
      AppLogger.debug('FCM Token refreshed: $_token');
      // Here, you might want to send the new token to your server
    });
  }

  // Handle messages received in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.debug('Foreground message received: ${message.notification?.title}');

    // Extract notification data
    final notification = message.notification;
    final android = message.notification?.android;

    // If the notification contains a title and body, display a local notification
    if (notification != null && notification.title != null && notification.body != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'notification_icon',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  // Handle messages when app is opened from a notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.debug('App opened from notification: ${message.notification?.title}');

    // Navigate to a specific screen based on the notification
    _handleNotificationNavigation(message.data);
  }

  // Handle navigation when a notification is tapped
  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.debug('Notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationNavigation(data);
      } catch (e) {
        AppLogger.error('Error parsing notification payload', e);
      }
    }
  }

  // Navigate to a specific screen based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Example of navigation based on notification data
    if (data.containsKey('screen')) {
      final screen = data['screen'] as String;

      switch (screen) {
        case 'profile':
          _navigationService.navigateToRoute('/profile');
          break;
        case 'notifications':
          _navigationService.navigateToRoute('/notifications');
          break;
        case 'settings':
          _navigationService.navigateToRoute('/settings');
          break;
        default:
          _navigationService.navigateToRoute('/home');
      }
    }
  }

  // Subscribe to a topic to receive targeted notifications
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    AppLogger.debug('Subscribed to topic: $topic');
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    AppLogger.debug('Unsubscribed from topic: $topic');
  }
}
