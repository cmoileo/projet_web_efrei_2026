import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/molecules/app_card.dart';
import '../../domain/dashboard_models.dart';

class TaskSummaryCard extends StatelessWidget {
  const TaskSummaryCard({super.key, required this.summary});

  final TaskSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.checkSquare,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s2),
              Text('Mes tâches', style: AppTypography.subheading),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          if (summary.total == 0)
            Text('Aucune tâche pour le moment',
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary))
          else
            Row(
              children: [
                _StatChip(
                  label: 'Total',
                  value: summary.total,
                  color: AppColors.primary,
                  bgColor: AppColors.primaryLight,
                ),
                const SizedBox(width: AppSpacing.s3),
                _StatChip(
                  label: 'En cours',
                  value: summary.inProgress,
                  color: AppColors.badgeInProgressText,
                  bgColor: AppColors.badgeInProgressBg,
                ),
                const SizedBox(width: AppSpacing.s3),
                _StatChip(
                  label: 'Terminées',
                  value: summary.completed,
                  color: AppColors.badgeDoneText,
                  bgColor: AppColors.badgeDoneBg,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final int value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s3, horizontal: AppSpacing.s2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: AppTypography.heading.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.s1),
            Text(label, style: AppTypography.tiny.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
