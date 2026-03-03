import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/chat_provider.dart';

class NewDirectConversationDialog extends ConsumerStatefulWidget {
  const NewDirectConversationDialog({
    super.key,
    required this.benevoleId,
  });

  final String benevoleId;

  @override
  ConsumerState<NewDirectConversationDialog> createState() =>
      _NewDirectConversationDialogState();
}

class _NewDirectConversationDialogState
    extends ConsumerState<NewDirectConversationDialog> {
  UserModel? _selected;
  bool _loading = false;

  Future<void> _create() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    try {
      final id = await ref
          .read(conversationRepositoryProvider)
          .createDirectConversation(widget.benevoleId, _selected!.uid);
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
            Text('Nouvelle conversation', style: AppTypography.heading),
            const SizedBox(height: AppSpacing.s2),
            Text(
              'Choisissez un élève',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s4),
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
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final isSelected = _selected?.uid == student.uid;
                      return InkWell(
                        onTap: () => setState(() => _selected = student),
                        borderRadius: BorderRadius.circular(AppSpacing.s2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s2,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textDisabled,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: AppSpacing.s3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${student.firstName} ${student.lastName}',
                                      style: AppTypography.bodyMedium,
                                    ),
                                    Text(
                                      student.email,
                                      style: AppTypography.small,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
                  onPressed: _selected == null || _loading ? null : _create,
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
                      : const Text('Démarrer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
