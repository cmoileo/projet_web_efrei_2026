import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';

class MessageBubble extends ConsumerWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.allMembers,
    this.showAvatar = true,
  });

  final Message message;
  final String currentUserId;
  final List<String> allMembers;
  final bool showAvatar;

  bool get _isMine => message.senderId == currentUserId;

  bool get _isReadByAll {
    final others = allMembers.where((m) => m != currentUserId).toList();
    if (others.isEmpty) return true;
    return others.every((m) => message.readBy.contains(m));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(
        left: _isMine ? AppSpacing.s8 : AppSpacing.s4,
        right: _isMine ? AppSpacing.s4 : AppSpacing.s8,
        top: AppSpacing.s1,
        bottom: AppSpacing.s1,
      ),
      child: Row(
        mainAxisAlignment:
            _isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isMine && showAvatar) ...[
            _SenderAvatar(senderId: message.senderId),
            const SizedBox(width: AppSpacing.s2),
          ] else if (!_isMine) ...[
            const SizedBox(width: 28 + AppSpacing.s2),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  _isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s3,
                    vertical: AppSpacing.s2,
                  ),
                  decoration: BoxDecoration(
                    color: _isMine ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppSpacing.s3),
                      topRight: const Radius.circular(AppSpacing.s3),
                      bottomLeft: Radius.circular(_isMine ? AppSpacing.s3 : 4),
                      bottomRight: Radius.circular(_isMine ? 4 : AppSpacing.s3),
                    ),
                    border:
                        _isMine ? null : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    message.content,
                    style: AppTypography.body.copyWith(
                      color: _isMine ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (_isMine) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isReadByAll
                            ? LucideIcons.checkCheck
                            : LucideIcons.check,
                        size: 12,
                        color: _isReadByAll
                            ? AppColors.primary
                            : AppColors.textDisabled,
                      ),
                      if (_isReadByAll) ...[
                        const SizedBox(width: 2),
                        Text(
                          'Lu',
                          style: AppTypography.tiny.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SenderAvatar extends ConsumerWidget {
  const _SenderAvatar({required this.senderId});

  final String senderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(senderId));
    return userAsync.when(
      data: (user) {
        final name = user != null ? '${user.firstName} ${user.lastName}' : 'U';
        final initials = name
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();
        int hash = 0;
        for (final c in name.codeUnits) {
          hash = c + ((hash << 5) - hash);
        }
        final hue = (hash % 360).abs().toDouble();
        final bg = HSLColor.fromAHSL(1.0, hue, 0.55, 0.50).toColor();
        final fg = bg.computeLuminance() > 0.35 ? Colors.black : Colors.white;
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(width: 28, height: 28),
      error: (_, __) => const SizedBox(width: 28, height: 28),
    );
  }
}
