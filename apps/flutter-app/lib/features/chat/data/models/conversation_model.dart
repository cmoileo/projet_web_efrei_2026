import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/conversation.dart';

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.type,
    required this.name,
    required this.createdBy,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  });

  final String id;
  final String type;
  final String? name;
  final String createdBy;
  final List<String> members;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessage;

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      type: data['type'] as String,
      name: data['name'] as String?,
      createdBy: data['createdBy'] as String,
      members: List<String>.from(data['members'] as List),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastMessage: data['lastMessage'] as String?,
    );
  }

  Map<String, Object?> toJson() => {
        'type': type,
        'name': name,
        'createdBy': createdBy,
        'members': members,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'lastMessage': lastMessage,
      };

  Conversation toEntity({int unreadCount = 0}) => Conversation(
        id: id,
        type: type,
        name: name,
        createdBy: createdBy,
        members: members,
        createdAt: createdAt,
        updatedAt: updatedAt,
        unreadCount: unreadCount,
        lastMessage: lastMessage,
      );
}
