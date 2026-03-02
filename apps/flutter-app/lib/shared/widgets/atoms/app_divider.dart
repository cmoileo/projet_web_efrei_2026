/// Atom : AppDivider — Learn@Home
///
/// Séparateur horizontal conforme aux tokens de la charte UI.
/// Utilise color-border, hauteur 1px, margin top/bottom space-4.
///
/// ## Exemple
/// ```dart
/// const AppDivider()
///
/// // Avec label centré
/// AppDivider(label: 'ou')
/// ```
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Séparateur horizontal Learn@Home.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.label});

  /// Optionnel : texte centré sur le séparateur (ex. "ou").
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
        child: Divider(color: AppColors.border, thickness: 1, height: 1),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: AppColors.border, thickness: 1, height: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
            child: Text(label!, style: AppTypography.small),
          ),
          const Expanded(
            child: Divider(color: AppColors.border, thickness: 1, height: 1),
          ),
        ],
      ),
    );
  }
}
