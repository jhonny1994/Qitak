import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/admin/presentation/admin_surface_scaffold.dart';
import 'package:qitak_app/features/transactions/data/dispute_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class DisputeDetailScreen extends ConsumerStatefulWidget {
  const DisputeDetailScreen({required this.disputeId, super.key});

  final String disputeId;

  @override
  ConsumerState<DisputeDetailScreen> createState() =>
      _DisputeDetailScreenState();
}

class _DisputeDetailScreenState extends ConsumerState<DisputeDetailScreen> {
  final _noteController = TextEditingController();
  String _decision = 'buyer';
  String _outcomeAction = 'no_action';
  String? _reasonCode;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dispute = ref.watch(adminDisputeProvider(widget.disputeId));
    return dispute.when(
      data: (item) => AdminSurfaceScaffold(
        eyebrow: context.l10n.adminDisputesQueueTitle,
        title: context.l10n.adminDisputeDetailTitle,
        subtitle: context.l10n.adminDisputeDetailSubtitle,
        children: item == null
            ? [
                QitakStateMessage(
                  title: context.l10n.adminDisputeDetailEmptyTitle,
                  message: context.l10n.adminDisputeDetailEmptyBody,
                ),
              ]
            : [
                QitakSignalStrip(
                  label: context.l10n.transactionRecordLabel,
                  value: item.transactionId,
                  status: item.status,
                ),
                const SizedBox(height: 16),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${context.l10n.disputeReasonLabel}: ${item.reason}',
                      ),
                      const SizedBox(height: 10),
                      Text(item.description),
                      if (item.listingTitle.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${context.l10n.adminDisputeListingLabel}: '
                          '${item.listingTitle}',
                        ),
                      ],
                      if (item.buyerName.isNotEmpty ||
                          item.sellerName.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${context.l10n.adminDisputeBuyerLabel}: '
                          '${item.buyerName.isEmpty ? '-' : item.buyerName}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${context.l10n.adminDisputeSellerLabel}: '
                          '${item.sellerName.isEmpty ? '-' : item.sellerName}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.disputeEvidenceLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      if (item.evidence.isEmpty)
                        Text(context.l10n.disputeEvidenceValue)
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final evidence in item.evidence)
                              InkWell(
                                onTap: evidence.previewUrl.isEmpty
                                    ? null
                                    : () => showDialog<void>(
                                        context: context,
                                        builder: (dialogContext) => Dialog(
                                          child: InteractiveViewer(
                                            child: Image.network(
                                              evidence.previewUrl,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                child: SizedBox(
                                  width: 92,
                                  child: Column(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          child: evidence.previewUrl.isEmpty
                                              ? ColoredBox(
                                                  color: context
                                                      .qitakTokens
                                                      .stroke,
                                                )
                                              : Image.network(
                                                  evidence.previewUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        evidence.storagePath.split('/').last,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if ((item.conversationId ?? '').isNotEmpty)
                  QitakPanel(
                    child: FilledButton.tonal(
                      onPressed: () => context.go(
                        '/admin/conversations/${item.conversationId}',
                      ),
                      child: Text(context.l10n.adminConversationOversightTitle),
                    ),
                  ),
                if ((item.conversationId ?? '').isNotEmpty)
                  const SizedBox(height: 16),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      QitakDropdownField<String>(
                        value: _decision,
                        items: [
                          DropdownMenuItem(
                            value: 'buyer',
                            child: Text(
                              context.l10n.adminDisputeDecisionBuyer,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'seller',
                            child: Text(
                              context.l10n.adminDisputeDecisionSeller,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'dismiss',
                            child: Text(
                              context.l10n.adminDisputeDecisionDismiss,
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _decision = value ?? 'buyer'),
                      ),
                      const SizedBox(height: 12),
                      QitakDropdownField<String>(
                        value: _outcomeAction,
                        items: [
                          DropdownMenuItem(
                            value: 'no_action',
                            child: Text(
                              context.l10n.adminDisputeOutcomeNoAction,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'warn',
                            child: Text(context.l10n.adminDisputeOutcomeWarn),
                          ),
                          DropdownMenuItem(
                            value: 'suspend',
                            child: Text(
                              context.l10n.adminDisputeOutcomeSuspend,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'remove_listing',
                            child: Text(
                              context.l10n.adminDisputeOutcomeRemoveListing,
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(
                          () => _outcomeAction = value ?? 'no_action',
                        ),
                      ),
                      const SizedBox(height: 12),
                      QitakDropdownField<String>(
                        value: _reasonCode,
                        items: [
                          DropdownMenuItem(
                            value: 'damaged_part',
                            child: Text(
                              context.l10n.adminDisputeReasonDamagedPart,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'wrong_part',
                            child: Text(
                              context.l10n.adminDisputeReasonWrongPart,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'insufficient_evidence',
                            child: Text(
                              context
                                  .l10n
                                  .adminDisputeReasonInsufficientEvidence,
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _reasonCode = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText:
                              context.l10n.adminModerationDecisionNoteLabel,
                          hintText:
                              context.l10n.adminModerationDecisionNoteHint,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _reasonCode == null ? null : _resolve,
                        child: Text(
                          context.l10n.adminDisputeResolveAction,
                        ),
                      ),
                    ],
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
        child: Column(
          children: [
            QitakPanel(child: QitakSkeletonBox(height: 84)),
            SizedBox(height: 16),
            QitakPanel(child: QitakSkeletonBox(height: 260)),
          ],
        ),
      ),
    );
  }

  Future<void> _resolve() async {
    final reasonCode = _reasonCode;
    if (reasonCode == null) {
      return;
    }
    await ref
        .read(disputeRepositoryProvider)
        .resolve(
          disputeId: widget.disputeId,
          decision: _decision,
          reasonCode: reasonCode,
          outcomeAction: _outcomeAction,
          note: _noteController.text.trim(),
        );
    ref
      ..invalidate(adminDisputesProvider)
      ..invalidate(adminDisputeProvider(widget.disputeId));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.adminDisputeDecisionSaved)),
    );
  }
}
