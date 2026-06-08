import 'package:flutter/widgets.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';

String transactionStatusLabel(BuildContext context, TransactionState state) {
  switch (state) {
    case TransactionState.disputeOpened:
      return 'Dispute open';
    case TransactionState.disputeResolved:
      return 'Dispute resolved';
    case TransactionState.pendingSellerResponse:
    case TransactionState.sellerConfirmed:
    case TransactionState.paymentProofSubmitted:
    case TransactionState.paymentConfirmed:
    case TransactionState.expired:
    case TransactionState.cancelled:
    case TransactionState.completed:
      return context.l10n.displayTransactionState(state);
  }
}

String? transactionDisputeGuidance(
  BuildContext context,
  TransactionState state,
) {
  switch (state) {
    case TransactionState.disputeOpened:
      return 'A dispute is open and the operations team is reviewing it.';
    case TransactionState.disputeResolved:
      return 'The dispute was resolved. Review the final outcome before taking the next step.';
    case TransactionState.pendingSellerResponse:
    case TransactionState.sellerConfirmed:
    case TransactionState.paymentProofSubmitted:
    case TransactionState.paymentConfirmed:
    case TransactionState.expired:
    case TransactionState.cancelled:
    case TransactionState.completed:
      return null;
  }
}

String transactionTimelineFinalStepBody(
  BuildContext context,
  TransactionState state,
) {
  switch (state) {
    case TransactionState.cancelled:
    case TransactionState.expired:
      return context.l10n.transactionTimelineCancelledBody;
    case TransactionState.disputeOpened:
    case TransactionState.disputeResolved:
      return transactionDisputeGuidance(context, state)!;
    case TransactionState.pendingSellerResponse:
    case TransactionState.sellerConfirmed:
    case TransactionState.paymentProofSubmitted:
    case TransactionState.paymentConfirmed:
    case TransactionState.completed:
      return context.l10n.transactionTimelineCompletedBody;
  }
}
