/// Tokens de typographie — Learn@Home
///
/// Police : Inter (Google Fonts). Source : shared/docs/UI.doc.md §2 "Typographie"
/// Usage : toujours utiliser AppTypography.xxx dans les TextStyle.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Styles de texte centralisés basés sur Inter.
abstract final class AppTypography {
  /// `text-display` — 28px / w700 — Titre de page.
  static TextStyle get display => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// `text-heading` — 20px / w600 — Titre de section.
  static TextStyle get heading => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// `text-subheading` — 16px / w600 — Sous-titre, card header.
  static TextStyle get subheading => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// `text-body` — 14px / w400 — Texte courant.
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// `text-body` w500 — Variante body semi-gras (ex. titres de tâche).
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// `text-small` — 12px / w400 — Labels, métadonnées.
  static TextStyle get small => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// `text-tiny` — 11px / w500 — Badges, chips.
  static TextStyle get tiny => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  /// TextTheme Material 3 mappé sur les tokens Learn@Home.
  static TextTheme get textTheme => TextTheme(
    displayLarge: display,
    titleLarge: heading,
    titleMedium: subheading,
    bodyLarge: bodyMedium,
    bodyMedium: body,
    bodySmall: small,
    labelSmall: tiny,
  );
}
