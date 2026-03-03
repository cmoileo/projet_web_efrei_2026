import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/chat/presentation/providers/chat_provider.dart';
import '../atoms/avatar_initials.dart';
import 'app_bottom_nav.dart';
import 'app_top_bar.dart';

class _NavItem {
  const _NavItem({
    required this.path,
    required this.icon,
    required this.label,
    required this.title,
  });

  final String path;
  final IconData icon;
  final String label;
  final String title;
}

const _navItems = [
  _NavItem(
    path: '/dashboard',
    icon: LucideIcons.layoutDashboard,
    label: 'Accueil',
    title: 'Tableau de bord',
  ),
  _NavItem(
    path: '/tasks',
    icon: LucideIcons.checkSquare,
    label: 'Tâches',
    title: 'Mes tâches',
  ),
  _NavItem(
    path: '/calendar',
    icon: LucideIcons.calendar,
    label: 'Calendrier',
    title: 'Calendrier',
  ),
  _NavItem(
    path: '/chat',
    icon: LucideIcons.messageCircle,
    label: 'Messages',
    title: 'Messages',
  ),
  _NavItem(
    path: '/profile',
    icon: LucideIcons.user,
    label: 'Profil',
    title: 'Mon profil',
  ),
];

class MainShell extends ConsumerWidget {
  const MainShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  final Widget child;
  final String currentLocation;

  int get _selectedIndex {
    final idx =
        _navItems.indexWhere((item) => currentLocation.startsWith(item.path));
    return idx < 0 ? 0 : idx;
  }

  String get _pageTitle {
    for (final item in _navItems) {
      if (currentLocation.startsWith(item.path)) return item.title;
    }
    return 'Learn@Home';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserModelProvider);
    final unread = ref.watch(totalUnreadCountProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: _pageTitle,
        actions: [
          userAsync.maybeWhen(
            data: (user) {
              if (user == null) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: AppTypography.small,
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  AvatarInitials(
                    firstName: user.firstName,
                    lastName: user.lastName,
                    nickname: user.nickname,
                    size: AvatarSize.sm,
                  ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => context.go(_navItems[index].path),
        destinations: _navItems.map((item) {
          final badge = item.path == '/chat' && unread > 0 ? unread : null;
          return AppNavDestination(
              icon: item.icon, label: item.label, badge: badge);
        }).toList(),
      ),
    );
  }
}
