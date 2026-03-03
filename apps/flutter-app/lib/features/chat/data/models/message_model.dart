import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message.dart';

class MessageModel {
  const MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.sentAt,
    required this.readBy,
  });

  final String id;
  final String content;
  final String senderId;
  final DateTime sentAt;
  final List<String> readBy;

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      content: data['content'] as String,
      senderId: data['senderId'] as String,
      sentAt: data['sentAt'] != null
          ? (data['sentAt'] as Timestamp).toDate()
          : DateTime.now(),
      readBy: List<String>.from(data['readBy'] as List? ?? []),
    );
  }

  Map<String, Object> toJson() => {
        'content': content,
        'senderId': senderId,
        'sentAt': Timestamp.fromDate(sentAt),
        'readBy': readBy,
      };

  Message toEntity() => Message(
        id: id,
        content: content,
        senderId: senderId,
        sentAt: sentAt,
        readBy: readBy,
      );
}
