import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/atoms/app_status_badge.dart';
import '../../../../shared/widgets/molecules/app_card.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

class TaskSummaryCard extends ConsumerWidget {
  const TaskSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByEleveProvider);

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
          tasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return Text(
                  'Aucune tâche pour le moment',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                );
              }
              final total = tasks.length;
              final inProgress =
                  tasks.where((t) => t.status == TaskStatus.inProgress).length;
              final completed =
                  tasks.where((t) => t.status == TaskStatus.done).length;
              return Row(
                children: [
                  _StatChip(
                    label: 'Total',
                    value: total,
                    color: AppColors.primary,
                    bgColor: AppColors.primaryLight,
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  _StatChip(
                    label: 'En cours',
                    value: inProgress,
                    color: AppColors.badgeInProgressText,
                    bgColor: AppColors.badgeInProgressBg,
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  _StatChip(
                    label: 'Terminées',
                    value: completed,
                    color: AppColors.badgeDoneText,
                    bgColor: AppColors.badgeDoneBg,
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: SizedBox(
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => Text(
              'Impossible de charger les tâches',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
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
