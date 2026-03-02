/// Tokens d'ombres — Learn@Home
///
/// Source : shared/docs/UI.doc.md §2 "Ombres"
library;

import 'package:flutter/material.dart';

/// Définitions de box shadows.
abstract final class AppShadows {
  /// `shadow-sm` — Cards au repos.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0,0,0,0.08)
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  /// `shadow-md` — Cards hover, dropdowns.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0,0,0,0.10)
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  /// `shadow-lg` — Modals.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1F000000), // rgba(0,0,0,0.12)
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];
}
