import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../routes/navigation_observer.dart';
import '../di/injection.dart';

@lazySingleton
class NavigationService {
  AppNavigationObserver get _observer => getIt<AppNavigationObserver>();

  // Method to navigate to a specific route
  void navigateTo(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }

  // Method to navigate to a route without context (useful for notifications)
  void navigateToRoute(String route) {
    // Use the global navigator to navigate
    final router = getIt<GoRouter>();
    router.go(route);
  }

  // Method to push a new route onto the stack
  void pushRoute(BuildContext context, String route, {Object? extra}) {
    context.push(route, extra: extra);
  }

  // Method to replace the current route
  void replaceRoute(BuildContext context, String route, {Object? extra}) {
    context.replace(route, extra: extra);
  }

  // Method to go back
  void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  // Method to check if we can go back
  bool canGoBack() {
    return _observer.canGoBack();
  }

  // Method to get the current route name
  String getCurrentRouteName() {
    return _observer.getCurrentRouteName();
  }

  // Method to display a confirmation dialog
  Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  // Method to display a snackbar
  void showSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: duration, action: action));
  }
}
