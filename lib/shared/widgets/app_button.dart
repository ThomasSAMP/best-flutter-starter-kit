import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/services/haptic_service.dart';

enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool useHapticFeedback;
  final HapticFeedbackType hapticFeedbackType;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.useHapticFeedback = true,
    this.hapticFeedbackType = HapticFeedbackType.buttonPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hapticService = getIt<HapticService>();

    // Fonction pour gérer l'appui sur le bouton avec retour haptique
    void handlePress() {
      if (onPressed != null) {
        if (useHapticFeedback) {
          hapticService.feedback(hapticFeedbackType);
        }
        onPressed!();
      }
    }

    Widget button;

    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : handlePress,
          style: ElevatedButton.styleFrom(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(8)),
          ),
          child: _buildButtonContent(theme),
        );
        break;
      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : handlePress,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(8)),
          ),
          child: _buildButtonContent(theme),
        );
        break;
      case AppButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : handlePress,
          style: OutlinedButton.styleFrom(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(8)),
          ),
          child: _buildButtonContent(theme),
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : handlePress,
          style: TextButton.styleFrom(padding: padding ?? const EdgeInsets.symmetric(vertical: 16)),
          child: _buildButtonContent(theme),
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(width: width ?? double.infinity, height: height, child: button);
    }

    return SizedBox(width: width, height: height, child: button);
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: _getLoadingColor(theme)),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(text)],
      );
    }

    return Text(text);
  }

  Color _getLoadingColor(ThemeData theme) {
    switch (type) {
      case AppButtonType.primary:
        return theme.colorScheme.onPrimary;
      case AppButtonType.secondary:
        return theme.colorScheme.onSecondary;
      case AppButtonType.outline:
      case AppButtonType.text:
        return theme.colorScheme.primary;
    }
  }
}
