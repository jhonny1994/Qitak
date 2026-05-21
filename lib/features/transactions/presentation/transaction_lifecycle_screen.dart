import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class TransactionLifecycleScreen extends ConsumerStatefulWidget {
  const TransactionLifecycleScreen({super.key});

  @override
  ConsumerState<TransactionLifecycleScreen> createState() =>
      _TransactionLifecycleScreenState();
}

class _TransactionLifecycleScreenState
    extends ConsumerState<TransactionLifecycleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authSessionProvider).profile?.id;
      if (user != null) {
        unawaited(ref.read(transactionProvider.notifier).refreshForUser(user));
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
    return QitakPullToRefresh(
      onRefresh: () async {
        await ref.read(transactionProvider.notifier).refreshForUser(userId);
      },
      child: SafeArea(
        top: false,
        child: ListView(
          padding: qitakPagePadding,
          children: [
            QitakPanel(
              child: QitakSectionHeader(
                eyebrow: context.l10n.transactionsTitle,
                title: context.l10n.transactionsTitle,
                subtitle: context.l10n.transactionLifecycleSubtitle,
              ),
            ),
            const SizedBox(height: 12),
            if (state.items.isEmpty)
              QitakStateMessage(
                title: context.l10n.transactionsTitle,
                message: context.l10n.transactionsEmpty,
              ),
            for (final tx in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QitakSignalStrip(
                        label: context.l10n.transactionRecordLabel,
                        value: context.l10n.transactionReferenceLabel(tx.id),
                        status: context.l10n.displayTransactionState(tx.state),
                      ),
                      ...switch (_buildActions(context, tx, userId)) {
                        [] => const <Widget>[],
                        final actions => <Widget>[
                          const SizedBox(height: 12),
                          Wrap(spacing: 8, runSpacing: 8, children: actions),
                        ],
                      },
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _transition({
    required String transactionId,
    required String userId,
    required TransactionState nextState,
  }) async {
    final ok = await ref
        .read(transactionProvider.notifier)
        .transition(
          transactionId: transactionId,
          actorUserId: userId,
          nextState: nextState,
        );
    if (!mounted) return;
    final text = ok
        ? context.l10n.transactionTransitionSuccess
        : context.l10n.transactionTransitionDenied;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> _buildActions(
    BuildContext context,
    TransactionRecord tx,
    String userId,
  ) {
    switch (tx.state) {
      case TransactionState.intentCreated:
      case TransactionState.pendingSellerResponse:
        return [
          if (userId == tx.sellerUserId)
            OutlinedButton(
              onPressed: () => _transition(
                transactionId: tx.id,
                userId: userId,
                nextState: TransactionState.sellerConfirmed,
              ),
              child: Text(context.l10n.transactionAccept),
            ),
          if (userId == tx.sellerUserId)
            OutlinedButton(
              onPressed: () => _transition(
                transactionId: tx.id,
                userId: userId,
                nextState: TransactionState.expired,
              ),
              child: Text(context.l10n.transactionExpire),
            ),
          if (userId == tx.buyerUserId)
            OutlinedButton(
              onPressed: () => _confirmCancelTransaction(
                transactionId: tx.id,
                userId: userId,
              ),
              child: Text(context.l10n.transactionCancel),
            ),
        ];
      case TransactionState.sellerConfirmed:
        return [
          OutlinedButton(
            onPressed: () => _transition(
              transactionId: tx.id,
              userId: userId,
              nextState: TransactionState.completed,
            ),
            child: Text(context.l10n.transactionComplete),
          ),
          OutlinedButton(
            onPressed: () => _confirmCancelTransaction(
              transactionId: tx.id,
              userId: userId,
            ),
            child: Text(context.l10n.transactionCancel),
          ),
        ];
      case TransactionState.disputeOpened:
        return const <Widget>[];
      case TransactionState.expired:
      case TransactionState.completed:
      case TransactionState.cancelled:
      case TransactionState.disputeResolved:
        return const <Widget>[];
    }
  }

  Future<void> _confirmCancelTransaction({
    required String transactionId,
    required String userId,
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
    if (confirmed == true) {
      await _transition(
        transactionId: transactionId,
        userId: userId,
        nextState: TransactionState.cancelled,
      );
    }
  }
}
