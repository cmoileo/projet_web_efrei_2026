import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tableau de bord', style: AppTypography.subheading),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: AppColors.textPrimary),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: userAsync.when(
            data: (user) {
              debugPrint(
                  '[Dashboard] currentUserModelProvider data: ${user?.uid ?? "null"}');
              // user == null → pas connecté, le router redirige vers /login
              if (user == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.s4),
                  Row(
                    children: [
                      AvatarInitials(
                        firstName: user.firstName,
                        lastName: user.lastName,
                        nickname: user.nickname,
                        size: AvatarSize.lg,
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour, ${user.firstName} !',
                            style: AppTypography.heading,
                          ),
                          Text(
                            '@${user.nickname}',
                            style: AppTypography.small,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    'Bienvenue sur Learn@Home.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            },
            loading: () {
              debugPrint('[Dashboard] currentUserModelProvider \u2192 loading');
              return const Center(child: CircularProgressIndicator());
            },
            error: (e, stack) {
              debugPrint('[Dashboard] currentUserModelProvider → error: $e');
              return Center(
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
                        'Votre compte Firebase existe mais aucun profil n\'a été trouvé dans la base de données.',
                        style: AppTypography.body
                            .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(authNotifierProvider.notifier).logout(),
                        icon: const Icon(LucideIcons.logOut),
                        label: const Text('Se déconnecter'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
