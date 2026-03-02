/// Atom : AppIcon — Learn@Home
///
/// Wrapper d'icône Lucide avec label accessible obligatoire (Tooltip + Semantics).
/// Tailles standardisées selon le contexte d'usage.
///
/// ⚠️ Conformément à la charte UI, toute icône DOIT avoir un label accessible.
///
/// ## Paramètres
/// - [icon]        : IconData (depuis lucide_icons)
/// - [semanticLabel: description accessible de l'icône (obligatoire)
/// - [size]        : [AppIconSize] — inline | button | nav
/// - [color]       : couleur de l'icône (hérite du contexte si null)
/// - [showTooltip] : affiche un tooltip au survol/long-press (défaut: true)
///
/// ## Exemple
/// ```dart
/// AppIcon(
///   icon: LucideIcons.plus,
///   semanticLabel: 'Ajouter une tâche',
///   size: AppIconSize.button,
/// )
///
/// AppIcon(
///   icon: LucideIcons.checkCircle,
///   semanticLabel: 'Tâche terminée',
///   color: AppColors.success,
///   showTooltip: false,
/// )
/// ```
library;

import 'package:flutter/material.dart';

// ─── Types ────────────────────────────────────────────────────────────────────

/// Tailles d'icône standardisées.
enum AppIconSize {
  /// 16px — icône inline dans du texte.
  inline(16),

  /// 20px — icône dans un bouton.
  button(20),

  /// 24px — icône de navigation.
  nav(24);

  const AppIconSize(this.dimension);
  final double dimension;
}

// ─── Widget ───────────────────────────────────────────────────────────────────

/// Icône Lucide accessible avec label et tooltip.
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.size = AppIconSize.button,
    this.color,
    this.showTooltip = true,
  });

  final IconData icon;
  final String semanticLabel;
  final AppIconSize size;
  final Color? color;
  final bool showTooltip;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Semantics(
      label: semanticLabel,
      child: Icon(icon, size: size.dimension, color: color),
    );

    if (showTooltip) {
      return Tooltip(message: semanticLabel, child: iconWidget);
    }

    return iconWidget;
  }
}

/// Bouton icône avec zone tactile garantie ≥ 44px.
///
/// ## Paramètres
/// - [icon]         : IconData (depuis lucide_icons)
/// - [semanticLabel]: description accessible
/// - [onPressed]    : callback d'action
/// - [size]         : taille de l'icône
/// - [color]        : couleur de l'icône
///
/// ## Exemple
/// ```dart
/// AppIconButton(
///   icon: LucideIcons.trash2,
///   semanticLabel: 'Supprimer la tâche',
///   onPressed: () => ref.read(taskNotifierProvider.notifier).deleteTask(id),
///   color: AppColors.danger,
/// )
/// ```
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.size = AppIconSize.button,
    this.color,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final AppIconSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: semanticLabel,
      child: SizedBox(
        width: 44,
        height: 44,
        child: IconButton(
          icon: Icon(icon, size: size.dimension, color: color),
          onPressed: onPressed,
          tooltip: semanticLabel,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
