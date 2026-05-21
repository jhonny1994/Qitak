class ConversationThreadSummary {
  const ConversationThreadSummary({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.lastMessageBody,
    required this.lastMessageAt,
    required this.lastSenderId,
    required this.otherPartyLabel,
  });

  final String id;
  final String listingId;
  final String listingTitle;
  final String lastMessageBody;
  final DateTime lastMessageAt;
  final String lastSenderId;
  final String otherPartyLabel;
}
