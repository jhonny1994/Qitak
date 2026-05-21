import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/messaging/providers/messaging_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(conversationThreadsProvider);
    final isOnline = ref.watch(messagingOnlineProvider);
    return threads.when(
      data: (items) => QitakPullToRefresh(
        onRefresh: () async => ref.invalidate(conversationThreadsProvider),
        slivers: [
          SliverPadding(
            padding: qitakPagePadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                QitakPanel(
                  child: QitakSectionHeader(
                    eyebrow: context.l10n.messagesTitle,
                    title: context.l10n.messagesInboxTitle,
                    subtitle: context.l10n.messagesInboxSubtitle,
                  ),
                ),
                const SizedBox(height: 18),
                if (!isOnline)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: QitakPanel(
                      child: QitakStateMessage(
                        title: context.l10n.messagesOnlineOnly,
                        message: context.l10n.messagesBlockedStatus,
                      ),
                    ),
                  ),
                if (items.isEmpty)
                  QitakPanel(
                    child: QitakStateMessage(
                      title: context.l10n.messagesEmptyTitle,
                      message: context.l10n.messagesInboxEmpty,
                      action: FilledButton.tonal(
                        onPressed: () => context.go('/home'),
                        child: Text(context.l10n.messagesBrowseListingsAction),
                      ),
                    ),
                  )
                else
                  QitakPanel(
                    child: Column(
                      children: [
                        for (var index = 0; index < items.length; index++) ...[
                          InkWell(
                            onTap: () => context.go(
                              '/messages/thread/${items[index].id}',
                            ),
                            borderRadius: BorderRadius.circular(18),
                            child: QitakQueueRow(
                              title: items[index].listingTitle.isEmpty
                                  ? context.l10n.messagesConversationTitle
                                  : items[index].listingTitle,
                              meta: items[index].lastMessageBody,
                              status: context.l10n.messagesOpenStatus,
                              trailing: const Icon(Icons.chevron_right_rounded),
                            ),
                          ),
                          if (index < items.length - 1)
                            const Divider(height: 24),
                        ],
                      ],
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
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
            children: [
              QitakSkeletonBox(height: 24, width: 180),
              SizedBox(height: 14),
              QitakSkeletonBox(height: 72),
              SizedBox(height: 12),
              QitakSkeletonBox(height: 72),
            ],
          ),
        ),
      ),
    );
  }
}
