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
      _statusMessage = 'Haptic feedback ${value ? 'enabled' : 'disabled'}';
    });
  }

  void _triggerHaptic(HapticFeedbackType type) {
    _hapticService.feedback(type);
    setState(() {
      _statusMessage = 'Haptic feedback triggered: ${type.name}';
    });
  }

  void _triggerCustomVibration() {
    // Custom vibration pattern: 500ms on, 100ms off, 200ms on, 100ms off, 500ms on
    _hapticService.customVibration([0, 500, 100, 200, 100, 500]);
    setState(() {
      _statusMessage = 'Custom vibration triggered';
    });
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    final canVibrate = _hapticService.canVibrate;

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Haptic Test',
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
              'Haptic Feedback',
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
                child: const Text('Your device does not support vibration'),
              )
            else
              Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable haptic feedback'),
                    value: _hapticEnabled,
                    onChanged: _toggleHaptic,
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Haptic Feedback Types',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildHapticButton('Light', HapticFeedbackType.light),
                      _buildHapticButton('Medium', HapticFeedbackType.medium),
                      _buildHapticButton('Heavy', HapticFeedbackType.heavy),
                      _buildHapticButton('Success', HapticFeedbackType.success),
                      _buildHapticButton('Warning', HapticFeedbackType.warning),
                      _buildHapticButton('Error', HapticFeedbackType.error),
                      _buildHapticButton('Selection', HapticFeedbackType.selection),
                      _buildHapticButton('Tab', HapticFeedbackType.tabSelection),
                      _buildHapticButton('Button', HapticFeedbackType.buttonPress),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Custom Vibration',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Custom Vibration',
                    onPressed: _triggerCustomVibration,
                    icon: Icons.vibration,
                  ),
                  AppButton(
                    text: 'Stop Vibration',
                    onPressed: () {
                      _hapticService.stopVibration();
                      setState(() {
                        _statusMessage = 'Vibration stopped';
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
              '1. Turn haptic feedback on or off with the switch\n'
              '2. Try out the different types of haptic feedback by pressing the buttons\n'
              '3. Test custom vibration to feel a complex vibration pattern\n'
              '4. Note that some feedback types may not be perceptible on all devices',
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
