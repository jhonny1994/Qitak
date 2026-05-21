import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/providers/discovery_provider.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class TransactionIntentScreen extends ConsumerStatefulWidget {
  const TransactionIntentScreen({
    required this.listingId,
    super.key,
  });

  final String listingId;

  @override
  ConsumerState<TransactionIntentScreen> createState() =>
      _TransactionIntentScreenState();
}

class _TransactionIntentScreenState
    extends ConsumerState<TransactionIntentScreen> {
  final TextEditingController _exchangeOfferController =
      TextEditingController();
  String _dealType = 'buy';

  @override
  void dispose() {
    _exchangeOfferController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authSessionProvider).profile;
    final listing = ref.watch(discoveryListingProvider(widget.listingId));
    final txState = ref.watch(transactionProvider);

    if (profile == null) {
      return Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.authGateTitle,
          message: context.l10n.authGateBody,
        ),
      );
    }

    return listing.when(
      data: (item) {
        if (item == null || item.sellerUserId.isEmpty) {
          return Padding(
            padding: qitakPagePadding,
            child: QitakStateMessage(
              title: context.l10n.transactionListingUnavailableTitle,
              message: context.l10n.transactionListingUnavailableBody,
            ),
          );
        }

        final canExchange = item.exchangeAllowed;
        if (!canExchange && _dealType != 'buy') {
          _dealType = 'buy';
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
                    title: context.l10n.transactionStartTitle,
                    subtitle: context.l10n.transactionStartBody,
                  ),
                  const SizedBox(height: 16),
                  QitakSignalStrip(
                    label: context.l10n.transactionListingContextLabel,
                    value: item.title,
                    status: item.priceLabel,
                  ),
                  const SizedBox(height: 12),
                  QitakSignalStrip(
                    label: context.l10n.transactionSellerContextLabel,
                    value: item.locationLabel,
                    status: item.fitmentLabel,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      QitakChip(
                        label: context.l10n.discoveryDealTypeBuy,
                        selected: _dealType == 'buy',
                        onTap: () => setState(() => _dealType = 'buy'),
                      ),
                      if (canExchange)
                        QitakChip(
                          label: context.l10n.discoveryDealTypeBuyOrExchange,
                          selected: _dealType == 'exchange',
                          onTap: () => setState(() => _dealType = 'exchange'),
                        ),
                    ],
                  ),
                  if (_dealType == 'exchange') ...[
                    const SizedBox(height: 16),
                    QitakFormGroup(
                      label: context.l10n.listingExchangeEnabled,
                      helper: context.l10n.transactionSellerContextLabel,
                      child: TextField(
                        controller: _exchangeOfferController,
                        maxLines: 3,
                      ),
                    ),
                  ],
                  if (txState.lastError != null) ...[
                    const SizedBox(height: 16),
                    QitakStateMessage(
                      title: context.l10n.transactionBlockedTitle,
                      message: context.l10n.transactionOpenIntentExists,
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('transaction-start-button'),
                    onPressed: () async {
                      final ok = await ref
                          .read(transactionProvider.notifier)
                          .createIntent(
                            listingId: widget.listingId,
                            buyerUserId: profile.id,
                            sellerUserId: item.sellerUserId,
                            dealType: _dealType == 'exchange'
                                ? 'exchange'
                                : 'buy',
                            exchangeOffer: _dealType == 'exchange'
                                ? _exchangeOfferController.text.trim()
                                : null,
                          );
                      if (!context.mounted) return;
                      final message = ok
                          ? context.l10n.transactionIntentCreated
                          : context.l10n.transactionOpenIntentExists;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    },
                    child: Text(context.l10n.requestPartCta),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) => Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.errorStateTitle,
          message: context.l10n.discoveryErrorBody,
        ),
      ),
      loading: () => const Padding(
        padding: qitakPagePadding,
        child: QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSkeletonBox(height: 24, width: 180),
              SizedBox(height: 16),
              QitakSkeletonBox(height: 56),
              SizedBox(height: 12),
              QitakSkeletonBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
