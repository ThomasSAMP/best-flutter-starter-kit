import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/services/update_service.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/update_dialog.dart';

class UpdateTestScreen extends ConsumerStatefulWidget {
  const UpdateTestScreen({super.key});

  @override
  ConsumerState<UpdateTestScreen> createState() => _UpdateTestScreenState();
}

class _UpdateTestScreenState extends ConsumerState<UpdateTestScreen> {
  final _updateService = getIt<UpdateService>();
  final _navigationService = getIt<NavigationService>();
  String? _statusMessage;
  bool _isLoading = false;
  UpdateInfo? _updateInfo;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _updateService.initialize();
      setState(() {
        _statusMessage =
            'Application version: ${_updateService.currentVersion} (${_updateService.currentBuild})';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _updateInfo = null;
    });

    try {
      final updateInfo = await _updateService.checkForUpdate();

      setState(() {
        if (updateInfo != null) {
          _updateInfo = updateInfo;
          _statusMessage = 'Mise à jour disponible: ${updateInfo.availableVersion}';
        } else {
          _statusMessage = 'Aucune mise à jour disponible';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showUpdateDialog() {
    if (_updateInfo == null) return;

    showDialog(
      context: context,
      barrierDismissible: !_updateInfo!.forceUpdate,
      builder:
          (context) => UpdateDialog(
            updateInfo: _updateInfo!,
            onUpdate: () {
              Navigator.of(context).pop();
              _openStore();
            },
            onLater: _updateInfo!.forceUpdate ? null : () => Navigator.of(context).pop(),
          ),
    );
  }

  Future<void> _openStore() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final success = await _updateService.openStore();

      setState(() {
        _statusMessage = success ? 'Store ouvert avec succès' : 'Impossible d\'ouvrir le store';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _simulateForceUpdate() async {
    setState(() {
      _updateInfo = UpdateInfo(
        availableVersion: '2.0.0',
        minRequiredVersion: '2.0.0',
        releaseNotes: [
          '• Refonte complète de l\'application',
          '• Nouvelles fonctionnalités majeures',
          '• Corrections de sécurité importantes',
        ],
        updateUrl: '',
        forceUpdate: true,
      );
    });

    _showUpdateDialog();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Update Test',
        showBackButton: canPop,
        leading:
            !canPop
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _navigationService.navigateTo(context, '/settings'),
                )
                : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations sur l\'application',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (_statusMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusMessage!),
              ),
              const SizedBox(height: 16),
            ],
            AppButton(
              text: 'Vérifier les mises à jour',
              onPressed: _isLoading ? null : _checkForUpdates,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            if (_updateInfo != null) ...[
              AppButton(
                text: 'Afficher le dialogue de mise à jour',
                onPressed: _isLoading ? null : _showUpdateDialog,
              ),
              const SizedBox(height: 16),
            ],
            AppButton(text: 'Ouvrir le store', onPressed: _isLoading ? null : _openStore),
            const SizedBox(height: 16),
            AppButton(
              text: 'Simuler une mise à jour forcée',
              onPressed: _isLoading ? null : _simulateForceUpdate,
              type: AppButtonType.outline,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Instructions de test',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Utilisez le bouton "Vérifier les mises à jour" pour rechercher des mises à jour\n'
              '2. En mode développement, une mise à jour simulée sera disponible\n'
              '3. Utilisez "Afficher le dialogue de mise à jour" pour voir le dialogue de mise à jour\n'
              '4. "Ouvrir le store" tentera d\'ouvrir le store correspondant à votre plateforme\n'
              '5. "Simuler une mise à jour forcée" affichera un dialogue de mise à jour obligatoire',
            ),
          ],
        ),
      ),
    );
  }
}
