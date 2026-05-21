import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/admin/data/conversation_oversight_repository.dart';
import 'package:qitak_app/features/admin/domain/conversation_oversight_case.dart';
import 'package:qitak_app/features/admin/presentation/admin_surface_scaffold.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class ConversationOversightScreen extends ConsumerStatefulWidget {
  const ConversationOversightScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ConversationOversightScreen> createState() =>
      _ConversationOversightScreenState();
}

class _ConversationOversightScreenState
    extends ConsumerState<ConversationOversightScreen> {
  final TextEditingController _noteController = TextEditingController();
  String? _purpose;
  Future<ConversationOversightCase>? _caseFuture;
  bool _savingNote = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSurfaceScaffold(
      eyebrow: context.l10n.adminDashboardEyebrow,
      title: context.l10n.adminConversationOversightTitle,
      subtitle: context.l10n.adminConversationOversightSubtitle,
      children: [
        if (_caseFuture == null) ...[
          QitakSignalStrip(
            label: context.l10n.transactionRecordLabel,
            value: widget.conversationId,
            status: context.l10n.adminPurposeGateRequired,
          ),
          const SizedBox(height: 16),
          QitakPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.adminPurposeGateTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.adminPurposeGateBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: const Key('admin-purpose-select'),
                  initialValue: _purpose,
                  items: [
                    DropdownMenuItem(
                      value: 'dispute_review',
                      child: Text(context.l10n.adminPurposeOptionDispute),
                    ),
                    DropdownMenuItem(
                      value: 'abuse_review',
                      child: Text(context.l10n.adminPurposeOptionAbuse),
                    ),
                    DropdownMenuItem(
                      value: 'support_intervention',
                      child: Text(context.l10n.adminPurposeOptionSupport),
                    ),
                  ],
                  onChanged: (value) => setState(() => _purpose = value),
                  decoration: InputDecoration(
                    labelText: context.l10n.adminPurposeFieldLabel,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('admin-purpose-note'),
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: context.l10n.adminPurposeNoteLabel,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('admin-purpose-confirm'),
                  onPressed: _purpose == null ? null : _loadCase,
                  child: Text(context.l10n.adminConversationLoadAction),
                ),
              ],
            ),
          ),
        ] else
          FutureBuilder<ConversationOversightCase>(
            future: _caseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const QitakPanel(child: QitakSkeletonBox(height: 220));
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return QitakStateMessage(
                  title: context.l10n.errorStateTitle,
                  message: context.l10n.discoveryErrorBody,
                );
              }
              final item = snapshot.data!;
              return Column(
                children: [
                  QitakSignalStrip(
                    label: context.l10n.transactionListingContextLabel,
                    value: item.listingTitle,
                    status: _purposeLabel(context, _purpose ?? ''),
                  ),
                  const SizedBox(height: 16),
                  QitakPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow(
                          context.l10n.adminConversationBuyerLabel,
                          item.buyerName,
                        ),
                        _detailRow(
                          context.l10n.adminConversationSellerLabel,
                          item.sellerName,
                        ),
                        _detailRow(
                          context.l10n.adminConversationLinkedDealLabel,
                          item.transactionId ?? '-',
                        ),
                        _detailRow(
                          context.l10n.adminConversationLinkedDisputeLabel,
                          item.disputeId ?? '-',
                        ),
                        _detailRow(
                          context.l10n.adminConversationLinkedReportLabel,
                          item.reportId ?? '-',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  QitakPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.adminConversationTranscriptTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        if (item.messages.isEmpty)
                          Text(context.l10n.messagesEmptyState)
                        else
                          for (final message in item.messages)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: QitakQueueRow(
                                title: message.senderId == item.buyerUserId
                                    ? item.buyerName
                                    : message.senderId == item.sellerUserId
                                    ? item.sellerName
                                    : message.senderId,
                                meta: message.body,
                                status: TimeOfDay.fromDateTime(
                                  message.createdAt,
                                ).format(context),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  QitakPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.adminConversationRelatedContextTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonal(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(
                                    text:
                                        'conversation:${item.threadId}:message-link',
                                  ),
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context
                                          .l10n
                                          .adminConversationCopyLinkSuccess,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                context.l10n.adminConversationCopyLinkAction,
                              ),
                            ),
                            OutlinedButton(
                              onPressed: _savingNote
                                  ? null
                                  : () => _attachNote(item),
                              child: Text(
                                context.l10n.adminConversationAttachNoteAction,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Future<void> _loadCase() async {
    final purpose = _purpose;
    if (purpose == null) {
      return;
    }
    setState(() {
      _caseFuture = ref
          .read(conversationOversightRepositoryProvider)
          .loadCase(
            threadId: widget.conversationId,
            purpose: purpose,
            note: _noteController.text,
          );
    });
  }

  String _purposeLabel(BuildContext context, String purpose) {
    switch (purpose) {
      case 'dispute_review':
        return context.l10n.adminPurposeOptionDispute;
      case 'abuse_review':
        return context.l10n.adminPurposeOptionAbuse;
      case 'support_intervention':
        return context.l10n.adminPurposeOptionSupport;
      default:
        return context.l10n.adminPurposeGateRequired;
    }
  }

  Future<void> _attachNote(ConversationOversightCase item) async {
    final purpose = _purpose;
    final note = _noteController.text.trim();
    if (purpose == null || note.isEmpty) {
      return;
    }
    setState(() => _savingNote = true);
    try {
      await ref
          .read(conversationOversightRepositoryProvider)
          .attachNote(
            threadId: item.threadId,
            purpose: purpose,
            note: note,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminConversationAttachNoteAction),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _savingNote = false);
      }
    }
  }
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text('$label: $value'),
  );
}
