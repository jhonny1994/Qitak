import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/l10n/app_error_localization.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/features/support/data/support_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

final supportReasonOptionsProvider = FutureProvider<List<AppPolicyOption>>((
  ref,
) async {
  return ref.watch(supportReasonPolicyProvider.future);
});

Future<bool?> showSupportTicketCreateSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const SupportTicketCreateSheet(),
  );
}

class SupportTicketCreateSheet extends ConsumerStatefulWidget {
  const SupportTicketCreateSheet({super.key});

  @override
  ConsumerState<SupportTicketCreateSheet> createState() =>
      _SupportTicketCreateSheetState();
}

class _SupportTicketCreateSheetState
    extends ConsumerState<SupportTicketCreateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  bool _submitting = false;
  String? _selectedReason;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(supportReasonOptionsProvider);
    final reasonOptions =
        optionsAsync.asData?.value ?? const <AppPolicyOption>[];
    final selectedReason =
        reasonOptions.any(
          (option) => option.code == _selectedReason,
        )
        ? _selectedReason
        : (reasonOptions.isNotEmpty ? reasonOptions.first.code : null);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.74,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: QitakPanel(
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              children: [
                QitakSectionHeader(
                  eyebrow: context.l10n.supportCenterEyebrow,
                  title: context.l10n.supportTicketCreateTitle,
                  subtitle: context.l10n.supportTicketCreateSubtitle,
                ),
                const SizedBox(height: 16),
                QitakFormGroup(
                  label: context.l10n.supportTicketReasonLabel,
                  child: DropdownButtonFormField<String>(
                    key: const Key('support-reason-field'),
                    initialValue: selectedReason,
                    items: [
                      for (final option in reasonOptions)
                        DropdownMenuItem<String>(
                          value: option.code,
                          child: Text(
                            supportReasonLabel(context, option.labelKey),
                          ),
                        ),
                    ],
                    onChanged: _submitting
                        ? null
                        : (value) => setState(() => _selectedReason = value),
                    validator: (value) => value == null || value.isEmpty
                        ? context.l10n.supportTicketReasonError
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                QitakFormGroup(
                  label: context.l10n.supportTicketDescriptionLabel,
                  helper: context.l10n.supportTicketDescriptionHelper,
                  child: TextFormField(
                    key: const Key('support-description-field'),
                    controller: _descriptionController,
                    maxLines: 5,
                    validator: (value) =>
                        value == null || value.trim().length < 20
                        ? context.l10n.supportTicketDescriptionError
                        : null,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  key: const Key('support-submit-ticket-button'),
                  onPressed: _submitting || reasonOptions.isEmpty
                      ? null
                      : _submit,
                  child: _submitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.l10n.supportTicketSubmitAction),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(context.l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final reasonOptions =
        ref.read(supportReasonOptionsProvider).asData?.value ??
        const <AppPolicyOption>[];
    final selectedReason =
        _selectedReason ??
        (reasonOptions.isNotEmpty ? reasonOptions.first.code : null);
    if (selectedReason == null || selectedReason.isEmpty) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(supportRepositoryProvider)
          .createTicket(
            reason: selectedReason,
            description: _descriptionController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.appExceptionMessage(error))),
      );
      setState(() => _submitting = false);
    }
  }
}

String supportReasonLabel(BuildContext context, String labelKey) {
  switch (labelKey) {
    case 'supportReasonAccountAccess':
      return context.l10n.supportReasonAccountAccess;
    case 'supportReasonPaymentIssue':
      return context.l10n.supportReasonPaymentIssue;
    case 'supportReasonSellerIssue':
      return context.l10n.supportReasonSellerIssue;
    case 'supportReasonTechnicalIssue':
      return context.l10n.supportReasonTechnicalIssue;
    case 'supportReasonOther':
      return context.l10n.supportReasonOther;
    default:
      return labelKey;
  }
}

String supportTicketStatusLabel(BuildContext context, String status) {
  switch (status) {
    case 'under_review':
      return context.l10n.supportTicketStatusUnderReview;
    case 'dismissed':
      return context.l10n.supportTicketStatusClosed;
    case 'actioned':
    case 'resolved':
      return context.l10n.supportTicketStatusResolved;
    case 'open':
    default:
      return context.l10n.supportTicketStatusOpen;
  }
}
