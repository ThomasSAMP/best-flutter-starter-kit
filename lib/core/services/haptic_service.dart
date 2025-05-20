import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:vibration/vibration.dart';

import '../utils/logger.dart';

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  success,
  warning,
  error,
  selection,
  tabSelection,
  buttonPress,
}

@lazySingleton
class HapticService {
  bool _hapticEnabled = true;
  bool _canVibrate = false;

  // Constructor
  HapticService() {
    _initHaptic();
  }

  // Initialize haptic service
  Future<void> _initHaptic() async {
    try {
      _canVibrate = await Vibration.hasVibrator() ?? false;
      AppLogger.debug('HapticService initialized, canVibrate: $_canVibrate');
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing HapticService', e, stackTrace);
      _canVibrate = false;
    }
  }

  // Enable/disable haptic feedback
  void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
    AppLogger.debug('Haptic feedback ${enabled ? 'enabled' : 'disabled'}');
  }

  // Check if haptic feedback is enabled
  bool get isHapticEnabled => _hapticEnabled;

  // Check if the device can vibrate
  bool get canVibrate => _canVibrate;

  // Generic method to trigger haptic feedback
  Future<void> feedback(HapticFeedbackType type) async {
    if (!_hapticEnabled || !_canVibrate) return;

    try {
      switch (type) {
        case HapticFeedbackType.light:
          await _lightImpact();
          break;
        case HapticFeedbackType.medium:
          await _mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          await _heavyImpact();
          break;
        case HapticFeedbackType.success:
          await _successFeedback();
          break;
        case HapticFeedbackType.warning:
          await _warningFeedback();
          break;
        case HapticFeedbackType.error:
          await _errorFeedback();
          break;
        case HapticFeedbackType.selection:
          await _selectionFeedback();
          break;
        case HapticFeedbackType.tabSelection:
          await _tabSelectionFeedback();
          break;
        case HapticFeedbackType.buttonPress:
          await _buttonPressFeedback();
          break;
      }
    } catch (e) {
      AppLogger.error('Error triggering haptic feedback', e);
    }
  }

  // Light impact
  Future<void> _lightImpact() async {
    if (Platform.isIOS) {
      Vibration.vibrate(duration: 20, amplitude: 40);
    } else {
      Vibration.vibrate(duration: 20, amplitude: 40);
    }
  }

  // Medium impact
  Future<void> _mediumImpact() async {
    if (Platform.isIOS) {
      Vibration.vibrate(duration: 40, amplitude: 100);
    } else {
      Vibration.vibrate(duration: 40, amplitude: 100);
    }
  }

  // Heavy impact
  Future<void> _heavyImpact() async {
    if (Platform.isIOS) {
      Vibration.vibrate(duration: 60, amplitude: 255);
    } else {
      Vibration.vibrate(duration: 60, amplitude: 255);
    }
  }

  // Success feedback (custom vibration)
  Future<void> _successFeedback() async {
    if (Platform.isIOS) {
      await Vibration.vibrate(pattern: [0, 30, 100, 30]);
    } else {
      // Simulate success feedback on Android
      await Vibration.vibrate(pattern: [0, 30, 100, 30]);
    }
  }

  // Warning feedback (custom vibration)
  Future<void> _warningFeedback() async {
    if (Platform.isIOS) {
      await Vibration.vibrate(pattern: [0, 50, 100, 50]);
    } else {
      // Simulate warning feedback on Android
      await Vibration.vibrate(pattern: [0, 50, 100, 50]);
    }
  }

  // Error feedback (custom vibration)
  Future<void> _errorFeedback() async {
    if (Platform.isIOS) {
      await Vibration.vibrate(pattern: [0, 70, 100, 70, 100, 70]);
    } else {
      // Simulate error feedback on Android
      await Vibration.vibrate(pattern: [0, 70, 100, 70, 100, 70]);
    }
  }

  // Selection feedback
  Future<void> _selectionFeedback() async {
    await HapticFeedback.selectionClick();
  }

  // Tab selection feedback
  Future<void> _tabSelectionFeedback() async {
    if (Platform.isIOS) {
      await Vibration.vibrate(duration: 10, amplitude: 40);
    } else {
      await HapticFeedback.selectionClick();
    }
  }

  // Button press feedback
  Future<void> _buttonPressFeedback() async {
    if (Platform.isIOS) {
      await Vibration.vibrate(duration: 15, amplitude: 40);
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  // Custom vibration (for advanced cases)
  Future<void> customVibration(List<int> pattern, {int repeat = -1}) async {
    if (!_hapticEnabled || !_canVibrate) return;

    try {
      await Vibration.vibrate(pattern: pattern, repeat: repeat);
    } catch (e) {
      AppLogger.error('Error triggering custom vibration', e);
    }
  }

  // Stop vibration
  Future<void> stopVibration() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      AppLogger.error('Error stopping vibration', e);
    }
  }
}
