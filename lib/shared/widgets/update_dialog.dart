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
      title: Text(updateInfo.forceUpdate ? 'Update Required' : 'Update Available'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              updateInfo.forceUpdate
                  ? 'An update is required to continue using the application.'
                  : 'A new version of the application is available.',
            ),
            const SizedBox(height: 16),
            Text(
              'Version ${updateInfo.availableVersion}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              const Text('What\'s New:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...updateInfo.releaseNotes.map(
                (note) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(note)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!updateInfo.forceUpdate) TextButton(onPressed: onLater, child: const Text('Later')),
        AppButton(
          text: 'Update',
          onPressed: onUpdate,
          fullWidth: false,
          type: AppButtonType.primary,
        ),
      ],
    );
  }
}
