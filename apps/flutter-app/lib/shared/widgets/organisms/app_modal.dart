/// Organism : AppModal — Learn@Home
///
/// Dialog/modal conforme à la charte UI : overlay sombre, radius-lg, shadow-lg.
/// Structure : Header (titre + fermeture) + Body + Footer (actions).
///
/// Utiliser [showAppModal] pour afficher le modal (ne pas instancier directement).
///
/// ## Paramètres de [showAppModal]
/// - [context]       : BuildContext
/// - [title]         : titre du modal (text-heading)
/// - [body]          : contenu du modal
/// - [primaryLabel]  : texte du bouton primaire (obligatoire)
/// - [onPrimary]     : callback bouton primaire
/// - [secondaryLabel]: texte du bouton ghost (optionnel, défaut: "Annuler")
/// - [onSecondary]   : callback bouton ghost (défaut: ferme le modal)
/// - [isDismissible] : clique sur overlay ferme le modal (défaut: true)
///
/// ## Exemple
/// ```dart
/// showAppModal(
///   context,
///   title: 'Supprimer la tâche ?',
///   body: const Text('Cette action est irréversible.'),
///   primaryLabel: 'Supprimer',
///   onPrimary: () {
///     Navigator.pop(context);
///     ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
///   },
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../atoms/app_button.dart';
import '../atoms/app_icon.dart';

/// Affiche un modal conforme à la charte UI Learn@Home.
Future<T?> showAppModal<T>(
  BuildContext context, {
  required String title,
  required Widget body,
  required String primaryLabel,
  required VoidCallback onPrimary,
  String secondaryLabel = 'Annuler',
  VoidCallback? onSecondary,
  bool isDismissible = true,
  bool isPrimaryDanger = false,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    barrierColor: const Color(0x66000000), // rgba(0,0,0,0.4)
    builder: (_) => _AppModal(
      title: title,
      body: body,
      primaryLabel: primaryLabel,
      onPrimary: onPrimary,
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary ?? () => Navigator.of(context).pop(),
      isPrimaryDanger: isPrimaryDanger,
    ),
  );
}

// ─── Widget interne ───────────────────────────────────────────────────────────

class _AppModal extends StatelessWidget {
  const _AppModal({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    required this.isPrimaryDanger,
  });

  final String title;
  final Widget body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;
  final bool isPrimaryDanger;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: Text(title, style: AppTypography.heading)),
                  AppIconButton(
                    icon: LucideIcons.x,
                    semanticLabel: 'Fermer le modal',
                    onPressed: onSecondary,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.s5),

              // ─── Body ─────────────────────────────────────────────────
              DefaultTextStyle(style: AppTypography.body, child: body),

              const SizedBox(height: AppSpacing.s5),

              // ─── Footer ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: secondaryLabel,
                    variant: AppButtonVariant.ghost,
                    onPressed: onSecondary,
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  AppButton(
                    label: primaryLabel,
                    variant: isPrimaryDanger
                        ? AppButtonVariant.danger
                        : AppButtonVariant.primary,
                    onPressed: onPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
