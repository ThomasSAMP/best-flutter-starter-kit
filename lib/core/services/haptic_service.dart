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

  // Constructeur
  HapticService() {
    _initHaptic();
  }

  // Initialiser le service haptique
  Future<void> _initHaptic() async {
    try {
      _canVibrate = await Vibration.hasVibrator() ?? false;
      AppLogger.debug('HapticService initialized, canVibrate: $_canVibrate');
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing HapticService', e, stackTrace);
      _canVibrate = false;
    }
  }

  // Activer/désactiver les retours haptiques
  void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
    AppLogger.debug('Haptic feedback ${enabled ? 'enabled' : 'disabled'}');
  }

  // Vérifier si les retours haptiques sont activés
  bool get isHapticEnabled => _hapticEnabled;

  // Vérifier si l'appareil peut vibrer
  bool get canVibrate => _canVibrate;

  // Méthode générique pour déclencher un retour haptique
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

  // Impact léger
  Future<void> _lightImpact() async {
    if (Platform.isIOS) {
      Vibration.vibrate(duration: 20, amplitude: 40);
    } else {
      Vibration.vibrate(duration: 20, amplitude: 40);
    }
  }

  // Impact moyen
  Future<void> _mediumImpact() async {
    if (Platform.isIOS) {
      Vibration.vibrate(duration: 40, amplitude: 100);
    } else {
      Vibration.vibrate(duration: 40, amplitude: 100);
    }
  }

  // Impact fort
  Future<void> _heavyImpact() async {
    if (Platform.isIOS) {
      Vibration.vibrate(duration: 60, amplitude: 255);
    } else {
      Vibration.vibrate(duration: 60, amplitude: 255);
    }
  }

  // Retour de succès (vibration personnalisée)
  Future<void> _successFeedback() async {
    if (Platform.isIOS) {
      await Vibration.vibrate(pattern: [0, 30, 100, 30]);
    } else {
      // Simuler un retour de succès sur Android
      await Vibration.vibrate(pattern: [0, 30, 100, 30]);
    }
  }

  // Retour d'avertissement (vibration personnalisée)
  Future<void> _warningFeedback() async {
    if (Platform.isIOS) {
      await Vibration.vibrate(pattern: [0, 50, 100, 50]);
    } else {
      // Simuler un retour d'avertissement sur Android
      await Vibration.vibrate(pattern: [0, 50, 100, 50]);
    }
  }

  // Retour d'erreur (vibration personnalisée)
  Future<void> _errorFeedback() async {
    if (Platform.isIOS) {
      await Vibration.vibrate(pattern: [0, 70, 100, 70, 100, 70]);
    } else {
      // Simuler un retour d'erreur sur Android
      await Vibration.vibrate(pattern: [0, 70, 100, 70, 100, 70]);
    }
  }

  // Retour de sélection
  Future<void> _selectionFeedback() async {
    await HapticFeedback.selectionClick();
  }

  // Retour de sélection d'onglet
  Future<void> _tabSelectionFeedback() async {
    if (Platform.isIOS) {
      await Vibration.vibrate(duration: 10, amplitude: 40);
    } else {
      await HapticFeedback.selectionClick();
    }
  }

  // Retour d'appui sur bouton
  Future<void> _buttonPressFeedback() async {
    if (Platform.isIOS) {
      await Vibration.vibrate(duration: 15, amplitude: 40);
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  // Vibration personnalisée (pour les cas avancés)
  Future<void> customVibration(List<int> pattern, {int repeat = -1}) async {
    if (!_hapticEnabled || !_canVibrate) return;

    try {
      await Vibration.vibrate(pattern: pattern, repeat: repeat);
    } catch (e) {
      AppLogger.error('Error triggering custom vibration', e);
    }
  }

  // Arrêter la vibration
  Future<void> stopVibration() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      AppLogger.error('Error stopping vibration', e);
    }
  }
}
