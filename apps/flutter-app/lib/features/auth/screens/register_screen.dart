import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _nicknameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _birthdateFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _passwordConfirmFocus = FocusNode();

  DateTime? _selectedBirthdate;
  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  String? _firstNameError;
  String? _lastNameError;
  String? _nicknameError;
  String? _emailError;
  String? _birthdateError;
  String? _passwordError;
  String? _passwordConfirmError;

  static final _nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\-' ]+$");
  static final _nicknameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  static final _passwordUppercase = RegExp(r'[A-Z]');
  static final _passwordDigit = RegExp(r'[0-9]');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _nicknameFocus.dispose();
    _emailFocus.dispose();
    _birthdateFocus.dispose();
    _passwordFocus.dispose();
    _passwordConfirmFocus.dispose();
    super.dispose();
  }

  bool _validateForm() {
    bool valid = true;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;

    setState(() {
      if (firstName.isEmpty) {
        _firstNameError = 'Le prénom est requis.';
        valid = false;
      } else if (firstName.length < 2 || firstName.length > 50) {
        _firstNameError = 'Entre 2 et 50 caractères.';
        valid = false;
      } else if (!_nameRegex.hasMatch(firstName)) {
        _firstNameError = 'Lettres uniquement.';
        valid = false;
      } else {
        _firstNameError = null;
      }

      if (lastName.isEmpty) {
        _lastNameError = 'Le nom est requis.';
        valid = false;
      } else if (lastName.length < 2 || lastName.length > 50) {
        _lastNameError = 'Entre 2 et 50 caractères.';
        valid = false;
      } else if (!_nameRegex.hasMatch(lastName)) {
        _lastNameError = 'Lettres uniquement.';
        valid = false;
      } else {
        _lastNameError = null;
      }

      if (nickname.isEmpty) {
        _nicknameError = 'Le pseudo est requis.';
        valid = false;
      } else if (nickname.length < 3 || nickname.length > 20) {
        _nicknameError = 'Entre 3 et 20 caractères.';
        valid = false;
      } else if (!_nicknameRegex.hasMatch(nickname)) {
        _nicknameError = 'Alphanumérique et _ uniquement, pas d\'espaces.';
        valid = false;
      } else {
        _nicknameError = null;
      }

      if (email.isEmpty) {
        _emailError = 'L\'email est requis.';
        valid = false;
      } else if (!_emailRegex.hasMatch(email)) {
        _emailError = 'Format d\'email invalide.';
        valid = false;
      } else {
        _emailError = null;
      }

      if (_selectedBirthdate == null) {
        _birthdateError = 'La date de naissance est requise.';
        valid = false;
      } else {
        final now = DateTime.now();
        final age = now.year -
            _selectedBirthdate!.year -
            (now.month < _selectedBirthdate!.month ||
                    (now.month == _selectedBirthdate!.month &&
                        now.day < _selectedBirthdate!.day)
                ? 1
                : 0);
        if (age < 10) {
          _birthdateError = 'Âge minimum : 10 ans.';
          valid = false;
        } else if (age > 25) {
          _birthdateError = 'Âge maximum : 25 ans.';
          valid = false;
        } else {
          _birthdateError = null;
        }
      }

      if (password.isEmpty) {
        _passwordError = 'Le mot de passe est requis.';
        valid = false;
      } else if (password.length < 8) {
        _passwordError = 'Minimum 8 caractères.';
        valid = false;
      } else if (!_passwordUppercase.hasMatch(password)) {
        _passwordError = 'Au moins une majuscule.';
        valid = false;
      } else if (!_passwordDigit.hasMatch(password)) {
        _passwordError = 'Au moins un chiffre.';
        valid = false;
      } else {
        _passwordError = null;
      }

      if (passwordConfirm.isEmpty) {
        _passwordConfirmError = 'La confirmation est requise.';
        valid = false;
      } else if (passwordConfirm != password) {
        _passwordConfirmError = 'Les mots de passe ne correspondent pas.';
        valid = false;
      } else {
        _passwordConfirmError = null;
      }
    });

    return valid;
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 15),
      firstDate: DateTime(now.year - 26),
      lastDate: DateTime(now.year - 10),
      helpText: 'Date de naissance',
      locale: const Locale('fr'),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthdate = picked;
        _birthdateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        _birthdateError = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_validateForm()) return;
    ref.read(authNotifierProvider.notifier).clearError();
    final success = await ref.read(authNotifierProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          nickname: _nicknameController.text.trim(),
          birthdate: _selectedBirthdate!,
          role: _selectedRole,
        );
    if (success && mounted) {
      context.go('/dashboard');
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.s4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Créer un compte', style: AppTypography.display),
              const SizedBox(height: AppSpacing.s2),
              Text(
                'Rejoignez Learn@Home',
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s5),
              if (firebaseError != null) ...[
                _ErrorBanner(message: firebaseError),
                const SizedBox(height: AppSpacing.s4),
              ],
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      controller: _firstNameController,
                      label: 'Prénom',
                      prefixIcon: LucideIcons.user,
                      errorText: _firstNameError,
                      enabled: !isLoading,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      focusNode: _firstNameFocus,
                      onSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_lastNameFocus),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: AppInput(
                      controller: _lastNameController,
                      label: 'Nom',
                      prefixIcon: LucideIcons.user,
                      errorText: _lastNameError,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      focusNode: _lastNameFocus,
                      onSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_nicknameFocus),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s4),
              AppInput(
                controller: _nicknameController,
                label: 'Pseudo',
                hint: 'mon_pseudo',
                prefixIcon: LucideIcons.atSign,
                errorText: _nicknameError,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                focusNode: _nicknameFocus,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_emailFocus),
              ),
              const SizedBox(height: AppSpacing.s4),
              AppInput(
                controller: _emailController,
                label: 'Adresse e-mail',
                hint: 'exemple@email.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: LucideIcons.mail,
                errorText: _emailError,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                focusNode: _emailFocus,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_birthdateFocus),
              ),
              const SizedBox(height: AppSpacing.s4),
              GestureDetector(
                onTap: isLoading ? null : _pickBirthdate,
                child: AbsorbPointer(
                  child: AppInput(
                    controller: _birthdateController,
                    label: 'Date de naissance',
                    hint: 'JJ/MM/AAAA',
                    prefixIcon: LucideIcons.calendar,
                    errorText: _birthdateError,
                    enabled: !isLoading,
                    focusNode: _birthdateFocus,
                    suffixIcon: const Icon(
                      LucideIcons.chevronsUpDown,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              AppInput(
                controller: _passwordController,
                label: 'Mot de passe',
                hint: '8 caractères min, 1 majuscule, 1 chiffre',
                obscureText: _obscurePassword,
                prefixIcon: LucideIcons.lock,
                errorText: _passwordError,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                focusNode: _passwordFocus,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordConfirmFocus),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: isLoading
                      ? null
                      : () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              AppInput(
                controller: _passwordConfirmController,
                label: 'Confirmer le mot de passe',
                obscureText: _obscurePasswordConfirm,
                prefixIcon: LucideIcons.lock,
                errorText: _passwordConfirmError,
                enabled: !isLoading,
                textInputAction: TextInputAction.done,
                focusNode: _passwordConfirmFocus,
                onSubmitted: (_) => _submit(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePasswordConfirm
                        ? LucideIcons.eye
                        : LucideIcons.eyeOff,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: isLoading
                      ? null
                      : () => setState(() =>
                          _obscurePasswordConfirm = !_obscurePasswordConfirm),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              _RoleSelector(
                selected: _selectedRole,
                enabled: !isLoading,
                onChanged: (role) => setState(() => _selectedRole = role),
              ),
              const SizedBox(height: AppSpacing.s5),
              AppButton(
                label: 'Créer mon compte',
                onPressed: isLoading ? null : _submit,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.s4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Déjà un compte ?',
                    style: AppTypography.small.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : () => context.pop(),
                    child: Text(
                      'Se connecter',
                      style: AppTypography.small.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s4),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selected,
    required this.onChanged,
    required this.enabled,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Je suis…',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.s2),
        Row(
          children: [
            Expanded(
              child: _RoleTile(
                label: 'Élève',
                description: 'Je cherche de l\'aide',
                icon: LucideIcons.graduationCap,
                isSelected: selected == UserRole.student,
                enabled: enabled,
                onTap: () => onChanged(UserRole.student),
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: _RoleTile(
                label: 'Bénévole',
                description: 'Je propose mon aide',
                icon: LucideIcons.bookOpen,
                isSelected: selected == UserRole.volunteer,
                enabled: enabled,
                onTap: () => onChanged(UserRole.volunteer),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.s3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.s2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTypography.small,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                LucideIcons.checkCircle,
                size: 16,
                color: AppColors.primary,
              ),
          ],
        ),
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
