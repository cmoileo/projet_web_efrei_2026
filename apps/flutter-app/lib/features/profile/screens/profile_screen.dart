import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/atoms/app_button.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserModelProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s4),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                        style: AppTypography.heading
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    Text('${user.firstName} ${user.lastName}',
                        style: AppTypography.heading),
                    const SizedBox(height: AppSpacing.s1),
                    Text('@${user.nickname}', style: AppTypography.small),
                    const SizedBox(height: AppSpacing.s1),
                    Text(user.email,
                        style: AppTypography.body
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              AppButton(
                label: 'Se déconnecter',
                icon: LucideIcons.logOut,
                variant: AppButtonVariant.danger,
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).logout(),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
          child: Icon(Icons.error_outline, color: AppColors.danger, size: 48)),
    );
  }
}
