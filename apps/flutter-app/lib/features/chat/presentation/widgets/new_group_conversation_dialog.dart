import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/chat_provider.dart';

class NewGroupConversationDialog extends ConsumerStatefulWidget {
  const NewGroupConversationDialog({
    super.key,
    required this.benevoleId,
  });

  final String benevoleId;

  @override
  ConsumerState<NewGroupConversationDialog> createState() =>
      _NewGroupConversationDialogState();
}

class _NewGroupConversationDialogState
    extends ConsumerState<NewGroupConversationDialog> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedIds = {};
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canCreate =>
      _nameController.text.trim().isNotEmpty && _selectedIds.isNotEmpty;

  Future<void> _create() async {
    if (!_canCreate) return;
    setState(() => _loading = true);
    try {
      final id = await ref
          .read(conversationRepositoryProvider)
          .createGroupConversation(
            widget.benevoleId,
            _nameController.text.trim(),
            _selectedIds.toList(),
          );
      if (mounted) {
        Navigator.of(context).pop();
        context.push('/chat/$id');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsForCurrentVolunteerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.s4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nouveau groupe', style: AppTypography.heading),
            const SizedBox(height: AppSpacing.s4),
            TextField(
              controller: _nameController,
              style: AppTypography.body,
              decoration: InputDecoration(
                labelText: 'Nom du groupe',
                labelStyle:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s3,
                  vertical: AppSpacing.s3,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Membres',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s2),
            studentsAsync.when(
              data: (students) {
                if (students.isEmpty) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.s3),
                    child: Text(
                      'Aucun élève assigné.',
                      style: AppTypography.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final isSelected = _selectedIds.contains(student.uid);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedIds.add(student.uid);
                            } else {
                              _selectedIds.remove(student.uid);
                            }
                          });
                        },
                        title: Text(
                          '${student.firstName} ${student.lastName}',
                          style: AppTypography.bodyMedium,
                        ),
                        subtitle: Text(
                          student.email,
                          style: AppTypography.small,
                        ),
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.s4),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => Text(
                'Impossible de charger les élèves.',
                style: AppTypography.body.copyWith(color: AppColors.danger),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Annuler',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                FilledButton(
                  onPressed: _canCreate && !_loading ? _create : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Créer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
