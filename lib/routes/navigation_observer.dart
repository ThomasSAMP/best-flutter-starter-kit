import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/services/error_service.dart';
import '../core/utils/logger.dart';

class AppNavigationObserver extends NavigatorObserver {
  final List<Route<dynamic>> routeStack = [];
  final ErrorService _errorService = getIt<ErrorService>();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    routeStack.add(route);
    _logNavigation('PUSH', route, previousRoute);

    // Ajouter un breadcrumb pour Crashlytics
    _addNavigationBreadcrumb('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    routeStack.remove(route);
    _logNavigation('POP', route, previousRoute);

    // Ajouter un breadcrumb pour Crashlytics
    _addNavigationBreadcrumb('POP', route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    routeStack.remove(route);
    _logNavigation('REMOVE', route, previousRoute);

    // Ajouter un breadcrumb pour Crashlytics
    _addNavigationBreadcrumb('REMOVE', route, previousRoute);
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

    // Ajouter un breadcrumb pour Crashlytics
    _addNavigationBreadcrumb('REPLACE', newRoute, oldRoute);
  }

  void _logNavigation(String action, Route<dynamic>? route, Route<dynamic>? previousRoute) {
    // Extraire le nom de la route de manière plus robuste
    final routeName = _getRouteName(route);
    final previousRouteName = _getRouteName(previousRoute);

    AppLogger.debug('Navigation: $action - From: $previousRouteName To: $routeName');
  }

  void _addNavigationBreadcrumb(
    String action,
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  ) {
    final routeName = _getRouteName(route);
    final previousRouteName = _getRouteName(previousRoute);

    _errorService.addBreadcrumb(
      'Navigation: $action',
      data: {'from': previousRouteName, 'to': routeName},
    );
  }

  String _getRouteName(Route<dynamic>? route) {
    if (route == null) return 'none';

    // Essayer d'obtenir le nom de la route à partir des paramètres
    if (route.settings.name != null && route.settings.name!.isNotEmpty) {
      return route.settings.name!;
    }

    // Essayer d'obtenir des informations à partir des arguments
    if (route.settings.arguments != null) {
      return 'Route(args: ${route.settings.arguments})';
    }

    // Dernier recours: utiliser le type de route
    return route.runtimeType.toString();
  }

  bool canGoBack() {
    return routeStack.length > 1;
  }

  String getCurrentRouteName() {
    if (routeStack.isEmpty) return '';
    return _getRouteName(routeStack.last);
  }
}
