import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';
import 'package:qitak_app/features/auth/presentation/protected_action_gate.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/discovery/presentation/discovery_filter_sheet.dart';
import 'package:qitak_app/features/discovery/providers/discovery_provider.dart';
import 'package:qitak_app/features/listings/providers/saved_listings_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final listings = ref.watch(discoveryListingsProvider(0));
    final savedIds = ref
        .watch(savedListingIdsProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => const <String>{},
        );
    final brandWordmark = context.l10n.brandWordmark;

    return QitakPullToRefresh(
      onRefresh: () => ref.refresh(discoveryListingsProvider(0).future),
      slivers: [
        SliverPadding(
          padding: qitakPagePadding,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              QitakPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(height: 40, width: double.infinity),
                        Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    key: const Key('home-brand-logo'),
                                    'assets/brand/qitak-logo.png',
                                    height: 44,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    brandWordmark,
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const PositionedDirectional(
                          start: 0,
                          child: SizedBox(width: 48, height: 40),
                        ),
                        PositionedDirectional(
                          end: 0,
                          child: session.isAuthenticated
                              ? IconButton.filledTonal(
                                  onPressed: () => context.go('/notifications'),
                                  icon: const Icon(
                                    Icons.notifications_none_rounded,
                                  ),
                                  tooltip: context.l10n.notificationsTitle,
                                )
                              : const SizedBox(width: 48, height: 40),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.discoverySearchHint,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('home-search-field'),
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _submitSearch(context),
                      decoration: InputDecoration(
                        hintText: context.l10n.discoverySearchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        key: const Key('home-filter-button'),
                        onPressed: () => showDiscoveryFilterSheet(context),
                        icon: const Icon(Icons.tune_rounded),
                        label: Text(context.l10n.discoveryFilterButton),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('home-search-button'),
                        onPressed: () => _submitSearch(context),
                        icon: const Icon(Icons.search_rounded),
                        label: Text(context.l10n.discoverySearchButton),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
        ...listings.when<List<Widget>>(
          data: (items) {
            if (items.isEmpty) {
              return [
                SliverPadding(
                  padding: qitakPageHorizontalPadding,
                  sliver: SliverToBoxAdapter(
                    child: _HomeEmptyMarketplaceState(
                      title: context.l10n.discoveryEmptyTitle,
                      message: context.l10n.discoveryEmptyBody,
                    ),
                  ),
                ),
              ];
            }

            final featured = items.first;
            final latest = items.skip(1).toList(growable: false);

            return [
              SliverPadding(
                padding: qitakPageHorizontalPadding,
                sliver: SliverToBoxAdapter(
                  child: _DiscoverySection(
                    title: context.l10n.discoveryFeaturedListingsTitle,
                    child: _FeaturedListingCard(
                      item: featured,
                      isSaved: savedIds.contains(featured.id),
                      onOpen: () => context.go('/listing/${featured.id}'),
                      onToggleSave: () =>
                          _toggleSave(context, ref, featured.id),
                    ),
                  ),
                ),
              ),
              if (latest.isNotEmpty)
                SliverPadding(
                  padding: qitakPageHorizontalPadding,
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 10),
                      child: Text(
                        context.l10n.discoveryLatestListingsTitle,
                        style:
                            Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: qitakPageHorizontalPadding,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = latest[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == latest.length - 1 ? 0 : 14,
                      ),
                      child: _ListingRow(
                        item: item,
                        isSaved: savedIds.contains(item.id),
                        onOpen: () => context.go('/listing/${item.id}'),
                        onToggleSave: () => _toggleSave(context, ref, item.id),
                      ),
                    );
                  }, childCount: latest.length),
                ),
              ),
            ];
          },
          error: (error, stackTrace) => [
            SliverPadding(
              padding: qitakPageHorizontalPadding,
              sliver: SliverToBoxAdapter(
                child: QitakStateMessage(
                  title: context.l10n.errorStateTitle,
                  message: context.l10n.discoveryErrorBody,
                  action: FilledButton(
                    onPressed: () =>
                        ref.invalidate(discoveryListingsProvider(0)),
                    child: Text(context.l10n.retryAction),
                  ),
                ),
              ),
            ),
          ],
          loading: () => const [
            SliverPadding(
              padding: qitakPageHorizontalPadding,
              sliver: SliverToBoxAdapter(child: _DiscoveryLoadingState()),
            ),
          ],
        ),
      ],
    );
  }

  void _submitSearch(BuildContext context) {
    final trimmed = _searchController.text.trim();
    final query = trimmed.isEmpty
        ? '/search/results'
        : '/search/results?q=${Uri.encodeComponent(trimmed)}';
    context.go(query);
  }

  Future<void> _toggleSave(
    BuildContext context,
    WidgetRef ref,
    String listingId,
  ) async {
    final session = ref.read(authSessionProvider);
    if (!session.isAuthenticated) {
      await _handleAction(
        context,
        ref,
        PostAuthRedirectIntent.action(
          'save-listing',
          arguments: <String, String>{
            'route': '/home',
            'listingId': listingId,
          },
        ),
      );
      return;
    }
    await ref.read(savedListingIdsProvider.notifier).toggle(listingId);
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    PostAuthRedirectIntent intent,
  ) async {
    final session = ref.read(authSessionProvider);
    if (!session.isAuthenticated) {
      await showProtectedActionGate(context, ref, intent: intent);
    }
  }
}

class _HomeEmptyMarketplaceState extends StatelessWidget {
  const _HomeEmptyMarketplaceState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;

    return QitakPanel(
      padding: const EdgeInsets.all(16),
      backgroundColor: tokens.panelMuted,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverySection extends StatelessWidget {
  const _DiscoverySection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _FeaturedListingCard extends StatelessWidget {
  const _FeaturedListingCard({
    required this.item,
    required this.isSaved,
    required this.onOpen,
    required this.onToggleSave,
  });

  final MarketplaceListing item;
  final bool isSaved;
  final VoidCallback onOpen;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onOpen,
      child: QitakListingSurface(
        title: item.localizedTitle(context.l10n),
        price: item.priceLabel,
        subtitle: item.locationLabel,
        imageUrl: item.preferredImageUrl,
        heroTag: qitakListingHeroTag(item.id),
        actions: [
          IconButton(
            key: const Key('home-featured-save-button'),
            onPressed: onToggleSave,
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            ),
            tooltip: context.l10n.discoverySave,
          ),
        ],
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({
    required this.item,
    required this.isSaved,
    required this.onOpen,
    required this.onToggleSave,
  });

  final MarketplaceListing item;
  final bool isSaved;
  final VoidCallback onOpen;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    return QitakPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onOpen,
        child: Row(
          children: [
            QitakListingThumbnail(
              imageUrl: item.preferredImageUrl,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.localizedTitle(context.l10n),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.locationLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.priceLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  key: Key('listing-row-save-${item.id}'),
                  onPressed: onToggleSave,
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                  tooltip: context.l10n.discoverySave,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryLoadingState extends StatelessWidget {
  const _DiscoveryLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSkeletonBox(height: 26, width: 160),
              SizedBox(height: 12),
              QitakSkeletonBox(height: 14, width: 240),
              SizedBox(height: 18),
              QitakSkeletonBox(height: 52),
            ],
          ),
        ),
        SizedBox(height: 16),
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSkeletonBox(height: 24, width: 120),
              SizedBox(height: 10),
              QitakSkeletonBox(height: 18, width: 220),
              SizedBox(height: 18),
              QitakSkeletonBox(height: 42),
            ],
          ),
        ),
      ],
    );
  }
}
