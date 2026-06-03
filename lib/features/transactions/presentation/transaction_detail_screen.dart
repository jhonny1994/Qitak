import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/providers/discovery_provider.dart';
import 'package:qitak_app/features/listings/providers/listing_media_picker_provider.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({required this.transactionId, super.key});

  final String transactionId;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authSessionProvider).profile?.id;
      if (userId != null) {
        unawaited(
          ref.read(transactionProvider.notifier).refreshForUser(userId),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authSessionProvider).profile;
    final state = ref.watch(transactionProvider);
    final directRecord = ref.watch(
      transactionDetailProvider(widget.transactionId),
    );
    final paymentMethodOptions = ref.watch(buyerPaymentMethodPolicyProvider);
    if (profile == null) {
      return Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.authGateTitle,
          message: context.l10n.authGateBody,
        ),
      );
    }

    final matches = state.items.where(
      (item) => item.id == widget.transactionId,
    );
    final record = matches.isEmpty
        ? directRecord.maybeWhen(data: (value) => value, orElse: () => null)
        : matches.first;
    final listingAsync = record == null
        ? null
        : ref.watch(discoveryListingProvider(record.listingId));
    final listing = switch (listingAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final paymentOptions =
        paymentMethodOptions.asData?.value ?? const <AppPolicyOption>[];
    if (record == null) {
      return Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.transactionDetailMissingTitle,
          message: context.l10n.transactionDetailMissingBody,
          action: FilledButton.tonal(
            onPressed: () => context.go('/deals'),
            child: Text(context.l10n.transactionsTitle),
          ),
        ),
      );
    }

    return ListView(
      padding: qitakPagePadding,
      children: [
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSectionHeader(
                eyebrow: context.l10n.transactionsTitle,
                title: context.l10n.transactionDetailTitle,
                subtitle: context.l10n.transactionDetailSubtitle,
                leading: const QitakRouteBackButton(fallbackPath: '/deals'),
              ),
              const SizedBox(height: 16),
              QitakSignalStrip(
                label: context.l10n.transactionRecordLabel,
                value: context.l10n.transactionReferenceLabel(record.id),
                status: context.l10n.displayTransactionState(record.state),
              ),
              const SizedBox(height: 16),
              QitakListingSurface(
                title:
                    listing?.localizedTitle(context.l10n) ??
                    '${context.l10n.transactionListingContextLabel} ${context.l10n.transactionReferenceLabel(record.listingId)}',
                price: record.state == TransactionState.completed
                    ? context.l10n.transactionDecisionComplete
                    : context.l10n.transactionDecisionActive,
                subtitle: listing == null
                    ? context.l10n.transactionDetailListingContext
                    : '${listing.localizedFitment(context.l10n)} | ${listing.localizedLocation(context.l10n)}',
                badges: [
                  QitakChip(
                    label:
                        listing?.localizedCategory(context.l10n) ??
                        context.l10n.displayTransactionState(record.state),
                  ),
                  QitakChip(
                    label: record.dealType == 'exchange'
                        ? context.l10n.discoveryDealTypeBuyOrExchange
                        : context.l10n.discoveryDealTypeBuy,
                  ),
                  if (record.paymentMethod != null)
                    QitakChip(
                      label: _paymentMethodLabel(
                        context,
                        record.paymentMethod!,
                      ),
                    ),
                  QitakChip(
                    label: record.buyerUserId == profile.id
                        ? context.l10n.transactionRoleBuyer
                        : context.l10n.transactionRoleSeller,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              QitakPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.transactionPaymentTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QitakDetailRow(
                      label: context.l10n.transactionPaymentMethodLabel,
                      value: record.paymentMethod == null
                          ? context.l10n.transactionPaymentMethodPending
                          : _paymentMethodLabel(context, record.paymentMethod!),
                    ),
                    QitakDetailRow(
                      label: context.l10n.transactionPaymentProofLabel,
                      value: record.paymentProofPath == null
                          ? context.l10n.transactionPaymentProofPending
                          : context.l10n.transactionPaymentProofUploaded,
                    ),
                    if (record.state == TransactionState.sellerConfirmed &&
                        profile.id == record.buyerUserId) ...[
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.transactionPaymentMethodHelper,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final option in paymentOptions)
                            QitakChip(
                              label: _paymentMethodPolicyLabel(
                                context,
                                option.labelKey,
                              ),
                              selected:
                                  record.paymentMethod?.value == option.code,
                              onTap: () => _selectPaymentMethod(
                                transactionId: record.id,
                                actorUserId: profile.id,
                                code: option.code,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (record.state == TransactionState.sellerConfirmed &&
                        profile.id == record.buyerUserId &&
                        record.requiresPaymentProof) ...[
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: () => _submitPaymentProof(
                          transactionId: record.id,
                          actorUserId: profile.id,
                        ),
                        child: Text(context.l10n.transactionUploadProofAction),
                      ),
                    ],
                    if (record.state ==
                            TransactionState.paymentProofSubmitted &&
                        profile.id == record.sellerUserId) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton(
                            onPressed: () => _transition(
                              userId: profile.id,
                              transactionId: record.id,
                              nextState: TransactionState.paymentConfirmed,
                            ),
                            child: Text(
                              context.l10n.transactionConfirmPaymentAction,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => _rejectPaymentProof(
                              userId: profile.id,
                              transactionId: record.id,
                            ),
                            child: Text(
                              context.l10n.transactionRejectProofAction,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (record.state == TransactionState.paymentConfirmed &&
                        profile.id == record.buyerUserId) ...[
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => _transition(
                          userId: profile.id,
                          transactionId: record.id,
                          nextState: TransactionState.completed,
                        ),
                        child: Text(
                          context.l10n.transactionConfirmReceiptAction,
                        ),
                      ),
                    ],
                    if (record.state == TransactionState.sellerConfirmed &&
                        record.isCashPayment &&
                        profile.id == record.sellerUserId) ...[
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => _transition(
                          userId: profile.id,
                          transactionId: record.id,
                          nextState: TransactionState.completed,
                        ),
                        child: Text(context.l10n.transactionConfirmCashAction),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              QitakPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.transactionNextStepTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QitakSignalStrip(
                      label: profile.id == record.buyerUserId
                          ? context.l10n.transactionRoleBuyer
                          : context.l10n.transactionRoleSeller,
                      value: _nextStepMessage(context, record, profile.id),
                      status: context.l10n.displayTransactionState(record.state),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.transactionTimelineTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ..._buildTimeline(context, record),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_canCancelTransaction(record, profile.id))
                    OutlinedButton(
                      onPressed: () => _confirmCancelTransaction(
                        userId: profile.id,
                        transactionId: record.id,
                      ),
                      child: Text(context.l10n.transactionCancel),
                    ),
                  if (record.state == TransactionState.expired &&
                      record.buyerUserId == profile.id)
                    FilledButton(
                      onPressed: () => context.push(
                        '/transactions/listing/${record.listingId}/request',
                      ),
                      child: Text(context.l10n.retryAction),
                    ),
                  FilledButton.tonal(
                    onPressed: () async {
                      final threadId = await ref
                          .read(messagingRepositoryProvider)
                          .ensureThread(
                            listingId: record.listingId,
                            buyerUserId: record.buyerUserId,
                            sellerUserId: record.sellerUserId,
                          );
                      if (!context.mounted) {
                        return;
                      }
                      context.go('/messages/thread/$threadId');
                    },
                    child: Text(context.l10n.transactionMessageAction),
                  ),
                  if (record.state == TransactionState.sellerConfirmed ||
                      record.state == TransactionState.paymentProofSubmitted ||
                      record.state == TransactionState.paymentConfirmed ||
                      record.state == TransactionState.completed)
                    OutlinedButton(
                      onPressed: () =>
                          context.push('/deals/${record.id}/dispute'),
                      child: Text(context.l10n.transactionOpenDisputeAction),
                    ),
                  if (record.state == TransactionState.completed)
                    FilledButton(
                      onPressed: () =>
                          context.push('/ratings/transaction/${record.id}'),
                      child: Text(context.l10n.transactionRateAction),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTimeline(BuildContext context, TransactionRecord record) {
    final requested = QitakTimelineBlock(
      title: context.l10n.transactionTimelineRequested,
      subtitle: context.l10n.transactionTimelineRequestedBody,
      isCurrent: record.state == TransactionState.pendingSellerResponse,
    );
    final accepted = QitakTimelineBlock(
      title: context.l10n.transactionTimelineAccepted,
      subtitle: context.l10n.transactionTimelineAcceptedBody,
      isCurrent: record.state == TransactionState.sellerConfirmed,
    );
    final payment = QitakTimelineBlock(
      title: context.l10n.transactionTimelinePayment,
      subtitle: record.state == TransactionState.paymentProofSubmitted
          ? context.l10n.transactionTimelinePaymentSubmittedBody
          : record.state == TransactionState.paymentConfirmed
          ? context.l10n.transactionTimelinePaymentConfirmedBody
          : context.l10n.transactionTimelinePaymentPendingBody,
      isCurrent:
          record.state == TransactionState.paymentProofSubmitted ||
          record.state == TransactionState.paymentConfirmed,
    );
    final completed = QitakTimelineBlock(
      title: context.l10n.transactionTimelineCompleted,
      subtitle:
          record.state == TransactionState.cancelled ||
              record.state == TransactionState.expired
          ? context.l10n.transactionTimelineCancelledBody
          : record.state == TransactionState.disputeOpened ||
                record.state == TransactionState.disputeResolved
          ? context.l10n.transactionTimelineRejectedBody
          : context.l10n.transactionTimelineCompletedBody,
      isCurrent: record.state == TransactionState.completed,
    );
    return [requested, accepted, payment, completed];
  }

  bool _canCancelTransaction(TransactionRecord record, String userId) {
    final isParticipant =
        record.buyerUserId == userId || record.sellerUserId == userId;
    if (!isParticipant) {
      return false;
    }
    return record.state == TransactionState.pendingSellerResponse ||
        record.state == TransactionState.sellerConfirmed ||
        record.state == TransactionState.paymentProofSubmitted;
  }

  Future<void> _transition({
    required String userId,
    required String transactionId,
    required TransactionState nextState,
  }) async {
    final ok = await ref
        .read(transactionProvider.notifier)
        .transition(
          transactionId: transactionId,
          actorUserId: userId,
          nextState: nextState,
        );
    if (!mounted) {
      return;
    }
    final text = ok
        ? context.l10n.transactionTransitionSuccess
        : context.l10n.transactionTransitionDenied;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _confirmCancelTransaction({
    required String userId,
    required String transactionId,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => QitakConfirmationModal(
        title: context.l10n.cancelTransactionTitle,
        body: context.l10n.cancelTransactionBody,
        confirmLabel: context.l10n.cancelTransactionConfirm,
        cancelLabel: context.l10n.cancel,
        isDestructive: true,
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    await _transition(
      userId: userId,
      transactionId: transactionId,
      nextState: TransactionState.cancelled,
    );
  }

  Future<void> _selectPaymentMethod({
    required String transactionId,
    required String actorUserId,
    required String code,
  }) async {
    final method = TransactionPaymentMethodX.fromValue(code);
    if (method == null) {
      return;
    }
    final ok = await ref
        .read(transactionProvider.notifier)
        .selectPaymentMethod(
          transactionId: transactionId,
          actorUserId: actorUserId,
          paymentMethod: method,
        );
    if (!mounted) {
      return;
    }
    final text = ok
        ? context.l10n.transactionPaymentMethodSaved
        : context.l10n.transactionTransitionDenied;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submitPaymentProof({
    required String transactionId,
    required String actorUserId,
  }) async {
    final picker = ref.read(listingMediaPickerProvider);
    final picked = await picker.pickImages(maxImages: 1);
    if (picked.isEmpty) {
      return;
    }
    final ok = await ref
        .read(transactionProvider.notifier)
        .submitPaymentProof(
          transactionId: transactionId,
          actorUserId: actorUserId,
          proof: picked.first,
        );
    if (!mounted) {
      return;
    }
    final text = ok
        ? context.l10n.transactionPaymentProofSubmitted
        : context.l10n.transactionTransitionDenied;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _rejectPaymentProof({
    required String userId,
    required String transactionId,
  }) async {
    final ok = await ref
        .read(transactionProvider.notifier)
        .rejectPaymentProof(
          transactionId: transactionId,
          actorUserId: userId,
        );
    if (!mounted) {
      return;
    }
    final text = ok
        ? context.l10n.transactionPaymentProofRejected
        : context.l10n.transactionTransitionDenied;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _paymentMethodLabel(
    BuildContext context,
    TransactionPaymentMethod method,
  ) {
    switch (method) {
      case TransactionPaymentMethod.ccp:
        return context.l10n.transactionPaymentMethodCcp;
      case TransactionPaymentMethod.baridiMob:
        return context.l10n.transactionPaymentMethodBaridiMob;
      case TransactionPaymentMethod.cash:
        return context.l10n.transactionPaymentMethodCash;
    }
  }

  String _paymentMethodPolicyLabel(BuildContext context, String labelKey) {
    switch (labelKey) {
      case 'transactionPaymentMethodCcp':
        return context.l10n.transactionPaymentMethodCcp;
      case 'transactionPaymentMethodBaridiMob':
        return context.l10n.transactionPaymentMethodBaridiMob;
      case 'transactionPaymentMethodCash':
        return context.l10n.transactionPaymentMethodCash;
      default:
        return labelKey;
    }
  }

  String _nextStepMessage(
    BuildContext context,
    TransactionRecord record,
    String userId,
  ) {
    final isBuyer = userId == record.buyerUserId;
    switch (record.state) {
      case TransactionState.pendingSellerResponse:
        return isBuyer
            ? context.l10n.transactionNextStepPendingBuyer
            : context.l10n.transactionNextStepPendingSeller;
      case TransactionState.sellerConfirmed:
        if (record.paymentMethod == null && isBuyer) {
          return context.l10n.transactionNextStepBuyerSelectMethod;
        }
        if (record.isCashPayment) {
          return isBuyer
              ? context.l10n.transactionNextStepBuyerCash
              : context.l10n.transactionNextStepSellerCash;
        }
        return isBuyer
            ? context.l10n.transactionNextStepBuyerUploadProof
            : context.l10n.transactionNextStepSellerWaitForProof;
      case TransactionState.paymentProofSubmitted:
        return isBuyer
            ? context.l10n.transactionNextStepBuyerAwaitReview
            : context.l10n.transactionNextStepSellerReviewProof;
      case TransactionState.paymentConfirmed:
        return isBuyer
            ? context.l10n.transactionNextStepBuyerConfirmReceipt
            : context.l10n.transactionNextStepSellerAwaitReceipt;
      case TransactionState.completed:
        return context.l10n.transactionNextStepCompleted;
      case TransactionState.cancelled:
      case TransactionState.expired:
      case TransactionState.disputeOpened:
      case TransactionState.disputeResolved:
        return context.l10n.transactionNextStepInactive;
    }
  }
}
