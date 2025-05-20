import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../utils/logger.dart';

@lazySingleton
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver? _observer;

  // Getter for the observer (used in router configuration)
  FirebaseAnalyticsObserver get observer {
    _observer ??= FirebaseAnalyticsObserver(analytics: _analytics);
    return _observer!;
  }

  // Initialize analytics service
  Future<void> initialize() async {
    try {
      // Enable analytics collection (disabled in debug mode by default)
      await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);

      // Set user ID if available
      // await _analytics.setUserId(id: 'user123');

      AppLogger.info('AnalyticsService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize AnalyticsService', e, stackTrace);
    }
  }

  // Log a login event
  Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      AppLogger.debug('Analytics: Logged login event with method: $method');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log login event', e, stackTrace);
    }
  }

  // Log a sign up event
  Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      AppLogger.debug('Analytics: Logged sign up event with method: $method');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log sign up event', e, stackTrace);
    }
  }

  // Log a search event
  Future<void> logSearch({required String searchTerm}) async {
    try {
      await _analytics.logSearch(searchTerm: searchTerm);
      AppLogger.debug('Analytics: Logged search event with term: $searchTerm');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log search event', e, stackTrace);
    }
  }

  // Log a purchase event
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

  // Log a custom event
  Future<void> logCustomEvent({required String name, Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      AppLogger.debug('Analytics: Logged custom event: $name with params: $parameters');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log custom event', e, stackTrace);
    }
  }

  // Set user properties
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

  // Set current screen
  Future<void> setCurrentScreen({required String screenName}) async {
    try {
      await _analytics.setCurrentScreen(screenName: screenName);
      AppLogger.debug('Analytics: Set current screen to: $screenName');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set current screen', e, stackTrace);
    }
  }
}
