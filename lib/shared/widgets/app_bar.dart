import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;

  const AppBarWidget({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      leading: _buildLeading(context),
      actions: actions,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    // Si un widget leading personnalisé est fourni, l'utiliser
    if (leading != null) return leading;

    // Sinon, afficher le bouton de retour si demandé et si on peut revenir en arrière
    if (showBackButton && context.canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => context.pop(),
      );
    }

    // Sinon, ne pas afficher de bouton
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
