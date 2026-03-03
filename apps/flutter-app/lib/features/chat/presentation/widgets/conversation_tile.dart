import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/conversation.dart';
import '../providers/chat_provider.dart';

class ConversationTile extends ConsumerWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGroup = conversation.type == 'group';

    return FutureBuilder<String>(
      future: _resolveDisplayName(ref, isGroup),
      builder: (context, snapshot) {
        final displayName = snapshot.data ?? '…';
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s3,
            ),
            child: Row(
              children: [
                _ConversationAvatar(
                  displayName: displayName,
                  isGroup: isGroup,
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
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
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.s3),
                              ),
                              child: Text(
                                '${conversation.unreadCount}',
                                style: AppTypography.tiny.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        conversation.lastMessage ?? 'Aucun message',
                        style: AppTypography.body.copyWith(
                          color: conversation.unreadCount > 0
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _resolveDisplayName(WidgetRef ref, bool isGroup) async {
    if (isGroup) return conversation.name ?? 'Groupe';
    final otherUid = conversation.members
        .firstWhere((m) => m != currentUserId, orElse: () => currentUserId);
    final user = await ref.read(userByIdProvider(otherUid).future);
    if (user == null) return 'Utilisateur';
    return '${user.firstName} ${user.lastName}';
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({
    required this.displayName,
    required this.isGroup,
  });

  final String displayName;
  final bool isGroup;

  Color _colorFromName(String name) {
    int hash = 0;
    for (final c in name.codeUnits) {
      hash = c + ((hash << 5) - hash);
    }
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.50).toColor();
  }

  @override
  Widget build(BuildContext context) {
    if (isGroup) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child:
            const Icon(LucideIcons.users, size: 20, color: AppColors.primary),
      );
    }

    final bg = _colorFromName(displayName);
    final fg = bg.computeLuminance() > 0.35 ? Colors.black : Colors.white;
    final initials = displayName.trim().isNotEmpty
        ? displayName
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
