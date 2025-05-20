import 'package:flutter/material.dart';

class TabItem {
  final String initialLocation;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  TabItem({
    required this.initialLocation,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
