import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/providers/discovery_provider.dart';
import 'package:qitak_app/features/ratings/providers/rating_provider.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({required this.transactionId, super.key});

  final String transactionId;

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  int _score = 5;

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
    final ratingState = ref.watch(ratingProvider);
    final transactionState = ref.watch(transactionProvider);
    final theme = Theme.of(context);
    final matches = transactionState.items.where(
      (item) => item.id == widget.transactionId,
    );
    final record = matches.isEmpty ? null : matches.first;
    final listingAsync = record == null
        ? null
        : ref.watch(discoveryListingProvider(record.listingId));
    final listing = switch (listingAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final counterpartyLabel = record == null || profile == null
        ? context.l10n.ratingCounterpartyPending
        : profile.id == record.buyerUserId
        ? context.l10n.transactionRoleSeller
        : context.l10n.transactionRoleBuyer;
    final submitTargetUserId = record == null || profile == null
        ? 'counterparty'
        : profile.id == record.buyerUserId
        ? record.sellerUserId
        : record.buyerUserId;

    return QitakPullToRefresh(
      onRefresh: () async {
        final userId = ref.read(authSessionProvider).profile?.id;
        if (userId != null) {
          await ref.read(transactionProvider.notifier).refreshForUser(userId);
        }
        if (record != null) {
          ref.invalidate(discoveryListingProvider(record.listingId));
        }
      },
      child: ListView(
        padding: qitakPagePadding,
        children: [
          QitakPanel(
            child: Text(
              context.l10n.ratingTitle,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          if (record != null) ...[
            const SizedBox(height: 16),
            QitakPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QitakSectionHeader(
                    eyebrow: context.l10n.ratingContextEyebrow,
                    title: context.l10n.ratingContextTitle,
                    subtitle: context.l10n.ratingContextSubtitle,
                  ),
                  const SizedBox(height: 16),
                  QitakSignalStrip(
                    label: context.l10n.transactionRecordLabel,
                    value: context.l10n.transactionReferenceLabel(record.id),
                    status: context.l10n.displayTransactionState(record.state),
                  ),
                  const SizedBox(height: 16),
                  if (listing != null)
                    QitakListingSurface(
                      title: listing.localizedTitle(context.l10n),
                      price: context.l10n.ratingListingContextValue,
                      subtitle:
                          '${listing.localizedFitment(context.l10n)} | ${listing.localizedLocation(context.l10n)}',
                      ratingLabel: listing.localizedCondition(context.l10n),
                      badges: [
                        QitakChip(
                          label: listing.localizedCategory(context.l10n),
                        ),
                        QitakChip(label: counterpartyLabel),
                      ],
                    )
                  else
                    QitakQueueRow(
                      title: context.l10n.ratingListingContextFallback,
                      meta: context.l10n.ratingListingContextPending,
                      status: counterpartyLabel,
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.ratingScoreLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _score,
                items: const [1, 2, 3, 4, 5]
                    .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                    .toList(),
                onChanged: (value) => setState(() => _score = value ?? 5),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('rating-submit-button'),
                icon: const Icon(Icons.star_rounded),
                onPressed: () async {
                  final from = profile?.id ?? 'anonymous';
                  final ok = await ref
                      .read(ratingProvider.notifier)
                      .submit(
                        transactionId: widget.transactionId,
                        fromUserId: from,
                        toUserId: submitTargetUserId,
                        score: _score,
                      );
                  if (!context.mounted) return;
                  final current = ref.read(ratingProvider);
                  final msg = ok
                      ? context.l10n.ratingSubmitted
                      : current.lastError == 'ineligible'
                      ? context.l10n.ratingRequiresCompletedTransaction
                      : context.l10n.ratingAlreadySubmitted;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(msg)));
                },
                label: Text(context.l10n.ratingSubmit),
              ),
              if (ratingState.lastError == 'duplicate') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    context.l10n.ratingAlreadySubmitted,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
