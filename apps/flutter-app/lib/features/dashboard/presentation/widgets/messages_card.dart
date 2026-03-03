import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/molecules/app_card.dart';

class MessagesCard extends StatelessWidget {
  const MessagesCard({super.key, required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: unreadCount > 0
                  ? AppColors.primaryLight
                  : AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.messageCircle,
              size: 20,
              color:
                  unreadCount > 0 ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Messages', style: AppTypography.subheading),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  unreadCount == 0
                      ? 'Aucun message non lu'
                      : '$unreadCount message${unreadCount > 1 ? 's' : ''} non lu${unreadCount > 1 ? 's' : ''}',
                  style: AppTypography.body.copyWith(
                    color: unreadCount > 0
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s2, vertical: AppSpacing.s1),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: AppTypography.tiny.copyWith(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
