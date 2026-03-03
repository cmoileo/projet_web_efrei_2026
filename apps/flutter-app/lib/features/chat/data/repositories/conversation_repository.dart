import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ConversationRepository {
  const ConversationRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<Conversation>> getConversations(String userId) {
    return _firestore
        .collection(FirestoreCollections.conversations)
        .where('members', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final conversations = <Conversation>[];
      for (final doc in snapshot.docs) {
        final model = ConversationModel.fromFirestore(doc);
        final unreadSnapshot = await _firestore
            .collection(FirestoreCollections.conversations)
            .doc(doc.id)
            .collection('messages')
            .get();
        final unreadCount = unreadSnapshot.docs
            .where((m) =>
                !(List<String>.from(m.data()['readBy'] as List? ?? []))
                    .contains(userId))
            .length;
        conversations.add(model.toEntity(unreadCount: unreadCount));
      }
      return conversations;
    });
  }

  Stream<Conversation?> getConversationById(
    String conversationId,
    String userId,
  ) {
    return _firestore
        .collection(FirestoreCollections.conversations)
        .doc(conversationId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return null;
      final model = ConversationModel.fromFirestore(doc);
      final unreadSnapshot = await _firestore
          .collection(FirestoreCollections.conversations)
          .doc(conversationId)
          .collection('messages')
          .get();
      final unreadCount = unreadSnapshot.docs
          .where((m) => !(List<String>.from(m.data()['readBy'] as List? ?? []))
              .contains(userId))
          .length;
      return model.toEntity(unreadCount: unreadCount);
    });
  }

  Stream<List<Message>> getMessages(
    String conversationId, {
    int limit = 30,
  }) {
    return _firestore
        .collection(FirestoreCollections.conversations)
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc).toEntity())
              .toList(),
        );
  }

  Future<void> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) async {
    final batch = _firestore.batch();

    final messageRef = _firestore
        .collection(FirestoreCollections.conversations)
        .doc(conversationId)
        .collection('messages')
        .doc();

    batch.set(messageRef, {
      'content': content,
      'senderId': senderId,
      'sentAt': FieldValue.serverTimestamp(),
      'readBy': [senderId],
    });

    final conversationRef = _firestore
        .collection(FirestoreCollections.conversations)
        .doc(conversationId);

    batch.update(conversationRef, {
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': content,
    });

    await batch.commit();
  }

  Future<void> markAsRead(
    String conversationId,
    String userId,
    List<String> messageIds,
  ) async {
    if (messageIds.isEmpty) return;

    final batch = _firestore.batch();
    for (final id in messageIds) {
      final ref = _firestore
          .collection(FirestoreCollections.conversations)
          .doc(conversationId)
          .collection('messages')
          .doc(id);
      batch.update(ref, {
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }
    await batch.commit();
  }

  Future<String> createDirectConversation(
    String benevoleId,
    String eleveId,
  ) async {
    final existing = await _firestore
        .collection(FirestoreCollections.conversations)
        .where('type', isEqualTo: 'direct')
        .where('members', arrayContains: benevoleId)
        .get();

    for (final doc in existing.docs) {
      final members = List<String>.from(doc.data()['members'] as List);
      if (members.contains(eleveId)) return doc.id;
    }

    final ref =
        await _firestore.collection(FirestoreCollections.conversations).add({
      'type': 'direct',
      'name': null,
      'createdBy': benevoleId,
      'members': [benevoleId, eleveId],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': null,
    });
    return ref.id;
  }

  Future<String> createGroupConversation(
    String benevoleId,
    String name,
    List<String> memberIds,
  ) async {
    final members = [benevoleId, ...memberIds];
    final ref =
        await _firestore.collection(FirestoreCollections.conversations).add({
      'type': 'group',
      'name': name,
      'createdBy': benevoleId,
      'members': members,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': null,
    });
    return ref.id;
  }
}
