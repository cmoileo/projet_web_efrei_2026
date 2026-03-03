import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/atoms/app_button.dart';
import '../../../../shared/widgets/atoms/app_status_badge.dart';
import '../../../../shared/widgets/molecules/app_card.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));
    final notifierState = ref.watch(taskStatusNotifierProvider);

    ref.listen(taskStatusNotifierProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${next.error}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      if (!next.isLoading && !next.hasError && next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statut mis à jour avec succès.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
          tooltip: 'Retour',
        ),
        title: Text('Détail de la tâche', style: AppTypography.bodyMedium),
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Text(
              'Impossible de charger cette tâche.',
              style: AppTypography.body.copyWith(color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (task) {
          if (task == null) {
            return Center(
              child: Text(
                'Tâche introuvable.',
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
            );
          }
          return _TaskDetailContent(
            task: task,
            isUpdating: notifierState.isLoading,
          );
        },
      ),
    );
  }
}

// ─── Contenu du détail ────────────────────────────────────────────────────────

class _TaskDetailContent extends ConsumerWidget {
  const _TaskDetailContent({
    required this.task,
    required this.isUpdating,
  });

  final Task task;
  final bool isUpdating;

  TaskStatus? get _nextStatus => switch (task.status) {
        TaskStatus.todo => TaskStatus.inProgress,
        TaskStatus.inProgress => TaskStatus.done,
        _ => null,
      };

  String? get _nextStatusLabel => switch (task.status) {
        TaskStatus.todo => 'Marquer En cours',
        TaskStatus.inProgress => 'Marquer Terminée',
        _ => null,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('d MMMM yyyy', 'fr').format(task.dueDate);
    final isOverdue =
        task.status != TaskStatus.done && task.dueDate.isBefore(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Badge statut ───────────────────────────────────────────────
          AppStatusBadge(status: task.status),
          const SizedBox(height: AppSpacing.s4),

          // ─── Titre ──────────────────────────────────────────────────────
          Text(task.title, style: AppTypography.heading),
          const SizedBox(height: AppSpacing.s5),

          // ─── Carte info ─────────────────────────────────────────────────
          AppCard(
            variant: AppCardVariant.flat,
            child: Column(
              children: [
                _InfoRow(
                  icon: LucideIcons.calendar,
                  label: 'Échéance',
                  value: dateStr,
                  valueColor: isOverdue ? AppColors.danger : null,
                ),
                const Divider(height: AppSpacing.s5, color: AppColors.border),
                _InfoRow(
                  icon: LucideIcons.tag,
                  label: 'Statut',
                  value: task.status.label,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s4),

          // ─── Description ────────────────────────────────────────────────
          AppCard(
            variant: AppCardVariant.flat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.alignLeft,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Text(
                      'Description',
                      style: AppTypography.small.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s3),
                Text(
                  task.description,
                  style: AppTypography.body,
                ),
              ],
            ),
          ),

          // ─── Bouton changement de statut ────────────────────────────────
          if (_nextStatus != null) ...[
            const SizedBox(height: AppSpacing.s5),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: _nextStatusLabel!,
                isLoading: isUpdating,
                onPressed: isUpdating
                    ? null
                    : () => ref
                        .read(taskStatusNotifierProvider.notifier)
                        .updateStatus(task.id, _nextStatus!),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.s6),
        ],
      ),
    );
  }
}

// ─── Ligne d'information ──────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppRadius.borderSm,
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.small
                    .copyWith(color: AppColors.textSecondary),
              ),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
