import 'package:flutter/material.dart';

import '../core/utils/logger.dart';

class AppNavigationObserver extends NavigatorObserver {
  final List<Route<dynamic>> routeStack = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    routeStack.add(route);
    _logNavigation('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    routeStack.remove(route);
    _logNavigation('POP', route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    routeStack.remove(route);
    _logNavigation('REMOVE', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      final index = routeStack.indexOf(oldRoute);
      if (index != -1 && newRoute != null) {
        routeStack[index] = newRoute;
      }
    }
    _logNavigation('REPLACE', newRoute, oldRoute);
  }

  void _logNavigation(String action, Route<dynamic>? route, Route<dynamic>? previousRoute) {
    final routeName = route?.settings.name ?? 'unknown';
    final previousRouteName = previousRoute?.settings.name ?? 'none';

    AppLogger.debug('Navigation: $action - From: $previousRouteName To: $routeName');

    // Ici, vous pourriez également envoyer des événements à Firebase Analytics
    // ou à d'autres services d'analyse
  }

  bool canGoBack() {
    return routeStack.length > 1;
  }

  String getCurrentRouteName() {
    if (routeStack.isEmpty) return '';
    return routeStack.last.settings.name ?? '';
  }
}
