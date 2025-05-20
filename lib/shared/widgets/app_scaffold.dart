import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/services/haptic_service.dart';
import '../models/tab_item.dart';
import 'connectivity_indicator.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final List<TabItem> tabs;
  final String currentPath;

  const AppScaffold({
    super.key,
    required this.child,
    required this.tabs,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final hapticService = getIt<HapticService>();

    return WillPopScope(
      onWillPop: () async {
        // Vérifier si on peut naviguer en arrière dans le navigateur actuel
        final canPop = Navigator.of(context).canPop();
        if (canPop) {
          return true; // Laisser le framework gérer le pop
        }

        // Si on est sur une page autre que la page d'accueil, naviguer vers la page d'accueil
        if (currentPath != '/home') {
          context.go('/home');
          return false; // Empêcher le comportement par défaut
        }

        // Sinon, demander à l'utilisateur s'il veut quitter l'application
        return await _showExitDialog(context) ?? false;
      },
      child: Scaffold(
        body: Column(
          children: [
            // Ajouter l'indicateur de connectivité en haut
            const ConnectivityIndicator(),
            // Contenu principal
            Expanded(child: child),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _getCurrentIndex(),
          onTap: (index) => _onItemTapped(context, index, hapticService),
          items:
              tabs.map((tab) {
                return BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label,
                );
              }).toList(),
        ),
      ),
    );
  }

  int _getCurrentIndex() {
    final index = tabs.indexWhere((tab) => tab.initialLocation == currentPath);
    return index < 0 ? 0 : index;
  }

  void _onItemTapped(BuildContext context, int index, HapticService hapticService) {
    final destination = tabs[index].initialLocation;
    if (destination != currentPath) {
      // Déclencher un retour haptique lors du changement d'onglet
      hapticService.feedback(HapticFeedbackType.tabSelection);
      context.go(destination);
    }
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    // Déclencher un retour haptique pour la boîte de dialogue
    getIt<HapticService>().feedback(HapticFeedbackType.medium);

    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Déclencher un retour haptique pour confirmer la sortie
                  getIt<HapticService>().feedback(HapticFeedbackType.heavy);
                  Navigator.of(context).pop(true);
                },
                child: const Text('Exit'),
              ),
            ],
          ),
    );
  }
}
