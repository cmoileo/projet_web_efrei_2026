class Message {
  const Message({
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

  Message copyWith({
    String? id,
    String? content,
    String? senderId,
    DateTime? sentAt,
    List<String>? readBy,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      sentAt: sentAt ?? this.sentAt,
      readBy: readBy ?? this.readBy,
    );
  }
}
