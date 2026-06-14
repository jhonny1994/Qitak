import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/providers/discovery_provider.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_action_note_dialog.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_copy.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class SellerOrdersScreen extends ConsumerStatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  ConsumerState<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends ConsumerState<SellerOrdersScreen> {
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
    final userId = ref.watch(authSessionProvider).profile?.id;
    final state = ref.watch(transactionProvider);
    if (userId == null) {
      return Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.authGateTitle,
          message: context.l10n.authGateBody,
        ),
      );
    }

    final orders =
        state.items.where((item) => item.sellerUserId == userId).toList()
          ..sort(_compareSellerOrders);
    final newOrders = orders
        .where((item) => item.state == TransactionState.pendingSellerResponse)
        .toList();
    final proofReview = orders
        .where((item) => item.state == TransactionState.paymentProofSubmitted)
        .toList();
    final active = orders
        .where(
          (item) =>
              item.state == TransactionState.sellerConfirmed ||
              item.state == TransactionState.paymentConfirmed,
        )
        .toList();
    final closed = orders.where((item) => item.state.isClosed).toList();

    return QitakPullToRefresh(
      onRefresh: () => ref
          .read(transactionProvider.notifier)
          .refreshForUser(
            userId,
          ),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: qitakPagePadding,
          children: [
            QitakPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QitakSectionHeader(
                    eyebrow: context.l10n.navOrders,
                    title: context.l10n.sellerOrdersTitle,
                    subtitle: context.l10n.sellerOrdersSubtitle,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      QitakChip(
                        label:
                            '${context.l10n.sellerOrdersNewLabel} ${newOrders.length}',
                      ),
                      QitakChip(
                        label:
                            '${context.l10n.sellerOrdersProofReviewLabel} ${proofReview.length}',
                      ),
                      QitakChip(
                        label:
                            '${context.l10n.sellerOrdersActiveLabel} ${active.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (orders.isEmpty)
              QitakStateMessage(
                title: context.l10n.sellerOrdersTitle,
                message: context.l10n.sellerOrdersEmpty,
              ),
            if (newOrders.isNotEmpty) ...[
              _SellerOrderSectionTitle(
                title: context.l10n.sellerOrdersNewLabel,
                subtitle: context.l10n.sellerOrdersNewSectionHint,
              ),
              for (final order in newOrders)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SellerOrderCard(
                    transaction: order,
                    sellerUserId: userId,
                    summary: context.l10n.sellerOrdersNewSummary,
                    onOpen: () => context.push('/deals/${order.id}'),
                    onAccept: () => _transition(
                      transactionId: order.id,
                      sellerUserId: userId,
                      nextState: TransactionState.sellerConfirmed,
                    ),
                    onDecline: () => _declineOrder(order.id, userId),
                  ),
                ),
            ],
            if (proofReview.isNotEmpty) ...[
              _SellerOrderSectionTitle(
                title: context.l10n.sellerOrdersProofReviewLabel,
                subtitle: context.l10n.sellerOrdersProofReviewSectionHint,
              ),
              for (final order in proofReview)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SellerOrderCard(
                    transaction: order,
                    sellerUserId: userId,
                    summary: context.l10n.transactionNextStepSellerReviewProof,
                    onOpen: () => context.push('/deals/${order.id}'),
                    onAccept: () => _transition(
                      transactionId: order.id,
                      sellerUserId: userId,
                      nextState: TransactionState.paymentConfirmed,
                    ),
                    onDecline: () => _rejectPaymentProof(order.id, userId),
                    acceptLabel: context.l10n.transactionConfirmPaymentAction,
                    declineLabel: context.l10n.transactionRejectProofAction,
                  ),
                ),
            ],
            if (active.isNotEmpty) ...[
              _SellerOrderSectionTitle(
                title: context.l10n.sellerOrdersActiveLabel,
                subtitle: context.l10n.sellerOrdersActiveSectionHint,
              ),
              for (final order in active)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SellerOrderCard(
                    transaction: order,
                    sellerUserId: userId,
                    summary: _activeSummary(context, order),
                    onOpen: () => context.push('/deals/${order.id}'),
                  ),
                ),
            ],
            if (closed.isNotEmpty) ...[
              _SellerOrderSectionTitle(
                title: context.l10n.sellerOrdersClosedLabel,
                subtitle: context.l10n.sellerOrdersClosedSectionHint,
                actionLabel: context.l10n.sellerOrdersViewHistoryAction,
                onAction: () => context.push('/transactions/history'),
              ),
              for (final order in closed.take(5))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SellerOrderCard(
                    transaction: order,
                    sellerUserId: userId,
                    summary: _closedSummary(context, order),
                    onOpen: () => context.push('/deals/${order.id}'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _transition({
    required String transactionId,
    required String sellerUserId,
    required TransactionState nextState,
    String? note,
  }) async {
    final ok = await ref
        .read(transactionProvider.notifier)
        .transition(
          transactionId: transactionId,
          actorUserId: sellerUserId,
          nextState: nextState,
          note: note,
        );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? context.l10n.transactionTransitionSuccess
              : context.l10n.transactionTransitionDenied,
        ),
      ),
    );
  }

  Future<void> _declineOrder(String transactionId, String sellerUserId) async {
    final note = await promptTransactionActionNote(
      context,
      title: context.l10n.transactionDeclineTitle,
      body: context.l10n.transactionDeclineBody,
      confirmLabel: context.l10n.transactionDeclineAction,
    );
    if (note == null || !mounted) {
      return;
    }
    await _transition(
      transactionId: transactionId,
      sellerUserId: sellerUserId,
      nextState: TransactionState.cancelled,
      note: note,
    );
  }

  Future<void> _rejectPaymentProof(
    String transactionId,
    String sellerUserId,
  ) async {
    final reason = await promptTransactionActionNote(
      context,
      title: context.l10n.transactionRejectProofTitle,
      body: context.l10n.transactionRejectProofBody,
      confirmLabel: context.l10n.transactionRejectProofAction,
    );
    if (reason == null) {
      return;
    }
    final ok = await ref
        .read(transactionProvider.notifier)
        .rejectPaymentProof(
          transactionId: transactionId,
          actorUserId: sellerUserId,
          reason: reason,
        );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? context.l10n.transactionPaymentProofRejected
              : context.l10n.transactionTransitionDenied,
        ),
      ),
    );
  }

  String _activeSummary(BuildContext context, TransactionRecord order) {
    switch (order.state) {
      case TransactionState.sellerConfirmed:
        return order.isCashPayment
            ? context.l10n.transactionNextStepSellerCash
            : context.l10n.transactionNextStepSellerWaitForProof;
      case TransactionState.paymentConfirmed:
        return context.l10n.transactionNextStepSellerAwaitReceipt;
      case TransactionState.pendingSellerResponse:
      case TransactionState.paymentProofSubmitted:
      case TransactionState.expired:
      case TransactionState.cancelled:
      case TransactionState.completed:
      case TransactionState.disputeOpened:
      case TransactionState.disputeResolved:
        return context.l10n.transactionNextStepInactive;
    }
  }

  String _closedSummary(BuildContext context, TransactionRecord order) {
    if (order.state == TransactionState.cancelled &&
        order.cancellationReason != null) {
      return order.cancellationReason!;
    }
    return order.state == TransactionState.completed
        ? context.l10n.transactionNextStepCompleted
        : context.l10n.transactionNextStepInactive;
  }

  int _compareSellerOrders(TransactionRecord a, TransactionRecord b) {
    final aPriority = _priorityForState(a.state);
    final bPriority = _priorityForState(b.state);
    if (aPriority != bPriority) {
      return aPriority.compareTo(bPriority);
    }
    final aTime =
        a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bTime =
        b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bTime.compareTo(aTime);
  }

  int _priorityForState(TransactionState state) {
    switch (state) {
      case TransactionState.pendingSellerResponse:
        return 0;
      case TransactionState.paymentProofSubmitted:
        return 1;
      case TransactionState.sellerConfirmed:
      case TransactionState.paymentConfirmed:
        return 2;
      case TransactionState.disputeOpened:
        return 3;
      case TransactionState.completed:
      case TransactionState.cancelled:
      case TransactionState.expired:
      case TransactionState.disputeResolved:
        return 4;
    }
  }
}

class _SellerOrderSectionTitle extends StatelessWidget {
  const _SellerOrderSectionTitle({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _SellerOrderCard extends ConsumerWidget {
  const _SellerOrderCard({
    required this.transaction,
    required this.sellerUserId,
    required this.summary,
    required this.onOpen,
    this.onAccept,
    this.onDecline,
    this.acceptLabel,
    this.declineLabel,
  });

  final TransactionRecord transaction;
  final String sellerUserId;
  final String summary;
  final VoidCallback onOpen;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final String? acceptLabel;
  final String? declineLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(discoveryListingProvider(transaction.listingId));

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onOpen,
      child: QitakPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            listing.when(
              data: (item) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QitakListingThumbnail(imageUrl: item?.preferredImageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item?.localizedTitle(context.l10n) ??
                              context.l10n.transactionsTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          transactionStatusLabel(context, transaction.state),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            QitakChip(
                              label: _urgencyLabel(context, transaction),
                            ),
                            if (transaction.paymentMethod != null)
                              QitakChip(
                                label: _paymentMethodLabel(
                                  context,
                                  transaction,
                                ),
                              ),
                            QitakChip(
                              label: _timestampLabel(context, transaction),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              error: (_, _) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            QitakSurface(
              padding: const EdgeInsets.all(14),
              role: QitakSurfaceRole.section,
              child: Text(summary),
            ),
            if (transaction.paymentProofRejectionReason != null) ...[
              const SizedBox(height: 12),
              QitakSurface(
                padding: const EdgeInsets.all(14),
                role: QitakSurfaceRole.section,
                child: Text(transaction.paymentProofRejectionReason!),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onAccept != null)
                  FilledButton(
                    onPressed: onAccept,
                    child: Text(
                      acceptLabel ?? context.l10n.transactionAccept,
                    ),
                  ),
                if (onDecline != null)
                  OutlinedButton(
                    onPressed: onDecline,
                    child: Text(
                      declineLabel ?? context.l10n.transactionDeclineAction,
                    ),
                  ),
                OutlinedButton(
                  onPressed: onOpen,
                  child: Text(context.l10n.transactionOpenDetailsAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _urgencyLabel(BuildContext context, TransactionRecord transaction) {
    switch (transaction.state) {
      case TransactionState.pendingSellerResponse:
        return context.l10n.sellerOrdersUrgencyNeedsResponse;
      case TransactionState.paymentProofSubmitted:
        return context.l10n.sellerOrdersUrgencyProofWaiting;
      case TransactionState.sellerConfirmed:
        return transaction.isCashPayment
            ? context.l10n.sellerOrdersUrgencyCashHandoff
            : context.l10n.sellerOrdersUrgencyWaitingBuyer;
      case TransactionState.paymentConfirmed:
        return context.l10n.sellerOrdersUrgencyWaitingReceipt;
      case TransactionState.expired:
      case TransactionState.cancelled:
      case TransactionState.completed:
      case TransactionState.disputeOpened:
      case TransactionState.disputeResolved:
        return context.l10n.sellerOrdersUrgencyClosed;
    }
  }

  String _paymentMethodLabel(
    BuildContext context,
    TransactionRecord transaction,
  ) {
    switch (transaction.paymentMethod) {
      case TransactionPaymentMethod.ccp:
        return context.l10n.transactionPaymentMethodCcp;
      case TransactionPaymentMethod.baridiMob:
        return context.l10n.transactionPaymentMethodBaridiMob;
      case TransactionPaymentMethod.cash:
        return context.l10n.transactionPaymentMethodCash;
      case null:
        return context.l10n.transactionPaymentMethodPending;
    }
  }

  String _timestampLabel(BuildContext context, TransactionRecord transaction) {
    final value = transaction.updatedAt ?? transaction.createdAt;
    if (value == null) {
      return context.l10n.sellerOrdersTimestampUnknown;
    }
    final delta = DateTime.now().difference(value);
    if (delta.inMinutes < 1) {
      return context.l10n.sellerOrdersTimestampJustNow;
    }
    if (delta.inHours < 1) {
      return context.l10n.sellerOrdersTimestampMinutes(delta.inMinutes);
    }
    if (delta.inDays < 1) {
      return context.l10n.sellerOrdersTimestampHours(delta.inHours);
    }
    return context.l10n.sellerOrdersTimestampDays(delta.inDays);
  }
}
