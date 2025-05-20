import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../routes/navigation_observer.dart';
import '../di/injection.dart';

@lazySingleton
class NavigationService {
  AppNavigationObserver get _observer => getIt<AppNavigationObserver>();

  // Méthode pour naviguer vers une route spécifique
  void navigateTo(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }

  // Méthode pour naviguer vers une route sans contexte (utile pour les notifications)
  void navigateToRoute(String route) {
    // Utilisez le navigateur global pour naviguer
    final router = getIt<GoRouter>();
    router.go(route);
  }

  // Méthode pour pousser une nouvelle route sur la pile
  void pushRoute(BuildContext context, String route, {Object? extra}) {
    context.push(route, extra: extra);
  }

  // Méthode pour remplacer la route actuelle
  void replaceRoute(BuildContext context, String route, {Object? extra}) {
    context.replace(route, extra: extra);
  }

  // Méthode pour revenir en arrière
  void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  // Méthode pour vérifier si on peut revenir en arrière
  bool canGoBack() {
    return _observer.canGoBack();
  }

  // Méthode pour obtenir le nom de la route actuelle
  String getCurrentRouteName() {
    return _observer.getCurrentRouteName();
  }

  // Méthode pour afficher une boîte de dialogue de confirmation
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

  // Méthode pour afficher une snackbar
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
