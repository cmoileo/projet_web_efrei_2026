/// Organism : AppTopBar — Learn@Home
///
/// Barre d'application supérieure conforme à la charte UI.
/// Hauteur 56px, fond color-surface, bordure bas color-border.
/// Ombre uniquement en scroll (gérée par [SliverAppBar] ou scrolledUnderElevation).
///
/// Implémente [PreferredSizeWidget] pour s'insérer dans [Scaffold.appBar].
///
/// ## Paramètres
/// - [title]        : titre de la page (text-heading)
/// - [actions]      : widgets d'action à droite (icônes, avatar)
/// - [leading]      : widget à gauche (défaut: bouton retour si navigable)
/// - [showBackButton]: force l'affichage du bouton retour
///
/// ## Exemple
/// ```dart
/// Scaffold(
///   appBar: AppTopBar(
///     title: 'Mes tâches',
///     actions: [
///       AppIconButton(
///         icon: LucideIcons.plus,
///         semanticLabel: 'Ajouter une tâche',
///         onPressed: () => context.push('/tasks/new'),
///       ),
///       AppAvatar(name: user.displayName, size: AppAvatarSize.sm),
///     ],
///   ),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../atoms/app_icon.dart';

/// Barre d'application supérieure Learn@Home.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final displayBackButton = showBackButton ?? canPop;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: Row(
              children: [
                // ─── Leading ───────────────────────────────────────────
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.s2),
                ] else if (displayBackButton) ...[
                  AppIconButton(
                    icon: LucideIcons.arrowLeft,
                    semanticLabel: 'Retour',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.s2),
                ],

                // ─── Titre ─────────────────────────────────────────────
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.heading,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // ─── Actions ───────────────────────────────────────────
                if (actions != null) ...[
                  const SizedBox(width: AppSpacing.s2),
                  ...actions!.map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.s1),
                      child: action,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
