import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/l10n/app_error_localization.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/features/listings/data/listing_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

final listingReportReasonOptionsProvider =
    FutureProvider<List<AppPolicyOption>>((ref) async {
      return ref.watch(listingReportReasonPolicyProvider.future);
    });

Future<void> showReportListingSheet(
  BuildContext context, {
  required String listingId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => ReportListingSheet(listingId: listingId),
  );
}

class ReportListingSheet extends ConsumerStatefulWidget {
  const ReportListingSheet({
    required this.listingId,
    super.key,
  });

  final String listingId;

  @override
  ConsumerState<ReportListingSheet> createState() => _ReportListingSheetState();
}

class _ReportListingSheetState extends ConsumerState<ReportListingSheet> {
  String? _selectedReason;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(listingReportReasonOptionsProvider);
    final reasonOptions = options.asData?.value ?? const <AppPolicyOption>[];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.68,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: QitakPanel(
          child: ListView(
            controller: scrollController,
            children: [
              QitakSectionHeader(
                eyebrow: context.l10n.reportListingAction,
                title: context.l10n.reportListingAction,
                subtitle: context.l10n.reportListingAlreadyReported,
              ),
              const SizedBox(height: 16),
              RadioGroup<String>(
                groupValue: _selectedReason,
                onChanged: _submitting ? _ignoreReasonChange : _selectReason,
                child: Column(
                  children: [
                    for (final option in reasonOptions)
                      _ReasonTile(
                        title: _policyLabel(context, option.labelKey),
                        value: option.code,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _submitting || _selectedReason == null
                    ? null
                    : _submit,
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.reportListingAction),
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
    );
  }

  void _selectReason(String? value) {
    setState(() => _selectedReason = value);
  }

  void _ignoreReasonChange(String? _) {}

  Future<void> _submit() async {
    final selectedReason = _selectedReason;
    if (selectedReason == null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(listingRepositoryProvider)
          .reportListing(widget.listingId, selectedReason);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.reportListingSuccess)),
      );
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.appExceptionMessage(error))),
      );
      setState(() => _submitting = false);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      setState(() => _submitting = false);
    }
  }
}

String _policyLabel(BuildContext context, String labelKey) {
  switch (labelKey) {
    case 'reportListingReasonSpam':
      return context.l10n.reportListingReasonSpam;
    case 'reportListingReasonMisleading':
      return context.l10n.reportListingReasonMisleading;
    case 'reportListingReasonWrongCategory':
      return context.l10n.reportListingReasonWrongCategory;
    case 'reportListingReasonOther':
      return context.l10n.reportListingReasonOther;
    default:
      return labelKey;
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      contentPadding: EdgeInsets.zero,
    );
  }
}
