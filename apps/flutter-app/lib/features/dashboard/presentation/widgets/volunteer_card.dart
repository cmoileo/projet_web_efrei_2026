import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/molecules/app_card.dart';
import '../../domain/dashboard_models.dart';

class VolunteerCard extends StatelessWidget {
  const VolunteerCard({super.key, required this.volunteer});

  final VolunteerInfo? volunteer;

  @override
  Widget build(BuildContext context) {
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
          if (volunteer == null)
            Text(
              'Aucun bénévole associé',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            )
          else
            Row(
              children: [
                _InitialsAvatar(text: volunteer!.initials),
                const SizedBox(width: AppSpacing.s3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(volunteer!.fullName, style: AppTypography.bodyMedium),
                    const SizedBox(height: AppSpacing.s1),
                    Text('@${volunteer!.nickname}', style: AppTypography.small),
                  ],
                ),
              ],
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
