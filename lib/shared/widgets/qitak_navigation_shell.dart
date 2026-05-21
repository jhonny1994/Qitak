import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/shared/providers/unread_counts_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

/// Role-aware navigation shell that adapts the bottom navigation bar
/// based on the current user's account role.
///
/// Shell destinations per the screen acceptance matrix:
/// - Guest/Anonymous: Home (search-first), Account/Auth
/// - Buyer: Home, Saved, Messages, Account
/// - Seller: Home, Listings, Messages, Account
/// - Admin: Home, Queues, Reports, Account
/// - Super Admin: Admin shell + Team management
class QitakNavigationShell extends ConsumerWidget {
  const QitakNavigationShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final role = session.profile?.role ?? AccountRole.anonymous;
    final unreadCounts =
        ref.watch(unreadCountsProvider).asData?.value ??
        (messages: 0, notifications: 0);
    var sellerApproved = false;
    if (role == AccountRole.seller) {
      sellerApproved =
          ref
              .watch(currentSellerApplicationProvider)
              .asData
              ?.value
              ?.isApproved ==
          true;
    }
    final items = _itemsForRole(
      context,
      role,
      sellerApproved: sellerApproved,
      messageBadgeCount: unreadCounts.messages,
      notificationBadgeCount: unreadCounts.notifications,
    );
    final selectedIndex = _selectedIndex(navigationShell.currentIndex, items);
    final tokens = context.qitakTokens;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: QitakPageCanvas(
        child: SafeArea(
          bottom: false,
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(items[index].path),
        backgroundColor: tokens.panel,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 0,
        height: 72,
        destinations: items.map((item) => item.destination).toList(),
      ),
      floatingActionButton: role == AccountRole.seller && sellerApproved
          ? FloatingActionButton(
              onPressed: () => context.go('/seller/listings/new'),
              tooltip: context.l10n.createListingCta,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  int _selectedIndex(int currentBranch, List<_ShellDestination> items) {
    final index = items.indexWhere((item) => item.branchIndex == currentBranch);
    return index < 0 ? 0 : index;
  }

  List<_ShellDestination> _itemsForRole(
    BuildContext context,
    AccountRole role, {
    bool sellerApproved = false,
    int messageBadgeCount = 0,
    int notificationBadgeCount = 0,
  }) {
    switch (role) {
      case AccountRole.anonymous:
        return [
          _ShellDestination(
            path: '/home',
            branchIndex: 0,
            destination: NavigationDestination(
              icon: const Icon(Icons.storefront_outlined),
              selectedIcon: const Icon(Icons.storefront_rounded),
              label: context.l10n.navHome,
            ),
          ),
          _ShellDestination(
            path: '/guest/account',
            branchIndex: 4,
            destination: NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: context.l10n.navAccount,
            ),
          ),
        ];

      case AccountRole.buyer:
        return [
          _ShellDestination(
            path: '/home',
            branchIndex: 0,
            destination: NavigationDestination(
              icon: const Icon(Icons.storefront_outlined),
              selectedIcon: const Icon(Icons.storefront_rounded),
              label: context.l10n.navHome,
            ),
          ),
          _ShellDestination(
            path: '/saved',
            branchIndex: 2,
            destination: NavigationDestination(
              icon: const Icon(Icons.bookmark_border_rounded),
              selectedIcon: const Icon(Icons.bookmark_rounded),
              label: context.l10n.navSaved,
            ),
          ),
          _ShellDestination(
            path: '/messages',
            branchIndex: 3,
            destination: NavigationDestination(
              icon: _badgeIcon(
                context,
                const Icon(Icons.chat_bubble_outline_rounded),
                messageBadgeCount,
              ),
              selectedIcon: _badgeIcon(
                context,
                const Icon(Icons.chat_bubble_rounded),
                messageBadgeCount,
              ),
              label: context.l10n.navMessages,
            ),
          ),
          _ShellDestination(
            path: '/profile',
            branchIndex: 4,
            destination: NavigationDestination(
              icon: _badgeIcon(
                context,
                const Icon(Icons.person_outline_rounded),
                notificationBadgeCount,
              ),
              selectedIcon: _badgeIcon(
                context,
                const Icon(Icons.person_rounded),
                notificationBadgeCount,
              ),
              label: context.l10n.navAccount,
            ),
          ),
        ];

      case AccountRole.seller:
        if (!sellerApproved) {
          return [
            _ShellDestination(
              path: '/seller/onboarding/status',
              branchIndex: 0,
              destination: NavigationDestination(
                icon: const Icon(Icons.verified_user_outlined),
                selectedIcon: const Icon(Icons.verified_user_rounded),
                label: context.l10n.sellerStatusTitle,
              ),
            ),
            _ShellDestination(
              path: '/seller/profile',
              branchIndex: 4,
              destination: NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: context.l10n.navAccount,
              ),
            ),
          ];
        }
        return [
          _ShellDestination(
            path: '/seller/home',
            branchIndex: 0,
            destination: NavigationDestination(
              icon: const Icon(Icons.storefront_outlined),
              selectedIcon: const Icon(Icons.storefront_rounded),
              label: context.l10n.navHome,
            ),
          ),
          _ShellDestination(
            path: '/seller/listings',
            branchIndex: 1,
            destination: NavigationDestination(
              icon: const Icon(Icons.inventory_2_outlined),
              selectedIcon: const Icon(Icons.inventory_2_rounded),
              label: context.l10n.navListings,
            ),
          ),
          _ShellDestination(
            path: '/messages',
            branchIndex: 3,
            destination: NavigationDestination(
              icon: _badgeIcon(
                context,
                const Icon(Icons.chat_bubble_outline_rounded),
                messageBadgeCount,
              ),
              selectedIcon: _badgeIcon(
                context,
                const Icon(Icons.chat_bubble_rounded),
                messageBadgeCount,
              ),
              label: context.l10n.navMessages,
            ),
          ),
          _ShellDestination(
            path: '/seller/profile',
            branchIndex: 4,
            destination: NavigationDestination(
              icon: _badgeIcon(
                context,
                const Icon(Icons.person_outline_rounded),
                notificationBadgeCount,
              ),
              selectedIcon: _badgeIcon(
                context,
                const Icon(Icons.person_rounded),
                notificationBadgeCount,
              ),
              label: context.l10n.navAccount,
            ),
          ),
        ];

      case AccountRole.admin:
        return [
          _ShellDestination(
            path: '/admin/home',
            branchIndex: 0,
            destination: NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: context.l10n.navHome,
            ),
          ),
          _ShellDestination(
            path: '/admin/queues',
            branchIndex: 1,
            destination: NavigationDestination(
              icon: const Icon(Icons.assignment_outlined),
              selectedIcon: const Icon(Icons.assignment_rounded),
              label: context.l10n.navQueues,
            ),
          ),
          _ShellDestination(
            path: '/admin/reports',
            branchIndex: 2,
            destination: NavigationDestination(
              icon: const Icon(Icons.flag_outlined),
              selectedIcon: const Icon(Icons.flag_rounded),
              label: context.l10n.navReports,
            ),
          ),
          _ShellDestination(
            path: '/admin/profile',
            branchIndex: 4,
            destination: NavigationDestination(
              icon: _badgeIcon(
                context,
                const Icon(Icons.person_outline_rounded),
                notificationBadgeCount,
              ),
              selectedIcon: _badgeIcon(
                context,
                const Icon(Icons.person_rounded),
                notificationBadgeCount,
              ),
              label: context.l10n.navAccount,
            ),
          ),
        ];

      case AccountRole.superAdmin:
        return [
          _ShellDestination(
            path: '/admin/home',
            branchIndex: 0,
            destination: NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: context.l10n.navHome,
            ),
          ),
          _ShellDestination(
            path: '/admin/queues',
            branchIndex: 1,
            destination: NavigationDestination(
              icon: const Icon(Icons.assignment_outlined),
              selectedIcon: const Icon(Icons.assignment_rounded),
              label: context.l10n.navQueues,
            ),
          ),
          _ShellDestination(
            path: '/admin/reports',
            branchIndex: 2,
            destination: NavigationDestination(
              icon: const Icon(Icons.flag_outlined),
              selectedIcon: const Icon(Icons.flag_rounded),
              label: context.l10n.navReports,
            ),
          ),
          _ShellDestination(
            path: '/admin/team',
            branchIndex: 3,
            destination: NavigationDestination(
              icon: const Icon(Icons.group_outlined),
              selectedIcon: const Icon(Icons.group_rounded),
              label: context.l10n.navTeam,
            ),
          ),
          _ShellDestination(
            path: '/admin/profile',
            branchIndex: 4,
            destination: NavigationDestination(
              icon: _badgeIcon(
                context,
                const Icon(Icons.person_outline_rounded),
                notificationBadgeCount,
              ),
              selectedIcon: _badgeIcon(
                context,
                const Icon(Icons.person_rounded),
                notificationBadgeCount,
              ),
              label: context.l10n.navAccount,
            ),
          ),
        ];
    }
  }

  Widget _badgeIcon(BuildContext context, Widget icon, int count) {
    if (count <= 0) {
      return icon;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        PositionedDirectional(
          top: -4,
          end: -10,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              count > 9 ? '9+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.path,
    required this.destination,
    this.branchIndex,
  });

  final String path;
  final int? branchIndex;
  final NavigationDestination destination;
}
