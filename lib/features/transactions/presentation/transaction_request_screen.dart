import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/l10n/app_error_localization.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/providers/discovery_provider.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class TransactionRequestScreen extends ConsumerStatefulWidget {
  const TransactionRequestScreen({
    required this.listingId,
    super.key,
  });

  final String listingId;

  @override
  ConsumerState<TransactionRequestScreen> createState() =>
      _TransactionRequestScreenState();
}

class _TransactionRequestScreenState
    extends ConsumerState<TransactionRequestScreen> {
  final TextEditingController _exchangeOfferController =
      TextEditingController();
  String _dealType = 'buy';
  AppErrorCode? _requestErrorCode;
  String? _requestErrorMessage;

  @override
  void dispose() {
    _exchangeOfferController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authSessionProvider).profile;
    final listing = ref.watch(discoveryListingProvider(widget.listingId));

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
                    leading: QitakRouteBackButton(
                      fallbackPath: '/listing/${widget.listingId}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  QitakSignalStrip(
                    label: context.l10n.transactionListingContextLabel,
                    value: item.title,
                    status: item.localizedPrice(context.l10n),
                  ),
                  const SizedBox(height: 12),
                  QitakSignalStrip(
                    label: context.l10n.transactionSellerContextLabel,
                    value: item.localizedLocation(context.l10n),
                    status: item.localizedFitment(context.l10n),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      QitakChip(
                        key: const Key('transaction-intent-buy'),
                        label: context.l10n.discoveryDealTypeBuy,
                        selected: _dealType == 'buy',
                        onTap: () => setState(() => _dealType = 'buy'),
                      ),
                      if (canExchange)
                        QitakChip(
                          key: const Key('transaction-intent-exchange'),
                          label: context.l10n.discoveryDealTypeBuyOrExchange,
                          selected: _dealType == 'exchange',
                          onTap: () => setState(() => _dealType = 'exchange'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  QitakSurface(
                    key: const Key('transaction-obligations'),
                    role: QitakSurfaceRole.section,
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      _dealType == 'exchange'
                          ? context.l10n.transactionSellerContextLabel
                          : context.l10n.transactionStartBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
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
                  if (_requestErrorCode != null ||
                      _requestErrorMessage != null) ...[
                    const SizedBox(height: 16),
                    QitakStateMessage(
                      title: context.l10n.transactionBlockedTitle,
                      message: _requestFailureMessage(context),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('transaction-request-button'),
                    onPressed: () async {
                      final ok = await ref
                          .read(transactionProvider.notifier)
                          .createRequest(
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
                      if (ok) {
                        if (_requestErrorCode != null ||
                            _requestErrorMessage != null) {
                          setState(() {
                            _requestErrorCode = null;
                            _requestErrorMessage = null;
                          });
                        }
                      } else {
                        final requestState = ref.read(transactionProvider);
                        setState(() {
                          _requestErrorCode = requestState.lastErrorCode;
                          _requestErrorMessage = requestState.lastError;
                        });
                      }
                      final message = ok
                          ? context.l10n.transactionRequestCreated
                          : _requestFailureMessage(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                      if (!ok) {
                        return;
                      }
                      final created = ref
                          .read(transactionProvider)
                          .items
                          .firstOrNull;
                      if (created == null) {
                        return;
                      }
                      final router = GoRouter.maybeOf(context);
                      if (router != null) {
                        router.go('/deals/${created.id}');
                      }
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

  String _requestFailureMessage(BuildContext context) {
    final code = _requestErrorCode;
    if (code == AppErrorCode.conflict) {
      return context.l10n.transactionOpenRequestExists;
    }
    if (code != null) {
      return context.appErrorMessage(code);
    }
    return _requestErrorMessage ?? context.l10n.transactionTransitionDenied;
  }
}

extension _FirstOrNullTransactionX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
