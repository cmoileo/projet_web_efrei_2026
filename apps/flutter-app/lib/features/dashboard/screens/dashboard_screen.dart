import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/atoms/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../presentation/providers/dashboard_provider.dart';
import '../presentation/widgets/events_card.dart';
import '../presentation/widgets/messages_card.dart';
import '../presentation/widgets/students_card.dart';
import '../presentation/widgets/task_summary_card.dart';
import '../presentation/widgets/volunteer_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserModelProvider);
    final eventsAsync = ref.watch(dashboardEventsProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s2),
              Text(
                'Bonjour, ${user.firstName} 👋',
                style: AppTypography.heading,
              ),
              const SizedBox(height: AppSpacing.s1),
              Text(
                'Voici un résumé de votre activité du jour.',
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s5),
              if (user.role == UserRole.volunteer) ...[
                const StudentsCard(),
                const SizedBox(height: AppSpacing.s4),
                const MessagesCard(),
              ] else ...[
                const VolunteerCard(),
                const SizedBox(height: AppSpacing.s4),
                const TaskSummaryCard(),
                const SizedBox(height: AppSpacing.s4),
                EventsCard(
                  events: eventsAsync.valueOrNull ?? const [],
                ),
                const SizedBox(height: AppSpacing.s4),
                const MessagesCard(),
              ],
              const SizedBox(height: AppSpacing.s5),
              Text('Actions rapides', style: AppTypography.subheading),
              const SizedBox(height: AppSpacing.s3),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Mes tâches',
                      icon: LucideIcons.checkSquare,
                      onPressed: () => context.go('/tasks'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: AppButton(
                      label: 'Ouvrir le chat',
                      icon: LucideIcons.messageCircle,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.go('/chat'),
                    ),
                  ),
                ],
              ),
              if (user.role == UserRole.volunteer) ...[
                const SizedBox(height: AppSpacing.s3),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Créer une tâche',
                    icon: LucideIcons.plus,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.push('/tasks/new'),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.s8),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.danger),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'Profil introuvable',
                style: AppTypography.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                'Impossible de charger votre profil. Veuillez vous reconnecter.',
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s5),
              AppButton(
                label: 'Se déconnecter',
                icon: LucideIcons.logOut,
                variant: AppButtonVariant.danger,
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
