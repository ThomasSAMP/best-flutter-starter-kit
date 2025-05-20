import 'package:flutter/material.dart';

import '../../core/services/update_service.dart';
import 'app_button.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  final VoidCallback onUpdate;
  final VoidCallback? onLater;

  const UpdateDialog({super.key, required this.updateInfo, required this.onUpdate, this.onLater});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(updateInfo.forceUpdate ? 'Mise à jour requise' : 'Mise à jour disponible'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              updateInfo.forceUpdate
                  ? 'Une mise à jour est requise pour continuer à utiliser l\'application.'
                  : 'Une nouvelle version de l\'application est disponible.',
            ),
            const SizedBox(height: 16),
            Text(
              'Version ${updateInfo.availableVersion}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              const Text('Nouveautés :', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...updateInfo.releaseNotes.map(
                (note) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(note)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!updateInfo.forceUpdate) TextButton(onPressed: onLater, child: const Text('Plus tard')),
        AppButton(
          text: 'Mettre à jour',
          onPressed: onUpdate,
          fullWidth: false,
          type: AppButtonType.primary,
        ),
      ],
    );
  }
}
