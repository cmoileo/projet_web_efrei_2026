import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/services/user_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/repositories/conversation_repository.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository(firestore: ref.watch(firestoreProvider));
});

final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final userAsync = ref.watch(currentUserModelProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref
          .watch(conversationRepositoryProvider)
          .getConversations(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final conversationByIdProvider =
    StreamProvider.family<Conversation?, String>((ref, conversationId) {
  final userAsync = ref.watch(currentUserModelProvider);
  if (!userAsync.hasValue || userAsync.value == null) {
    return const Stream.empty();
  }
  final userId = userAsync.value!.uid;
  return ref
      .watch(conversationRepositoryProvider)
      .getConversationById(conversationId, userId);
});

final messagesProvider =
    StreamProvider.family<List<Message>, MessagesParams>((ref, params) {
  return ref
      .watch(conversationRepositoryProvider)
      .getMessages(params.conversationId, limit: params.limit);
});

class MessagesParams {
  const MessagesParams({required this.conversationId, required this.limit});

  final String conversationId;
  final int limit;

  @override
  bool operator ==(Object other) =>
      other is MessagesParams &&
      other.conversationId == conversationId &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(conversationId, limit);
}

MessagesParams messagesParams(String conversationId, int limit) =>
    MessagesParams(conversationId: conversationId, limit: limit);

final userByIdProvider =
    FutureProvider.family<UserModel?, String>((ref, uid) async {
  final userService = UserService(ref.watch(firestoreProvider));
  return userService.getUser(uid);
});

final studentsForCurrentVolunteerProvider =
    FutureProvider<List<UserModel>>((ref) async {
  final user = await ref.watch(currentUserModelProvider.future);
  if (user == null) return [];
  final userService = UserService(ref.watch(firestoreProvider));
  return userService.getStudentsForVolunteer(user.uid);
});
