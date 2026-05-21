class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.threadId,
    required this.body,
    required this.senderId,
    required this.createdAt,
  });

  final String id;
  final String threadId;
  final String body;
  final String senderId;
  final DateTime createdAt;
}
