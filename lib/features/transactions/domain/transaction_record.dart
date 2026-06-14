enum TransactionState {
  pendingSellerResponse,
  sellerConfirmed,
  paymentProofSubmitted,
  paymentConfirmed,
  expired,
  cancelled,
  completed,
  disputeOpened,
  disputeResolved,
}

enum TransactionPaymentMethod {
  ccp,
  baridiMob,
  cash,
}

extension TransactionPaymentMethodX on TransactionPaymentMethod {
  String get value {
    switch (this) {
      case TransactionPaymentMethod.ccp:
        return TransactionPaymentCatalog.ccp;
      case TransactionPaymentMethod.baridiMob:
        return TransactionPaymentCatalog.baridiMob;
      case TransactionPaymentMethod.cash:
        return TransactionPaymentCatalog.cash;
    }
  }

  static TransactionPaymentMethod? fromValue(String? raw) {
    switch (raw) {
      case TransactionPaymentCatalog.ccp:
        return TransactionPaymentMethod.ccp;
      case TransactionPaymentCatalog.baridiMob:
        return TransactionPaymentMethod.baridiMob;
      case TransactionPaymentCatalog.cash:
        return TransactionPaymentMethod.cash;
      default:
        return null;
    }
  }
}

extension TransactionStateX on TransactionState {
  String get value {
    switch (this) {
      case TransactionState.pendingSellerResponse:
        return TransactionStateCatalog.pendingSellerResponse;
      case TransactionState.sellerConfirmed:
        return TransactionStateCatalog.sellerConfirmed;
      case TransactionState.paymentProofSubmitted:
        return TransactionStateCatalog.paymentProofSubmitted;
      case TransactionState.paymentConfirmed:
        return TransactionStateCatalog.paymentConfirmed;
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
      case TransactionStateCatalog.pendingSellerResponse:
        return TransactionState.pendingSellerResponse;
      case TransactionStateCatalog.sellerConfirmed:
        return TransactionState.sellerConfirmed;
      case TransactionStateCatalog.paymentProofSubmitted:
        return TransactionState.paymentProofSubmitted;
      case TransactionStateCatalog.paymentConfirmed:
        return TransactionState.paymentConfirmed;
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
        return TransactionState.pendingSellerResponse;
    }
  }
}

/// Canonical deal status codes expected from backend contract surfaces.
abstract final class TransactionStateCatalog {
  static const String pendingSellerResponse = 'pending_seller_response';
  static const String sellerConfirmed = 'seller_confirmed';
  static const String paymentProofSubmitted = 'payment_proof_submitted';
  static const String paymentConfirmed = 'payment_confirmed';
  static const String expired = 'expired';
  static const String cancelled = 'cancelled';
  static const String completed = 'completed';
  static const String disputeOpened = 'dispute_opened';
  static const String disputeResolved = 'dispute_resolved';

  static const Set<String> knownCodes = <String>{
    pendingSellerResponse,
    sellerConfirmed,
    paymentProofSubmitted,
    paymentConfirmed,
    expired,
    cancelled,
    completed,
    disputeOpened,
    disputeResolved,
  };
}

abstract final class TransactionPaymentCatalog {
  static const String ccp = 'ccp';
  static const String baridiMob = 'baridimob';
  static const String cash = 'cash';
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
    this.paymentMethod,
    this.paymentProofPath,
    this.paymentProofRejectionReason,
    this.cancellationReason,
    this.expiresAt,
    this.confirmedAt,
    this.paymentProofSubmittedAt,
    this.paymentConfirmedAt,
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
  final TransactionPaymentMethod? paymentMethod;
  final String? paymentProofPath;
  final String? paymentProofRejectionReason;
  final String? cancellationReason;
  final DateTime? expiresAt;
  final DateTime? confirmedAt;
  final DateTime? paymentProofSubmittedAt;
  final DateTime? paymentConfirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isExchange => dealType == 'exchange';

  bool get requiresPaymentProof =>
      paymentMethod == TransactionPaymentMethod.ccp ||
      paymentMethod == TransactionPaymentMethod.baridiMob;

  bool get isCashPayment => paymentMethod == TransactionPaymentMethod.cash;

  TransactionRecord copyWith({
    String? id,
    String? listingId,
    String? buyerUserId,
    String? sellerUserId,
    TransactionState? state,
    String? dealType,
    String? exchangeOffer,
    TransactionPaymentMethod? paymentMethod,
    bool clearPaymentMethod = false,
    String? paymentProofPath,
    bool clearPaymentProofPath = false,
    String? paymentProofRejectionReason,
    bool clearPaymentProofRejectionReason = false,
    String? cancellationReason,
    bool clearCancellationReason = false,
    DateTime? expiresAt,
    DateTime? confirmedAt,
    DateTime? paymentProofSubmittedAt,
    bool clearPaymentProofSubmittedAt = false,
    DateTime? paymentConfirmedAt,
    bool clearPaymentConfirmedAt = false,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionRecord(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      buyerUserId: buyerUserId ?? this.buyerUserId,
      sellerUserId: sellerUserId ?? this.sellerUserId,
      state: state ?? this.state,
      dealType: dealType ?? this.dealType,
      exchangeOffer: exchangeOffer ?? this.exchangeOffer,
      paymentMethod: clearPaymentMethod
          ? null
          : paymentMethod ?? this.paymentMethod,
      paymentProofPath: clearPaymentProofPath
          ? null
          : paymentProofPath ?? this.paymentProofPath,
      paymentProofRejectionReason: clearPaymentProofRejectionReason
          ? null
          : paymentProofRejectionReason ?? this.paymentProofRejectionReason,
      cancellationReason: clearCancellationReason
          ? null
          : cancellationReason ?? this.cancellationReason,
      expiresAt: expiresAt ?? this.expiresAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      paymentProofSubmittedAt: clearPaymentProofSubmittedAt
          ? null
          : paymentProofSubmittedAt ?? this.paymentProofSubmittedAt,
      paymentConfirmedAt: clearPaymentConfirmedAt
          ? null
          : paymentConfirmedAt ?? this.paymentConfirmedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
