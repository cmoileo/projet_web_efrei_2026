import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/atoms/app_status_badge.dart';
import '../../../../shared/widgets/molecules/app_card.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

class StudentsCard extends ConsumerWidget {
  const StudentsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsForCurrentVolunteerProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.users, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s2),
              Text('Mes élèves', style: AppTypography.subheading),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          studentsAsync.when(
            data: (students) {
              if (students.isEmpty) {
                return Text(
                  'Aucun élève associé pour le moment',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                );
              }
              return Column(
                children: students
                    .map((s) => _StudentRow(key: ValueKey(s.uid), student: s))
                    .toList(),
              );
            },
            loading: () => const Center(
              child: SizedBox(
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => Text(
              'Impossible de charger les élèves',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends ConsumerWidget {
  const _StudentRow({super.key, required this.student});

  final UserModel student;

  String get _initials {
    final f =
        student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : '';
    final l =
        student.lastName.isNotEmpty ? student.lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByStudentIdProvider(student.uid));

    final total = tasksAsync.valueOrNull?.length ?? 0;
    final inProgress = tasksAsync.valueOrNull
            ?.where((t) => t.status == TaskStatus.inProgress)
            .length ??
        0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${student.firstName} ${student.lastName}',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.s1),
                Text('@${student.nickname}', style: AppTypography.small),
              ],
            ),
          ),
          tasksAsync.isLoading
              ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s3,
                        vertical: AppSpacing.s1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$total tâche${total > 1 ? 's' : ''}',
                        style: AppTypography.tiny
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                    if (inProgress > 0) ...[
                      const SizedBox(height: AppSpacing.s1),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s3,
                          vertical: AppSpacing.s1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.badgeInProgressBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$inProgress en cours',
                          style: AppTypography.tiny
                              .copyWith(color: AppColors.badgeInProgressText),
                        ),
                      ),
                    ],
                  ],
                ),
        ],
      ),
    );
  }
}
