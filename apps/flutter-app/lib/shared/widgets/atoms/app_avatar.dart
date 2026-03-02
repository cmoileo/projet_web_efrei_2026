/// Atom : AppAvatar — Learn@Home
///
/// Avatar circulaire avec fallback sur les initiales de l'utilisateur.
/// Tailles standardisées (24/32/40/48px). Conforme à la charte UI.
///
/// ## Paramètres
/// - [name]      : nom affiché (utilisé pour les initiales en fallback)
/// - [photoUrl]  : URL de la photo (optionnelle). Si null, affiche les initiales.
/// - [size]      : [AppAvatarSize] — xs | sm | md | lg
///
/// ## Exemple
/// ```dart
/// AppAvatar(name: 'Alice Martin', size: AppAvatarSize.md)
/// AppAvatar(name: 'Bob', photoUrl: 'https://...', size: AppAvatarSize.lg)
/// ```
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

// ─── Types ────────────────────────────────────────────────────────────────────

/// Tailles standardisées de l'avatar.
enum AppAvatarSize {
  xs(24),
  sm(32),
  md(40),
  lg(48);

  const AppAvatarSize(this.dimension);
  final double dimension;
}

// ─── Widget ───────────────────────────────────────────────────────────────────

/// Avatar utilisateur circulaire.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = AppAvatarSize.md,
  });

  final String name;
  final String? photoUrl;
  final AppAvatarSize size;

  /// Extrait les 1 ou 2 initiales depuis le nom complet.
  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dimension = size.dimension;

    return Semantics(
      label: 'Avatar de $name',
      child: SizedBox(
        width: dimension,
        height: dimension,
        child: ClipRRect(
          borderRadius: AppRadius.borderFull,
          child: photoUrl != null && photoUrl!.isNotEmpty
              ? Image.network(
                  photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _InitialsFallback(
                    initials: _initials,
                    dimension: dimension,
                  ),
                )
              : _InitialsFallback(initials: _initials, dimension: dimension),
        ),
      ),
    );
  }
}

// ─── Fallback initiales ────────────────────────────────────────────────────────

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.initials, required this.dimension});

  final String initials;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimension,
      height: dimension,
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.small.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: dimension * 0.35,
        ),
      ),
    );
  }
}
