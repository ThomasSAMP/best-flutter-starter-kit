import 'package:flutter/material.dart';

import '../../core/services/connectivity_service.dart';

class SyncStatusBadge extends StatelessWidget {
  final bool isSynced;
  final ConnectionStatus connectionStatus;
  final bool isSmall;

  const SyncStatusBadge({
    super.key,
    required this.isSynced,
    required this.connectionStatus,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOffline = connectionStatus == ConnectionStatus.offline;

    final icon = isOffline ? Icons.wifi_off : (isSynced ? Icons.cloud_done : Icons.cloud_off);

    final color = isOffline ? Colors.grey : (isSynced ? Colors.green : Colors.orange);

    final text = isOffline ? 'Hors ligne' : (isSynced ? 'Synchronisé' : 'Non synchronisé');

    if (isSmall) {
      return Icon(icon, size: 16, color: color);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
