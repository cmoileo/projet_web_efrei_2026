import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/new_direct_conversation_dialog.dart';
import '../widgets/new_group_conversation_dialog.dart';

class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  void _showCreateMenu(BuildContext context, String benevoleId) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.s2),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            ListTile(
              leading: const Icon(LucideIcons.user, color: AppColors.primary),
              title:
                  Text('Conversation directe', style: AppTypography.bodyMedium),
              subtitle: Text(
                'Avec un de vos élèves',
                style: AppTypography.small,
              ),
              onTap: () {
                Navigator.of(context).pop();
                showDialog<void>(
                  context: context,
                  builder: (_) =>
                      NewDirectConversationDialog(benevoleId: benevoleId),
                );
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.users, color: AppColors.primary),
              title: Text('Groupe', style: AppTypography.bodyMedium),
              subtitle: Text(
                'Plusieurs élèves',
                style: AppTypography.small,
              ),
              onTap: () {
                Navigator.of(context).pop();
                showDialog<void>(
                  context: context,
                  builder: (_) =>
                      NewGroupConversationDialog(benevoleId: benevoleId),
                );
              },
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final userAsync = ref.watch(currentUserModelProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        final isVolunteer = user.role == UserRole.volunteer;

        return Stack(
          children: [
            conversationsAsync.when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return _EmptyConversations(isVolunteer: isVolunteer);
                }
                return ListView.separated(
                  padding: EdgeInsets.only(
                    top: AppSpacing.s2,
                    bottom: isVolunteer ? 80 : AppSpacing.s2,
                  ),
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: AppSpacing.s4 + 44 + AppSpacing.s3,
                    endIndent: AppSpacing.s4,
                  ),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return ConversationTile(
                      conversation: conversation,
                      currentUserId: user.uid,
                      onTap: () => context.push('/chat/${conversation.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          size: 40, color: AppColors.danger),
                      const SizedBox(height: AppSpacing.s3),
                      Text(
                        'Erreur lors du chargement des conversations',
                        style: AppTypography.body
                            .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isVolunteer)
              Positioned(
                bottom: AppSpacing.s4,
                right: AppSpacing.s4,
                child: FloatingActionButton(
                  onPressed: () => _showCreateMenu(context, user.uid),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: const Icon(LucideIcons.plus),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations({required this.isVolunteer});

  final bool isVolunteer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.messageCircle,
                size: 56, color: AppColors.textDisabled),
            const SizedBox(height: AppSpacing.s4),
            Text('Aucune conversation', style: AppTypography.heading),
            const SizedBox(height: AppSpacing.s2),
            Text(
              isVolunteer
                  ? 'Créez votre première conversation\nen appuyant sur le bouton + .'
                  : 'Vous n\'avez pas encore de conversations.\nVotre bénévole vous contactera bientôt.',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
