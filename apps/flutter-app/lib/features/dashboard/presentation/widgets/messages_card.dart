import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/molecules/app_card.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../chat/domain/entities/conversation.dart';
import '../../../chat/presentation/providers/chat_provider.dart';

class MessagesCard extends ConsumerWidget {
  const MessagesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(unreadConversationsProvider);
    final userAsync = ref.watch(currentUserModelProvider);

    final currentUserId = userAsync.valueOrNull?.uid ?? '';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.messageCircle,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s2),
              Text('Messages non lus', style: AppTypography.subheading),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          unreadAsync.when(
            data: (conversations) {
              if (conversations.isEmpty) {
                return Text(
                  'Aucun message non lu',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                );
              }
              return Column(
                children: conversations
                    .map(
                      (c) => _UnreadConversationRow(
                        key: ValueKey(c.id),
                        conversation: c,
                        currentUserId: currentUserId,
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Center(
              child: SizedBox(
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => Text(
              'Impossible de charger les messages',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadConversationRow extends ConsumerWidget {
  const _UnreadConversationRow({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  final Conversation conversation;
  final String currentUserId;

  Future<String> _resolveDisplayName(WidgetRef ref) async {
    if (conversation.type == 'group') {
      return conversation.name ?? 'Groupe';
    }
    final otherUid = conversation.members.firstWhere(
      (m) => m != currentUserId,
      orElse: () => currentUserId,
    );
    final user = await ref.read(userByIdProvider(otherUid).future);
    if (user == null) return 'Utilisateur';
    return '${user.firstName} ${user.lastName}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: FutureBuilder<String>(
        future: _resolveDisplayName(ref),
        builder: (context, snapshot) {
          final name = snapshot.data ?? '…';
          final excerpt = conversation.lastMessage ?? '';
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTypography.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: AppTypography.tiny
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    if (excerpt.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        excerpt,
                        style: AppTypography.small
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
