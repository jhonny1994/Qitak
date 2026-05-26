import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/providers/discovery_provider.dart';
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
                  QitakChip(
                    label: record.buyerUserId == profile.id
                        ? context.l10n.transactionRoleBuyer
                        : context.l10n.transactionRoleSeller,
                  ),
                ],
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
                      onPressed: () => context.go(
                        '/transactions/listing/${record.listingId}/new',
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
                      record.state == TransactionState.completed)
                    OutlinedButton(
                      onPressed: () =>
                          context.go('/deals/${record.id}/dispute'),
                      child: Text(context.l10n.transactionOpenDisputeAction),
                    ),
                  if (record.state == TransactionState.completed)
                    FilledButton(
                      onPressed: () =>
                          context.go('/ratings/transaction/${record.id}'),
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
      isCurrent:
          record.state == TransactionState.intentCreated ||
          record.state == TransactionState.pendingSellerResponse,
    );
    final accepted = QitakTimelineBlock(
      title: context.l10n.transactionTimelineAccepted,
      subtitle: context.l10n.transactionTimelineAcceptedBody,
      isCurrent: record.state == TransactionState.sellerConfirmed,
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
    return [requested, accepted, completed];
  }

  bool _canCancelTransaction(TransactionRecord record, String userId) {
    final isParticipant =
        record.buyerUserId == userId || record.sellerUserId == userId;
    if (!isParticipant) {
      return false;
    }
    return record.state == TransactionState.pendingSellerResponse ||
        record.state == TransactionState.sellerConfirmed;
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

    final ok = await ref
        .read(transactionProvider.notifier)
        .transition(
          transactionId: transactionId,
          actorUserId: userId,
          nextState: TransactionState.cancelled,
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
}
