import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/tab_item.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final List<TabItem> tabs;
  final String currentPath;

  const AppScaffold({
    Key? key,
    required this.child,
    required this.tabs,
    required this.currentPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(),
        onTap: (index) => _onItemTapped(context, index),
        items:
            tabs.map((tab) {
              return BottomNavigationBarItem(
                icon: Icon(tab.icon),
                activeIcon: Icon(tab.activeIcon),
                label: tab.label,
              );
            }).toList(),
      ),
    );
  }

  int _getCurrentIndex() {
    final index = tabs.indexWhere((tab) => tab.initialLocation == currentPath);
    return index < 0 ? 0 : index;
  }

  void _onItemTapped(BuildContext context, int index) {
    final destination = tabs[index].initialLocation;
    if (destination != currentPath) {
      context.go(destination);
    }
  }
}
