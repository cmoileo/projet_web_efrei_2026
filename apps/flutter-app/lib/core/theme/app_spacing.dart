/// Tokens d'espacement — Learn@Home
///
/// Grille basée sur 4px. Source : shared/docs/UI.doc.md §2 "Espacements"
/// Usage : toujours utiliser AppSpacing.xxx, jamais de valeurs brutes dans les widgets.
library;

/// Constantes d'espacement (grille 4px).
abstract final class AppSpacing {
  /// 4px — micro espacement.
  static const double s1 = 4.0;

  /// 8px — espacement interne compact.
  static const double s2 = 8.0;

  /// 12px — padding inputs, gaps internes.
  static const double s3 = 12.0;

  /// 16px — padding standard.
  static const double s4 = 16.0;

  /// 24px — espacement entre sections.
  static const double s5 = 24.0;

  /// 32px — marges de page.
  static const double s6 = 32.0;

  /// 48px — espacement macro.
  static const double s8 = 48.0;

  // ─── Aliases sémantiques ─────────────────────────────────────────────────

  /// Alias : padding icône inline.
  static const double iconInlinePadding = s1;

  /// Alias : padding standard (ex. content padding).
  static const double pagePadding = s4;

  /// Alias : card padding.
  static const double cardPadding = s4;

  /// Alias : espacement entre sections.
  static const double sectionGap = s5;

  /// Taille minimale d'une zone tactile (WCAG 2.1 mobile ≥ 44px).
  static const double minTouchTarget = 44.0;
}
