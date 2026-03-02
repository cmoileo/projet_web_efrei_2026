import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  String? _emailError;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final email = _emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        _emailError = 'L\'email est requis.';
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
        _emailError = 'Format d\'email invalide.';
      } else {
        _emailError = null;
      }
    });
    return _emailError == null;
  }

  Future<void> _submit() async {
    if (!_validateForm()) return;
    ref.read(authNotifierProvider.notifier).clearError();
    final success = await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordResetEmail(_emailController.text.trim());
    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final firebaseError = authState.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: isLoading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.s5),
              Text('Mot de passe oublié', style: AppTypography.display),
              const SizedBox(height: AppSpacing.s2),
              Text(
                'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s6),
              if (_emailSent) ...[
                _SuccessBanner(email: _emailController.text.trim()),
                const SizedBox(height: AppSpacing.s5),
                AppButton(
                  label: 'Retour à la connexion',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.go('/login'),
                ),
              ] else ...[
                if (firebaseError != null) ...[
                  _ErrorBanner(message: firebaseError),
                  const SizedBox(height: AppSpacing.s4),
                ],
                AppInput(
                  controller: _emailController,
                  label: 'Adresse e-mail',
                  hint: 'exemple@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: LucideIcons.mail,
                  errorText: _emailError,
                  enabled: !isLoading,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  focusNode: _emailFocus,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.s5),
                AppButton(
                  label: 'Envoyer le lien',
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSpacing.s4),
                AppButton(
                  label: 'Retour à la connexion',
                  variant: AppButtonVariant.ghost,
                  onPressed: isLoading ? null : () => context.pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.checkCircle,
                  color: AppColors.success, size: 18),
              const SizedBox(width: AppSpacing.s2),
              Text(
                'Email envoyé !',
                style:
                    AppTypography.bodyMedium.copyWith(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            'Un lien de réinitialisation a été envoyé à $email. Vérifiez votre boîte de réception.',
            style: AppTypography.small.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle,
              color: AppColors.danger, size: 18),
          const SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Text(
              message,
              style: AppTypography.small.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
