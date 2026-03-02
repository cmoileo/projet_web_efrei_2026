/// Tokens de couleurs centralisés — Learn@Home
///
/// Source : shared/docs/UI.doc.md §2 "Couleurs"
/// Usage : toujours référencer ces constantes, jamais de hex en dur dans les composants.
library;

import 'package:flutter/material.dart';

/// Palette principale de l'application.
abstract final class AppColors {
  // ─── Couleurs primaires ───────────────────────────────────────────────────

  /// Bleu primaire — actions principales, liens actifs.
  static const Color primary = Color(0xFF4F6EF7);

  /// Fond clair du primaire — éléments actifs, sélection.
  static const Color primaryLight = Color(0xFFEEF1FE);

  /// Violet secondaire — accents, badges spéciaux.
  static const Color secondary = Color(0xFF7C3AED);

  // ─── Couleurs sémantiques ────────────────────────────────────────────────

  /// Vert — statut complété, validation.
  static const Color success = Color(0xFF16A34A);

  /// Orange — statut en attente, alertes.
  static const Color warning = Color(0xFFD97706);

  /// Rouge — erreurs, suppression.
  static const Color danger = Color(0xFFDC2626);

  // ─── Couleurs de surface ─────────────────────────────────────────────────

  /// Fond de page.
  static const Color background = Color(0xFFF8F9FB);

  /// Cards, modals, inputs.
  static const Color surface = Color(0xFFFFFFFF);

  /// Bordures et séparateurs.
  static const Color border = Color(0xFFE4E7EC);

  // ─── Couleurs de texte ───────────────────────────────────────────────────

  /// Titres, texte principal.
  static const Color textPrimary = Color(0xFF111827);

  /// Sous-titres, labels.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Éléments inactifs / désactivés.
  static const Color textDisabled = Color(0xFFD1D5DB);

  // ─── Couleurs de statut badge ────────────────────────────────────────────

  /// Fond badge "À faire".
  static const Color badgeTodoBg = Color(0xFFF3F4F6);

  /// Fond badge "En cours".
  static const Color badgeInProgressBg = Color(0xFFFEF3C7);

  /// Texte badge "En cours".
  static const Color badgeInProgressText = Color(0xFFD97706);

  /// Fond badge "Terminé".
  static const Color badgeDoneBg = Color(0xFFDCFCE7);

  /// Texte badge "Terminé".
  static const Color badgeDoneText = Color(0xFF16A34A);

  /// Fond badge "En retard".
  static const Color badgeLateBg = Color(0xFFFEE2E2);

  /// Texte badge "En retard".
  static const Color badgeLateText = Color(0xFFDC2626);
}
