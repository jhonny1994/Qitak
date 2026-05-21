import 'package:qitak_app/features/messaging/domain/conversation_message.dart';

class ConversationOversightCase {
  const ConversationOversightCase({
    required this.threadId,
    required this.listingId,
    required this.listingTitle,
    required this.buyerUserId,
    required this.sellerUserId,
    required this.buyerName,
    required this.sellerName,
    required this.messages,
    this.transactionId,
    this.reportId,
    this.disputeId,
  });

  final String threadId;
  final String listingId;
  final String listingTitle;
  final String buyerUserId;
  final String sellerUserId;
  final String buyerName;
  final String sellerName;
  final List<ConversationMessage> messages;
  final String? transactionId;
  final String? reportId;
  final String? disputeId;
}
