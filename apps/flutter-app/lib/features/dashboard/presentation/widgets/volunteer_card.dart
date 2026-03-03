import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/molecules/app_card.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';

class VolunteerCard extends ConsumerWidget {
  const VolunteerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserModelProvider);
    final volunteerId = userAsync.valueOrNull?.volunteerId;

    final volunteerAsync = volunteerId != null
        ? ref.watch(userByIdProvider(volunteerId))
        : const AsyncData(null);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.userCheck,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s2),
              Text('Mon bénévole', style: AppTypography.subheading),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          volunteerAsync.when(
            data: (volunteer) {
              if (volunteer == null) {
                return Text(
                  'Aucun bénévole associé',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                );
              }
              final initials = [
                if (volunteer.firstName.isNotEmpty)
                  volunteer.firstName[0].toUpperCase(),
                if (volunteer.lastName.isNotEmpty)
                  volunteer.lastName[0].toUpperCase(),
              ].join();
              return Row(
                children: [
                  _InitialsAvatar(text: initials),
                  const SizedBox(width: AppSpacing.s3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${volunteer.firstName} ${volunteer.lastName}',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.s1),
                      Text('@${volunteer.nickname}',
                          style: AppTypography.small),
                    ],
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 40,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => Text(
              'Impossible de charger le bénévole',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
      ),
    );
  }
}
