import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/domain/discovery_filter_taxonomy.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/features/listings/data/seller_listings_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class SellerListingsScreen extends ConsumerStatefulWidget {
  const SellerListingsScreen({super.key});

  @override
  ConsumerState<SellerListingsScreen> createState() =>
      _SellerListingsScreenState();
}

class _SellerListingsScreenState extends ConsumerState<SellerListingsScreen> {
  String _status = 'active';

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final taxonomy = ref.watch(discoveryFilterTaxonomyProvider);
    final taxonomyData = taxonomy.asData?.value;
    final statusContracts = ref.watch(listingStatusContractsProvider);
    final statusCatalog = statusContracts.asData?.value
        .map((entry) => (code: entry.code, labelKey: entry.labelKey))
        .toList(growable: false);
    final options = _statusOptions(context, statusCatalog);
    final effectiveStatus = options.any((option) => option.value == _status)
        ? _status
        : options.first.value;
    final sellerId = session.profile?.id;
    if (sellerId == null) {
      return Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.authGateTitle,
          message: context.l10n.authGateBody,
        ),
      );
    }

    final listings = ref.watch(sellerManagedListingsProvider(sellerId));
    return listings.when(
      data: (items) {
        final filtered = items.where((item) => item.status == _status).toList();
        final counts = <String, int>{
          for (final option in options)
            option.value: items
                .where((item) => item.status == option.value)
                .length,
        };
        return QitakPullToRefresh(
          onRefresh: () async =>
              ref.invalidate(sellerManagedListingsProvider(sellerId)),
          slivers: [
            SliverPadding(
              padding: qitakPagePadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  QitakPanel(
                    child: QitakSectionHeader(
                      eyebrow: context.l10n.sellerListingsEyebrow,
                      title: context.l10n.sellerListingsTitle,
                      subtitle: context.l10n.sellerListingsSubtitle,
                      trailing: FilledButton.tonal(
                        onPressed: () => context.go('/seller/listings/new'),
                        child: Text(context.l10n.createListingCta),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in options)
                        QitakChip(
                          label:
                              '${option.label} (${counts[option.value] ?? 0})',
                          selected: option.value == effectiveStatus,
                          onTap: () => setState(() => _status = option.value),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  QitakPanel(
                    child: Text(
                      _statusBody(context, _status),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (filtered.isEmpty)
                    QitakStateMessage(
                      title: _statusLabel(context, _status),
                      message: _emptyBody(context, _status),
                    )
                  else
                    for (final item in filtered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: QitakPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  QitakListingThumbnail(
                                    imageUrl: item.primaryImageUrl,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          [
                                                item.fitmentSummary,
                                                _locationSummary(
                                                  context,
                                                  item,
                                                  taxonomyData,
                                                ),
                                                _listingMeta(context, item),
                                              ]
                                              .where((part) => part.isNotEmpty)
                                              .join(' | '),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            QitakChip(
                                              label: _statusLabel(
                                                context,
                                                item.status,
                                              ),
                                            ),
                                            QitakChip(
                                              label: _conditionLabel(
                                                context,
                                                item.condition,
                                              ),
                                            ),
                                            if ((item.rejectionReason ?? '')
                                                .isNotEmpty)
                                              QitakChip(
                                                label: _humanizeInternalLabel(
                                                  item.rejectionReason!,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    context.l10n.priceWithDzd(item.price),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: KeyedSubtree(
                                      key: const Key(
                                        'seller-listing-next-action',
                                      ),
                                      child: _buildPrimaryAction(context, item),
                                    ),
                                  ),
                                  if (_hasOverflowActions(item)) ...[
                                    const SizedBox(width: 12),
                                    PopupMenuButton<
                                      _SellerListingOverflowAction
                                    >(
                                      key: const Key(
                                        'seller-listing-more-actions',
                                      ),
                                      onSelected: (value) =>
                                          _handleOverflowAction(
                                            context,
                                            item,
                                            value,
                                          ),
                                      itemBuilder: (context) =>
                                          _buildOverflowItems(context, item),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                ]),
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) => Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.errorStateTitle,
          message: context.l10n.sellerListingsErrorBody,
        ),
      ),
      loading: () => const _SellerListingsLoadingState(),
    );
  }

  Widget _buildPrimaryAction(BuildContext context, SellerManagedListing item) {
    switch (item.status) {
      case 'active':
        return FilledButton(
          onPressed: () => _applyAction(item.id, 'pause'),
          child: Text(context.l10n.sellerListingPauseAction),
        );
      case 'draft':
        return FilledButton(
          onPressed: () => _applyAction(item.id, 'resubmit'),
          child: Text(context.l10n.sellerListingSubmitAction),
        );
      case 'pending_review':
        return FilledButton.tonal(
          onPressed: () => context.push('/seller/listings/${item.id}'),
          child: Text(context.l10n.sellerListingsPreviewAction),
        );
      case 'paused':
        return FilledButton(
          onPressed: () => _applyAction(item.id, 'resume'),
          child: Text(context.l10n.sellerListingResumeAction),
        );
      case 'rejected':
        return FilledButton(
          onPressed: () => _applyAction(item.id, 'resubmit'),
          child: Text(context.l10n.sellerListingResubmitAction),
        );
      default:
        return FilledButton.tonal(
          onPressed: () => context.push('/seller/listings/${item.id}'),
          child: Text(context.l10n.sellerListingsPreviewAction),
        );
    }
  }

  bool _hasOverflowActions(SellerManagedListing item) {
    switch (item.status) {
      case 'pending_review':
      case 'closed':
        return false;
      default:
        return true;
    }
  }

  List<PopupMenuEntry<_SellerListingOverflowAction>> _buildOverflowItems(
    BuildContext context,
    SellerManagedListing item,
  ) {
    switch (item.status) {
      case 'active':
        return [
          PopupMenuItem(
            value: _SellerListingOverflowAction.edit,
            child: Text(context.l10n.sellerListingEditAction),
          ),
          PopupMenuItem(
            value: _SellerListingOverflowAction.close,
            child: Text(context.l10n.sellerListingCloseAction),
          ),
        ];
      case 'draft':
        return [
          PopupMenuItem(
            value: _SellerListingOverflowAction.edit,
            child: Text(context.l10n.sellerListingEditAction),
          ),
          PopupMenuItem(
            value: _SellerListingOverflowAction.deleteDraft,
            child: Text(context.l10n.sellerListingDeleteAction),
          ),
        ];
      case 'paused':
        return [
          PopupMenuItem(
            value: _SellerListingOverflowAction.edit,
            child: Text(context.l10n.sellerListingEditAction),
          ),
          PopupMenuItem(
            value: _SellerListingOverflowAction.close,
            child: Text(context.l10n.sellerListingCloseAction),
          ),
        ];
      case 'rejected':
        return [
          PopupMenuItem(
            value: _SellerListingOverflowAction.edit,
            child: Text(context.l10n.sellerListingEditAction),
          ),
        ];
      default:
        return const [];
    }
  }

  Future<void> _handleOverflowAction(
    BuildContext context,
    SellerManagedListing item,
    _SellerListingOverflowAction action,
  ) async {
    switch (action) {
      case _SellerListingOverflowAction.edit:
        await context.push('/seller/listings/${item.id}/edit');
      case _SellerListingOverflowAction.close:
        await _applyAction(item.id, 'close');
      case _SellerListingOverflowAction.deleteDraft:
        await _confirmDeleteDraft(item.id);
    }
  }

  Future<void> _applyAction(String listingId, String action) async {
    await ref
        .read(sellerListingsRepositoryProvider)
        .applyAction(
          listingId: listingId,
          action: action,
        );
    final sellerId = ref.read(authSessionProvider).profile?.id;
    if (sellerId != null) {
      ref.invalidate(sellerManagedListingsProvider(sellerId));
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.sellerListingActionUpdated)),
    );
  }

  Future<void> _confirmDeleteDraft(String listingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => QitakConfirmationModal(
        title: context.l10n.deleteListingTitle,
        body: context.l10n.deleteListingBody,
        confirmLabel: context.l10n.deleteListingConfirm,
        cancelLabel: context.l10n.cancel,
        isDestructive: true,
      ),
    );
    if (confirmed == true) {
      await _applyAction(listingId, 'delete_draft');
    }
  }
}

extension _SellerManagedListingPresentationX on SellerManagedListing {
  String get fitmentSummary {
    final parts = <String>[
      if (brand != null && brand!.isNotEmpty) brand!,
      if (model != null && model!.isNotEmpty) model!,
      if (year != null) year.toString(),
    ];
    return parts.join(' | ');
  }
}

String _locationSummary(
  BuildContext context,
  SellerManagedListing item,
  DiscoveryFilterTaxonomy? taxonomy,
) {
  if (taxonomy == null) {
    return '';
  }
  final wilaya = taxonomy.wilayas
      .where((candidate) => candidate.id == item.wilayaId)
      .cast<WilayaOption?>()
      .firstOrNull;
  final commune = wilaya?.communes
      .where((candidate) => candidate.id == item.communeId)
      .cast<CommuneOption?>()
      .firstOrNull;
  if (wilaya == null && commune == null) {
    return '';
  }
  final parts = <String>[
    if (commune != null) context.displayCommune(commune),
    if (wilaya != null) context.displayWilaya(wilaya),
  ];
  return parts.join(', ');
}

String _conditionLabel(BuildContext context, String raw) {
  switch (raw) {
    case 'new':
    case 'like_new':
    case 'used':
      return context.l10n.discoveryConditionLabel(raw);
    default:
      return _humanizeInternalLabel(raw);
  }
}

String _humanizeInternalLabel(String raw) {
  final normalized = raw.trim();
  if (normalized.isEmpty) {
    return raw;
  }
  if (!normalized.contains('_') && !normalized.contains('-')) {
    return normalized;
  }
  return normalized
      .split(RegExp('[_-]+'))
      .where((part) => part.isNotEmpty)
      .map(
        (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _listingMeta(BuildContext context, SellerManagedListing item) {
  if (item.status == 'pending_review' && item.submittedAt != null) {
    return context.l10n.sellerListingSubmittedLabel(
      item.submittedAt!.toLocal().toIso8601String().split('T').first,
    );
  }
  if (item.updatedAt != null) {
    return context.l10n.sellerListingUpdatedLabel(
      item.updatedAt!.toLocal().toIso8601String().split('T').first,
    );
  }
  return '';
}

class _SellerListingsLoadingState extends StatelessWidget {
  const _SellerListingsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: qitakPagePadding,
      children: const [
        QitakPanel(child: QitakSkeletonBox(height: 120)),
      ],
    );
  }
}

List<({String value, String label})> _statusOptions(
  BuildContext context,
  List<({String code, String? labelKey})>? statusContracts,
) {
  final contracts =
      statusContracts ??
      const <({String code, String? labelKey})>[
        (code: 'active', labelKey: 'sellerListingsStatusActive'),
        (code: 'draft', labelKey: 'sellerListingsStatusDrafts'),
        (code: 'pending_review', labelKey: 'sellerListingsStatusUnderReview'),
        (code: 'paused', labelKey: 'sellerListingsStatusPaused'),
        (code: 'rejected', labelKey: 'sellerListingsStatusRejected'),
        (code: 'closed', labelKey: 'sellerListingsStatusClosed'),
      ];
  return [
    for (final contract in contracts)
      (
        value: contract.code,
        label: _statusLabel(
          context,
          contract.code,
          contract.labelKey,
        ),
      ),
  ];
}

String _statusLabel(BuildContext context, String status, [String? labelKey]) {
  switch (labelKey) {
    case 'sellerListingsStatusActive':
      return context.l10n.sellerListingsStatusActive;
    case 'sellerListingsStatusDrafts':
      return context.l10n.sellerListingsStatusDrafts;
    case 'sellerListingsStatusUnderReview':
      return context.l10n.sellerListingsStatusUnderReview;
    case 'sellerListingsStatusPaused':
      return context.l10n.sellerListingsStatusPaused;
    case 'sellerListingsStatusRejected':
      return context.l10n.sellerListingsStatusRejected;
    case 'sellerListingsStatusClosed':
      return context.l10n.sellerListingsStatusClosed;
    default:
      break;
  }
  switch (status) {
    case 'active':
      return context.l10n.sellerListingsStatusActive;
    case 'draft':
      return context.l10n.sellerListingsStatusDrafts;
    case 'pending_review':
      return context.l10n.sellerListingsStatusUnderReview;
    case 'paused':
      return context.l10n.sellerListingsStatusPaused;
    case 'rejected':
      return context.l10n.sellerListingsStatusRejected;
    case 'closed':
      return context.l10n.sellerListingsStatusClosed;
    default:
      return status;
  }
}

String _statusBody(BuildContext context, String status) {
  switch (status) {
    case 'draft':
      return context.l10n.sellerListingsDraftStateBody;
    case 'pending_review':
      return context.l10n.sellerListingsUnderReviewStateBody;
    case 'paused':
      return context.l10n.sellerListingsPausedStateBody;
    case 'rejected':
      return context.l10n.sellerListingsRejectedStateBody;
    case 'closed':
      return context.l10n.sellerListingsClosedStateBody;
    case 'active':
    default:
      return context.l10n.sellerListingsActiveStateBody;
  }
}

String _emptyBody(BuildContext context, String status) {
  switch (status) {
    case 'draft':
      return context.l10n.sellerListingsDraftEmptyBody;
    case 'pending_review':
      return context.l10n.sellerListingsUnderReviewEmptyBody;
    case 'paused':
      return context.l10n.sellerListingsPausedEmptyBody;
    case 'rejected':
      return context.l10n.sellerListingsRejectedEmptyBody;
    case 'closed':
      return context.l10n.sellerListingsClosedEmptyBody;
    case 'active':
    default:
      return context.l10n.sellerListingsActiveEmptyBody;
  }
}

extension _IterableFirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

enum _SellerListingOverflowAction { edit, close, deleteDraft }
