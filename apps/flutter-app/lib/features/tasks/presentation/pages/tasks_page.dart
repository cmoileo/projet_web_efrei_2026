import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/atoms/app_status_badge.dart';
import '../../../../shared/widgets/molecules/app_card.dart';
import '../../../../shared/widgets/molecules/task_item.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserModelProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return user.role == UserRole.volunteer
            ? const _VolunteerTasksView()
            : const _StudentTasksView();
      },
    );
  }
}

// ─── Vue élève ────────────────────────────────────────────────────────────────

class _StudentTasksView extends ConsumerWidget {
  const _StudentTasksView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByEleveProvider);
    final activeFilter = ref.watch(taskStatusFilterProvider);

    return _TaskListScaffold(
      tasksAsync: tasksAsync,
      activeFilter: activeFilter,
      buildCard: (task) => _TaskCard(task: task),
    );
  }
}

// ─── Vue bénévole ─────────────────────────────────────────────────────────────

class _VolunteerTasksView extends ConsumerWidget {
  const _VolunteerTasksView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByVolunteerProvider);
    final activeFilter = ref.watch(taskStatusFilterProvider);
    final studentsAsync = ref.watch(studentsForVolunteerProvider);

    final studentsMap = studentsAsync.valueOrNull != null
        ? {for (final s in studentsAsync.valueOrNull!) s.uid: s}
        : <String, UserModel>{};

    return Stack(
      children: [
        _TaskListScaffold(
          tasksAsync: tasksAsync,
          activeFilter: activeFilter,
          buildCard: (task) => _TaskCard(
              task: task,
              studentName: _studentName(studentsMap, task.assignedTo)),
        ),
        Positioned(
          right: AppSpacing.pagePadding,
          bottom: AppSpacing.pagePadding,
          child: FloatingActionButton.extended(
            onPressed: () => context.push('/tasks/new'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(LucideIcons.plus),
            label: Text('Nouvelle tâche',
                style: AppTypography.small.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  String? _studentName(Map<String, UserModel> map, String uid) {
    final s = map[uid];
    if (s == null) return null;
    return '${s.firstName} ${s.lastName}';
  }
}

// ─── Vue partagée liste + filtres ─────────────────────────────────────────────

class _TaskListScaffold extends ConsumerWidget {
  const _TaskListScaffold({
    required this.tasksAsync,
    required this.activeFilter,
    required this.buildCard,
  });

  final AsyncValue<List<Task>> tasksAsync;
  final TaskStatus? activeFilter;
  final Widget Function(Task task) buildCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.alertCircle,
                  size: 40, color: AppColors.danger),
              const SizedBox(height: AppSpacing.s3),
              Text(
                'Erreur lors du chargement des tâches.',
                style:
                    AppTypography.bodyMedium.copyWith(color: AppColors.danger),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                error.toString(),
                style: AppTypography.small
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (tasks) {
        final filteredTasks = activeFilter == null
            ? tasks
            : tasks.where((t) => t.status == activeFilter).toList();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _StatusFilterBar(activeFilter: activeFilter),
            ),
            if (tasks.isEmpty)
              const SliverFillRemaining(
                child: _EmptyState(
                  message: 'Aucune tâche pour le moment.',
                ),
              )
            else if (filteredTasks.isEmpty)
              const SliverFillRemaining(
                child: _EmptyState(
                  message: 'Aucune tâche ne correspond à ce filtre.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.s3,
                ),
                sliver: SliverList.separated(
                  itemCount: filteredTasks.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.s2),
                  itemBuilder: (context, index) =>
                      buildCard(filteredTasks[index]),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.s8),
            ),
          ],
        );
      },
    );
  }
}

// ─── Barre de filtres par statut ──────────────────────────────────────────────

class _StatusFilterBar extends ConsumerWidget {
  const _StatusFilterBar({required this.activeFilter});

  final TaskStatus? activeFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = <TaskStatus?>[null, ...TaskStatus.values];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s2),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = filter == activeFilter;
          final label = filter == null ? 'Toutes' : filter.label;

          return GestureDetector(
            onTap: () =>
                ref.read(taskStatusFilterProvider.notifier).state = filter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s3,
                vertical: AppSpacing.s2,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: AppTypography.small.copyWith(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Carte de tâche ───────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, this.studentName});

  final Task task;
  final String? studentName;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy', 'fr').format(task.dueDate);
    final subtitle = studentName != null
        ? '$studentName · Échéance : $dateStr'
        : 'Échéance : $dateStr';

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/tasks/${task.id}'),
      semanticLabel: 'Ouvrir la tâche : ${task.title}',
      child: TaskItem(
        title: task.title,
        status: task.status,
        subtitle: subtitle,
        isCompleted: task.status == TaskStatus.done,
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.clipboardList,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              message,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
