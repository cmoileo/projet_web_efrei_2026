/// Tokens de rayon de bordure — Learn@Home
///
/// Source : shared/docs/UI.doc.md §2 "Rayons de bordure"
library;

import 'package:flutter/material.dart';

/// Constantes de border-radius.
abstract final class AppRadius {
  /// 4px — Inputs, badges.
  static const double sm = 4.0;

  /// 8px — Cards, boutons.
  static const double md = 8.0;

  /// 12px — Modals, drawers.
  static const double lg = 12.0;

  /// 9999px — Avatars, chips ronds.
  static const double full = 9999.0;

  // ─── BorderRadius pré-construits ─────────────────────────────────────────

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderFull = BorderRadius.all(
    Radius.circular(full),
  );
}
