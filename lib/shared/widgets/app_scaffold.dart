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
        // Check if we can navigate back in the current navigator
        final canPop = Navigator.of(context).canPop();
        if (canPop) {
          return true; // Let the framework handle the pop
        }

        // If we are on a page other than the home page, navigate to the home page
        if (currentPath != '/home') {
          context.go('/home');
          return false; // Prevent default behavior
        }

        // Otherwise, ask the user if they want to exit the application
        return await _showExitDialog(context) ?? false;
      },
      child: Scaffold(
        body: Column(
          children: [
            // Add connectivity indicator at the top
            const ConnectivityIndicator(),
            // Main content
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
      // Trigger haptic feedback when changing tabs
      hapticService.feedback(HapticFeedbackType.tabSelection);
      context.go(destination);
    }
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    // Trigger haptic feedback for the dialog
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
                  // Trigger haptic feedback to confirm exit
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
