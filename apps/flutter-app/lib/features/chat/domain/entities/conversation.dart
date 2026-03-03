class Conversation {
  const Conversation({
    required this.id,
    required this.type,
    required this.name,
    required this.createdBy,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount = 0,
    this.lastMessage,
  });

  final String id;
  final String type;
  final String? name;
  final String createdBy;
  final List<String> members;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;
  final String? lastMessage;

  Conversation copyWith({
    String? id,
    String? type,
    String? name,
    String? createdBy,
    List<String>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? unreadCount,
    String? lastMessage,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
