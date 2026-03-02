/// Atom : AppStatusBadge — Learn@Home
///
/// Badge coloré indiquant le statut d'une tâche. 4 statuts supportés.
/// Couleurs et styles centralisés dans AppColors / AppTypography.
///
/// ## Paramètres
/// - [status] : [TaskStatus] — todo | inProgress | done | late
///
/// ## Exemple
/// ```dart
/// AppStatusBadge(status: TaskStatus.inProgress)
/// AppStatusBadge(status: TaskStatus.done)
/// ```
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

// ─── Types ────────────────────────────────────────────────────────────────────

/// Statuts possibles d'une tâche.
enum TaskStatus {
  todo,
  inProgress,
  done,
  late;

  /// Libellé en français.
  String get label => switch (this) {
    TaskStatus.todo => 'À faire',
    TaskStatus.inProgress => 'En cours',
    TaskStatus.done => 'Terminé',
    TaskStatus.late => 'En retard',
  };

  /// Sérialisation Firestore.
  String get value => switch (this) {
    TaskStatus.todo => 'todo',
    TaskStatus.inProgress => 'in_progress',
    TaskStatus.done => 'done',
    TaskStatus.late => 'late',
  };

  /// Désérialisation depuis Firestore.
  static TaskStatus fromString(String value) => switch (value) {
    'in_progress' => TaskStatus.inProgress,
    'done' => TaskStatus.done,
    'late' => TaskStatus.late,
    _ => TaskStatus.todo,
  };
}

// ─── Widget ───────────────────────────────────────────────────────────────────

/// Badge de statut d'une tâche.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({super.key, required this.status});

  final TaskStatus status;

  _BadgeTokens get _tokens => switch (status) {
    TaskStatus.todo => const _BadgeTokens(
      background: AppColors.badgeTodoBg,
      foreground: AppColors.textSecondary,
    ),
    TaskStatus.inProgress => const _BadgeTokens(
      background: AppColors.badgeInProgressBg,
      foreground: AppColors.badgeInProgressText,
    ),
    TaskStatus.done => const _BadgeTokens(
      background: AppColors.badgeDoneBg,
      foreground: AppColors.badgeDoneText,
    ),
    TaskStatus.late => const _BadgeTokens(
      background: AppColors.badgeLateBg,
      foreground: AppColors.badgeLateText,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final tokens = _tokens;
    return Semantics(
      label: 'Statut : ${status.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: tokens.background,
          borderRadius: AppRadius.borderFull,
        ),
        child: Text(
          status.label,
          style: AppTypography.tiny.copyWith(color: tokens.foreground),
        ),
      ),
    );
  }
}

// ─── Modèle interne ────────────────────────────────────────────────────────────

class _BadgeTokens {
  const _BadgeTokens({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
