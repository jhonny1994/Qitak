import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/notifications/data/notification_repository.dart';
import 'package:qitak_app/features/notifications/domain/app_notification.dart';
import 'package:qitak_app/features/notifications/providers/notification_provider.dart';
import 'package:qitak_app/shared/providers/unread_counts_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return notifications.when(
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: qitakPagePadding,
            child: QitakStateMessage(
              title: context.l10n.notificationsTitle,
              message: context.l10n.notificationsEmptyBody,
            ),
          );
        }

        return QitakPullToRefresh(
          onRefresh: () async => ref.invalidate(notificationsProvider),
          child: ListView(
            padding: qitakPagePadding,
            children: [
              QitakPanel(
                child: QitakSectionHeader(
                  eyebrow: context.l10n.notificationsEyebrow,
                  title: context.l10n.notificationsTitle,
                  subtitle: context.l10n.notificationsSubtitle,
                  trailing: TextButton(
                    onPressed: () async {
                      await ref
                          .read(notificationRepositoryProvider)
                          .markAllRead();
                      ref
                          .read(foregroundNotificationsProvider.notifier)
                          .markAllRead();
                      ref.invalidate(notificationsProvider);
                      await ref.read(unreadCountsProvider.notifier).refresh();
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.notificationsAllCaughtUp),
                        ),
                      );
                    },
                    child: Text(context.l10n.notificationsMarkAllRead),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey(item.id),
                    background: _NotificationSwipeBackground(
                      icon: item.isUnread
                          ? Icons.mark_email_read_rounded
                          : Icons.mark_email_unread_rounded,
                      label: item.isUnread
                          ? context.l10n.notificationsMarkRead
                          : context.l10n.notificationsMarkUnread,
                      alignment: AlignmentDirectional.centerStart,
                    ),
                    secondaryBackground: _NotificationSwipeBackground(
                      icon: item.isUnread
                          ? Icons.mark_email_read_rounded
                          : Icons.mark_email_unread_rounded,
                      label: item.isUnread
                          ? context.l10n.notificationsMarkRead
                          : context.l10n.notificationsMarkUnread,
                      alignment: AlignmentDirectional.centerEnd,
                    ),
                    confirmDismiss: (_) async {
                      await ref
                          .read(notificationRepositoryProvider)
                          .markNotificationState(
                            notificationId: item.id,
                            isRead: item.isUnread,
                          );
                      ref
                          .read(foregroundNotificationsProvider.notifier)
                          .setReadState(
                            notificationId: item.id,
                            isRead: item.isUnread,
                          );
                      ref.invalidate(notificationsProvider);
                      await ref.read(unreadCountsProvider.notifier).refresh();
                      return false;
                    },
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => context.go(item.deepLink),
                      child: QitakPanel(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              item.isUnread
                                  ? Icons.notifications_active_outlined
                                  : Icons.notifications_none_rounded,
                              color: _notificationColor(context, item.type),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _resolveNotificationCopy(
                                      context,
                                      item,
                                    ).title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _resolveNotificationCopy(
                                      context,
                                      item,
                                    ).body,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      QitakChip(
                                        label: _resolveNotificationCopy(
                                          context,
                                          item,
                                        ).categoryLabel,
                                        selected: item.isUnread,
                                      ),
                                      QitakChip(
                                        label: _resolveNotificationCopy(
                                          context,
                                          item,
                                        ).timestampLabel,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.errorStateTitle,
          message: context.l10n.notificationsErrorBody,
        ),
      ),
      loading: () => const _NotificationsLoadingState(),
    );
  }
}

_ResolvedNotificationCopy _resolveNotificationCopy(
  BuildContext context,
  AppNotification item,
) {
  switch (item.type) {
    case 'message_received':
      return _ResolvedNotificationCopy(
        title:
            item.data['listing_title'] as String? ??
            context.l10n.notificationsSavedMessageTitle,
        body: item.body.isNotEmpty
            ? item.body
            : (item.data['message_preview'] as String? ??
                  context.l10n.notificationsSavedMessageBody),
        categoryLabel: context.l10n.notificationsCategoryMessage,
        timestampLabel: _relativeTimestamp(context, item.createdAt),
      );
    case 'listing_approved':
    case 'listing_rejected':
      return _ResolvedNotificationCopy(
        title: item.title.isNotEmpty
            ? item.title
            : (item.type == 'listing_approved'
                  ? context.l10n.notificationsListingApprovedTitle
                  : context.l10n.notificationsListingRejectedTitle),
        body: item.body,
        categoryLabel: context.l10n.notificationsCategoryListing,
        timestampLabel: _relativeTimestamp(context, item.createdAt),
      );
    case 'deal_created':
    case 'deal_confirmed':
    case 'deal_expired':
    case 'deal_completed':
    case 'deal_dispute_opened':
      return _ResolvedNotificationCopy(
        title: item.title.isNotEmpty
            ? item.title
            : context.l10n.notificationsDealUpdateTitle,
        body: item.body,
        categoryLabel: context.l10n.notificationsCategoryTransaction,
        timestampLabel: _relativeTimestamp(context, item.createdAt),
      );
    case 'verification_approved':
    case 'verification_needs_info':
      return _ResolvedNotificationCopy(
        title: item.title.isNotEmpty
            ? item.title
            : context.l10n.notificationsCategoryVerification,
        body: item.body,
        categoryLabel: context.l10n.notificationsCategoryVerification,
        timestampLabel: _relativeTimestamp(context, item.createdAt),
      );
    case 'dispute_opened':
    case 'dispute_resolved':
      return _ResolvedNotificationCopy(
        title: item.title.isNotEmpty
            ? item.title
            : context.l10n.notificationsCategoryDispute,
        body: item.body,
        categoryLabel: context.l10n.notificationsCategoryDispute,
        timestampLabel: _relativeTimestamp(context, item.createdAt),
      );
    default:
      return _ResolvedNotificationCopy(
        title: item.title.isNotEmpty ? item.title : item.type,
        body: item.body,
        categoryLabel: item.categoryLabel.isNotEmpty
            ? item.categoryLabel
            : context.l10n.notificationsCategorySystem,
        timestampLabel: item.timestampLabel.isNotEmpty
            ? item.timestampLabel
            : _relativeTimestamp(context, item.createdAt),
      );
  }
}

Color _notificationColor(BuildContext context, String type) {
  final scheme = Theme.of(context).colorScheme;
  switch (type) {
    case 'message_received':
      return scheme.secondary;
    case 'listing_approved':
    case 'listing_rejected':
      return scheme.primary;
    case 'deal_created':
    case 'deal_confirmed':
    case 'deal_expired':
    case 'deal_completed':
      return scheme.primary;
    case 'verification_approved':
    case 'verification_needs_info':
      return scheme.tertiary;
    case 'dispute_opened':
    case 'dispute_resolved':
      return scheme.error;
    default:
      return scheme.onSurfaceVariant;
  }
}

class _NotificationSwipeBackground extends StatelessWidget {
  const _NotificationSwipeBackground({
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final IconData icon;
  final String label;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

String _relativeTimestamp(BuildContext context, DateTime? createdAt) {
  if (createdAt == null) {
    return '';
  }
  final delta = DateTime.now().difference(createdAt);
  if (delta.inMinutes < 3) {
    return context.l10n.notificationsTime2mAgo;
  }
  if (delta.inHours < 2) {
    return context.l10n.notificationsTime1hAgo;
  }
  if (delta.inDays < 1) {
    return context.l10n.notificationsTimeHoursShort(delta.inHours);
  }
  return context.l10n.notificationsTimeDaysShort(delta.inDays);
}

class _ResolvedNotificationCopy {
  const _ResolvedNotificationCopy({
    required this.title,
    required this.body,
    required this.categoryLabel,
    required this.timestampLabel,
  });

  final String title;
  final String body;
  final String categoryLabel;
  final String timestampLabel;
}

class _NotificationsLoadingState extends StatelessWidget {
  const _NotificationsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: qitakPagePadding,
      children: const [
        QitakPanel(
          child: QitakSkeletonBox(height: 118),
        ),
      ],
    );
  }
}
