import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../utils/logger.dart';

@lazySingleton
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver? _observer;

  // Getter pour l'observer (utilisé dans la configuration du routeur)
  FirebaseAnalyticsObserver get observer {
    _observer ??= FirebaseAnalyticsObserver(analytics: _analytics);
    return _observer!;
  }

  // Initialiser le service d'analytics
  Future<void> initialize() async {
    try {
      // Activer la collecte d'analytics (désactivée en mode debug par défaut)
      await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);

      // Définir l'ID utilisateur si disponible
      // await _analytics.setUserId(id: 'user123');

      AppLogger.info('AnalyticsService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize AnalyticsService', e, stackTrace);
    }
  }

  // Enregistrer un événement de connexion
  Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      AppLogger.debug('Analytics: Logged login event with method: $method');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log login event', e, stackTrace);
    }
  }

  // Enregistrer un événement d'inscription
  Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      AppLogger.debug('Analytics: Logged sign up event with method: $method');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log sign up event', e, stackTrace);
    }
  }

  // Enregistrer un événement de recherche
  Future<void> logSearch({required String searchTerm}) async {
    try {
      await _analytics.logSearch(searchTerm: searchTerm);
      AppLogger.debug('Analytics: Logged search event with term: $searchTerm');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log search event', e, stackTrace);
    }
  }

  // Enregistrer un événement d'achat
  Future<void> logPurchase({
    required double value,
    required String currency,
    required String itemId,
    required String itemName,
  }) async {
    try {
      await _analytics.logPurchase(
        currency: currency,
        value: value,
        items: [AnalyticsEventItem(itemId: itemId, itemName: itemName)],
      );
      AppLogger.debug('Analytics: Logged purchase event: $itemName ($value $currency)');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log purchase event', e, stackTrace);
    }
  }

  // Enregistrer un événement personnalisé
  Future<void> logCustomEvent({required String name, Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      AppLogger.debug('Analytics: Logged custom event: $name with params: $parameters');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log custom event', e, stackTrace);
    }
  }

  // Définir les propriétés utilisateur
  Future<void> setUserProperties({
    String? userId,
    String? userRole,
    String? subscriptionType,
  }) async {
    try {
      if (userId != null) {
        await _analytics.setUserId(id: userId);
      }

      if (userRole != null) {
        await _analytics.setUserProperty(name: 'user_role', value: userRole);
      }

      if (subscriptionType != null) {
        await _analytics.setUserProperty(name: 'subscription_type', value: subscriptionType);
      }

      AppLogger.debug('Analytics: Set user properties');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set user properties', e, stackTrace);
    }
  }

  // Définir l'écran courant
  Future<void> setCurrentScreen({required String screenName}) async {
    try {
      await _analytics.setCurrentScreen(screenName: screenName);
      AppLogger.debug('Analytics: Set current screen to: $screenName');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set current screen', e, stackTrace);
    }
  }
}
