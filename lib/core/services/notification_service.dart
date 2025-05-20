import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../di/injection.dart';
import '../utils/logger.dart';
import 'navigation_service.dart';

// Canal de notification pour Android
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

  // Pour stocker le token FCM
  String? _token;
  String? get token => _token;

  // Initialiser le service de notification
  Future<void> initialize() async {
    try {
      // Demander la permission pour les notifications
      await _requestPermission();

      // Initialiser les notifications locales
      await _initializeLocalNotifications();

      // Configurer les gestionnaires de messages
      _configureForegroundHandler();
      _configureBackgroundOpenedAppHandler();

      // Obtenir le token FCM
      await _getToken();

      AppLogger.info('NotificationService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize NotificationService', e, stackTrace);
    }
  }

  // Demander la permission pour les notifications
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

  // Initialiser les notifications locales
  Future<void> _initializeLocalNotifications() async {
    // Initialiser les paramètres pour Android
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialiser les paramètres pour iOS
    const iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialiser les paramètres globaux
    const initSettings = InitializationSettings(android: androidInitSettings, iOS: iosInitSettings);

    // Initialiser le plugin avec les paramètres
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Créer le canal de notification pour Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Configurer le gestionnaire de messages en premier plan
  void _configureForegroundHandler() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Configurer le gestionnaire de messages en arrière-plan lorsque l'application est ouverte
  void _configureBackgroundOpenedAppHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  // Obtenir le token FCM
  Future<void> _getToken() async {
    _token = await _messaging.getToken();
    AppLogger.debug('FCM Token: $_token');

    // Écouter les changements de token
    _messaging.onTokenRefresh.listen((newToken) {
      _token = newToken;
      AppLogger.debug('FCM Token refreshed: $_token');
      // Ici, vous pourriez vouloir envoyer le nouveau token à votre serveur
    });
  }

  // Gérer les messages reçus en premier plan
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.debug('Foreground message received: ${message.notification?.title}');

    // Extraire les données de notification
    final notification = message.notification;
    final android = message.notification?.android;

    // Si la notification contient un titre et un corps, afficher une notification locale
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

  // Gérer les messages lorsque l'application est ouverte à partir d'une notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.debug('App opened from notification: ${message.notification?.title}');

    // Naviguer vers un écran spécifique en fonction de la notification
    _handleNotificationNavigation(message.data);
  }

  // Gérer la navigation lorsqu'une notification est tapée
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

  // Naviguer vers un écran spécifique en fonction des données de notification
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Exemple de navigation basée sur les données de notification
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

  // Souscrire à un topic pour recevoir des notifications ciblées
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    AppLogger.debug('Subscribed to topic: $topic');
  }

  // Se désabonner d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    AppLogger.debug('Unsubscribed from topic: $topic');
  }
}
