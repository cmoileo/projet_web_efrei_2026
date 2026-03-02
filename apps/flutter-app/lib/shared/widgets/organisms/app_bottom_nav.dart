/// Organism : AppBottomNav — Learn@Home
///
/// Barre de navigation inférieure Material 3 conforme à la charte UI mobile.
/// Maximum 4 destinations. Icônes Lucide + labels. Indicateur actif en color-primary.
///
/// Utilise [NavigationBar] Material 3 (pas [BottomNavigationBar]).
///
/// ## Paramètres
/// - [destinations] : liste de [AppNavDestination] (2–4 items)
/// - [selectedIndex]: index de l'item actif
/// - [onDestinationSelected]: callback de navigation
///
/// ## Exemple
/// ```dart
/// AppBottomNav(
///   selectedIndex: _currentIndex,
///   onDestinationSelected: (i) => _onNavTap(i, context),
///   destinations: const [
///     AppNavDestination(icon: LucideIcons.layoutDashboard, label: 'Accueil'),
///     AppNavDestination(icon: LucideIcons.checkSquare, label: 'Tâches'),
///     AppNavDestination(icon: LucideIcons.messageCircle, label: 'Chat'),
///     AppNavDestination(icon: LucideIcons.calendar, label: 'Calendrier'),
///   ],
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

// ─── Types ────────────────────────────────────────────────────────────────────

/// Destination de navigation.
class AppNavDestination {
  const AppNavDestination({
    required this.icon,
    required this.label,
    this.badge,
  });

  final IconData icon;
  final String label;

  /// Optionnel : badge de compteur (ex. messages non lus).
  final int? badge;
}

// ─── Widget ───────────────────────────────────────────────────────────────────

/// Barre de navigation inférieure Learn@Home.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : assert(
         destinations.length >= 2 && destinations.length <= 4,
         'AppBottomNav accepte entre 2 et 4 destinations.',
       );

  final List<AppNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map(_buildDestination).toList(),
      ),
    );
  }

  NavigationDestination _buildDestination(AppNavDestination dest) {
    final icon = Icon(dest.icon);

    return NavigationDestination(
      icon: dest.badge != null && dest.badge! > 0
          ? Badge(label: Text('${dest.badge}'), child: icon)
          : icon,
      selectedIcon: dest.badge != null && dest.badge! > 0
          ? Badge(
              label: Text('${dest.badge}'),
              child: Icon(dest.icon, color: AppColors.primary),
            )
          : Icon(dest.icon, color: AppColors.primary),
      label: dest.label,
    );
  }
}
