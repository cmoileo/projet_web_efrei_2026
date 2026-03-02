/// Atom : AppButton — Learn@Home
///
/// Bouton générique supportant 4 variantes et 3 tailles, conforme à la charte UI.
/// Toutes les couleurs et dimensions sont issues des tokens AppColors / AppSpacing.
///
/// ## Paramètres
/// - [label]    : texte affiché dans le bouton (obligatoire)
/// - [onPressed]: callback d'action (null = état disabled)
/// - [variant]  : [AppButtonVariant] — primary | secondary | ghost | danger
/// - [size]     : [AppButtonSize] — sm | md | lg
/// - [icon]     : icône optionnelle affichée à gauche du label (Lucide)
/// - [isLoading]: si true, remplace le label par un spinner et désactive le bouton
///
/// ## Exemple
/// ```dart
/// AppButton(
///   label: 'Créer une tâche',
///   icon: LucideIcons.plus,
///   onPressed: () => context.push('/tasks/new'),
/// )
///
/// AppButton(
///   label: 'Supprimer',
///   variant: AppButtonVariant.danger,
///   size: AppButtonSize.sm,
///   onPressed: () => ref.read(taskNotifierProvider.notifier).deleteTask(id),
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

// ─── Types ────────────────────────────────────────────────────────────────────

/// Variantes visuelles du bouton.
enum AppButtonVariant { primary, secondary, ghost, danger }

/// Tailles disponibles du bouton.
enum AppButtonSize { sm, md, lg }

// ─── Widget ───────────────────────────────────────────────────────────────────

/// Bouton réutilisable Learn@Home.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;

  // ─── Tokens par variante ────────────────────────────────────────────────

  _ButtonTokens get _tokens => switch (variant) {
    AppButtonVariant.primary => const _ButtonTokens(
      background: AppColors.primary,
      foreground: Colors.white,
      border: Colors.transparent,
    ),
    AppButtonVariant.secondary => const _ButtonTokens(
      background: AppColors.surface,
      foreground: AppColors.primary,
      border: AppColors.primary,
    ),
    AppButtonVariant.ghost => const _ButtonTokens(
      background: Colors.transparent,
      foreground: AppColors.textSecondary,
      border: Colors.transparent,
    ),
    AppButtonVariant.danger => const _ButtonTokens(
      background: AppColors.danger,
      foreground: Colors.white,
      border: Colors.transparent,
    ),
  };

  // ─── Tokens par taille ──────────────────────────────────────────────────

  _SizeTokens get _sizeTokens => switch (size) {
    AppButtonSize.sm => _SizeTokens(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: 6,
      ),
      textStyle: AppTypography.small,
      iconSize: 14,
      loaderSize: 14,
    ),
    AppButtonSize.md => _SizeTokens(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s5,
        vertical: 10,
      ),
      textStyle: AppTypography.body,
      iconSize: 16,
      loaderSize: 16,
    ),
    AppButtonSize.lg => _SizeTokens(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s6,
        vertical: 14,
      ),
      textStyle: AppTypography.subheading,
      iconSize: 18,
      loaderSize: 18,
    ),
  };

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final tokens = _tokens;
    final st = _sizeTokens;

    return Semantics(
      button: true,
      label: label,
      child: Opacity(
        opacity: _isDisabled ? 0.4 : 1.0,
        child: Material(
          color: tokens.background,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
            side: tokens.border != Colors.transparent
                ? BorderSide(color: tokens.border)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _isDisabled ? null : onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget,
              ),
              child: Padding(
                padding: st.padding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: st.loaderSize,
                        height: st.loaderSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: tokens.foreground,
                        ),
                      )
                    else ...[
                      if (icon != null) ...[
                        Icon(icon, size: st.iconSize, color: tokens.foreground),
                        const SizedBox(width: AppSpacing.s2),
                      ],
                      Text(
                        label,
                        style: st.textStyle.copyWith(color: tokens.foreground),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Modèles internes ──────────────────────────────────────────────────────────

class _ButtonTokens {
  const _ButtonTokens({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

class _SizeTokens {
  const _SizeTokens({
    required this.padding,
    required this.textStyle,
    required this.iconSize,
    required this.loaderSize,
  });

  final EdgeInsets padding;
  final TextStyle textStyle;
  final double iconSize;
  final double loaderSize;
}
