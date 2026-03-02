/// Atom : AppInput — Learn@Home
///
/// Champ de saisie conforme à la charte UI. Styles gérés par [InputDecorationTheme]
/// dans [AppTheme]. Ce widget ajoute uniquement la gestion du focus visuel
/// et des états error/disabled.
///
/// ## Paramètres
/// - [controller]   : TextEditingController (optionnel)
/// - [label]        : label flottant au-dessus du champ
/// - [hint]         : placeholder
/// - [errorText]    : message d'erreur (active le border danger si non null)
/// - [helperText]   : texte d'aide sous le champ
/// - [obscureText]  : pour les mots de passe
/// - [keyboardType] : type de clavier
/// - [prefixIcon]   : icône Lucide en préfixe
/// - [suffixIcon]   : widget en suffixe (ex. toggle visibility)
/// - [onChanged]    : callback à chaque modification
/// - [onSubmitted]  : callback à la validation clavier
/// - [enabled]      : false = état désactivé
/// - [autofocus]    : focus automatique au montage
/// - [textInputAction]: action du clavier (next, done...)
///
/// ## Exemple
/// ```dart
/// AppInput(
///   label: 'Adresse e-mail',
///   hint: 'exemple@email.com',
///   keyboardType: TextInputType.emailAddress,
///   prefixIcon: LucideIcons.mail,
///   onChanged: (v) => ref.read(loginFormProvider.notifier).setEmail(v),
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Champ de saisie Learn@Home.
class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.focusNode,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        enabled: enabled,
        autofocus: autofocus,
        textInputAction: textInputAction,
        focusNode: focusNode,
        maxLines: obscureText ? 1 : maxLines,
        style: AppTypography.body.copyWith(
          color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          helperText: helperText,
          prefixIcon: prefixIcon != null
              ? Semantics(label: label ?? '', child: Icon(prefixIcon, size: 18))
              : null,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
