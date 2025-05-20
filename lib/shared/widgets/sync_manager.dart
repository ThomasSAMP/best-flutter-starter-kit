import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/syncable_model.dart';
import '../../core/providers/offline_data_provider.dart';
import '../../core/services/connectivity_service.dart';
import 'app_button.dart';

class SyncManager<T extends SyncableModel> extends ConsumerWidget {
  final StateNotifierProvider<OfflineDataNotifier<T>, OfflineDataState<T>> provider;
  final String entityName;

  const SyncManager({super.key, required this.provider, required this.entityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Synchronisation des ${entityName.toLowerCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            AppButton(
              text: 'Synchroniser',
              onPressed:
                  state.isSyncing || state.connectionStatus == ConnectionStatus.offline
                      ? null
                      : notifier.syncWithServer,
              isLoading: state.isSyncing,
              fullWidth: false,
              type: AppButtonType.outline,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              state.connectionStatus == ConnectionStatus.online ? Icons.wifi : Icons.wifi_off,
              size: 16,
              color: state.connectionStatus == ConnectionStatus.online ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              state.connectionStatus == ConnectionStatus.online ? 'En ligne' : 'Hors ligne',
              style: TextStyle(
                color:
                    state.connectionStatus == ConnectionStatus.online ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              state.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
