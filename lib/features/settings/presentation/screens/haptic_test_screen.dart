import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_button.dart';

class HapticTestScreen extends ConsumerStatefulWidget {
  const HapticTestScreen({super.key});

  @override
  ConsumerState<HapticTestScreen> createState() => _HapticTestScreenState();
}

class _HapticTestScreenState extends ConsumerState<HapticTestScreen> {
  final _hapticService = getIt<HapticService>();
  final _navigationService = getIt<NavigationService>();

  bool _hapticEnabled = true;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _hapticEnabled = _hapticService.isHapticEnabled;
  }

  void _toggleHaptic(bool value) {
    setState(() {
      _hapticEnabled = value;
      _hapticService.setHapticEnabled(value);
      _statusMessage = 'Retour haptique ${value ? 'activé' : 'désactivé'}';
    });
  }

  void _triggerHaptic(HapticFeedbackType type) {
    _hapticService.feedback(type);
    setState(() {
      _statusMessage = 'Retour haptique déclenché: ${type.name}';
    });
  }

  void _triggerCustomVibration() {
    // Modèle de vibration personnalisé: 500ms on, 100ms off, 200ms on, 100ms off, 500ms on
    _hapticService.customVibration([0, 500, 100, 200, 100, 500]);
    setState(() {
      _statusMessage = 'Vibration personnalisée déclenchée';
    });
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    final canVibrate = _hapticService.canVibrate;

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Test Haptique',
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
              'Retour Haptique',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (!canVibrate)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Votre appareil ne prend pas en charge la vibration'),
              )
            else
              Column(
                children: [
                  SwitchListTile(
                    title: const Text('Activer le retour haptique'),
                    value: _hapticEnabled,
                    onChanged: _toggleHaptic,
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Types de retour haptique',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildHapticButton('Léger', HapticFeedbackType.light),
                      _buildHapticButton('Moyen', HapticFeedbackType.medium),
                      _buildHapticButton('Fort', HapticFeedbackType.heavy),
                      _buildHapticButton('Succès', HapticFeedbackType.success),
                      _buildHapticButton('Avertissement', HapticFeedbackType.warning),
                      _buildHapticButton('Erreur', HapticFeedbackType.error),
                      _buildHapticButton('Sélection', HapticFeedbackType.selection),
                      _buildHapticButton('Tab', HapticFeedbackType.tabSelection),
                      _buildHapticButton('Bouton', HapticFeedbackType.buttonPress),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Vibration Personnalisée',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Vibration Personnalisée',
                    onPressed: _triggerCustomVibration,
                    icon: Icons.vibration,
                  ),
                  AppButton(
                    text: 'Arrêter Vibration',
                    onPressed: () {
                      _hapticService.stopVibration();
                      setState(() {
                        _statusMessage = 'Vibration arrêtée';
                      });
                    },
                    icon: Icons.stop,
                    type: AppButtonType.outline,
                  ),
                ],
              ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusMessage!),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              '1. Activez ou désactivez le retour haptique avec le commutateur\n'
              '2. Essayez les différents types de retour haptique en appuyant sur les boutons\n'
              '3. Testez la vibration personnalisée pour sentir un modèle de vibration complexe\n'
              '4. Notez que certains types de retour peuvent ne pas être perceptibles sur tous les appareils',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHapticButton(String text, HapticFeedbackType type) {
    return ElevatedButton(
      onPressed: () => _triggerHaptic(type),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(text),
    );
  }
}
