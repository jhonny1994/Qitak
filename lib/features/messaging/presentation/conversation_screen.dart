import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/connectivity/connectivity_service.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/messaging/domain/conversation_thread_summary.dart';
import 'package:qitak_app/features/messaging/providers/messaging_provider.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({required this.threadId, super.key});

  final String threadId;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagingProvider);
    final profile = ref.watch(authSessionProvider).profile;
    final transactions = ref.watch(transactionProvider).items;
    final messages = ref.watch(conversationMessagesProvider(widget.threadId));
    final threadSummary = ref.watch(
      conversationThreadSummaryProvider(widget.threadId),
    );
    final completedDeal = _findCompletedDeal(
      transactions: transactions,
      profileId: profile?.id,
      threadSummary: threadSummary,
    );

    if (profile == null) {
      return Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.authGateTitle,
          message: context.l10n.authGateBody,
        ),
      );
    }

    return messages.when(
      data: (items) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: qitakPagePadding,
            children: [
              QitakPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QitakSectionHeader(
                      eyebrow: context.l10n.messagesTitle,
                      title: threadSummary?.otherPartyLabel.isNotEmpty == true
                          ? threadSummary!.otherPartyLabel
                          : context.l10n.messagesConversationTitle,
                      subtitle: threadSummary?.listingTitle.isNotEmpty == true
                          ? threadSummary!.listingTitle
                          : context.l10n.messagesConversationSubtitle,
                      leading: const QitakRouteBackButton(
                        fallbackPath: '/messages',
                      ),
                    ),
                    if (completedDeal != null) ...[
                      const SizedBox(height: 12),
                      QitakSurface(
                        role: QitakSurfaceRole.section,
                        padding: const EdgeInsets.all(14),
                        child: QitakSignalStrip(
                          label: context.l10n.transactionsTitle,
                          value: context.l10n.transactionNextStepCompleted,
                          status: context.l10n.transactionHistoryTitle,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (items.isEmpty)
                      QitakStateMessage(
                        title: context.l10n.messagesEmptyTitle,
                        message: context.l10n.messagesEmptyState,
                      )
                    else
                      for (final msg in items)
                        Align(
                          alignment: msg.senderId == profile.id
                              ? AlignmentDirectional.centerEnd
                              : AlignmentDirectional.centerStart,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                            ),
                            decoration: BoxDecoration(
                              color: msg.senderId == profile.id
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                  : context.qitakTokens.panelMuted,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.qitakTokens.stroke,
                              ),
                            ),
                            child: Text(msg.body),
                          ),
                        ),
                    const SizedBox(height: 16),
                    if (completedDeal == null)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: context.l10n.messagesInputHint,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            key: const Key('message-send-button'),
                            onPressed: _sending
                                ? null
                                : () => _handleSend(profile.id),
                            child: _sending
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(context.l10n.messagesSend),
                          ),
                        ],
                      )
                    else
                      QitakStateMessage(
                        title: context.l10n.transactionNextStepCompleted,
                        message: context.l10n.transactionHistoryTitle,
                      ),
                    if (state.lastError == 'offline') ...[
                      const SizedBox(height: 14),
                      QitakSignalStrip(
                        label: context.l10n.messagesStatusLabel,
                        value: context.l10n.messagesOnlineOnly,
                        status: context.l10n.messagesBlockedStatus,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSkeletonBox(height: 24, width: 160),
              SizedBox(height: 16),
              QitakSkeletonBox(height: 56),
              SizedBox(height: 12),
              QitakSkeletonBox(height: 56),
              SizedBox(height: 12),
              QitakSkeletonBox(height: 52),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSend(String senderId) async {
    if (_sending) {
      return;
    }

    final isOnline = ref.read(isOnlineProvider).asData?.value ?? true;
    if (!isOnline) {
      _showOfflineError();
      return;
    }

    setState(() => _sending = true);
    FocusScope.of(context).unfocus();

    try {
      final ok = await ref
          .read(messagingProvider.notifier)
          .sendMessage(
            threadId: widget.threadId,
            senderId: senderId,
            body: _controller.text,
          );
      if (!mounted) {
        return;
      }
      if (ok) {
        _controller.clear();
        return;
      }
      _showSendError();
    } on Object {
      if (!mounted) {
        return;
      }
      _showSendError();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _showSendError() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.messagesSendError)),
      );
  }

  void _showOfflineError() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.offlineBannerLabel)),
      );
  }

  TransactionRecord? _findCompletedDeal({
    required List<TransactionRecord> transactions,
    required String? profileId,
    required ConversationThreadSummary? threadSummary,
  }) {
    final userId = profileId;
    final summary = threadSummary;
    if (userId == null || summary == null) {
      return null;
    }
    for (final tx in transactions) {
      final isParticipant =
          (tx.buyerUserId == userId &&
              tx.sellerUserId == summary.otherPartyUserId) ||
          (tx.sellerUserId == userId &&
              tx.buyerUserId == summary.otherPartyUserId);
      if (isParticipant &&
          tx.listingId == summary.listingId &&
          tx.state == TransactionState.completed) {
        return tx;
      }
    }
    return null;
  }
}
