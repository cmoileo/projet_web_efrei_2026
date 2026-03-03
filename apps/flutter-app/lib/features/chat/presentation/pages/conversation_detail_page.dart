import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

class ConversationDetailPage extends ConsumerStatefulWidget {
  const ConversationDetailPage({
    super.key,
    required this.conversationId,
  });

  final String conversationId;

  @override
  ConsumerState<ConversationDetailPage> createState() =>
      _ConversationDetailPageState();
}

class _ConversationDetailPageState
    extends ConsumerState<ConversationDetailPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _limit = 30;
  bool _isSending = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String currentUserId) async {
    final content = _inputController.text.trim();
    if (content.isEmpty) return;
    setState(() => _isSending = true);
    _inputController.clear();
    try {
      await ref
          .read(conversationRepositoryProvider)
          .sendMessage(widget.conversationId, currentUserId, content);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _markUnreadAsRead(
    List<Message> messages,
    String currentUserId,
  ) async {
    final unreadIds = messages
        .where((m) => !m.readBy.contains(currentUserId))
        .map((m) => m.id)
        .toList();
    if (unreadIds.isEmpty) return;
    await ref.read(conversationRepositoryProvider).markAsRead(
          widget.conversationId,
          currentUserId,
          unreadIds,
        );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserModelProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return _buildScaffold(user.uid);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildScaffold(String currentUserId) {
    final conversationAsync =
        ref.watch(conversationByIdProvider(widget.conversationId));

    final conversation = conversationAsync.valueOrNull;
    final title = conversation?.name ?? 'Conversation';
    final isGroup = conversation?.type == 'group';
    final members = conversation?.members ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
        title: Row(
          children: [
            Expanded(
              child: Text(title, style: AppTypography.subheading),
            ),
            if (isGroup)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSpacing.s2),
                ),
                child: Text(
                  'Groupe',
                  style: AppTypography.tiny.copyWith(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _MessagesView(
              conversationId: widget.conversationId,
              currentUserId: currentUserId,
              limit: _limit,
              members: members,
              scrollController: _scrollController,
              onLoadMore: () => setState(() => _limit += 30),
              onMessagesLoaded: (messages) =>
                  _markUnreadAsRead(messages, currentUserId),
            ),
          ),
          _InputBar(
            controller: _inputController,
            isSending: _isSending,
            onSend: () => _sendMessage(currentUserId),
          ),
        ],
      ),
    );
  }
}

class _MessagesView extends ConsumerWidget {
  const _MessagesView({
    required this.conversationId,
    required this.currentUserId,
    required this.limit,
    required this.members,
    required this.scrollController,
    required this.onLoadMore,
    required this.onMessagesLoaded,
  });

  final String conversationId;
  final String currentUserId;
  final int limit;
  final List<String> members;
  final ScrollController scrollController;
  final VoidCallback onLoadMore;
  final void Function(List<Message> messages) onMessagesLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(
      messagesProvider(messagesParams(conversationId, limit)),
    );

    return messagesAsync.when(
      data: (messages) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMessagesLoaded(messages);
        });

        if (messages.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.messageSquare,
                      size: 48, color: AppColors.textDisabled),
                  const SizedBox(height: AppSpacing.s3),
                  Text(
                    'Aucun message',
                    style: AppTypography.subheading,
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    'Commencez la conversation !',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        final hasMore = messages.length >= limit;

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          itemCount: messages.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (hasMore && index == messages.length) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.s3),
                child: Center(
                  child: TextButton.icon(
                    onPressed: onLoadMore,
                    icon: const Icon(LucideIcons.chevronsUp, size: 16),
                    label: const Text('Charger les messages précédents'),
                  ),
                ),
              );
            }

            final message = messages[index];
            final showAvatar = index == messages.length - 1 ||
                messages[index + 1].senderId != message.senderId;

            return MessageBubble(
              message: message,
              currentUserId: currentUserId,
              allMembers: members,
              showAvatar: showAvatar,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Text(
            'Erreur : $error',
            style: AppTypography.body.copyWith(color: AppColors.danger),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.s3,
        right: AppSpacing.s3,
        top: AppSpacing.s2,
        bottom: AppSpacing.s2 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isSending,
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: 'Écrire un message…',
                hintStyle:
                    AppTypography.body.copyWith(color: AppColors.textDisabled),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s3,
                  vertical: AppSpacing.s2,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.s6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.s6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.s6),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              maxLines: 5,
              minLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.s2),
          isSending
              ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: onSend,
                  icon: const Icon(LucideIcons.send),
                  color: AppColors.primary,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    minimumSize: const Size(40, 40),
                  ),
                ),
        ],
      ),
    );
  }
}
