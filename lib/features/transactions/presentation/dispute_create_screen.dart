import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/listings/providers/listing_media_picker_provider.dart';
import 'package:qitak_app/features/transactions/data/dispute_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class DisputeCreateScreen extends ConsumerStatefulWidget {
  const DisputeCreateScreen({required this.transactionId, super.key});

  final String transactionId;

  @override
  ConsumerState<DisputeCreateScreen> createState() =>
      _DisputeCreateScreenState();
}

class _DisputeCreateScreenState extends ConsumerState<DisputeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _reason = 'wrong_part';
  bool _submitting = false;
  bool _submitted = false;
  List<ListingMediaSelection> _evidence = const <ListingMediaSelection>[];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return ListView(
        padding: qitakPagePadding,
        children: [
          QitakStateMessage(
            title: context.l10n.disputeSuccessTitle,
            message: context.l10n.disputeSuccessBody,
            icon: Icons.verified_outlined,
            action: FilledButton(
              onPressed: () => context.go('/deals'),
              child: Text(context.l10n.transactionsTitle),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        padding: qitakPagePadding,
        children: [
          QitakPanel(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  QitakSectionHeader(
                    eyebrow: context.l10n.transactionsTitle,
                    title: context.l10n.disputeTitle,
                    subtitle: context.l10n.disputeSubtitle,
                  ),
                  const SizedBox(height: 18),
                  QitakFormGroup(
                    label: context.l10n.disputeReasonLabel,
                    child: DropdownButtonFormField<String>(
                      initialValue: _reason,
                      items: [
                        DropdownMenuItem(
                          value: 'wrong_part',
                          child: Text(context.l10n.disputeReasonWrongPart),
                        ),
                        DropdownMenuItem(
                          value: 'condition',
                          child: Text(context.l10n.disputeReasonCondition),
                        ),
                        DropdownMenuItem(
                          value: 'not_received',
                          child: Text(context.l10n.disputeReasonNotReceived),
                        ),
                        DropdownMenuItem(
                          value: 'unresponsive',
                          child: Text(context.l10n.disputeReasonUnresponsive),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text(context.l10n.disputeReasonOther),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _reason = value ?? 'wrong_part'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  QitakFormGroup(
                    label: context.l10n.disputeDescriptionLabel,
                    helper: context.l10n.disputeDescriptionHelper,
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      validator: (value) =>
                          (value == null || value.trim().length < 50)
                          ? context.l10n.disputeDescriptionError
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QitakSignalStrip(
                    label: context.l10n.disputeEvidenceLabel,
                    value: _evidence.isEmpty
                        ? context.l10n.disputeEvidenceValue
                        : '${_evidence.length} file(s)',
                    status: context.l10n.disputeEvidenceStatus,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _submitting ? null : _pickEvidence,
                    child: Text(
                      context.l10n.sellerOnboardingDocumentAttachAction,
                    ),
                  ),
                  if (_evidence.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    for (var index = 0; index < _evidence.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: QitakQueueRow(
                          title: _evidence[index].fileName,
                          meta: _evidence[index].mimeType,
                          status: '#${index + 1}',
                          trailing: IconButton(
                            onPressed: _submitting
                                ? null
                                : () => setState(() {
                                    _evidence = [
                                      ..._evidence.take(index),
                                      ..._evidence.skip(index + 1),
                                    ];
                                  }),
                            icon: const Icon(Icons.delete_outline_rounded),
                            tooltip: context.l10n.listingMediaRemoveAction,
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton(
                    key: const Key('dispute-submit-button'),
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.disputeSubmit),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final userId = ref.read(authSessionProvider).profile?.id;
      if (userId == null) {
        throw StateError('Authenticated user required.');
      }
      await ref
          .read(disputeRepositoryProvider)
          .submit(
            transactionId: widget.transactionId,
            createdByUserId: userId,
            reason: _reason,
            description: _descriptionController.text.trim(),
            evidence: _evidence,
          );
      if (!mounted) {
        return;
      }
      setState(() => _submitted = true);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _pickEvidence() async {
    final picker = ref.read(listingMediaPickerProvider);
    final picked = await picker.pickImages();
    if (!mounted || picked.isEmpty) {
      return;
    }
    setState(() {
      _evidence = [..._evidence, ...picked].take(4).toList(growable: false);
    });
  }
}
