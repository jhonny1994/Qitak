import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/config/app_runtime_config.dart';
import 'package:qitak_app/core/connectivity/connectivity_service.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';
import 'package:qitak_app/features/auth/presentation/protected_action_gate.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/discovery/providers/discovery_provider.dart';
import 'package:qitak_app/features/listings/data/listing_repository.dart';
import 'package:qitak_app/features/listings/data/seller_listings_repository.dart';
import 'package:qitak_app/features/listings/presentation/report_listing_sheet.dart';
import 'package:qitak_app/features/listings/providers/saved_listings_provider.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';
import 'package:share_plus/share_plus.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({
    required this.listingId,
    this.sellerOwnedPreview = false,
    super.key,
  });

  final String listingId;
  final bool sellerOwnedPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final savedIds = ref
        .watch(savedListingIdsProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => const <String>{},
        );
    final managedListing = sellerOwnedPreview
        ? ref
              .watch(sellerManagedListingProvider(listingId))
              .maybeWhen(
                data: (value) => value,
                orElse: () => null,
              )
        : null;
    final listing = ref.watch(discoveryListingProvider(listingId));

    return QitakPullToRefresh(
      onRefresh: () => ref.refresh(discoveryListingProvider(listingId).future),
      slivers: listing.when<List<Widget>>(
        data: (item) {
          if (item == null) {
            return _buildUnavailableState(context);
          }

          final isOwner = session.profile?.id == item.sellerUserId;
          final isBuyer = session.profile?.role == AccountRole.buyer;
          final canReportListing =
              session.isAuthenticated && isBuyer && !isOwner;
          final hasReported =
              canReportListing &&
              (ref.watch(hasReportedListingProvider(item.id)).asData?.value ??
                  false);
          if (sellerOwnedPreview && !isOwner) {
            return _buildUnavailableState(context);
          }

          final isSaved = savedIds.contains(item.id);
          final detail = _ListingDetailViewData.fromListing(context, item);
          final sellerStatus = _sellerListingStatusLabel(
            context,
            managedListing?.status,
          );

          return [
            QitakCollapsingSliverAppBar(
              eyebrow: sellerOwnedPreview
                  ? context.l10n.sellerOwnedListingEyebrow
                  : context.l10n.listingDetailEyebrow,
              title: item.localizedTitle(context.l10n),
              subtitle: detail.displayLocation,
              expandedHeight: 140,
              actions: sellerOwnedPreview
                  ? const <Widget>[]
                  : [
                      IconButton.filledTonal(
                        onPressed: () => _showShareSheet(context, item),
                        icon: const Icon(Icons.ios_share_rounded),
                        tooltip: context.l10n.listingShareAction,
                      ),
                      PopupMenuButton<_ListingOverflowAction>(
                        tooltip: context.l10n.reportListingAction,
                        enabled: session.isAuthenticated && isBuyer && !isOwner,
                        onSelected: (value) async {
                          switch (value) {
                            case _ListingOverflowAction.report:
                              await showReportListingSheet(
                                context,
                                listingId: item.id,
                              );
                              ref.invalidate(
                                hasReportedListingProvider(item.id),
                              );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<_ListingOverflowAction>(
                            enabled: !hasReported,
                            value: _ListingOverflowAction.report,
                            child: Text(
                              hasReported
                                  ? context.l10n.reportListingAlreadyReported
                                  : context.l10n.reportListingAction,
                            ),
                          ),
                        ],
                      ),
                      IconButton.filledTonal(
                        onPressed: session.isAuthenticated
                            ? () {
                                final isOnline =
                                    ref.read(isOnlineProvider).asData?.value ??
                                    true;
                                if (!isOnline) {
                                  ScaffoldMessenger.of(context)
                                    ..clearSnackBars()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.l10n.offlineBannerLabel,
                                        ),
                                      ),
                                    );
                                  return;
                                }
                                unawaited(
                                  ref
                                      .read(savedListingIdsProvider.notifier)
                                      .toggle(item.id),
                                );
                              }
                            : () => showProtectedActionGate(
                                context,
                                ref,
                                intent: PostAuthRedirectIntent.action(
                                  'save-listing',
                                  arguments: <String, String>{
                                    'route': '/listing/${item.id}',
                                    'listingId': item.id,
                                  },
                                ),
                              ),
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                        ),
                        tooltip: context.l10n.discoverySave,
                      ),
                      const SizedBox(width: 8),
                    ],
            ),
            SliverPadding(
              padding: qitakPagePadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  QitakListingGallery(
                    heroTag: qitakListingHeroTag(item.id),
                    height: 196,
                    primaryImageUrl: item.preferredImageUrl,
                    imageUrls: item.galleryImageUrls,
                  ),
                  const SizedBox(height: 18),
                  QitakPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QitakSignalStrip(
                          label: context.l10n.listingPriceLabel,
                          value: item.priceLabel,
                          status: sellerOwnedPreview
                              ? sellerStatus
                              : detail.condition,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.localizedTitle(context.l10n),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          detail.vehicleLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          detail.displayLocation,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  QitakPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sellerOwnedPreview
                              ? context.l10n.sellerOwnedListingEyebrow
                              : context.l10n.listingPartDetailsTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 16),
                        if (sellerOwnedPreview) ...[
                          QitakDetailRow(
                            label: context.l10n.listingStatusLabel,
                            value: sellerStatus,
                          ),
                          QitakDetailRow(
                            label: context.l10n.categoryLabel,
                            value: detail.category,
                          ),
                          QitakDetailRow(
                            label: context.l10n.discoveryConditionFieldLabel,
                            value: detail.condition,
                          ),
                          QitakDetailRow(
                            label: context.l10n.quantityLabel,
                            value: detail.quantity.toString(),
                          ),
                        ] else ...[
                          QitakDetailRow(
                            label: context.l10n.categoryLabel,
                            value: detail.category,
                          ),
                          QitakDetailRow(
                            label: context.l10n.brandLabel,
                            value: detail.brand,
                          ),
                          QitakDetailRow(
                            label: context.l10n.modelLabel,
                            value: detail.model,
                          ),
                          QitakDetailRow(
                            label: context.l10n.yearLabel,
                            value: detail.year,
                          ),
                          QitakDetailRow(
                            label: context.l10n.discoveryConditionFieldLabel,
                            value: detail.condition,
                          ),
                          QitakDetailRow(
                            label: context.l10n.quantityLabel,
                            value: detail.quantity.toString(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!sellerOwnedPreview) ...[
                    const SizedBox(height: 18),
                    QitakPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.listingDescriptionTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    QitakPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.listingSellerSectionTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 16),
                          QitakDetailRow(
                            label: context.l10n.listingSellerSectionTitle,
                            value: detail.sellerName,
                          ),
                          QitakDetailRow(
                            label: context.l10n.listingLocationLabel,
                            value: detail.displayLocation,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  QitakPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sellerOwnedPreview
                              ? context.l10n.sellerOwnedListingEyebrow
                              : context.l10n.listingActionDockTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (sellerOwnedPreview || isOwner)
                              FilledButton(
                                onPressed: () => context.go(
                                  '/seller/listings/${item.id}/edit',
                                ),
                                child: Text(context.l10n.listingEditAction),
                              )
                            else ...[
                              OutlinedButton(
                                onPressed: () => _handleMessageSeller(
                                  context,
                                  ref,
                                  item,
                                ),
                                child: Text(
                                  context.l10n.discoveryMessageSeller,
                                ),
                              ),
                              FilledButton(
                                onPressed: () => _handleProtectedNav(
                                  context,
                                  ref,
                                  '/transactions/listing/${item.id}/new',
                                  PostAuthRedirectIntent.action(
                                    'start-transaction',
                                    arguments: <String, String>{
                                      'route':
                                          '/transactions/listing/${item.id}/new',
                                      'listingId': item.id,
                                    },
                                  ),
                                ),
                                child: Text(
                                  context.l10n.listingRequestToBuyAction,
                                ),
                              ),
                              if (item.exchangeAllowed)
                                FilledButton.tonal(
                                  onPressed: () => _handleProtectedNav(
                                    context,
                                    ref,
                                    '/transactions/listing/${item.id}/new',
                                    PostAuthRedirectIntent.action(
                                      'start-exchange',
                                      arguments: <String, String>{
                                        'route':
                                            '/transactions/listing/${item.id}/new',
                                        'listingId': item.id,
                                      },
                                    ),
                                  ),
                                  child: Text(
                                    context.l10n.discoveryDealTypeBuyOrExchange,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ];
        },
        error: (error, stackTrace) => [
          QitakCollapsingSliverAppBar(
            eyebrow: sellerOwnedPreview
                ? context.l10n.sellerOwnedListingEyebrow
                : context.l10n.listingDetailEyebrow,
            title: context.l10n.errorStateTitle,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: qitakPagePadding,
              child: QitakStateMessage(
                title: context.l10n.errorStateTitle,
                message: context.l10n.listingUnavailableBody,
              ),
            ),
          ),
        ],
        loading: () => const [
          SliverToBoxAdapter(
            child: Padding(
              padding: qitakPagePadding,
              child: _ListingDetailLoadingState(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUnavailableState(BuildContext context) {
    return [
      QitakCollapsingSliverAppBar(
        eyebrow: sellerOwnedPreview
            ? context.l10n.sellerOwnedListingEyebrow
            : context.l10n.listingDetailEyebrow,
        title: context.l10n.listingUnavailableTitle,
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: qitakPagePadding,
          child: QitakStateMessage(
            title: context.l10n.listingUnavailableTitle,
            message: context.l10n.listingUnavailableBody,
          ),
        ),
      ),
    ];
  }

  Future<void> _handleProtectedNav(
    BuildContext context,
    WidgetRef ref,
    String route,
    PostAuthRedirectIntent intent,
  ) async {
    if (!ref.read(authSessionProvider).isAuthenticated) {
      await showProtectedActionGate(context, ref, intent: intent);
      return;
    }
    if (context.mounted) {
      context.go(route);
    }
  }

  Future<void> _handleMessageSeller(
    BuildContext context,
    WidgetRef ref,
    MarketplaceListing item,
  ) async {
    final session = ref.read(authSessionProvider);
    final buyerId = session.profile?.id;
    if (!session.isAuthenticated || buyerId == null) {
      await showProtectedActionGate(
        context,
        ref,
        intent: PostAuthRedirectIntent.action(
          'message-seller',
          arguments: <String, String>{
            'route': '/listing/${item.id}',
            'listingId': item.id,
          },
        ),
      );
      return;
    }
    final threadId = await ref
        .read(messagingRepositoryProvider)
        .ensureThread(
          listingId: item.id,
          buyerUserId: buyerId,
          sellerUserId: item.sellerUserId,
        );
    if (!context.mounted) {
      return;
    }
    context.go('/messages/thread/$threadId');
  }

  Future<void> _showShareSheet(
    BuildContext context,
    MarketplaceListing item,
  ) async {
    final baseUrl = AppRuntimeConfig.deepLinkBaseUrl.trim();
    final link = baseUrl.isEmpty
        ? '/listings/${item.id}'
        : '$baseUrl/listings/${item.id}';
    await SharePlus.instance.share(
      ShareParams(
        text: context.l10n.shareListingText(
          item.localizedTitle(context.l10n),
          link,
        ),
        subject: item.localizedTitle(context.l10n),
      ),
    );
  }
}

// ignore: specify_nonobvious_property_types, Riverpod family typedefs vary in this repo setup.
final hasReportedListingProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, listingId) {
      return ref
          .read(listingRepositoryProvider)
          .hasUserReportedListing(listingId);
    });

enum _ListingOverflowAction { report }

class _ListingDetailViewData {
  const _ListingDetailViewData({
    required this.brand,
    required this.model,
    required this.year,
    required this.category,
    required this.condition,
    required this.displayLocation,
    required this.vehicleLabel,
    required this.quantity,
    required this.sellerName,
  });

  factory _ListingDetailViewData.fromListing(
    BuildContext context,
    MarketplaceListing item,
  ) {
    final fitmentParts = item.fitmentLabel
        .split('|')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    final vehicleLabel = fitmentParts.isNotEmpty ? fitmentParts.first : '-';
    final fallbackBrand = vehicleLabel.split(' ').firstOrNull ?? '-';
    final fallbackModel = vehicleLabel.startsWith(fallbackBrand)
        ? vehicleLabel.substring(fallbackBrand.length).trim()
        : '';
    final locationParts = item.locationLabel
        .split('|')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    final displayLocation = locationParts.length >= 2
        ? '${locationParts[1]} > ${locationParts[0]}'
        : item.locationLabel;

    return _ListingDetailViewData(
      brand: item.brand ?? fallbackBrand,
      model: item.model ?? (fallbackModel.isEmpty ? '-' : fallbackModel),
      year:
          (item.year ?? int.tryParse(fitmentParts.elementAtOrNull(1) ?? ''))
              ?.toString() ??
          '-',
      category: item.localizedCategory(context.l10n),
      condition: item.localizedCondition(context.l10n),
      displayLocation: displayLocation,
      vehicleLabel: vehicleLabel,
      quantity: item.quantity,
      sellerName: item.sellerName.isEmpty
          ? item.localizedSellerLabel(context.l10n)
          : item.sellerName,
    );
  }

  final String brand;
  final String model;
  final String year;
  final String category;
  final String condition;
  final String displayLocation;
  final String vehicleLabel;
  final int quantity;
  final String sellerName;
}

extension _FirstOrNullX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;

  T? elementAtOrNull(int index) =>
      index >= 0 && index < length ? this[index] : null;
}

String _sellerListingStatusLabel(BuildContext context, String? status) {
  switch (status) {
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
    case 'active':
    default:
      return context.l10n.sellerListingsStatusActive;
  }
}

class _ListingDetailLoadingState extends StatelessWidget {
  const _ListingDetailLoadingState();

  @override
  Widget build(BuildContext context) {
    return const QitakPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QitakSkeletonBox(height: 220),
          SizedBox(height: 18),
          QitakSkeletonBox(height: 28, width: 220),
          SizedBox(height: 12),
          QitakSkeletonBox(height: 16, width: 280),
          SizedBox(height: 18),
          QitakSkeletonBox(height: 54),
        ],
      ),
    );
  }
}
