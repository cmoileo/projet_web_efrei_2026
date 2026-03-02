/// Molecule : AppFormField — Learn@Home
///
/// Champ de formulaire complet : label + input + message d'erreur/aide.
/// Composition de l'atom [AppInput].
///
/// ## Paramètres
/// - [label]      : label du champ (obligatoire)
/// - [hint]       : placeholder interne
/// - [helperText] : texte d'aide sous le champ
/// - [errorText]  : message d'erreur (active le border rouge si non null)
/// - [controller] : TextEditingController
/// - [obscureText]: mot de passe
/// - [keyboardType]
/// - [prefixIcon] : icône Lucide en préfixe
/// - [suffixIcon] : widget en suffixe
/// - [onChanged]
/// - [onSubmitted]
/// - [enabled]
/// - [autofocus]
/// - [textInputAction]
///
/// ## Exemple
/// ```dart
/// AppFormField(
///   label: 'Adresse e-mail',
///   hint: 'vous@exemple.com',
///   keyboardType: TextInputType.emailAddress,
///   prefixIcon: LucideIcons.mail,
///   errorText: emailError,
///   onChanged: (v) => ref.read(formProvider.notifier).setEmail(v),
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../atoms/app_input.dart';

/// Champ de formulaire avec label et messages.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
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

  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppInput(
          controller: controller,
          label: label,
          hint: hint,
          errorText: errorText,
          helperText: helperText,
          obscureText: obscureText,
          keyboardType: keyboardType,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          enabled: enabled,
          autofocus: autofocus,
          textInputAction: textInputAction,
          focusNode: focusNode,
          maxLines: maxLines,
        ),
        const SizedBox(height: AppSpacing.s1),
      ],
    );
  }
}
