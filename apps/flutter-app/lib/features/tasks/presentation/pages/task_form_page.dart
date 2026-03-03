import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/atoms/app_button.dart';
import '../../../../shared/widgets/molecules/app_form_field.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/task_provider.dart';

class TaskFormPage extends ConsumerStatefulWidget {
  const TaskFormPage({super.key});

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _dueDate;
  UserModel? _selectedStudent;

  String? _titleError;
  String? _descError;
  String? _dueDateError;
  String? _studentError;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _titleError =
          _titleCtrl.text.trim().isEmpty ? 'Le titre est obligatoire.' : null;
      _descError = _descCtrl.text.trim().isEmpty
          ? 'La description est obligatoire.'
          : null;
      _dueDateError =
          _dueDate == null ? 'La date d\'échéance est obligatoire.' : null;
      _studentError =
          _selectedStudent == null ? 'Veuillez sélectionner un élève.' : null;
    });
    return _titleError == null &&
        _descError == null &&
        _dueDateError == null &&
        _studentError == null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('fr'),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateError = null;
      });
    }
  }

  Future<void> _submit(String createdBy) async {
    if (!_validate()) return;

    await ref.read(createTaskNotifierProvider.notifier).createTask(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          dueDate: _dueDate!,
          assignedTo: _selectedStudent!.uid,
          createdBy: createdBy,
        );

    if (!mounted) return;
    final state = ref.read(createTaskNotifierProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${state.error}'),
          backgroundColor: AppColors.danger,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tâche créée avec succès.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserModelProvider);
    final studentsAsync = ref.watch(studentsForVolunteerProvider);
    final notifierState = ref.watch(createTaskNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
          tooltip: 'Retour',
        ),
        title: Text('Nouvelle tâche', style: AppTypography.bodyMedium),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Titre ────────────────────────────────────────────────
                AppFormField(
                  label: 'Titre',
                  hint: 'Ex : Réviser le chapitre 3',
                  controller: _titleCtrl,
                  prefixIcon: LucideIcons.fileText,
                  errorText: _titleError,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() => _titleError = null),
                ),
                const SizedBox(height: AppSpacing.s4),

                // ─── Description ──────────────────────────────────────────
                AppFormField(
                  label: 'Description',
                  hint: 'Décrivez la tâche en détail…',
                  controller: _descCtrl,
                  prefixIcon: LucideIcons.alignLeft,
                  errorText: _descError,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  onChanged: (_) => setState(() => _descError = null),
                ),
                const SizedBox(height: AppSpacing.s4),

                // ─── Date d'échéance ──────────────────────────────────────
                _DatePickerField(
                  selectedDate: _dueDate,
                  errorText: _dueDateError,
                  onTap: _pickDate,
                ),
                const SizedBox(height: AppSpacing.s4),

                // ─── Sélecteur d'élève ────────────────────────────────────
                studentsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s3),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => Text(
                    'Impossible de charger les élèves.',
                    style:
                        AppTypography.small.copyWith(color: AppColors.danger),
                  ),
                  data: (students) => _StudentDropdown(
                    students: students,
                    selected: _selectedStudent,
                    errorText: _studentError,
                    onChanged: (s) => setState(() {
                      _selectedStudent = s;
                      _studentError = null;
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),

                // ─── Bouton soumettre ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Créer la tâche',
                    icon: LucideIcons.plus,
                    isLoading: notifierState.isLoading,
                    onPressed: notifierState.isLoading
                        ? null
                        : () => _submit(user.uid),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Date picker field ────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.selectedDate,
    required this.onTap,
    this.errorText,
  });

  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final label = selectedDate == null
        ? 'Date d\'échéance'
        : DateFormat('d MMMM yyyy', 'fr').format(selectedDate!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s3,
              vertical: AppSpacing.s3,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText != null ? AppColors.danger : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.calendar,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body.copyWith(
                      color: selectedDate == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(LucideIcons.chevronDown,
                    size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.s1),
          Text(
            errorText!,
            style: AppTypography.small.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}

// ─── Student dropdown ─────────────────────────────────────────────────────────

class _StudentDropdown extends StatelessWidget {
  const _StudentDropdown({
    required this.students,
    required this.selected,
    required this.onChanged,
    this.errorText,
  });

  final List<UserModel> students;
  final UserModel? selected;
  final ValueChanged<UserModel?> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.s3),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.userX,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.s3),
            Text(
              'Aucun élève assigné à votre compte.',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: errorText != null ? AppColors.danger : AppColors.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UserModel>(
              value: selected,
              isExpanded: true,
              hint: Text(
                'Sélectionner un élève',
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              items: students
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        '${s.firstName} ${s.lastName}',
                        style: AppTypography.body,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.s1),
          Text(
            errorText!,
            style: AppTypography.small.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}
