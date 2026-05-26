enum TransactionState {
  intentCreated,
  pendingSellerResponse,
  sellerConfirmed,
  expired,
  cancelled,
  completed,
  disputeOpened,
  disputeResolved,
}

extension TransactionStateX on TransactionState {
  String get value {
    switch (this) {
      case TransactionState.intentCreated:
        return TransactionStateCatalog.intentCreated;
      case TransactionState.pendingSellerResponse:
        return TransactionStateCatalog.pendingSellerResponse;
      case TransactionState.sellerConfirmed:
        return TransactionStateCatalog.sellerConfirmed;
      case TransactionState.expired:
        return TransactionStateCatalog.expired;
      case TransactionState.cancelled:
        return TransactionStateCatalog.cancelled;
      case TransactionState.completed:
        return TransactionStateCatalog.completed;
      case TransactionState.disputeOpened:
        return TransactionStateCatalog.disputeOpened;
      case TransactionState.disputeResolved:
        return TransactionStateCatalog.disputeResolved;
    }
  }

  bool get isClosed =>
      this == TransactionState.expired ||
      this == TransactionState.completed ||
      this == TransactionState.cancelled ||
      this == TransactionState.disputeResolved;

  static TransactionState fromValue(String raw) {
    switch (raw) {
      case TransactionStateCatalog.intentCreated:
        return TransactionState.intentCreated;
      case TransactionStateCatalog.pendingSellerResponse:
        return TransactionState.pendingSellerResponse;
      case TransactionStateCatalog.sellerConfirmed:
        return TransactionState.sellerConfirmed;
      case TransactionStateCatalog.expired:
        return TransactionState.expired;
      case TransactionStateCatalog.cancelled:
        return TransactionState.cancelled;
      case TransactionStateCatalog.completed:
        return TransactionState.completed;
      case TransactionStateCatalog.disputeOpened:
        return TransactionState.disputeOpened;
      case TransactionStateCatalog.disputeResolved:
        return TransactionState.disputeResolved;
      default:
        return TransactionState.intentCreated;
    }
  }
}

/// Canonical deal status codes expected from backend contract surfaces.
abstract final class TransactionStateCatalog {
  static const String intentCreated = 'intent_created';
  static const String pendingSellerResponse = 'pending_seller_response';
  static const String sellerConfirmed = 'seller_confirmed';
  static const String expired = 'expired';
  static const String cancelled = 'cancelled';
  static const String completed = 'completed';
  static const String disputeOpened = 'dispute_opened';
  static const String disputeResolved = 'dispute_resolved';

  static const Set<String> knownCodes = <String>{
    intentCreated,
    pendingSellerResponse,
    sellerConfirmed,
    expired,
    cancelled,
    completed,
    disputeOpened,
    disputeResolved,
  };
}

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.listingId,
    required this.buyerUserId,
    required this.sellerUserId,
    required this.state,
    this.dealType = 'buy',
    this.exchangeOffer,
    this.expiresAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String listingId;
  final String buyerUserId;
  final String sellerUserId;
  final TransactionState state;
  final String dealType;
  final String? exchangeOffer;
  final DateTime? expiresAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isExchange => dealType == 'exchange';
}
